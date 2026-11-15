--[[
	Created By: 	Nari
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
		-- A public card's map is the rotation's, which each client works out from the clock
		Rows.AddRow("Public", option.Mode, option.Size, "")
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Join

--[[
	**SERVER** |
	Sends a player, with their whole party here, into a public match of a card's mode: the fullest open one on any
	server on the map the card shows now (the rotation's) with a seat for each of them, on one team where it can, or a
	new one on that map (`shownMap`, the map the player's card showed, when the card moved on less than JOIN_GRACE
	seconds ago). Refused for a party
	member (their leader picks), while their last Join is on its way, and for a party bigger than the mode. Returns
	whether they're on their way.
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

	--[[ Joining ]]

	joining[player] = true
	local success: boolean
	local result: any | string?
	success, result = pcall(Module._join, card, group, Module._getMap(card, shownMap))
	joining[player] = nil
	if not success then
		warn(`[{_localName}::{script.Name}]: Couldn't join a {card.Mode} match for ({player.Name})! - ({result})`)
		Launch._tell({ player }, _settings.JOIN_FAILED_MESSAGE)
		return false
	end

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%% Join Group

--[[
	Seats a group in an open match of the card's mode on a map and sends it there, trying the matches in order until a
	claim holds (another server may have filled one first). With none, opens a new match on that map. A teleport that
	fails gives the seats back. Returns whether the group is on its way.
]]
--- @param card MatchBoard_Row
--- @param group { Player }
--- @return boolean
function Module._join(card, group, mapId: string)
	--[[ Local Variables ]]

	local seats = {} --- @type { Match_RosterEntry }
	local userIds = {} --- @type { number }
	for _index: number, member: Player in ipairs(group) do
		Rows.Leave(member)
		table.insert(seats, { UserId = member.UserId, PartyId = member:GetAttribute("PartyId"), Card = I.Matchmaking.GetCard(member) })
		table.insert(userIds, member.UserId)
	end

	--[[ Open Matches ]]

	--- @param lobby Matchmaking_Lobby
	for _index: number, lobby in ipairs(Module._getTargets(I.Matchmaking.GetOpen(card.Mode), #group, mapId)) do
		if not I.Matchmaking.Claim(card.Mode, lobby.Id, seats) then
			continue
		end
		if Launch.Send(group, Module._getMetadata(lobby), lobby.AccessCode) then
			return true
		end
		I.Matchmaking.Release(card.Mode, lobby.Id, userIds)
		return false
	end

	--[[ New Match ]]

	local lobbyId: string = I.S.HttpService:GenerateGUID(false)
	local roster = I.Matchmaking.Seat({}, seats, _settings.TEAM_SIZES[card.Mode], card.Size) --- @type { Match_RosterEntry }?

	--[[ Returning ]]

	return Launch.Send(group, {
		MatchId = lobbyId,
		Kind = "Public",
		Mode = card.Mode,
		Size = card.Size,
		MapId = mapId,
		Difficulty = _settings.PUBLIC_DIFFICULTY,
		Roster = roster or {},
		LobbyId = lobbyId,
	})
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

--%%%%%%%%%%%%%%%%%%%% Get Targets

--[[
	Returns the open matches on a map that a group of this size fits in, best first: those where it sits on one team,
	then the fullest, so matches fill up instead of many starting half empty.
]]
--- @param lobbies { Matchmaking_Lobby }
--- @return { Matchmaking_Lobby }
function Module._getTargets(lobbies, groupSize: number, mapId: string)
	--[[ Local Variables ]]

	local targets = {} --- @type { Matchmaking_Lobby }
	local free = {} --- @type { [string]: number }
	local together = {} --- @type { [string]: boolean }

	--[[ Filtering ]]

	--- @param lobby Matchmaking_Lobby
	for _index: number, lobby in ipairs(lobbies) do
		local seats: number
		local oneTeam: boolean
		seats, oneTeam = I.Matchmaking.GetFit(lobby, groupSize)
		if seats >= groupSize and lobby.MapId == mapId then
			free[lobby.Id] = seats
			together[lobby.Id] = oneTeam
			table.insert(targets, lobby)
		end
	end

	--[[ Sorting ]]

	--- @param a Matchmaking_Lobby
	--- @param b Matchmaking_Lobby
	table.sort(targets, function(a, b)
		if together[a.Id] ~= together[b.Id] then
			return together[a.Id]
		end
		return free[a.Id] < free[b.Id]
	end)

	--[[ Returning ]]

	return targets
end

--%%%%%%%%%%%%%%%%%%%% Get Metadata

--[[
	Returns the match an open match's server plays, for the teleport card (its map) and, on the Studio map, for joining
	it on this server.
]]
--- @param lobby Matchmaking_Lobby
--- @return Match_Metadata
function Module._getMetadata(lobby)
	return {
		MatchId = lobby.Id,
		Kind = "Public",
		Mode = lobby.Mode,
		Size = lobby.Size,
		MapId = lobby.MapId,
		Difficulty = _settings.PUBLIC_DIFFICULTY,
		Roster = lobby.Roster,
		LobbyId = lobby.Id,
	}
end

return Module
