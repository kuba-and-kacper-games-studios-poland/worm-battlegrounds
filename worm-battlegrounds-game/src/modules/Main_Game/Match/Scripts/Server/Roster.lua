--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Match"

--- @type Match_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Match ]]

--- @type Match_Metadata
local metadata = nil

-- Whether a lobby sent the roster (with the teleport, or through I.Match.Host on the Studio map)
local fromLobby: boolean = false

-- Every participant by id, and their ids in the order they joined the roster
local participants = {} --- @type { [string]: Match_Participant }
local order = {} --- @type { string }

--[[ World ]]

local participantsFolder: Folder

-- The players of a rematch, who play instead of the roster
local rematchPlayers = nil --- @type { Player }?

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

--- @class Match_Server_Roster
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init(matchFolder: Folder)
	--[[ Building ]]

	participantsFolder = I.Create("Folder")({
		Name = "Participants",
		Parent = matchFolder,
	})

	--[[ Saving ]]

	-- Match servers get their match from the lobby's teleport; the Match map alone in Studio plays STUDIO_METADATA
	metadata = I.Config.Metadata or _settings.STUDIO_METADATA
	fromLobby = I.Config.Metadata ~= nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Wait For Players

--[[
	Waits until every player in the roster is ready (in the server with their data loaded), or WAIT_FOR_PLAYERS
	seconds pass. On the Match map alone in Studio, where every test player plays, it waits STUDIO_WAIT seconds after
	the first one arrives. Writes the counts the waiting overlay shows.
]]
function Module.WaitForPlayers(matchFolder: Folder)
	--[[ Studio ]]

	if not fromLobby then
		while #I.S.Players:GetPlayers() == 0 do
			task.wait(0.2)
		end
		task.wait(_settings.STUDIO_WAIT)
		return
	end

	--[[ Waiting ]]

	local deadline: number = os.clock() + _settings.WAIT_FOR_PLAYERS
	while os.clock() < deadline do
		local arrived: number = 0
		--- @param entry Match_RosterEntry
		for _index: number, entry in ipairs(metadata.Roster) do
			-- A teleported player's data loads a few seconds after they join, and seating reads it
			if I.Player.Valid(I.S.Players:GetPlayerByUserId(entry.UserId)) then
				arrived += 1
			end
		end
		matchFolder:SetAttribute("Arrived", arrived)
		matchFolder:SetAttribute("Expected", #metadata.Roster)
		if arrived >= #metadata.Roster then
			return
		end
		task.wait(0.25)
	end
end

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Makes the match's participants: the roster's players who are ready (every player on the Match map alone in Studio),
	on the teams the lobby gave them or the first with room, then bots for every empty place up to the match's size
	(a custom match, or a party match without bots, drops its missing players instead; in Studio a custom match gets
	bots too, so one tester can play it). Gives everyone a colour, makes the Roblox teams in team modes,
	and writes each participant into Workspace.Ume.Match.Participants.
]]
function Module.Build()
	--[[ Clearing ]]

	Module.Clear()

	--[[ Local Variables ]]

	local teamSize: number = Module._getTeamSize()
	local teamCount: number = math.max(math.floor(metadata.Size / teamSize), 1)
	local filled = table.create(teamCount, 0) --- @type { number }

	-- The players to seat, in roster order (the Match map alone in Studio: everyone present)
	local players = {} --- @type { Player }
	local wanted = {} --- @type { [number]: number? }
	if rematchPlayers then
		players = rematchPlayers
	elseif fromLobby then
		--- @param entry Match_RosterEntry
		for _index: number, entry in ipairs(metadata.Roster) do
			local player: Player? = I.S.Players:GetPlayerByUserId(entry.UserId)
			if player then
				table.insert(players, player)
				wanted[entry.UserId] = entry.Team
			end
		end
	else
		players = I.S.Players:GetPlayers()
	end

	--[[ Players ]]

	for _index: number, player: Player in ipairs(players) do
		-- Skip a player whose data hasn't loaded: their loadout and skin can't be read yet
		if not I.Player.Valid(player) then
			continue
		end

		local team: number? = Module._getTeamWithRoom(filled, teamSize, wanted[player.UserId])
		if not team then
			break
		end

		-- What they take into the match: their loadout and their skin, chosen in the lobby
		local items = {} --- @type { string }
		local shinyItems = {} --- @type { [string]: boolean }
		local skinId: string
		local skinShiny: boolean
		items, shinyItems = I.Loadout.GetMatchLoadout(player)
		skinId, skinShiny = I.Cosmetics.GetSkin(player)

		--- @type Match_Participant
		local participant = {
			Id = `P_{player.UserId}`,
			UserId = player.UserId,
			DisplayName = player.DisplayName,
			Team = team,
			Color = Color3.new(),
			IsBot = false,
			Loadout = items,
			ShinyItems = shinyItems,
			Skin = skinId,
			Shiny = skinShiny,
			Vip = player:GetAttribute("Vip") == true,
			Level = player:GetAttribute("Level") or 0,
			Connected = true,
			Out = false,
		}
		Module._add(participant, filled)
	end

	--[[ Bots ]]

	if (metadata.Kind ~= "Custom" or I.S.RunService:IsStudio()) and metadata.Difficulty ~= "None" then
		while #order < metadata.Size do
			local team: number? = Module._getTeamWithRoom(filled, teamSize, nil)
			if not team then
				break
			end
			local bot = I.Bots.CreateParticipant(metadata.Difficulty, #order + 1) --- @type Match_Participant
			bot.Team = team
			Module._add(bot, filled)
		end
	end

	--[[ Teams ]]

	for _index: number, id: string in ipairs(order) do
		--- @type Match_Participant
		local participant = participants[id]
		participant.Color = if teamSize > 1 then _settings.TEAMS[participant.Team].Color else _settings.FFA_COLORS[(participant.Team - 1) % #_settings.FFA_COLORS + 1]
		if teamSize > 1 and not participant.IsBot then
			--- @type Match_TeamStyle
			local style = _settings.TEAMS[participant.Team]
			I.Team.Create(style.Name, style.Color, false)
			I.Team.Assign(I.S.Players:GetPlayerByUserId(participant.UserId), style.Name)
		end
		Module._write(participant)
	end
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	Forgets every participant and removes their entries from Workspace.Ume.Match.Participants.
]]
function Module.Clear()
	--[[ Clearing ]]

	participants = {}
	order = {}
	participantsFolder:ClearAllChildren()
