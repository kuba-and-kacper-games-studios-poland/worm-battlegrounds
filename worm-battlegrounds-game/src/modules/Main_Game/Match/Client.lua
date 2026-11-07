--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Match"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts: Folder = script.Parent:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local DropPicker = require(_scripts:FindFirstChild("Client"):FindFirstChild("DropPicker")) --- @type Match_Client_DropPicker

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local matchFolder: Folder
local wasMyTurn: boolean = false

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
	Returns whether it's the local player's snail's turn.
]]
--- @return boolean
function Module.IsMyTurn()
	return Module.GetActive() == Module.GetMyParticipantId()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
