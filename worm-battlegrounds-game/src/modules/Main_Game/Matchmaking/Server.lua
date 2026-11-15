--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Matchmaking"

--- @type Matchmaking_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("ServerSettings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Studio keeps its own store on the server (the Studio map's lobby and match share it), so a test never reaches the live one
local useStore: boolean = true

-- The Studio store: each mode's matches by id
local localStore = {} --- @type { [string]: { [string]: Matchmaking_LocalEntry } }

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	useStore = not I.S.RunService:IsStudio()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Matchmaking = {

		--[[ Control ]]

		Claim = Module.Claim,
		Release = Module.Release,
		Open = Module.Open,
		Refresh = Module.Refresh,
		Close = Module.Close,

		--[[ Methods ]]

		GetOpen = Module.GetOpen,
		GetCard = Module.GetCard,
		GetFit = Module.GetFit,
		Seat = Module.Seat,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Claim

--[[
	**SERVER** |
	Takes seats in an open match for a group (a party, or one player), in one step no other server can come between, so
	a match never gets more players than its size. Refused when the match closed, starts within MIN_SECONDS_LEFT, has
	fewer free seats than the group, or already seats one of them. Returns the match with the group seated, or nil.
]]
--- @param group { Match_RosterEntry }
--- @return Matchmaking_Lobby?
function Module.Claim(mode: string, lobbyId: string, group)
	--[[ Claiming ]]

	--- @param lobby Matchmaking_Lobby?
	return Module._update(mode, lobbyId, function(lobby)
		return Module._takeSeats(lobby, group)
	end, _settings.OPEN_SECONDS)
end

--%%%%%%%%%%%%%%%%%%%% Release

--[[
	**SERVER** |
	Gives back the seats of players who won't come (their teleport failed) or left before the match started, so others
	can take them. A match that closed keeps them.
]]
--- @param userIds { number }
function Module.Release(mode: string, lobbyId: string, userIds)
	--[[ Releasing ]]

	--- @param lobby Matchmaking_Lobby?
	Module._update(mode, lobbyId, function(lobby)
		return Module._giveBack(lobby, userIds)
	end, _settings.OPEN_SECONDS)
end

--%%%%%%%%%%%%%%%%%%%% Open

--[[
	**SERVER** |
	Puts a match server's public match in the store, open to joins from every lobby server. Returns whether it's in.
]]
--- @param lobby Matchmaking_Lobby
--- @return boolean
function Module.Open(lobby)
	--[[ Opening ]]

	--- @param _old Matchmaking_Lobby?
	return Module._update(lobby.Mode, lobby.Id, function(_old)
		return lobby
	end, _settings.OPEN_SECONDS) ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	**SERVER** |
	Keeps a match server's open match in the store and returns it as the store has it, with the seats lobby servers
	claimed since. One the store lost is put back from the server's copy. Returns nil when the store can't be reached.
]]
--- @param lobby Matchmaking_Lobby
--- @return Matchmaking_Lobby?
function Module.Refresh(lobby)
	--[[ Refreshing ]]

	--- @param current Matchmaking_Lobby?
	return Module._update(lobby.Mode, lobby.Id, function(current)
		return current or lobby
	end, _settings.OPEN_SECONDS)
end

--%%%%%%%%%%%%%%%%%%%% Close

--[[
	**SERVER** |
	Closes a match server's match to joins, in the same single step claims take, and returns it as it closed: its
	roster is final, since no claim can land after. Returns nil when the store can't be reached.
]]
--- @param lobby Matchmaking_Lobby
--- @return Matchmaking_Lobby?
function Module.Close(lobby)
	--[[ Closing ]]

	--- @param current Matchmaking_Lobby?
	return Module._update(lobby.Mode, lobby.Id, function(current)
		local closed = current or lobby --- @type Matchmaking_Lobby
		closed.Open = false
		return closed
	end, _settings.CLOSED_SECONDS)
end

--%%%%%%%%%%%%%%%%%%%% Take Seats

