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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local matchFolder: Folder

-- When each dropped player's worm is knocked out if they don't come back, by participant id
local rejoinDeadlines = {} --- @type { [string]: number }

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

--- @class Match_Server_Connection
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init(folder: Folder)
	--[[ Saving ]]

	matchFolder = folder

	--[[ Network ]]

	I.Network.GetEvent("Match_Leave", { "Player" }, { RateLimit = 1 })
	I.Network.Fired("Match_Leave", Module._onLeave)
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Connections ]]

	I.G_Player.OnPlayerAdded(I.Priority.Default, Module._onPlayerAdded)
	I.G_Player.OnPlayerRemoving(I.Priority.Default, Module._onPlayerRemoving)
	I.S.RunService.Heartbeat:Connect(Module._checkDeadlines)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Send To Lobby

--[[
	Teleports players to a public lobby. Leaving the tutorial match counts as playing it, so the lobby doesn't send
	them straight back. On the Studio map they go back to the lobby on this server; on the Match map alone in Studio,
	which can't teleport, it only says so.
]]
--- @param players { Player }
function Module.SendToLobby(players)
	--[[ Checks ]]

	-- Check if anyone is going
	if #players == 0 then
		return
	end

	--[[ Tutorial ]]

	if Roster.GetMetadata().Kind == "Tutorial" then
		for _index: number, player: Player in ipairs(players) do
			local success: boolean
			local result: any | string?
			success, result = pcall(function()
				if I.Tutorial.CompleteMatch(player) then
					I.Player.GetProfile(player):Save()
				end
			end)
			if not success then
				warn(`[{_localName}::{script.Name}]: Failed to complete the tutorial for ({player.Name})! - ({result})`)
			end
		end
	end

	--[[ Studio Map ]]

	if Module.IsStudioMap() then
		for _index: number, player: Player in ipairs(players) do
			player:SetAttribute("InMatch", false)
			I.Team.Assign(player, nil)
		end
		return
	end

	--[[ Teleporting ]]

	I.Transition.SetDestination(players, "Back to the lobby…", "")
	I.TeleportExternal(players, I.Config.PlaceLoader.DefaultPlaceId, "TeleportGui")
end

--%%%%%%%%%%%%%%%%%%%% Bring

--[[
	Brings players from the Studio map's lobby into its match, so they see the match's screens.
]]
--- @param players { Player }
function Module.Bring(players)
	--[[ Saving ]]

	for _index: number, player: Player in ipairs(players) do
		player:SetAttribute("InMatch", true)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Leave

--[[
	A player pressed Leave game (or Leave on the knocked-out panel): a worm still in play is knocked out as a leaver,
	which places it last among those still alive, and the player goes back to the lobby.
]]
function Module._onLeave(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Leaving ]]

	Module._knockOutLeaver(Roster.GetParticipantOf(player))
	Module.SendToLobby({ player })
end

--%%%%%%%%%%%%%%%%%%%% On Player Removing

--[[
	A player dropped: their worm stays and skips its turns for REJOIN_SECONDS, and their profile remembers the match
	so the lobby can offer to send them back.
]]
function Module._onPlayerRemoving(player: Player)
	--[[ Data ]]

	local participant = Roster.GetParticipantOf(player) --- @type Match_Participant?
	if not participant or participant.Out or matchFolder:GetAttribute("Phase") == "Ended" then
		return
	end

	--[[ Saving ]]

	participant.Connected = false
	Roster.SetInfo(participant.Id, "Connected", false)
	rejoinDeadlines[participant.Id] = os.clock() + _settings.REJOIN_SECONDS

	--[[ Remembering ]]

	local profile = I.Player.GetProfile(player) --- @type any
	if profile and I.Config.Metadata and I.Config.Metadata.AccessCode then
		profile.Data["Match"]["Rejoin"] = {

			--[[ General ]]

			PlaceId = game.PlaceId,
			AccessCode = I.Config.Metadata.AccessCode,
			Until = os.time() + _settings.REJOIN_SECONDS,
		}
	end
