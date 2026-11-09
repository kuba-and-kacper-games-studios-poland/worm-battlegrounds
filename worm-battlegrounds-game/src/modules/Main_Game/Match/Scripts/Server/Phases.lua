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

-- Each participant's landing spot on the arena's plane, and whether they placed it, by id
local drops = {} --- @type { [string]: Vector2 }
local placed = {} --- @type { [string]: boolean }

-- Whether the Studio map's lobby handed over a match that hasn't finished
local hosted: boolean = false

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
	while the rest go back to the lobby. A match that can't play sends everyone to the lobby. A match server empties
	when nobody votes; the Studio map clears the arena and waits for its lobby's next match. A stray server plays
	nothing.
]]
function Module._mainLoop()
	--[[ Checks ]]

	-- Check if a lobby sent this server a match (Connection sends a stray server's players to the lobby)
	if Connection.IsStray() then
		return
	end

	--[[ Matches ]]

	repeat
		--[[ Waiting ]]

		-- The Studio map's lobby hands over each match
		while Connection.IsStudioMap() and not hosted do
			task.wait(0.2)
		end

		--- @type Match_Metadata
		local metadata = Roster.GetMetadata()
		matchFolder:SetAttribute("Kind", metadata.Kind)
		matchFolder:SetAttribute("Mode", metadata.Mode)
		matchFolder:SetAttribute("MapId", metadata.MapId)
		Module.SetPhase("Waiting")

		-- The map shows while everyone arrives: a party's last member can take a while, and an empty arena looks broken
		I.Snails.Clear()
		local loaded: boolean = I.Arena.Load(metadata.MapId)
		Roster.WaitForPlayers(matchFolder)

		--[[ Playing ]]

		while true do
			local success: boolean
			local result: any | string?
			success, result = pcall(Module.Play, loaded)
			loaded = false

			-- A match that broke would leave its players waiting forever
			if not success or not result then
				warn(`[{_localName}::{script.Name}]: Match ({metadata.Kind} on {metadata.MapId}) couldn't play! - ({result})`)
				Connection.SendToLobby(Connection.GetPlayersInMatch())
				break
			end

			-- The tutorial match counts as played once it ends, and always goes back to the lobby after the results
			if metadata.Kind == "Tutorial" then
				Connection.CompleteTutorial(Connection.GetPlayersInMatch())
			end
			local voters = Rematch.Run() --- @type { Player }
			if metadata.Kind == "Tutorial" then
				voters = {}
			end
			local leaving = {} --- @type { Player }
			for _index: number, player: Player in ipairs(Connection.GetPlayersInMatch()) do
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

		--[[ Clearing ]]

		I.Snails.Clear()
		Roster.Clear()
		Module.SetPhase("Waiting")
		hosted = false
	until not Connection.IsStudioMap()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	**SERVER** |
	Plays one match on this server: loads the map (unless `loaded` says it's fresh), seats the participants, runs the
	drop and the landing, then turns until one team is left, and ends it. Returns false when the map didn't load.
]]
--- @return boolean
function Module.Play(loaded: boolean?)
	--[[ Loading ]]

	--- @type Match_Metadata
	local metadata = Roster.GetMetadata()
	matchFolder:SetAttribute("MapId", metadata.MapId)
	if not loaded then
		I.Snails.Clear()
		if not I.Arena.Load(metadata.MapId) then
			return false
		end
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
		-- The Studio map drops a match every player left, so its lobby can start another
		if Connection.IsStudioMap() and #Connection.GetPlayersInMatch() == 0 then
			Module.SetPhase("Ended")
			return true
		end
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

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Host

--[[
	**SERVER** |
	Plays a match the Studio map's lobby hands over, on this server: its players leave the lobby's screens for the
	match's. Refused anywhere but the Studio map, and while another match plays. Returns whether it started.
]]
--- @param players { Player }
--- @param metadata Match_Metadata
--- @return boolean
function Module.Host(players, metadata)
	--[[ Checks ]]

	-- Check if this server can take a match now
	if not Connection.IsStudioMap() or hosted then
		return false
	end

	--[[ Hosting ]]

	Roster.SetMetadata(metadata)
	Connection.Bring(players)
	hosted = true

	--[[ Returning ]]

	return true
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
	Places a player's landing spot during the drop phase: anywhere in the play area a snail fits, out of walls and
	liquid. A spot that doesn't fit is ignored.
]]
function Module.PickDrop(player: Player, x: number, y: number)
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

	-- Check if the spot is a number pair
	if x ~= x or y ~= y then
		return
	end

	-- Check if a snail fits there
	local spot: Vector2 = Vector2.new(x, y)
	if not I.Arena.IsFree(Vector3.new(spot.X, spot.Y, 0), I.Settings["Snails"].ROOT_SIZE / 2) then
		return
	end

	--[[ Saving ]]

	placed[participant.Id] = true
	Roster.SetInfo(participant.Id, "Placed", true)
	Module._setDrop(participant.Id, spot)
end

--%%%%%%%%%%%%%%%%%%%% Drop

