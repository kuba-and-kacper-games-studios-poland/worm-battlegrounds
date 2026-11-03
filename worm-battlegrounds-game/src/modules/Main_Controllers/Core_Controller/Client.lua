--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Core_Controller"

--- @type Core_Controller_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local _characterResetEvent: BindableEvent

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

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	-- Disabling all by default
	I.Core.Call("SetCoreGuiEnabled", Enum.CoreGuiType.All, false)

	--[[ Enabled ]]

	I.OnLoaded(I.Priority.Default, function()
		task.delay(_settings.ENABLE_DELAY, function()
			for _, coreGuiType: Enum.CoreGuiType in ipairs(_settings.ENABLED_CORE_GUIS) do
				I.Core.Call("SetCoreGuiEnabled", coreGuiType, true)
			end
		end)
	end)

	--[[ Reset Character ]]

	_characterResetEvent = Instance.new("BindableEvent")
	I.Core.Call("SetCore", "ResetButtonCallback", _characterResetEvent)
	_characterResetEvent.Event:Connect(function()
		--[[ Debounce ]]

		if I.Debounce.Run("CoreController_ResetButtonCallback", 1) then
			return
		end

		--[[ Getting Humanoid ]]

		local character: Model = I.Env.LocalPlayer.Character
		local humanoid: Humanoid = character and character:FindFirstChildOfClass("Humanoid")

		--[[ Resetting Character ]]

		-- Kill through Health when there is a Humanoid (a spawn ForceField blocks TakeDamage)
		if humanoid then
			humanoid.Health = 0
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