end

--%%%%%%%%%%%%%%%%%%%% Set Rematch

--[[
	Seats these players in the next match instead of the roster: the players who voted for a rematch.
]]
--- @param players { Player }
function Module.SetRematch(players)
	--[[ Saving ]]

	rematchPlayers = players
end

--%%%%%%%%%%%%%%%%%%%% Set Metadata

--[[
	Plays a match the lobby handed to this server (the Studio map): its roster seats, and no rematch players yet.
]]
--- @param newMetadata Match_Metadata
function Module.SetMetadata(newMetadata)
	--[[ Saving ]]

	metadata = newMetadata
	fromLobby = true
	rematchPlayers = nil
end

--%%%%%%%%%%%%%%%%%%%% Set Info

--[[
	Writes one of a participant's values that clients show (DropX, DropY, Placed, Out, Place, Connected) onto their entry.
]]
function Module.SetInfo(participantId: string, name: string, value: any)
	--[[ Data ]]

	local entry: Instance? = participantsFolder:FindFirstChild(participantId)
	if not entry then
		return
	end

	--[[ Saving ]]

	entry:SetAttribute(name, value)
end

--%%%%%%%%%%%%%%%%%%%% Add

--[[
	Seats a participant on its team.
]]
--- @param participant Match_Participant
--- @param filled { number }
function Module._add(participant, filled)
	--[[ Saving ]]

	participants[participant.Id] = participant
	table.insert(order, participant.Id)
	filled[participant.Team] += 1
end

--%%%%%%%%%%%%%%%%%%%% Write

--[[
	Writes a participant's entry, which clients read for names, colours, drop markers and results.
]]
--- @param participant Match_Participant
function Module._write(participant)
	--[[ Building ]]

	local entry: Configuration = I.Create("Configuration")({
		Name = participant.Id,
	})
	entry:SetAttribute("DisplayName", participant.DisplayName)
	entry:SetAttribute("UserId", participant.UserId)
	entry:SetAttribute("Team", participant.Team)
	entry:SetAttribute("Color", participant.Color)
	entry:SetAttribute("IsBot", participant.IsBot)
	entry:SetAttribute("Out", false)
	entry:SetAttribute("Connected", true)
	entry.Parent = participantsFolder
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Metadata

--[[
	Returns the match this server plays.
]]
--- @return Match_Metadata
function Module.GetMetadata()
	return metadata
end

--%%%%%%%%%%%%%%%%%%%% Get Participant

--[[
	Returns a participant by id.
]]
--- @return Match_Participant?
function Module.GetParticipant(participantId: string)
	return participants[participantId]
end

--%%%%%%%%%%%%%%%%%%%% Get Participant Of

--[[
	Returns a player's participant.
]]
--- @return Match_Participant?
function Module.GetParticipantOf(player: Player)
	return participants[`P_{player.UserId}`]
end

--%%%%%%%%%%%%%%%%%%%% Get Participants

--[[
	Returns every participant, in roster order.
]]
--- @return { Match_Participant }
function Module.GetParticipants()
	--[[ Local Variables ]]

	local list = {} --- @type { Match_Participant }
	for _index: number, id: string in ipairs(order) do
		table.insert(list, participants[id])
	end

	--[[ Returning ]]

	return list
end

--%%%%%%%%%%%%%%%%%%%% Get Team Size

--[[
	Returns how many snails a team has in this match's mode (a custom Teams match splits the size in two).
]]
--- @return number
function Module._getTeamSize()
	--[[ Returning ]]

	if metadata.Mode == "Teams" then
		return math.max(math.floor(metadata.Size / 2), 1)
	end
	return _settings.TEAM_SIZES[metadata.Mode] or 1
end

--%%%%%%%%%%%%%%%%%%%% Get Team With Room

--[[
	Returns the team a participant sits on: the one asked for when it has room, else the first with room, or nil when
	the match is full.
]]
--- @param filled { number }
--- @return number?
function Module._getTeamWithRoom(filled, teamSize: number, wanted: number?)
	--[[ Checks ]]

	-- Check if the team asked for has room
	if wanted and filled[wanted] and filled[wanted] < teamSize then
		return wanted
	end

	--[[ Searching ]]

	for team: number, count: number in ipairs(filled) do
		if count < teamSize then
			return team
		end
	end

	--[[ Returning ]]

	return nil
end

return Module