--[[
	Claim's step: seats the group in the match as stored, unless the match closed, starts within MIN_SECONDS_LEFT, has
	fewer free seats than the group or already seats one of them. Returns the match to keep, or nil to leave it.
]]
--- @param lobby Matchmaking_Lobby?
--- @param group { Match_RosterEntry }
--- @return Matchmaking_Lobby?
function Module._takeSeats(lobby, group)
	--[[ Checks ]]

	-- Check if the match still takes joins
	if not lobby or not lobby.Open or os.time() > lobby.EndsAt - _settings.MIN_SECONDS_LEFT then
		return nil
	end

	-- Check if anyone in the group already has a seat in it
	--- @param entry Match_RosterEntry
	for _index: number, entry in ipairs(group) do
		if Module._isSeated(lobby.Roster, entry.UserId) then
			return nil
		end
	end

	--[[ Seating ]]

	local seated = Module.Seat(lobby.Roster, group, lobby.TeamSize, lobby.Size) --- @type { Match_RosterEntry }?
	if not seated then
		return nil
	end
	table.move(seated, 1, #seated, #lobby.Roster + 1, lobby.Roster)

	--[[ Returning ]]

	return lobby
end

--%%%%%%%%%%%%%%%%%%%% Give Back

--[[
	Release's step: takes the players' seats out of the match as stored, unless it closed or seats none of them.
	Returns the match to keep, or nil to leave it.
]]
--- @param lobby Matchmaking_Lobby?
--- @param userIds { number }
--- @return Matchmaking_Lobby?
function Module._giveBack(lobby, userIds)
	--[[ Checks ]]

	-- Check if the match still takes joins
	if not lobby or not lobby.Open then
		return nil
	end

	--[[ Releasing ]]

	local kept = {} --- @type { Match_RosterEntry }
	--- @param entry Match_RosterEntry
	for _index: number, entry in ipairs(lobby.Roster) do
		if not table.find(userIds, entry.UserId) then
			table.insert(kept, entry)
		end
	end

	-- Check if any seat was theirs
	if #kept == #lobby.Roster then
		return nil
	end
	lobby.Roster = kept

	--[[ Returning ]]

	return lobby
end

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	Changes one match in the store in a single step: `transform` gets it as stored (nil when there's none) and returns
	what to keep, or nil to leave it. MemoryStore may run `transform` more than once, so it changes nothing else.
	Returns what was kept, or nil when nothing changed or the store can't be reached.
]]
--- @param transform (lobby: Matchmaking_Lobby | nil) -> Matchmaking_Lobby?
--- @return Matchmaking_Lobby?
function Module._update(mode: string, lobbyId: string, transform, seconds: number)
	--[[ Studio ]]

	if not useStore then
		return Module._updateLocal(mode, lobbyId, transform, seconds)
	end

	--[[ Local Variables ]]

	local sortedMap: MemoryStoreSortedMap = I.S.MemoryStoreService:GetSortedMap(_settings.STORE_NAME .. mode)

	--[[ Updating ]]

	for try: number = 1, _settings.RETRIES do
		local success: boolean
		local result: any | string?
		success, result = pcall(function()
			return sortedMap:UpdateAsync(lobbyId, transform, seconds)
		end)
		if success then
			return result
		end
		warn(`[{_localName}::{script.Name}]: Couldn't update match ({lobbyId}), try {try}! - ({result})`)
		task.wait(_settings.RETRY_DELAY * try)
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Update Local

--[[
	The Studio store's update: the same single step, on this server, with every value kept as JSON so it travels as it
	would through MemoryStore.
]]
--- @param transform (lobby: Matchmaking_Lobby | nil) -> Matchmaking_Lobby?
--- @return Matchmaking_Lobby?
function Module._updateLocal(mode: string, lobbyId: string, transform, seconds: number)
	--[[ Data ]]

	localStore[mode] = localStore[mode] or {}
	local entry = localStore[mode][lobbyId] --- @type Matchmaking_LocalEntry?

	--[[ Updating ]]

	local current = if entry and entry.ExpiresAt > os.clock() then I.S.HttpService:JSONDecode(entry.Value) else nil --- @type Matchmaking_Lobby?
	local kept = transform(current) --- @type Matchmaking_Lobby?
	if kept == nil then
		return nil
	end

	--[[ Saving ]]

	local value: string = I.S.HttpService:JSONEncode(kept)
	localStore[mode][lobbyId] = { Value = value, ExpiresAt = os.clock() + seconds }

	--[[ Returning ]]

	return I.S.HttpService:JSONDecode(value)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Open

--[[
	**SERVER** |
	Returns a mode's public matches still taking joins, from every server: open, and not starting within
	MIN_SECONDS_LEFT. Empty when the store can't be reached.
]]
--- @return { Matchmaking_Lobby }
function Module.GetOpen(mode: string)
	--[[ Local Variables ]]

	local now: number = os.time()
	local lobbies = {} --- @type { Matchmaking_Lobby }

	--[[ Reading ]]

	--- @param lobby Matchmaking_Lobby
	for _index: number, lobby in ipairs(Module._list(mode)) do
		if lobby.Open and now <= lobby.EndsAt - _settings.MIN_SECONDS_LEFT then
			table.insert(lobbies, lobby)
		end
	end

	--[[ Returning ]]

	return lobbies
end

--%%%%%%%%%%%%%%%%%%%% Get Card

--[[
	**SERVER** |
	Returns what a player takes into a match: their name, loadout and outfit, read where they are now. A match seats a
	player who hasn't arrived or loaded yet from the card their lobby made.
]]
--- @return Matchmaking_Card
function Module.GetCard(player: Player)
	--[[ Data ]]

	local items = {} --- @type { string }
	local shinyItems = {} --- @type { [string]: boolean }
	local outfit = {} --- @type Cosmetics_Outfit
	local skinShiny: boolean
	items, shinyItems = I.Loadout.GetMatchLoadout(player)
	outfit, skinShiny = I.Cosmetics.GetOutfit(player)

	--[[ Returning ]]

	return {

		--[[ Player ]]

		DisplayName = player.DisplayName,
		Vip = player:GetAttribute("Vip") == true,
		Level = player:GetAttribute("Level") or 0,

		--[[ Match ]]

		Loadout = items,
		ShinyItems = shinyItems,
		Skin = I.G_Cosmetics.GetOutfitText(outfit),
		Shiny = skinShiny,
	}