end

--%%%%%%%%%%%%%%%%%%%% On Player Added

--[[
	A dropped player came back in time: their worm is theirs again from its next turn.
]]
function Module._onPlayerAdded(player: Player)
	--[[ Data ]]

	local participant = Roster.GetParticipantOf(player) --- @type Match_Participant?
	local profile = I.Player.GetProfile(player) --- @type any

	--[[ Clearing ]]

	if profile then
		profile.Data["Match"]["Rejoin"] = false
	end

	--[[ Location ]]

	-- Everyone on a match server is in the match; the Studio map brings players in when its lobby starts one
	if not Module.IsStudioMap() then
		player:SetAttribute("InMatch", true)
	end

	--[[ Strangers ]]

	-- A match server only takes the players its lobby sent
	if not participant and I.Config.Metadata and not Module._isInRoster(player.UserId) then
		Module.SendToLobby({ player })
		return
	end

	--[[ Checks ]]

	-- Check if they were dropped from this match
	if not participant or participant.Connected or participant.Out then
		return
	end

	--[[ Saving ]]

	participant.Connected = true
	rejoinDeadlines[participant.Id] = nil
	Roster.SetInfo(participant.Id, "Connected", true)
end

--%%%%%%%%%%%%%%%%%%%% Check Deadlines

--[[
	Knocks out the worms of players who didn't come back within REJOIN_SECONDS, as leavers.
]]
function Module._checkDeadlines()
	--[[ Checking ]]

	for participantId: string, deadline: number in pairs(rejoinDeadlines) do
		if os.clock() >= deadline and Module._isRunning() then
			rejoinDeadlines[participantId] = nil
			Module._knockOutLeaver(Roster.GetParticipant(participantId))
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Knock Out Leaver

--[[
	Knocks out a leaver's worm when it's still in play in a running match.
]]
--- @param participant Match_Participant?
function Module._knockOutLeaver(participant)
	--[[ Checks ]]

	-- Check if the worm is still in play
	if not participant or participant.Out or not Module._isRunning() then
		return
	end

	--[[ Knocking Out ]]

	participant.Connected = false
	I.Worms.Kill(participant.Id, "Left")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Players In Match

--[[
	Returns the players in the match (the InMatch Player attribute): everyone on a match server, and on the Studio map
	those its lobby brought in.
]]
--- @return { Player }
function Module.GetPlayersInMatch()
	--[[ Searching ]]

	local players = {} --- @type { Player }
	for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
		if player:GetAttribute("InMatch") then
			table.insert(players, player)
		end
	end

	--[[ Returning ]]

	return players
end

--%%%%%%%%%%%%%%%%%%%% Is Studio Map

--[[
	Returns whether this server is the Studio map, which plays the lobby and its matches together.
]]
--- @return boolean
function Module.IsStudioMap()
	return I.Config.PlaceLoader.MapId == _settings.STUDIO_MAP
end

--%%%%%%%%%%%%%%%%%%%% Is In Roster

--[[
	Returns whether a user is in the roster the lobby sent with this match.
]]
--- @return boolean
function Module._isInRoster(userId: number)
	--[[ Searching ]]

	--- @param entry Match_RosterEntry
	for _index: number, entry in ipairs(I.Config.Metadata.Roster) do
		if entry.UserId == userId then
			return true
		end
	end

	--[[ Returning ]]

	return false
end

--%%%%%%%%%%%%%%%%%%%% Is Running

--[[
	Returns whether worms are in play: between the drop and the end.
]]
--- @return boolean
function Module._isRunning()
	--[[ Local Variables ]]

	local phase: string = matchFolder:GetAttribute("Phase") or "Waiting"

	--[[ Returning ]]

	return phase ~= "Waiting" and phase ~= "Drop" and phase ~= "Ended"
end

return Module
