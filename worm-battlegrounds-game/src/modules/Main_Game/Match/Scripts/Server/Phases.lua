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
local Turns = require(script.Parent:FindFirstChild("Turns")) --- @type Match_Server_Turns
local Placement = require(script.Parent:FindFirstChild("Placement")) --- @type Match_Server_Placement
local Stats = require(script.Parent:FindFirstChild("Stats")) --- @type Match_Server_Stats
local Connection = require(script.Parent:FindFirstChild("Connection")) --- @type Match_Server_Connection
local Rematch = require(script.Parent:FindFirstChild("Rematch")) --- @type Match_Server_Rematch

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local matchFolder: Folder
local random: Random = Random.new()

-- Each participant's landing spot along X, by id
local drops = {} --- @type { [string]: number }

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

--- @class Match_Server_Phases
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init(folder: Folder)
	matchFolder = folder
	Turns.Init(folder, Module.SetPhase)
	Rematch.Init(folder)
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Starting ]]

	task.spawn(Module._mainLoop)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Main Loop

--[[
	Runs the match: waits for its players, plays it to the end, then plays it again with whoever voted for a rematch
	while the rest go back to the lobby. The server empties when nobody votes.
]]
function Module._mainLoop()
	--[[ Waiting ]]

	--- @type Match_Metadata
	local metadata = Roster.GetMetadata()
	matchFolder:SetAttribute("Kind", metadata.Kind)
	matchFolder:SetAttribute("Mode", metadata.Mode)
	matchFolder:SetAttribute("MapId", metadata.MapId)
	Module.SetPhase("Waiting")
	Roster.WaitForPlayers(matchFolder)

	--[[ Playing ]]

	while true do
		Module.Play()

		-- The tutorial match always goes back to the lobby, after the results
		local voters = Rematch.Run() --- @type { Player }
		if metadata.Kind == "Tutorial" then
			voters = {}
		end
		local leaving = {} --- @type { Player }
		for _index: number, player: Player in ipairs(I.S.Players:GetPlayers()) do
			if not table.find(voters, player) then
				table.insert(leaving, player)
			end
		end
		Connection.SendToLobby(leaving)
		if #voters == 0 then
			break
		end
		Roster.SetRematch(voters)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	**SERVER** |
	Plays one match on this server: loads the map, seats the participants, runs the drop and the landing, then turns
	until one team is left, and ends it.
]]
function Module.Play()
	--[[ Loading ]]

	--- @type Match_Metadata
	local metadata = Roster.GetMetadata()
	matchFolder:SetAttribute("MapId", metadata.MapId)
	I.Worms.Clear()
	if not I.Arena.Load(metadata.MapId) then
		return
	end

	--[[ Seating ]]

	Roster.Build()
	local ids = {} --- @type { string }
	--- @param participant Match_Participant
	for _index: number, participant in ipairs(Roster.GetParticipants()) do
		table.insert(ids, participant.Id)
	end
	Stats.Reset(ids)
	Placement.Reset()
	Turns.Reset()

	--[[ Playing ]]

	Module._drop()
	Module._land()
	while not Placement.IsOver() do
		Turns.RunTurn()
	end

	--[[ Ending ]]

	local placements = Placement.GetPlacements() --- @type { Match_Placement }
	--- @param placement Match_Placement
	for _index: number, placement in ipairs(placements) do
		Roster.SetInfo(placement.ParticipantId, "Place", placement.Place)
	end
	Module.SetPhase("Ended")
	I.Topic.Publish("Match_Ended", placements, Stats.Get(), metadata)
end

--%%%%%%%%%%%%%%%%%%%% Set Phase

--[[
	**SERVER** |
	Moves the match to a phase: Waiting, Drop, Landing, Turn, Flight, Settle or Ended.
]]
function Module.SetPhase(phase: string)
	--[[ Saving ]]

	matchFolder:SetAttribute("Phase", phase)

	--[[ Publishing ]]

	I.Topic.Publish("Match_PhaseChanged", phase)
end

--%%%%%%%%%%%%%%%%%%%% Pick Drop

--[[
	Moves a player's landing spot during the drop phase, kept inside the drop zone.
]]
function Module.PickDrop(player: Player, x: number)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Match_Participant?
	local participant = Roster.GetParticipantOf(player)

	--[[ Checks ]]

	-- Check if the drop is running and the player plays
	if matchFolder:GetAttribute("Phase") ~= "Drop" or not participant then
		return
	end

	--[[ Saving ]]

	Module._setDrop(participant.Id, x)
end

--%%%%%%%%%%%%%%%%%%%% Drop

--[[
	The drop phase: everyone starts on a spread-out random spot of the drop zone and has DROP_SECONDS to move it.
]]
function Module._drop()
	--[[ Data ]]

	local zone: BasePart = I.Arena.GetDropZone()
	local participants = Roster.GetParticipants() --- @type { Match_Participant }

	--[[ Local Variables ]]

	local low: number = zone.Position.X - zone.Size.X / 2 + 2
	local high: number = zone.Position.X + zone.Size.X / 2 - 2
	local slots = {} --- @type { number }
	for index: number = 1, #participants do
		table.insert(slots, low + (high - low) * (index - 0.5) / #participants)
	end

	--[[ Saving ]]

	drops = {}
	matchFolder:SetAttribute("DropMinX", low)
	matchFolder:SetAttribute("DropMaxX", high)
	matchFolder:SetAttribute("DropY", zone.Position.Y + zone.Size.Y / 2)
	matchFolder:SetAttribute("DropEndsAt", I.S.Workspace:GetServerTimeNow() + _settings.DROP_SECONDS)

	-- Bots keep their spread-out spot; players start on one and can move it
	--- @param participant Match_Participant
	for _index: number, participant in ipairs(participants) do
		Module._setDrop(participant.Id, table.remove(slots, random:NextInteger(1, #slots)))
	end

	--[[ Waiting ]]

	Module.SetPhase("Drop")
	task.wait(_settings.DROP_SECONDS)
end

--%%%%%%%%%%%%%%%%%%%% Land

--[[
	The landing: every worm appears at the top of the drop zone over its spot with its parachute open, and the match
	waits until they all landed (or went out), MAX_LANDING seconds at most.
]]
function Module._land()
	--[[ Local Variables ]]

	local height: number = matchFolder:GetAttribute("DropY")

	--[[ Spawning ]]

	--- @param participant Match_Participant
	for _index: number, participant in ipairs(Roster.GetParticipants()) do
		I.Worms.Spawn(participant, Vector3.new(drops[participant.Id], height, 0))
		I.WormControl.ApplyEffect(participant.Id, "Parachute")
	end
	Module.SetPhase("Landing")

	--[[ Waiting ]]

	local deadline: number = os.clock() + _settings.MAX_LANDING
	while os.clock() < deadline do
		local landing: boolean = false
		for _index: number, model: Model in ipairs(I.Worms.GetAlive()) do
			if model:GetAttribute("Parachute") then
				landing = true
				break
			end
		end
		if not landing then
			break
		end
		task.wait(0.1)
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Drop

--[[
	Saves a participant's landing spot, clamped to the drop zone, and shows it on their entry for the drop markers.
]]
function Module._setDrop(participantId: string, x: number)
	--[[ Local Variables ]]

	local clamped: number = math.clamp(x, matchFolder:GetAttribute("DropMinX"), matchFolder:GetAttribute("DropMaxX"))

	--[[ Saving ]]

	drops[participantId] = clamped
	Roster.SetInfo(participantId, "DropX", clamped)
end

return Module
