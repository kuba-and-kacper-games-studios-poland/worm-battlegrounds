--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Match"

--- @type Match_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Roster = require(script.Parent:FindFirstChild("Roster")) --- @type Match_Server_Roster
local Connection = require(script.Parent:FindFirstChild("Connection")) --- @type Match_Server_Connection

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local matchFolder: Folder

-- The public match as this server last read it from Matchmaking's store, while its room is open
local lobby = nil --- @type Matchmaking_Lobby?

--[[ Players ]]

-- Who voted to start, and who has been in the room, by user id
local ready = {} --- @type { [number]: boolean }
local seen = {} --- @type { [number]: boolean }

-- When each player here without a seat was first seen (os.clock), by user id
local strangers = {} --- @type { [number]: number }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   __       __                  __            __
--  /  \     /  |                /  |          /  |
--  $$  \   /$$ |  ______    ____$$ | __    __ $$ |  ______
--  $$$  \ /$$$ | /      \  /    $$ |/  |  /  |$$ | /      \
--  $$$$  /$$$$ |/$$$$$$  |/$$$$$$$ |$$ |  $$ |$$ |/$$$$$$  |
--  $$ $$ $$/$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |$$    $$ |
--  $$ |$$$/ $$ |$$ \__$$ |$$ \__$$ |$$ \__$$ |$$ |$$$$$$$$/
--  $$ | $/  $$ |$$    $$/ $$    $$ |$$    $$/ $$ |$$       |
--  $$/      $$/  $$$$$$/   $$$$$$$/  $$$$$$/  $$/  $$$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- @class Match_Server_WaitingRoom
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init(folder: Folder)
	--[[ Saving ]]

	matchFolder = folder

	--[[ Network ]]

	I.Network.GetEvent("Match_Ready", { "Player" }, { RateLimit = 2 })
	I.Network.Fired("Match_Ready", Module._onReady)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Run

--[[
	Runs a public match's waiting room: puts the match in Matchmaking's store (the lobby that opened it put it there
	pending; the seats lobbies claimed since are kept), where every lobby server seats players and parties in it, until
	it starts (WAITING_SECONDS from now; when a lobby opened it first, when that lobby said, but no sooner than
	Matchmaking's MIN_ROOM_SECONDS from now), every player here pressed Ready, or
	FULL_START_SECONDS after its last seat is taken, or VOTE_START_SECONDS after enough players here voted to start
	(everyone up to VOTE_ALL_UP_TO players, VOTE_SHARE of them above), then closes it to joins. The room shows why it
	starts (RoomStarting: "Full" or "Vote") and the votes (RoomVotes, RoomVotesNeeded). The roster it closed with is the
	match's (bots fill the empty seats); anyone here without a seat goes back to the lobby.
]]
--- @param metadata Match_Metadata
function Module.Run(metadata)
	--[[ Opening ]]

	ready = {}
	seen = {}
	strangers = {}
	lobby = {

		--[[ General ]]

		Id = metadata.LobbyId,
		AccessCode = metadata.AccessCode,
		Open = true,
		EndsAt = os.time() + _settings.WAITING_SECONDS,

		--[[ Match ]]

		Mode = metadata.Mode,
		Size = metadata.Size,
		TeamSize = Roster.GetTeamSize(),
		MapId = metadata.MapId,
		Roster = metadata.Roster,
	}
	local opened = I.Matchmaking.Open(lobby) --- @type Matchmaking_Lobby?
	if opened then
		lobby = opened
		Roster.SetRoster(opened.Roster)
	end

	local endsAt: number = I.S.Workspace:GetServerTimeNow() + math.max(lobby.EndsAt - os.time(), 0)
	matchFolder:SetAttribute("RoomEndsAt", endsAt)

	--[[ Waiting ]]

	local refreshAt: number = 0
	local starting: string? = nil
	while I.S.Workspace:GetServerTimeNow() < endsAt do
		if os.clock() >= refreshAt then
			refreshAt = os.clock() + _settings.ROOM_REFRESH_SECONDS
			Module._refresh()
		end

		-- Every seat taken, or the vote passed: start soon, not at the timer's end
		local votes: number
		local needed: number
		votes, needed = Module._getVotes()
		matchFolder:SetAttribute("RoomVotes", votes)
		matchFolder:SetAttribute("RoomVotesNeeded", needed)
		local reason: string? = if #lobby.Roster >= lobby.Size then "Full" elseif needed > 0 and votes >= needed then "Vote" else nil
		local soonAt: number = I.S.Workspace:GetServerTimeNow() + (if reason == "Full" then _settings.FULL_START_SECONDS else _settings.VOTE_START_SECONDS)
		if reason and not starting and soonAt < endsAt then
			starting = reason
			endsAt = soonAt
			matchFolder:SetAttribute("RoomEndsAt", endsAt)
			matchFolder:SetAttribute("RoomStarting", reason)
		end
		Module._releaseLeavers()
		Module._publish()
		task.wait(0.25)
	end

	--[[ Closing ]]

	-- The roster as the store closed it is final: no lobby can seat anyone after
	local closed = I.Matchmaking.Close(lobby) --- @type Matchmaking_Lobby?
	if closed then
		Roster.SetRoster(closed.Roster)
	end
	lobby = nil
	matchFolder:SetAttribute("RoomEndsAt", nil)
	matchFolder:SetAttribute("Room", nil)
	matchFolder:SetAttribute("RoomStarting", nil)
	matchFolder:SetAttribute("RoomVotes", nil)
	matchFolder:SetAttribute("RoomVotesNeeded", nil)

	--[[ Strangers ]]

	Module._sendStrangers(0)
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Reads the match from the store (the seats lobbies claimed since) and keeps it there, then sends back anyone here
	who still has no seat after STRANGER_SECONDS. While the store can't be reached the room keeps the seats it has.
]]
function Module._refresh()
	--[[ Refreshing ]]

	local current = I.Matchmaking.Refresh(lobby) --- @type Matchmaking_Lobby?
	if current then
		lobby = current
		Roster.SetRoster(current.Roster)
	end

	--[[ Strangers ]]

	Module._sendStrangers(_settings.STRANGER_SECONDS)
