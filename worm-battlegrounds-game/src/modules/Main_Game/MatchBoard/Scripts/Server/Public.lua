--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchBoard"

--- @type MatchBoard_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Rows = require(script.Parent:FindFirstChild("Rows")) --- @type MatchBoard_Server_Rows
local Launch = require(script.Parent:FindFirstChild("Launch")) --- @type MatchBoard_Server_Launch
local Rotation = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Rotation")) --- @type MatchBoard_Rotation

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The leaders whose Join is on its way (it waits on Matchmaking's store), so a second press doesn't seat them twice
local joining = {} --- @type { [Player]: boolean }

-- The public cards, by mode, whose live match (their mode's frontier) is read every CARD_REFRESH_SECONDS
local cards = {} --- @type { [string]: MatchBoard_Row }

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

--- @class MatchBoard_Server_Public
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Network ]]

	I.Network.GetEvent("MatchBoard_Join", { "Player", "string", { Type = "string", Optional = true } }, { RateLimit = 2 })
	I.Network.Fired("MatchBoard_Join", Module.Join)
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Cards ]]

	--- @param option MatchBoard_RowOption
	for _index: number, option in ipairs(_settings.PUBLIC_ROWS) do
		-- A public card's map is the rotation's, which each client works out from the clock, until a match fills on it
		cards[option.Mode] = Rows.AddRow("Public", option.Mode, option.Size, "")
	end

	--[[ Live Matches ]]

	I.DoEvery.Every(_settings.CARD_REFRESH_SECONDS, Module._refreshCards)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Refresh Cards

