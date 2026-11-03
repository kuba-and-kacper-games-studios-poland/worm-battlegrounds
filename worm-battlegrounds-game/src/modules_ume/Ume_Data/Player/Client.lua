--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Player"

--- @type Player_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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

	I.OnStarted(I.Priority.Late, function()
		-- Register Character Events
		I.Env.LocalPlayer.CharacterAdded:Connect(Module.CharacterAdded)
		I.Env.LocalPlayer.CharacterRemoving:Connect(Module.CharacterRemoving)

		-- Fallback -> Only matters if the `Players.CharacterAutoLoads` is enabled
		if I.Env.LocalPlayer.Character then
			task.spawn(function()
				Module.CharacterAdded(I.Env.LocalPlayer.Character)
			end)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Character Control

--%%%%%%%%%%%%%%%%%%%% Character Added

--[[
	Triggers when the player's character is spawned.
]]
function Module.CharacterAdded(character: Model)
	local humanoid: Humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 60)
	if not humanoid then
		return
	end

	--[[ Wait for all limbs ]]

	for _, limbName: string in ipairs(_settings.LIMB_TREES[humanoid.RigType] or {}) do
		local limb: Instance? = character:FindFirstChild(`{limbName}`) or character:WaitForChild(limbName, _settings.LIMB_WAIT_TIMEOUT)

		-- Warn about a limb the rig doesn't have and keep going
		if not limb then
			warn(`[{_localName}::{script.Name}]: Character has no ({limbName}) after {_settings.LIMB_WAIT_TIMEOUT}s! -`, character)
		end
	end

	--[[ Publish event ]]

	I.Topic.Publish("_Player_CharacterAdded", character)
end

--%%%%%%%%%%%%%%%%%%%% Character Removing

--[[
	Triggers when the player's character is removed or dies.
]]
function Module.CharacterRemoving(character: Model)
	I.Topic.Publish("_Player_CharacterRemoving", character)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