--[[
	The drop phase: everyone gets a spread-out random spot in the sky over land, and players have DROP_SECONDS to place
	theirs anywhere in the play area; it ends early once every connected player has placed.
]]
function Module._drop()
	--[[ Data ]]

	local bounds: BasePart = I.Arena.GetBounds()
	local participants = Roster.GetParticipants() --- @type { Match_Participant }
	local spots = I.Arena.GetLandSpots(#participants, I.Settings["Snails"].ROOT_SIZE / 2) --- @type { Vector3 }

	--[[ Checks ]]

	-- Check if the map has land for everyone to start on
	if #spots == 0 then
		warn(`[{_localName}::{script.Name}]: Map ({matchFolder:GetAttribute("MapId")}) has no land to start snails on - using the top of its bounds!`)
		table.insert(spots, bounds.Position + Vector3.new(0, bounds.Size.Y / 2 - I.Settings["Arena"].START_TOP_GAP, 0))
	end

	--[[ Saving ]]

	drops = {}
	placed = {}
	matchFolder:SetAttribute("DropMinX", bounds.Position.X - bounds.Size.X / 2)
	matchFolder:SetAttribute("DropMaxX", bounds.Position.X + bounds.Size.X / 2)
	matchFolder:SetAttribute("DropMinY", bounds.Position.Y - bounds.Size.Y / 2)
	matchFolder:SetAttribute("DropMaxY", bounds.Position.Y + bounds.Size.Y / 2 - I.Settings["Arena"].START_TOP_GAP)
	matchFolder:SetAttribute("DropEndsAt", I.S.Workspace:GetServerTimeNow() + _settings.DROP_SECONDS)

	-- Bots pick their land (the tutorial bot keeps its own); players start on one and can place their own (spots repeat when there are too few)
	local taken = {} --- @type { Vector3 }
	--- @param participant Match_Participant
	for index: number, participant in ipairs(participants) do
		local picks: boolean = participant.IsBot and participant.Difficulty ~= "Tutorial"
		local spot: Vector3 = if picks then I.Bots.GetStart(participant.Difficulty or "Easy", spots, taken) else spots[(index - 1) % #spots + 1]
		table.insert(taken, spot)
		placed[participant.Id] = participant.IsBot
		Roster.SetInfo(participant.Id, "Placed", participant.IsBot)
		Module._setDrop(participant.Id, Module._getSkySpot(spot))
	end

	--[[ Waiting ]]

	Module.SetPhase("Drop")
	local deadline: number = os.clock() + _settings.DROP_SECONDS
	while os.clock() < deadline and not Module._isEveryonePlaced() do
		task.wait(0.1)
	end

	-- Stops the drop timer on screen when everyone placed early
	matchFolder:SetAttribute("DropEndsAt", I.S.Workspace:GetServerTimeNow())
end

--%%%%%%%%%%%%%%%%%%%% Land

--[[
	The landing: every snail appears on its spot with its parachute open, and the match waits until they all landed (or
	went out), MAX_LANDING seconds at most.
]]
function Module._land()
	--[[ Spawning ]]

	--- @param participant Match_Participant
	for _index: number, participant in ipairs(Roster.GetParticipants()) do
		local spot: Vector2 = drops[participant.Id]
		I.Snails.Spawn(participant, Vector3.new(spot.X, spot.Y, 0))
		I.SnailControl.ApplyEffect(participant.Id, "Parachute")
	end
	Module.SetPhase("Landing")

	--[[ Waiting ]]

	local deadline: number = os.clock() + _settings.MAX_LANDING
	while os.clock() < deadline do
		local landing: boolean = false
		for _index: number, model: Model in ipairs(I.Snails.GetAlive()) do
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
	Saves a participant's landing spot and shows it on their entry for the drop markers.
]]
function Module._setDrop(participantId: string, spot: Vector2)
	--[[ Saving ]]

	drops[participantId] = spot
	Roster.SetInfo(participantId, "DropX", spot.X)
	Roster.SetInfo(participantId, "DropY", spot.Y)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Sky Spot

--[[
	Returns where a snail parachutes from onto a land spot: DROP_HEIGHT above it, or lower where terrain over it (a
	floating ledge) or the top of the play area is in the way.
]]
--- @return Vector2
function Module._getSkySpot(land: Vector3)
	--[[ Local Variables ]]

	local radius: number = I.Settings["Snails"].ROOT_SIZE / 2
	local height: number = 0

	--[[ Calculating ]]

	-- Climbs a stud at a time while the way down to the land stays clear
	while height < _settings.DROP_HEIGHT and I.Arena.IsFree(land + Vector3.new(0, height + 1, 0), radius) do
		height += 1
	end

	--[[ Returning ]]

	return Vector2.new(land.X, land.Y + height)
end

--%%%%%%%%%%%%%%%%%%%% Is Everyone Placed

--[[
	Returns whether every connected player in the match has placed their landing spot.
]]
--- @return boolean
function Module._isEveryonePlaced()
	--[[ Checking ]]

	--- @param participant Match_Participant
	for _index: number, participant in ipairs(Roster.GetParticipants()) do
		if participant.Connected and not placed[participant.Id] then
			return false
		end
	end

	--[[ Returning ]]

	return true
end

return Module
