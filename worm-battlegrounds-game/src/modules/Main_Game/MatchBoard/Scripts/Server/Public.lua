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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The public cards, one per mode, in PUBLIC_ROWS order
local cards = {} --- @type { MatchBoard_Row }

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

	I.Network.GetEvent("MatchBoard_Join", { "Player", "string" }, { RateLimit = 2 })
	I.Network.Fired("MatchBoard_Join", Module.Join)
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Cards ]]

	--- @param option MatchBoard_RowOption
	for _index: number, option in ipairs(_settings.PUBLIC_ROWS) do
		table.insert(cards, Rows.AddRow("Public", option.Mode, option.Size, Launch.GetMap(option.Size)))
	end

	--[[ Starting ]]

	task.spawn(Module._mainLoop)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Main Loop

--[[
	Reads every mode's open matches again each TARGETS_SECONDS, so each card shows the map a Join would land on.
]]
function Module._mainLoop()
	--[[ Refreshing ]]

	while true do
		--- @param card MatchBoard_Row
		for _index: number, card in ipairs(cards) do
			local success: boolean
			local result: any | string?
			success, result = pcall(Module._refreshTargets, card)
			if not success then
				warn(`[{_localName}::{script.Name}]: Couldn't read the open {card.Mode} matches! - ({result})`)
			end
		end
		task.wait(_settings.TARGETS_SECONDS)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Join

--[[
	**SERVER** |
	Sends a player, with their whole party here, into a public match of a card's mode: the fullest open one on any
	server with a seat for each of them (on one team where it can), or a new one on the card's map. Refused for a party
	member (their leader picks), while their last Join is on its way, and for a party bigger than the mode. Returns
	whether they're on their way.
]]
--- @return boolean
function Module.Join(player: Player, rowId: string)
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
	success, result = pcall(Module._join, card, group)
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
	Seats a group in an open match of the card's mode and sends it there, trying the matches in order until a claim
	holds (another server may have filled one first). With none, opens a new match on the card's map and moves the
	card to another. A teleport that fails gives the seats back. Returns whether the group is on its way.
]]
--- @param card MatchBoard_Row
--- @param group { Player }
--- @return boolean
function Module._join(card, group)
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
	for _index: number, lobby in ipairs(Module._getTargets(I.Matchmaking.GetOpen(card.Mode), #group)) do
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
	local mapId: string = card.MapId
	card.MapId = Launch.GetMap(card.Size, mapId)
	Rows.Publish(card)

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

--%%%%%%%%%%%%%%%%%%%% Refresh Targets

--[[
	Writes on a card the map a Join would land on for each group size up to Party's MAX_PARTY: the open match it'd
	join, or "" for a new one on the card's map.
]]
--- @param card MatchBoard_Row
function Module._refreshTargets(card)
	--[[ Local Variables ]]

	local lobbies = I.Matchmaking.GetOpen(card.Mode) --- @type { Matchmaking_Lobby }
	local targets = {} --- @type { string }

	--[[ Calculating ]]

	for groupSize: number = 1, I.Settings["Party"].MAX_PARTY do
		local target = Module._getTargets(lobbies, groupSize)[1] --- @type Matchmaking_Lobby?
		table.insert(targets, if target then target.MapId else "")
	end

	--[[ Publishing ]]

	card.Targets = targets
	Rows.Publish(card)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Targets

--[[
	Returns the open matches a group of this size fits in, best first: those where it sits on one team, then the
	fullest, so matches fill up instead of many starting half empty.
]]
--- @param lobbies { Matchmaking_Lobby }
--- @return { Matchmaking_Lobby }
function Module._getTargets(lobbies, groupSize: number)
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
		if seats >= groupSize then
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
