--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchBoard"

--- @type MatchBoard_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local random: Random = Random.new()

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

--- @class MatchBoard_Server_Launch
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Network ]]

	I.Network.GetEvent("MatchBoard_PlaySolo", { "Player", "string" }, { RateLimit = 1 })
	I.Network.Fired("MatchBoard_PlaySolo", Module.PlaySolo)
	I.Network.GetEvent("MatchBoard_PlayParty", { "Player", "string" }, { RateLimit = 1 })
	I.Network.Fired("MatchBoard_PlayParty", Module.PlayParty)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Launch

--[[
	**SERVER** |
	Sends players to a new match server: puts them on teams (each party on one team, a party bigger than a team
	spilling onto the next with room, then the solo players), builds the
	match's metadata and teleports them together. The Studio map plays the match on this server instead; the Lobby
	map alone in Studio, which can't teleport, prints the metadata. Players who couldn't go are told so. Returns
	whether the match started.
]]
--- @param players { Player }
--- @return boolean
function Module.Launch(players, kind: string, mode: string, size: number, mapId: string, difficulty: string, tutorial: boolean?)
	--[[ Local Variables ]]

	local teamSize: number = if mode == "Teams" then math.max(math.floor(size / 2), 1) else _settings.TEAM_SIZES[mode] or 1
	local filled = {} --- @type { [number]: number }
	local roster = {} --- @type { Match_RosterEntry }

	--[[ Teams ]]

	-- Parties first, so each stays together, then everyone else
	local groups = {} --- @type { [string]: { Player } }
	local order = {} --- @type { string }
	for _index: number, player: Player in ipairs(players) do
		local groupId: string = player:GetAttribute("PartyId") or `Solo_{player.UserId}`
		if not groups[groupId] then
			groups[groupId] = {}
			table.insert(order, groupId)
		end
		table.insert(groups[groupId], player)
	end
	table.sort(order, function(a: string, b: string)
		return #groups[a] > #groups[b]
	end)

	local teamCount: number = math.max(math.floor(size / teamSize), 1)
	for _index: number, groupId: string in ipairs(order) do
		local team: number = Module._getTeamWithRoom(filled, teamSize, #groups[groupId], teamCount)
		for _index2: number, player: Player in ipairs(groups[groupId]) do
			-- A party bigger than a team spills onto the team with the most room
			if (filled[team] or 0) >= teamSize then
				team = Module._getTeamWithRoom(filled, teamSize, 1, teamCount)
			end
			filled[team] = (filled[team] or 0) + 1
			table.insert(roster, { UserId = player.UserId, Team = team, PartyId = player:GetAttribute("PartyId") })
		end
	end

	--[[ Metadata ]]

	--- @type Match_Metadata
	local metadata = {
		MatchId = I.S.HttpService:GenerateGUID(false),
		Kind = if tutorial then "Tutorial" else kind,
		Mode = mode,
		Size = size,
		MapId = mapId,
		Difficulty = difficulty,
		Roster = roster,
	}

	--[[ Studio Map ]]

	if I.Config.PlaceLoader.MapId == _settings.STUDIO_MAP then
		if I.Match.Host(players, metadata) then
			return true
		end
		Module._tell(players, "A Studio match is still running: wait for it to end.")
		return false
	end

	--[[ Teleporting ]]

	I.Transition.SetDestination(players, `Heading to {_settings.MAPS[mapId].Name}…`, _settings.MAPS[mapId].Thumbnail)

	local success: boolean
	local result: any | string?
	success, result = pcall(I.Teleport, players, _settings.MATCH_PLACE_ID, "Match", metadata, _settings.TELEPORT_GUI)
	if not success or not result then
		warn(`[{_localName}::{script.Name}]: Couldn't start match ({metadata.MatchId})! - ({result})`)
		Module._tell(players, "Couldn't start the match. Try again!")
		return false
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Play Solo

--[[
	**SERVER** |
	Starts a 1v1 against one bot at a difficulty. Refused in a party of 2 or more.
]]
--- @return boolean
function Module.PlaySolo(player: Player, difficulty: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Check if the difficulty exists
	if not table.find(_settings.SOLO_DIFFICULTIES, difficulty) then
		return false
	end

	-- Check if the player plays alone
	if player:GetAttribute("PartyId") and #I.Party.GetMembers(player:GetAttribute("PartyId")) > 1 then
		Module._tell({ player }, "Solo matches are for one player: leave your party first.")
		return false
	end

	--[[ Launching ]]

	return Module.Launch({ player }, "Solo", "Deathmatch", 2, Module.GetMap(2), difficulty)
end

--%%%%%%%%%%%%%%%%%%%% Play Party

--[[
	**SERVER** |
	Starts a friends-only deathmatch for the leader's party: with bots at a difficulty (PARTY_BOTS_PER_PLAYER per member),
	or "None" for the party alone, which pays less. Refused unless the player leads a party of 2 or more here.
]]
--- @return boolean
function Module.PlayParty(player: Player, difficulty: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	local partyId: string? = player:GetAttribute("PartyId")
	local members = if partyId then I.Party.GetMembers(partyId) else {} --- @type { Player }

	--[[ Checks ]]

	-- Check if the difficulty exists
	if difficulty ~= "None" and not table.find(_settings.SOLO_DIFFICULTIES, difficulty) then
		return false
	end

	-- Check if the player leads a party of two or more
	if #members < 2 or not I.Party.IsLeader(player) then
		Module._tell({ player }, "Only a party's leader can start a party match.")
		return false
	end

	--[[ Launching ]]

	local size: number = if difficulty == "None" then #members else math.min(#members * (1 + _settings.PARTY_BOTS_PER_PLAYER), _settings.PARTY_MAX_SIZE)
	return Module.Launch(members, "Party", "Deathmatch", size, Module.GetMap(size), difficulty)
end

--%%%%%%%%%%%%%%%%%%%% Tell

--[[
	Shows players a short message.
]]
--- @param players { Player }
function Module._tell(players, message: string)
	--[[ Showing ]]

	for _index: number, player: Player in ipairs(players) do
		I.Notify.ShowNotification(player, message)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Map

--[[
	**SERVER** |
	Returns a random map from MAP_POOL made for a match size, or any map in the pool when none is; never `avoid` (the
	map a row just had) while there's another.
]]
--- @return string
function Module.GetMap(size: number, avoid: string?)
	--[[ Local Variables ]]

	local fitting = {} --- @type { string }
	for _index: number, mapId: string in ipairs(_settings.MAP_POOL) do
		if table.find(_settings.MAPS[mapId].Sizes, size) then
			table.insert(fitting, mapId)
		end
	end
	local pool = table.clone(if #fitting > 0 then fitting else _settings.MAP_POOL) --- @type { string }
	if #pool > 1 and table.find(pool, avoid) then
		table.remove(pool, table.find(pool, avoid))
	end

	--[[ Returning ]]

	return pool[random:NextInteger(1, #pool)]
end

--%%%%%%%%%%%%%%%%%%%% Get Team With Room

--[[
	Returns the team with the most room for a group of players (the first one, when a group is bigger than a team).
]]
--- @param filled { [number]: number }
--- @return number
function Module._getTeamWithRoom(filled, teamSize: number, groupSize: number, teamCount: number)
	--[[ Searching ]]

	local best: number = 1
	local bestRoom: number = -math.huge
	for team: number = 1, teamCount do
		local room: number = teamSize - (filled[team] or 0)
		if room >= groupSize and room > bestRoom then
			best = team
			bestRoom = room
		end
	end

	--[[ Returning ]]

	return best
end

return Module
