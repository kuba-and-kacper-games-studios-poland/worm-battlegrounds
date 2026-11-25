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

local Rotation = require(script.Parent.Parent:FindFirstChild("Helpers"):FindFirstChild("Rotation")) --- @type MatchBoard_Rotation

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

	I.Network.GetEvent("MatchBoard_PlaySolo", { "Player", "string", "string" }, { RateLimit = 1 })
	I.Network.Fired("MatchBoard_PlaySolo", Module.PlaySolo)
	I.Network.GetEvent("MatchBoard_PlayParty", { "Player", "string", "string" }, { RateLimit = 1 })
	I.Network.Fired("MatchBoard_PlayParty", Module.PlayParty)
	I.Network.GetEvent("MatchBoard_PlayLocal", { "Player", "string", "string", "number", "boolean" }, { RateLimit = 1 })
	I.Network.Fired("MatchBoard_PlayLocal", Module.PlayLocal)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Launch

--[[
	**SERVER** |
	Sends players to a new match server: puts them on teams (each party on one team, a party bigger than a team
	spilling onto the next with room, then the solo players), each with the card the match seats them from until they
	arrive, builds the match's metadata and sends them. Players who couldn't go are told so. Returns whether the
	match started. Wind blows only when `wind` is true (a custom lobby that turned it on).
]]
--- @param players { Player }
--- @return boolean
function Module.Launch(players, kind: string, mode: string, size: number, mapId: string, difficulty: string, tutorial: boolean?, wind: boolean?)
	--[[ Local Variables ]]

	local teamSize: number = if mode == "Teams" then math.max(math.floor(size / 2), 1) else _settings.TEAM_SIZES[mode] or 1
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

	for _index: number, groupId: string in ipairs(order) do
		local seats = {} --- @type { Match_RosterEntry }
		for _index2: number, player: Player in ipairs(groups[groupId]) do
			table.insert(seats, { UserId = player.UserId, PartyId = player:GetAttribute("PartyId"), Card = I.Matchmaking.GetCard(player) })
		end

		-- Check if the group fits (callers check the size first)
		local seated = I.Matchmaking.Seat(roster, seats, teamSize, size) --- @type { Match_RosterEntry }?
		if not seated then
			warn(`[{_localName}::{script.Name}]: Group ({groupId}) doesn't fit a {mode} match of {size}!`)
			continue
		end
		table.move(seated, 1, #seated, #roster + 1, roster)
	end

	--[[ Returning ]]

	return Module.Send(players, {
		MatchId = I.S.HttpService:GenerateGUID(false),
		Kind = if tutorial then "Tutorial" else kind,
		Mode = mode,
		Size = size,
		MapId = mapId,
		Difficulty = difficulty,
		Wind = wind == true,
		Roster = roster,
	})
end

--%%%%%%%%%%%%%%%%%%%% Send

--[[
	**SERVER** |
	Teleports players to their match: a new server of the Match map with the match's metadata, or, with `accessCode`,
	the server of an open public match they were seated in. The Studio map plays the match on this server instead
	(`I.Match.Host`); the Lobby map alone in Studio, which can't teleport, only warns. Returns whether they're on their
	way.
]]
--- @param players { Player }
--- @param metadata Match_Metadata
--- @return boolean
function Module.Send(players, metadata, accessCode: string?)
	--[[ Studio Map ]]

	if I.Config.PlaceLoader.MapId == _settings.STUDIO_MAP then
		if I.Match.Host(players, metadata) then
			return true
		end
		Module._tell(players, "A Studio match is still running: wait for it to end.")
		return false
	end

	--[[ Teleporting ]]

	I.Transition.SetDestination(players, Module.GetDestination(_settings.DESTINATION_KICKER, metadata.MapId, metadata.Mode, metadata.Size))

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		if accessCode then
			return I.TeleportToServer(players, I.Config.PlaceLoader.MatchPlaceId, nil, accessCode, _settings.TELEPORT_GUI)
		end
		return I.Teleport(players, I.Config.PlaceLoader.MatchPlaceId, "Match", metadata, _settings.TELEPORT_GUI)
	end)
	if not success or not result then
		warn(`[{_localName}::{script.Name}]: Couldn't send players to match ({metadata.MatchId})! - ({result})`)
		Module._tell(players, "Couldn't start the match. Try again!")
		return false
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Play Solo

