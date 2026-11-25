--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Matchmaking"

--- @type Matchmaking_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("ServerSettings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- Studio keeps its own store on the server (the Studio map's lobby and match share it), so a test never reaches the live one
local useStore: boolean = true

-- The Studio store: each mode's matches by id, and each mode's frontier under FRONTIER_MAP
local localStore = {} --- @type { [string]: { [string]: Matchmaking_LocalEntry } }

-- The store's map (after STORE_NAME) that holds every mode's frontier, keyed by mode
local FRONTIER_MAP: string = "Frontier"

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
		TakeFrontier = Module.TakeFrontier,
		TouchFrontier = Module.TouchFrontier,

		--[[ Methods ]]

		Get = Module.Get,
		GetFrontier = Module.GetFrontier,
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
	Puts a public match in the store, open to joins from every lobby server: a lobby opens it pending (no server or
	AccessCode yet, kept `seconds` while the server boots), and its server opens it again once it's up. When it's there
	already, the seats lobbies claimed meanwhile are kept, and it starts no sooner than it said, nor sooner than
	MIN_ROOM_SECONDS from now. Returns the match as stored, or nil when the store can't be reached.
]]
--- @param lobby Matchmaking_Lobby
--- @return Matchmaking_Lobby?
function Module.Open(lobby, seconds: number?)
	--[[ Opening ]]

	--- @param old Matchmaking_Lobby?
	return Module._update(lobby.Mode, lobby.Id, function(old)
		local opened = table.clone(lobby) --- @type Matchmaking_Lobby
		if old then
			opened.Roster = old.Roster
			--- @param entry Match_RosterEntry
			for _index: number, entry in ipairs(lobby.Roster) do
				if not Module._isSeated(opened.Roster, entry.UserId) then
					table.insert(opened.Roster, entry)
				end
			end
			opened.EndsAt = math.max(old.EndsAt, os.time() + _settings.MIN_ROOM_SECONDS)
		end
		return opened
	end, seconds or _settings.OPEN_SECONDS)
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
	local stored = Module._update(lobby.Mode, lobby.Id, function(current)
		return current or lobby
	end, _settings.OPEN_SECONDS) --- @type Matchmaking_Lobby?

	--[[ Frontier ]]

	if stored then
		Module.TouchFrontier(stored)
	end

	--[[ Returning ]]

	return stored
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
	local closed = Module._update(lobby.Mode, lobby.Id, function(current)
		local closing = current or lobby --- @type Matchmaking_Lobby
		closing.Open = false
		return closing
	end, _settings.CLOSED_SECONDS) --- @type Matchmaking_Lobby?

	--[[ Frontier ]]

	-- A started match is no card's any more: the next Join opens a new one
	Module.TouchFrontier(closed or lobby, true)

	--[[ Returning ]]

	return closed
end

--%%%%%%%%%%%%%%%%%%%% Take Frontier

--[[
	**SERVER** |
	Makes a match its mode's frontier, the one match every lobby's card for the mode shows and Join seats players in,
	in one step no other server can come between: only while the frontier is still `staleId` (the full, closed or
	missing match the caller found there) or holds nothing live. The match must be in the store already (Open), so a
	lobby that reads the frontier can always claim in it. Returns whether it took it: false means another lobby just
	opened one, which the caller joins instead.
]]
--- @param lobby Matchmaking_Lobby
--- @return boolean
function Module.TakeFrontier(lobby, staleId: string?)
	--[[ Taking ]]

	--- @param current Matchmaking_Frontier?
	return Module._update(FRONTIER_MAP, lobby.Mode, function(current)
		if current and current.Id ~= staleId and current.Id ~= lobby.Id and Module._isLive(current) then
			return nil
		end
		return Module._getFrontierOf(lobby, false)
	end, Module._getFrontierSeconds(lobby)) ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Touch Frontier