end

--%%%%%%%%%%%%%%%%%%%% Get Fit

--[[
	**SERVER** |
	Returns a match's free seats, and whether a group of this size would sit on one team there (always true for a
	group bigger than a team, which spills anyway).
]]
--- @param lobby Matchmaking_Lobby
--- @return number
--- @return boolean
function Module.GetFit(lobby, groupSize: number)
	--[[ Local Variables ]]

	local filled = Module._getFilled(lobby.Roster, lobby.TeamSize, lobby.Size) --- @type { number }
	local free: number = #filled * lobby.TeamSize - #lobby.Roster
	local room: number = 0
	for _team: number, count: number in ipairs(filled) do
		room = math.max(room, lobby.TeamSize - count)
	end

	--[[ Returning ]]

	return free, groupSize > lobby.TeamSize or room >= groupSize
end

--%%%%%%%%%%%%%%%%%%%% Seat

--[[
	**SERVER** |
	Seats a group in a match's roster: all of it on the team with the most room, a member spilling onto the next team
	with the most room once that one's full. Returns the group's entries with their teams, or nil when the match has
	fewer free seats than the group.
]]
--- @param roster { Match_RosterEntry }
--- @param group { Match_RosterEntry }
--- @return { Match_RosterEntry }?
function Module.Seat(roster, group, teamSize: number, size: number)
	--[[ Local Variables ]]

	local filled = Module._getFilled(roster, teamSize, size) --- @type { number }

	--[[ Checks ]]

	-- Check if the match has a seat for everyone in the group
	if #roster + #group > #filled * teamSize then
		return nil
	end

	--[[ Seating ]]

	local seated = {} --- @type { Match_RosterEntry }
	local team: number = Module._getRoomiest(filled, teamSize)
	--- @param entry Match_RosterEntry
	for _index: number, entry in ipairs(group) do
		if filled[team] >= teamSize then
			team = Module._getRoomiest(filled, teamSize)
		end
		filled[team] += 1
		local seat = table.clone(entry) --- @type Match_RosterEntry
		seat.Team = team
		table.insert(seated, seat)
	end

	--[[ Returning ]]

	return seated
end

--%%%%%%%%%%%%%%%%%%%% List

--[[
	Returns every match the store holds for a mode (MemoryStore drops expired ones by itself). Empty when the store
	can't be reached.
]]
--- @return { Matchmaking_Lobby }
function Module._list(mode: string)
	--[[ Local Variables ]]

	local lobbies = {} --- @type { Matchmaking_Lobby }

	--[[ Studio ]]

	if not useStore then
		--- @param entry Matchmaking_LocalEntry
		for _lobbyId: string, entry in pairs(localStore[mode] or {}) do
			if entry.ExpiresAt > os.clock() then
				table.insert(lobbies, I.S.HttpService:JSONDecode(entry.Value))
			end
		end
		return lobbies
	end

	--[[ Reading ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		return I.S.MemoryStoreService:GetSortedMap(_settings.STORE_NAME .. mode):GetRangeAsync(Enum.SortDirection.Ascending, _settings.LIST_COUNT)
	end)
	if not success then
		warn(`[{_localName}::{script.Name}]: Couldn't read the open {mode} matches! - ({result})`)
		return lobbies
	end

	for _index: number, item: any in ipairs(result) do
		table.insert(lobbies, item.value)
	end

	--[[ Returning ]]

	return lobbies
end

--%%%%%%%%%%%%%%%%%%%% Get Filled

--[[
	Returns how many seats each team of a match has taken: SIZE // teamSize teams (at least one).
]]
--- @param roster { Match_RosterEntry }
--- @return { number }
function Module._getFilled(roster, teamSize: number, size: number)
	--[[ Local Variables ]]

	local filled = table.create(math.max(size // teamSize, 1), 0) --- @type { number }

	--[[ Counting ]]

	--- @param entry Match_RosterEntry
	for _index: number, entry in ipairs(roster) do
		if entry.Team and filled[entry.Team] then
			filled[entry.Team] += 1
		end
	end

	--[[ Returning ]]

	return filled
end

--%%%%%%%%%%%%%%%%%%%% Get Roomiest

--[[
	Returns the team with the most free seats (the first of those with as many).
]]
--- @param filled { number }
--- @return number
function Module._getRoomiest(filled, teamSize: number)
	--[[ Searching ]]

	local best: number = 1
	for team: number, count: number in ipairs(filled) do
		if teamSize - count > teamSize - filled[best] then
			best = team
		end
	end

	--[[ Returning ]]

	return best
end

--%%%%%%%%%%%%%%%%%%%% Is Seated

--[[
	Returns whether a user has a seat in a roster.
]]
--- @param roster { Match_RosterEntry }
--- @return boolean
function Module._isSeated(roster, userId: number)
	--[[ Searching ]]

	--- @param entry Match_RosterEntry
	for _index: number, entry in ipairs(roster) do
		if entry.UserId == userId then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

return {
	_init = Module.Init,
	_start = Module.Start,
}