--[[
	**SERVER** |
	Starts a 1v1 against one bot at a difficulty, on the map the player picked (when it's in the rotation for 2) or a
	random one. Refused in a party of 2 or more.
]]
--- @return boolean
function Module.PlaySolo(player: Player, difficulty: string, mapId: string)
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

	return Module.Launch({ player }, "Solo", "Deathmatch", 2, Module.GetMap(2, mapId), difficulty)
end

--%%%%%%%%%%%%%%%%%%%% Play Party

--[[
	**SERVER** |
	Starts a friends-only deathmatch for the leader's party: with bots at a difficulty (PARTY_BOTS_PER_PLAYER per member),
	or "None" for the party alone, which pays less, on the map the leader picked (when it's in the rotation for that
	size) or a random one. Refused unless the player leads a party of 2 or more here.
]]
--- @return boolean
function Module.PlayParty(player: Player, difficulty: string, mapId: string)
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

	local size: number = Rotation.GetPlaySize(#members, difficulty)
	return Module.Launch(members, "Party", "Deathmatch", size, Module.GetMap(size, mapId), difficulty)
end

--%%%%%%%%%%%%%%%%%%%% Play Local

--[[
	**SERVER** |
	Starts a local match: the player and 1 to LOCAL_MAX_PLAYERS − 1 guests on their screen (each guest a snail of its
	own, played from the host's screen, named LOCAL_GUEST_NAME), with a bot per player at a difficulty or none, on the
	picked map or a random one, with wind or without (off unless picked: the owner, 2026-11-24). Pays nothing. Refused in
	a party of 2 or more.
]]
--- @return boolean
function Module.PlayLocal(player: Player, difficulty: string, mapId: string, players: number, wind: boolean)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Check if the difficulty exists
	if difficulty ~= "None" and not table.find(_settings.SOLO_DIFFICULTIES, difficulty) then
		return false
	end

	-- Check if the player count is allowed
	if players ~= math.floor(players) or players < 2 or players > _settings.LOCAL_MAX_PLAYERS then
		return false
	end

	-- Check if the player plays alone
	if player:GetAttribute("PartyId") and #I.Party.GetMembers(player:GetAttribute("PartyId")) > 1 then
		Module._tell({ player }, "Local play is for friends on one screen: leave your party first.")
		return false
	end

	--[[ Roster ]]

	local size: number = Rotation.GetPlaySize(players, difficulty)
	local card = I.Matchmaking.GetCard(player) --- @type Matchmaking_Card
	local roster = { { UserId = player.UserId, Card = card } } --- @type { Match_RosterEntry }
	for guest: number = 2, players do
		local guestCard = table.clone(card) --- @type Matchmaking_Card
		guestCard.DisplayName = string.format(_settings.LOCAL_GUEST_NAME, guest)
		table.insert(roster, { UserId = player.UserId, Guest = guest, Card = guestCard })
	end

	--[[ Launching ]]

	return Module.Send({ player }, {
		MatchId = I.S.HttpService:GenerateGUID(false),
		Kind = "Local",
		Mode = "Deathmatch",
		Size = size,
		MapId = Module.GetMap(size, mapId),
		Difficulty = difficulty,
		Wind = wind,
		Roster = roster,
	})
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
	Returns the asked map when it's in MAP_POOL for a match size, else a random one of those (any map in the pool when
	none is made for the size).
]]
--- @return string
function Module.GetMap(size: number, askedId: string?)
	--[[ Local Variables ]]

	local pool = Rotation.GetPool(size) --- @type { string }

	--[[ Returning ]]

	if askedId and table.find(pool, askedId) then
		return askedId
	end
	return pool[random:NextInteger(1, #pool)]
end

--%%%%%%%%%%%%%%%%%%%% Get Destination

--[[
	**SERVER** |
	Returns what the teleport card shows for a match: a line over the map's name, its scene, and the mode with its icon
	and how many snails play.
]]
--- @return Transition_Destination
function Module.GetDestination(kicker: string, mapId: string, mode: string, size: number)
	--[[ Returning ]]

	return {

		--[[ General ]]

		Kicker = kicker,
		Title = _settings.MAPS[mapId].Name,
		MapId = mapId,

		--[[ Match ]]

		Mode = _settings.MODE_NAMES[mode] or mode,
		ModeIcon = _settings.MODE_ICONS[mode],
		Detail = string.format(_settings.DESTINATION_DETAIL, size),
	}
end

return Module
