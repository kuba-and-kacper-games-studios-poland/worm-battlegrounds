--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AFKTeleport"

--- @type AFKTeleport_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local UserInputService = I.S.UserInputService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance | GuiObject }

--[[ General ]]

local moduleGui: ScreenGui

--[[ Timer ]]

local currentTime: number = 0

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

	Module._getElements()
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	-- Do not active AFK Teleport in Studio
	if I.Env.IsStudio then
		return
	end

	-- Do not run in the lobby
	if I.Config.IsLobby then
		return
	end

	--[[ Timer Reset ]]

	UserInputService.InputBegan:Connect(Module._resetTimer)
	UserInputService.InputChanged:Connect(Module._resetTimer)
	UserInputService.InputEnded:Connect(Module._resetTimer)

	--[[ Timer Connection ]]

	Module._mainLoop()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Main Loop

--[[
	Connects the idle timer to the shared timer signal.
]]
function Module._mainLoop()
	--[[ Connections ]]

	I.DoEvery.Get(_settings.TIMER_INTERVAL):Connect(Module._updateTimer)
end

--%%%%%%%%%%%%%%%%%%%% Update Timer

--[[
	Counts idle time and shows the warning countdown for its last seconds.
	Requests the teleport when the countdown runs out, and again after the retry time.
]]
function Module._updateTimer(_elapsed: number, ticks: number)
	--[[ Counting ]]

	currentTime += _settings.TIMER_INTERVAL * ticks

	--[[ Local Variables ]]

	local remainingTime: number = _settings.TELEPORT_REQUEST_TIME - currentTime

	--[[ Warning ]]

	moduleGui.Enabled = remainingTime <= _settings.WARNING_TIME
	elems["Time"].Text = tostring(math.max(remainingTime, 0))

	--[[ Checks ]]

	-- Check if the countdown has run out
	if remainingTime > 0 then
		return
	end

	--[[ Requesting Teleport ]]

	-- Subtracting time for retry call
	currentTime -= _settings.TELEPORT_RETRY_TIME

	-- Requesting teleport
	I.Network.Fire("AFKController_RequestTeleport")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements.
]]
function Module._getElements()
	moduleGui = I.UserInterface.UI["AFKTeleport"]

	--[[ General ]]

	elems["Warning"] = moduleGui:FindFirstChild("U_Warning", true) --- @type Frame
	elems["Time"] = elems["Warning"]:FindFirstChild("S_Time", true) --- @type TextLabel
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Reset Timer

--[[
	Resets the idle timer on any input of the player and hides the warning.
]]
function Module._resetTimer(input: InputObject)
	--[[ Checks ]]

	-- Skip device motion, which changes without the player
	if input.UserInputType == Enum.UserInputType.Accelerometer or input.UserInputType == Enum.UserInputType.Gyro then
		return
	end

	--[[ Resetting ]]

	currentTime = 0
	moduleGui.Enabled = false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