--[[
	Shows on each public card the match filling for its mode on every server (Matchmaking's frontier): its map, the
	players seated in it and when it starts, as the card's LiveId, LiveMapId, LivePlayers and LiveEndsAt attributes
	(LiveId "" while none fills, and the card shows the rotation's next map with no one in it).
]]
function Module._refreshCards()
	--[[ Cards ]]

	for mode: string, card: MatchBoard_Row in pairs(cards) do
		local frontier = I.Matchmaking.GetFrontier(mode) --- @type Matchmaking_Frontier?
		card.Config:SetAttribute("LiveId", if frontier then frontier.Id else "")
		card.Config:SetAttribute("LiveMapId", if frontier then frontier.MapId else "")
		card.Config:SetAttribute("LivePlayers", if frontier then frontier.Players else 0)
		card.Config:SetAttribute("LiveEndsAt", if frontier then frontier.EndsAt else 0)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Join

--[[
	**SERVER** |
	Sends a player, with their whole party here, into the public match of a card's mode that every server fills first
	(Matchmaking's frontier), or opens the next one on the map the card shows (the rotation's; `shownMap`, the map the
	player's card showed, when the card moved on less than JOIN_GRACE seconds ago). Refused for a party member (their
	leader picks), while their last Join is on its way, and for a party bigger than the mode. Returns whether they're
	on their way.
]]
--- @return boolean
function Module.Join(player: Player, rowId: string, shownMap: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	local card = Rows.GetRow(rowId) --- @type MatchBoard_Row?
	local group = Rows.GetGroup(player) --- @type { Player }

	--[[ Checks ]]

	-- Check if it's a public card
	if not card or card.Kind ~= "Public" then
		return false
	end

	-- Check if the player may bring the party
	if player:GetAttribute("PartyId") and not player:GetAttribute("PartyLeader") then
		Launch._tell({ player }, "Only your party's leader can join a match.")
		return false
	end

	-- Check if their last Join is still on its way
	if joining[player] then
		return false
	end

	-- Check if the party fits the mode
	if #group > card.Size then
		Launch._tell({ player }, "Your party doesn't fit in that match.")
		return false
	end

	--[[ Showing ]]

	-- The teleport card goes up at once, so the press shows while the match is found (the Studio map plays it here)
	if I.Config.PlaceLoader.MapId ~= _settings.STUDIO_MAP then
		I.Transition.Show(group, {

			--[[ General ]]

			Kicker = _settings.JOIN_SEARCH_KICKER,
			Title = _settings.JOIN_SEARCH_MESSAGE,

			--[[ Match ]]

			Mode = _settings.MODE_NAMES[card.Mode] or card.Mode,
			ModeIcon = _settings.MODE_ICONS[card.Mode],

			--[[ Searching ]]

			Pool = Rotation.GetPool(card.Size),
		})
	end

	--[[ Joining ]]

	joining[player] = true
	local success: boolean
	local result: any | string?
	success, result = pcall(Module._join, card, group, shownMap)
	joining[player] = nil
	if not success or not result then
		I.Transition.Hide(group)
	end
	if not success then
		warn(`[{_localName}::{script.Name}]: Couldn't join a {card.Mode} match for ({player.Name})! - ({result})`)
		Launch._tell({ player }, _settings.JOIN_FAILED_MESSAGE)
		return false
	end

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%% Play Again

--[[
	**SERVER** |
	Puts a player back into a match like the one they were knocked out of: the public card of its mode (Join), or a
	solo match at its difficulty on a random map. Returns whether they're on their way.
]]
--- @return boolean
function Module.PlayAgain(player: Player, kind: string, mode: string, difficulty: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Returning ]]

	if kind == "Solo" then
		return Launch.PlaySolo(player, difficulty, "")
	end
	local card = cards[mode] --- @type MatchBoard_Row?
	return card ~= nil and Module.Join(player, card.Id)
end

--%%%%%%%%%%%%%%%%%%%% Join Group

--[[
	Seats a group in its mode's filling match (the frontier, on any server) and sends it there. When that's full, closed
	or there's none, opens the next one on the card's map: in the store first (pending, the group seated), then as the
	mode's frontier, in one step no other lobby can come between, so two lobbies pressing Join together never open two
	matches: the one that loses the step joins the other's instead. Up to JOIN_TRIES rounds; with the store out of
	reach the group gets a match of its own. Returns whether the group is on its way.
]]
--- @param card MatchBoard_Row
--- @param group { Player }
--- @return boolean
function Module._join(card, group, shownMap: string?)
	--[[ Local Variables ]]

	local seats = {} --- @type { Match_RosterEntry }
	local userIds = {} --- @type { number }
	for _index: number, member: Player in ipairs(group) do
		Rows.Leave(member)
		table.insert(seats, { UserId = member.UserId, PartyId = member:GetAttribute("PartyId"), Card = I.Matchmaking.GetCard(member) })
		table.insert(userIds, member.UserId)
	end

	--[[ Joining ]]

	for _try: number = 1, _settings.JOIN_TRIES do
		local frontier: Matchmaking_Frontier?
		local staleId: string?
		frontier, staleId = I.Matchmaking.GetFrontier(card.Mode)

		-- The filling match, when the group fits in it
		if frontier and frontier.Size - frontier.Players >= #group then
			local lobby = I.Matchmaking.Claim(card.Mode, frontier.Id, seats) --- @type Matchmaking_Lobby?
			if lobby then
				I.Matchmaking.TouchFrontier(lobby)
				return Module._sendSeated(card, group, lobby, userIds)
			end
			staleId = frontier.Id
		elseif frontier then
			staleId = frontier.Id
		end

		-- The next match, unless another lobby opens it first
		local lobby = Module._getNewLobby(card, seats, Module._getMap(card, shownMap)) --- @type Matchmaking_Lobby?
		if not lobby then
			break
		end
		local opened = I.Matchmaking.Open(lobby, _settings.PENDING_SECONDS) --- @type Matchmaking_Lobby?
		if not opened then
			break
		end
		if I.Matchmaking.TakeFrontier(opened, staleId) then
			return Module._sendNew(group, opened, userIds)
		end
		I.Matchmaking.Close(opened)
	end

	--[[ Alone ]]

	-- The store can't be reached: a match of the group's own, bots in the empty seats
	local lobbyId: string = I.S.HttpService:GenerateGUID(false)

	--[[ Returning ]]

	return Launch.Send(group, {
		MatchId = lobbyId,
		Kind = "Public",
		Mode = card.Mode,
		Size = card.Size,
		MapId = Module._getMap(card, shownMap),
		Difficulty = _settings.PUBLIC_DIFFICULTY,
		Roster = I.Matchmaking.Seat({}, seats, _settings.TEAM_SIZES[card.Mode], card.Size) or {},
		LobbyId = lobbyId,
	})
end

--%%%%%%%%%%%%%%%%%%%% Send New

--[[
	Sends the group that opened a match to its new server (Launch makes it and hands it the match). A teleport that
	fails closes the match, so nobody waits for a server that won't come.
]]
--- @param group { Player }
--- @param lobby Matchmaking_Lobby
--- @param userIds { number }
--- @return boolean
function Module._sendNew(group, lobby, userIds)
	--[[ Sending ]]

	if Launch.Send(group, Module._getMetadata(lobby)) then
		return true
	end

	--[[ Failing ]]

	I.Matchmaking.Release(lobby.Mode, lobby.Id, userIds)
	I.Matchmaking.Close(lobby)

	--[[ Returning ]]

	return false
end

--%%%%%%%%%%%%%%%%%%%% Send Seated

--[[
	Sends a group seated in a match to its server. A match another lobby just opened has no server yet: the group waits
	(SERVER_WAIT_SECONDS at most, told "Match found!") until it's up and wrote its AccessCode. A teleport that fails, or
	a server that never comes, gives the seats back.
]]
--- @param card MatchBoard_Row
--- @param group { Player }
--- @param lobby Matchmaking_Lobby
--- @param userIds { number }
--- @return boolean
function Module._sendSeated(card, group, lobby, userIds)
	--[[ Studio Map ]]

	-- The Studio map plays the match on this server, which has no AccessCode: Launch joins the one running
	if I.Config.PlaceLoader.MapId == _settings.STUDIO_MAP then
		return Launch.Send(group, Module._getMetadata(lobby))
	end

	--[[ Waiting ]]

	local seated = lobby --- @type Matchmaking_Lobby?
	if not lobby.AccessCode then
		I.Transition.SetDestination(group, Launch.GetDestination(_settings.JOIN_WAIT_MESSAGE, lobby.MapId, card.Mode, card.Size))
		local waitUntil: number = os.clock() + _settings.SERVER_WAIT_SECONDS
		while seated and not seated.AccessCode and os.clock() < waitUntil do
			task.wait(_settings.SERVER_WAIT_POLL)
			seated = I.Matchmaking.Get(card.Mode, lobby.Id)
		end
	end

	--[[ Sending ]]

	if seated and seated.AccessCode and Launch.Send(group, Module._getMetadata(seated), seated.AccessCode) then
		return true
	end

	--[[ Failing ]]

	I.Matchmaking.Release(card.Mode, lobby.Id, userIds)
	if not seated or not seated.AccessCode then
		Launch._tell(group, _settings.JOIN_FAILED_MESSAGE)
	end

	--[[ Returning ]]

	return false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Map

--[[
	Returns the map a Join on a card plays: the rotation's now, or the one before it when the press came in less than
	JOIN_GRACE seconds after the card moved on and the player's card still showed that one.
]]
--- @param card MatchBoard_Row
--- @return string
function Module._getMap(card, shownMap: string?)
	--[[ Local Variables ]]

	local now: number = I.S.Workspace:GetServerTimeNow()
	local previous: string = Rotation.GetMap(card.Mode, card.Size, now - _settings.JOIN_GRACE)

	--[[ Returning ]]

	return if shownMap == previous then previous else Rotation.GetMap(card.Mode, card.Size, now)
end

--%%%%%%%%%%%%%%%%%%%% Get New Lobby

--[[
	Returns the next public match of a card's mode on a map, the group seated in it, to open in the store: it starts
	WAITING_SECONDS after its server could be up (SERVER_BOOT_SECONDS). Nil when the group doesn't fit it.
]]
--- @param card MatchBoard_Row
--- @param seats { Match_RosterEntry }
--- @return Matchmaking_Lobby?
function Module._getNewLobby(card, seats, mapId: string)
	--[[ Local Variables ]]

	local teamSize: number = _settings.TEAM_SIZES[card.Mode] or 1
	local roster = I.Matchmaking.Seat({}, seats, teamSize, card.Size) --- @type { Match_RosterEntry }?

	--[[ Checks ]]

	-- Check if the group fits the match
	if not roster then
		return nil
	end

	--[[ Returning ]]

	return {
		Id = I.S.HttpService:GenerateGUID(false),
		Open = true,
		EndsAt = os.time() + _settings.SERVER_BOOT_SECONDS + _settings.WAITING_SECONDS,
		Mode = card.Mode,
		Size = card.Size,
		TeamSize = teamSize,
		MapId = mapId,
		Roster = roster,
	}
end

--%%%%%%%%%%%%%%%%%%%% Get Metadata

--[[
	Returns the match an open match's server plays, for the teleport card (its map) and, on the Studio map, for joining
	it on this server. It carries the mode's and map's names and the mode's icon for the match server's waiting room,
	since the match place doesn't load MatchBoard.
]]
--- @param lobby Matchmaking_Lobby
--- @return Match_Metadata
function Module._getMetadata(lobby)
	--[[ Data ]]

	local mapRow = _settings.MAPS[lobby.MapId] --- @type MatchBoard_MapRow?

	--[[ Returning ]]

	return {
		MatchId = lobby.Id,
		Kind = "Public",
		Mode = lobby.Mode,
		Size = lobby.Size,
		MapId = lobby.MapId,
		Difficulty = _settings.PUBLIC_DIFFICULTY,
		ModeName = _settings.MODE_NAMES[lobby.Mode] or lobby.Mode,
		ModeIcon = _settings.MODE_ICONS[lobby.Mode],
		MapName = if mapRow then mapRow.Name else nil,
		Roster = lobby.Roster,
		LobbyId = lobby.Id,
	}
end

return Module
