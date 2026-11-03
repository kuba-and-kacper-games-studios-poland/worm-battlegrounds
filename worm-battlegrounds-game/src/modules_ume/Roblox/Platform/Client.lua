--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Platform"

--- @type Platform_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local UserInputService = I.S.UserInputService
local GuiService = I.S.GuiService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[
    Last input method.
]]
local lastInput: "Keyboard" | "Touchscreen" | "Gamepad" = "Keyboard"

--[[
	**CLIENT** |
    Current platform the client is on.
]]
--- @type "Desktop" | "Mobile" | "Console" | "VR"
local platform = "Desktop"

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

	--[[ Device Type Changed ]]

	UserInputService.GamepadConnected:Connect(Module._get)
	UserInputService.GamepadDisconnected:Connect(Module._get)
	UserInputService.TouchStarted:Connect(Module._get)

	--[[ Input Type Changed ]]

	UserInputService.LastInputTypeChanged:Connect(Module._trackLastInputType)

	--[[ Checking ]]

	I.DoEvery.Get(_settings.INPUT_CHECK_DELAY):Connect(Module._get)

	--[[ Framework Loaded ]]

	I.OnLoaded(I.Priority.Setup, Module._reportPlatform)
	I.OnLoaded(I.Priority.Late, function()
		I.Topic.Publish("Platform_Changed", platform)
	end)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Platform_Changed", { "string" })
	I.Topic.Register("Platform_InputChanged", { "string" })

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Platform = {

		--[[ Data ]]

		Current = platform,
		LastInput = lastInput,
	}

	----------------------------
	-------- POST-INIT ---------
	----------------------------

	Module._get()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Report Platform

--[[
	Sends the current platform to the server once the player has loaded there.
]]
function Module._reportPlatform()
	--[[ Sending ]]

	I.Network.Fire("Platform_Changed", platform)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Get

--[[
    Runs a bunch of checks to get the current platform.
]]
function Module._get()
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Enabled Variables

	--[[ Desktop Variables ]]

	-- local keyboardEnabled: boolean = UserInputService.KeyboardEnabled
	local mouseEnabled: boolean = UserInputService.MouseEnabled

	--[[ Console Variables ]]

	local gamepadEnabled: boolean = UserInputService.GamepadEnabled
	local tenFootInterface: boolean = GuiService:IsTenFootInterface()

	--[[ Mobile Variables ]]

	local touchEnabled: boolean = UserInputService.TouchEnabled
	local gyroscopeEnabled: boolean = UserInputService.GyroscopeEnabled
	local accelerometerEnabled: boolean = UserInputService.AccelerometerEnabled

	--[[ VR ]]

	local vrEnabled: boolean = UserInputService.VREnabled and I.Config.Map.VRSupport

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Device Type Variables

	local desktop = false
	local mobile = false
	local console = false
	local vr = false

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Update Functions

	local function consoleSet()
		console = true
	end

	local function mobileSet()
		if not gyroscopeEnabled then
			if accelerometerEnabled then
				mobile = true
			else
				desktop = true
			end
		else
			mobile = true
		end
	end

	local function vrSet()
		vr = true
		desktop = not false
	end

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Device Check

	-- Gamepad
	if gamepadEnabled then
		if lastInput == "Keyboard" then
			desktop = true
		elseif lastInput == "Touchscreen" then
			mobileSet()
		else
			consoleSet()
		end
	-- Console
	elseif tenFootInterface then
		if not mouseEnabled then
			consoleSet()
		elseif vrEnabled then
			vrSet()
		elseif touchEnabled then
			if not mouseEnabled then
				mobile = true
			else
				mobileSet()
			end
		else
			mobileSet()
		end
	-- VR
	elseif vrEnabled then
		vrSet()
	-- Mobile
	elseif touchEnabled then
		if not mouseEnabled then
			mobile = true
		else
			mobileSet()
		end
	else
		mobileSet()
	end

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Platform Update

	if desktop then
		if vr then
			Module._changed("VR")
		elseif console then
			Module._changed("Console")
		elseif mobile then
			Module._changed("Mobile")
		else
			Module._changed("Desktop")
		end
	elseif mobile then
		if vr then
			Module._changed("VR")
		elseif console then
			Module._changed("Console")
		else
			Module._changed("Mobile")
		end
	elseif console then
		if vr then
			Module._changed("VR")
		else
			Module._changed("Console")
		end
	elseif vr then
		Module._changed("VR")
	else
		Module._changed("Desktop")
	end
end

--%%%%%%%%%%%%%%%%%%%% Track Last Input Type

--[[
	Saves the kind of input used last and publishes it when it changes.
	Requests a platform update when it changed.
]]
function Module._trackLastInputType(input: Enum.UserInputType)
	--[[ Local Variables ]]

	local previousInput: string = lastInput

	--[[ Finding ]]

	-- Mouse input counts as Keyboard
	if input.Name == "Keyboard" or string.find(input.Name, "Mouse") then
		lastInput = "Keyboard"
	elseif input.Name == "Touch" then
		lastInput = "Touchscreen"
	elseif string.find(input.Name, "Gamepad") then
		lastInput = "Gamepad"
	end

	--[[ Checks ]]

	-- Skip when the input kind did not change
	if lastInput == previousInput then
		return
	end

	--[[ Saving ]]

	I.Platform.LastInput = lastInput

	--[[ Publishing ]]

	I.Topic.Publish("Platform_InputChanged", lastInput)

	--[[ Updating ]]

	Module._get()
end

--%%%%%%%%%%%%%%%%%%%% Changed

--[[
    Updates platform and publishes changes.
]]
function Module._changed(newPlatform: string)
	if platform ~= newPlatform then
		-- Invalid platform
		if not table.find(_settings.PLATFORMS, newPlatform) then
			return
		end

		--[[ Updating Platform ]]

		platform = newPlatform
		I.Platform.Current = platform

		--[[ Publishing Changes ]]

		I.Topic.Publish("Platform_Changed", newPlatform)
		I.Network.Fire("Platform_Changed", newPlatform)
	end
end
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
