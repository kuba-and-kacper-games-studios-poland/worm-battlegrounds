--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Match"

--- @type Match_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts: Folder = script.Parent:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local DropPicker = require(_scripts:FindFirstChild("Client"):FindFirstChild("DropPicker")) --- @type Match_Client_DropPicker

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local matchFolder: Folder
local wasMyTurn: boolean = false

-- How far the drawing clock is from the local clock, and when it was last read (os.clock)
local drawOffset: number? = nil
local drawReadAt: number = 0

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

	matchFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Match_PhaseChanged", { "string" })
	I.Topic.Register("Match_TurnStarted", { "string" })
	I.Topic.Register("Match_MyTurn", { "boolean" })

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Match = {

		--[[ Methods ]]

		GetFolder = Module.GetFolder,
		GetPhase = Module.GetPhase,
		GetActive = Module.GetActive,
		GetMyParticipantId = Module.GetMyParticipantId,
		GetParticipantInfo = Module.GetParticipantInfo,
		IsMyTurn = Module.IsMyTurn,
		GetDrawTime = Module.GetDrawTime,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Module._createConnections()
	DropPicker.Start(matchFolder)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Republishes the match's attributes as client Topics: the phase, each turn, and whether it's the local player's.
]]
function Module._createConnections()
	--[[ Connections ]]

	matchFolder:GetAttributeChangedSignal("Phase"):Connect(function()
		I.Topic.Publish("Match_PhaseChanged", Module.GetPhase())
	end)

	matchFolder:GetAttributeChangedSignal("ActiveId"):Connect(function()
		local activeId: string? = Module.GetActive()
		if activeId then
			I.Topic.Publish("Match_TurnStarted", activeId)
		end
		if Module.IsMyTurn() ~= wasMyTurn then
			wasMyTurn = Module.IsMyTurn()
			I.Topic.Publish("Match_MyTurn", wasMyTurn)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Folder

--[[
	**CLIENT** |
	Returns Workspace.Ume.Match, whose attributes hold the match's state.
]]
--- @return Folder
function Module.GetFolder()
	return matchFolder
end

--%%%%%%%%%%%%%%%%%%%% Get Phase

--[[
	**CLIENT** |
	Returns the match's phase: Waiting, Drop, Landing, Turn, Flight, Settle or Ended.
]]
--- @return string
function Module.GetPhase()
	return matchFolder:GetAttribute("Phase") or "Waiting"
end

--%%%%%%%%%%%%%%%%%%%% Get Active

--[[
	**CLIENT** |
	Returns the id of the participant whose turn it is, or nil between turns.
]]
--- @return string?
function Module.GetActive()
	--[[ Local Variables ]]

	local activeId: string? = matchFolder:GetAttribute("ActiveId")

	--[[ Returning ]]

	return if activeId and activeId ~= "" then activeId else nil
end

--%%%%%%%%%%%%%%%%%%%% Get My Participant Id

--[[
	**CLIENT** |
	Returns the local player's participant id.
]]
--- @return string
function Module.GetMyParticipantId()
	return `P_{I.S.Players.LocalPlayer.UserId}`
end

--%%%%%%%%%%%%%%%%%%%% Get Participant Info

--[[
	**CLIENT** |
	Returns a participant's entry, whose attributes hold their name, team, colour, drop spot, place and whether
	they're out.
]]
--- @return Configuration?
function Module.GetParticipantInfo(participantId: string)
	return matchFolder:FindFirstChild("Participants"):FindFirstChild(participantId)
end

--%%%%%%%%%%%%%%%%%%%% Is My Turn

--[[
	**CLIENT** |
	Returns whether it's the local player's snail's turn, played by them (not by a bot while they were away).
]]
--- @return boolean
function Module.IsMyTurn()
	return Module.GetActive() == Module.GetMyParticipantId() and not matchFolder:GetAttribute("Autopilot")
end

--%%%%%%%%%%%%%%%%%%%% Get Draw Time

--[[
	**CLIENT** |
	Returns the server's clock for drawing what moves on it (shots, thrown snails, falling ground): it runs at the local
	clock's steady rate and eases toward the server's over DRAW_CLOCK_EASE seconds, so it never stands still or steps
	back when the client's estimate of the server's clock is corrected; one off by DRAW_CLOCK_SNAP or more jumps to it.
]]
--- @return number
function Module.GetDrawTime()
	--[[ Local Variables ]]

	local now: number = os.clock()
	local target: number = I.S.Workspace:GetServerTimeNow() - now

	--[[ Easing ]]

	if not drawOffset or math.abs(target - drawOffset) >= _settings.DRAW_CLOCK_SNAP then
		drawOffset = target
	else
		drawOffset += (target - drawOffset) * (1 - math.exp(-(now - drawReadAt) / _settings.DRAW_CLOCK_EASE))
	end
	drawReadAt = now

	--[[ Returning ]]

	return now + drawOffset
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