end

--%%%%%%%%%%%%%%%%%%%% Release Leavers

--[[
	Gives back the seats of players who were in the room and left it (the server, or the match on the Studio map), so
	lobbies can seat others there.
]]
function Module._releaseLeavers()
	--[[ Local Variables ]]

	local here = Module._getHere() --- @type { [number]: Player }
	local leaving = {} --- @type { number }

	--[[ Searching ]]

	for userId: number, _seen: boolean in pairs(seen) do
		if not here[userId] then
			table.insert(leaving, userId)
		end
	end
	for userId: number, _player: Player in pairs(here) do
		if Module._isSeated(userId) then
			seen[userId] = true
		end
	end

	-- Check if anyone left
	if #leaving == 0 then
		return
	end

	--[[ Releasing ]]

	local kept = {} --- @type { Match_RosterEntry }
	--- @param entry Match_RosterEntry
	for _index: number, entry in ipairs(lobby.Roster) do
		if not table.find(leaving, entry.UserId) then
			table.insert(kept, entry)
		end
	end
	for _index: number, userId: number in ipairs(leaving) do
		seen[userId] = nil
		ready[userId] = nil
	end
	lobby.Roster = kept
	Roster.SetRoster(kept)
	I.Matchmaking.Release(lobby.Mode, lobby.Id, leaving)
end

--%%%%%%%%%%%%%%%%%%%% Send Strangers

--[[
	Sends back to the lobby the players here with no seat in the match, once they've been here `after` seconds (a seat
	a lobby just claimed shows on the next refresh).
]]
function Module._sendStrangers(after: number)
	--[[ Local Variables ]]

	local now: number = os.clock()
	local sending = {} --- @type { Player }

	--[[ Searching ]]

	for userId: number, player: Player in pairs(Module._getHere()) do
		if Module._isSeated(userId) then
			strangers[userId] = nil
			continue
		end
		strangers[userId] = strangers[userId] or now
		if now - strangers[userId] >= after then
			strangers[userId] = nil
			table.insert(sending, player)
		end
	end

	--[[ Sending ]]

	Connection.SendToLobby(sending)
end

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Writes the room for every client (the Room attribute, JSON): each seat's name, whether they pressed Ready, and
	whether they're here and loaded.
]]
function Module._publish()
	--[[ Local Variables ]]

	local here = Module._getHere() --- @type { [number]: Player }
	local room = {} --- @type { Match_RoomSeat }

	--[[ Building ]]

	--- @param entry Match_RosterEntry
	for _index: number, entry in ipairs(lobby.Roster) do
		table.insert(room, {
			UserId = entry.UserId,
			Name = if entry.Card then entry.Card.DisplayName else "",
			Ready = ready[entry.UserId] == true,
			Here = here[entry.UserId] ~= nil,
		})
	end

	--[[ Saving ]]

	matchFolder:SetAttribute("Room", I.S.HttpService:JSONEncode(room))
end

--%%%%%%%%%%%%%%%%%%%% On Ready

--[[
	A player in the room voted to start: once enough have (Run), the match starts soon, bots in the empty seats.
]]
function Module._onReady(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	-- Check if the room is open and the player has a seat in it
	if not lobby or not Module._isSeated(player.UserId) then
		return
	end

	--[[ Saving ]]

	ready[player.UserId] = true
	Module._publish()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Here

--[[
	Returns the players in the match with their data loaded (the InMatch Player attribute, set once it has), by user id.
]]
--- @return { [number]: Player }
function Module._getHere()
	--[[ Searching ]]

	local here = {} --- @type { [number]: Player }
	for _index: number, player: Player in ipairs(Connection.GetPlayersInMatch()) do
		here[player.UserId] = player
	end

	--[[ Returning ]]

	return here
end

--%%%%%%%%%%%%%%%%%%%% Get Votes

--[[
	Returns how many seated players here voted to start, and how many votes start it: every one of them up to
	VOTE_ALL_UP_TO players, VOTE_SHARE of them (rounded up) above. Players still arriving or loading don't count: a bot
	plays for them until they have.
]]
--- @return number
--- @return number
function Module._getVotes()
	--[[ Counting ]]

	local here: number = 0
	local votes: number = 0
	for userId: number, _player: Player in pairs(Module._getHere()) do
		if Module._isSeated(userId) then
			here += 1
			votes += if ready[userId] then 1 else 0
		end
	end

	--[[ Returning ]]

	return votes, if here <= _settings.VOTE_ALL_UP_TO then here else math.ceil(here * _settings.VOTE_SHARE)
end

--%%%%%%%%%%%%%%%%%%%% Is Seated

--[[
	Returns whether a user has a seat in the match's roster.
]]
--- @return boolean
function Module._isSeated(userId: number)
	--[[ Searching ]]

	--- @param entry Match_RosterEntry
	for _index: number, entry in ipairs(Roster.GetMetadata().Roster) do
		if entry.UserId == userId then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

return Module