--[[
	**SERVER** |
	Brings a mode's frontier up to date with its match (its seats taken, when it starts), or marks it over once the
	match closed. Leaves it alone when the frontier is another match by now.
]]
--- @param lobby Matchmaking_Lobby
function Module.TouchFrontier(lobby, closed: boolean?)
	--[[ Touching ]]

	--- @param current Matchmaking_Frontier?
	Module._update(FRONTIER_MAP, lobby.Mode, function(current)
		if not current or current.Id ~= lobby.Id then
			return nil
		end
		return Module._getFrontierOf(lobby, closed == true or not lobby.Open)
	end, Module._getFrontierSeconds(lobby))
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

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	**SERVER** |
	Returns one match as the store has it, or nil when it has none (or can't be reached).
]]
--- @return Matchmaking_Lobby?
function Module.Get(mode: string, lobbyId: string)
	return Module._get(mode, lobbyId)
end

--%%%%%%%%%%%%%%%%%%%% Get Frontier

--[[
	**SERVER** |
	Returns a mode's frontier (the match its cards show and Join fills) while it's live: seats left and not starting
	within MIN_SECONDS_LEFT. Nil when there's none or the store can't be reached; then the second value is the id of
	one that isn't live any more, for TakeFrontier.
]]
--- @return Matchmaking_Frontier?
--- @return string?
function Module.GetFrontier(mode: string)
	--[[ Data ]]

	local frontier = Module._get(FRONTIER_MAP, mode) --- @type Matchmaking_Frontier?

	--[[ Checks ]]

	-- Check if there's one, and if it's live
	if not frontier then
		return nil, nil
	end
	if not Module._isLive(frontier) then
		return nil, frontier.Id
	end

	--[[ Returning ]]

	return frontier, nil
end

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
	local goldenItems = {} --- @type { [string]: boolean }
	local itemLooks = {} --- @type { [string]: string }
	local outfit = {} --- @type Cosmetics_Outfit
	local skinShiny: boolean
	items, shinyItems, goldenItems, itemLooks = I.Loadout.GetMatchLoadout(player)
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
		GoldenItems = goldenItems,
		ItemLooks = itemLooks,
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

--%%%%%%%%%%%%%%%%%%%% Get Value

--[[
	Returns one value from one of the store's maps (a mode's matches, or FRONTIER_MAP), or nil when it holds none or
	can't be reached.
]]
--- @return any
function Module._get(mapName: string, key: string)
	--[[ Studio ]]

	if not useStore then
		local entry = (localStore[mapName] or {})[key] --- @type Matchmaking_LocalEntry?
		return if entry and entry.ExpiresAt > os.clock() then I.S.HttpService:JSONDecode(entry.Value) else nil
	end

	--[[ Reading ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		return I.S.MemoryStoreService:GetSortedMap(_settings.STORE_NAME .. mapName):GetAsync(key)
	end)
	if not success then
		warn(`[{_localName}::{script.Name}]: Couldn't read ({mapName}/{key})! - ({result})`)
		return nil
	end

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%% Get Frontier Of

--[[
	Returns what a mode's frontier keeps of its match: what the cards show and Join needs. A closed match keeps it with
	no room left, so it isn't live.
]]
--- @param lobby Matchmaking_Lobby
--- @return Matchmaking_Frontier
function Module._getFrontierOf(lobby, closed: boolean)
	return {
		Id = lobby.Id,
		MapId = lobby.MapId,
		Size = lobby.Size,
		Players = if closed then lobby.Size else #lobby.Roster,
		EndsAt = lobby.EndsAt,
	}
end

--%%%%%%%%%%%%%%%%%%%% Get Frontier Seconds

--[[
	Returns how long a frontier stays in the store: until its match starts, and CLOSED_SECONDS after, so a late reader
	sees it full rather than nothing.
]]
--- @param lobby Matchmaking_Lobby
--- @return number
function Module._getFrontierSeconds(lobby)
	return math.max(lobby.EndsAt - os.time(), 1) + _settings.CLOSED_SECONDS
end

--%%%%%%%%%%%%%%%%%%%% Is Live

--[[
	Returns whether a frontier's match still takes joins: seats left, and not starting within MIN_SECONDS_LEFT.
]]
--- @param frontier Matchmaking_Frontier
--- @return boolean
function Module._isLive(frontier)
	return frontier.Players < frontier.Size and os.time() <= frontier.EndsAt - _settings.MIN_SECONDS_LEFT
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
