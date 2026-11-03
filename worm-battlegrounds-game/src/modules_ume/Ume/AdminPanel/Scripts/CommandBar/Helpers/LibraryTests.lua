--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local UIEmitterShowcase = require(_scripts:FindFirstChild("CommandBar"):FindFirstChild("Client"):FindFirstChild("UIEmitterShowcase")) --- @type AdminPanel_CommandBar_Client_UIEmitterShowcase

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

--[[ Camera Shake ]]

local DEFAULT_SHAKE_PRESET: string = "Explosion"
local DEFAULT_SHAKE_DURATION: number = 1

--[[ Ragdoll ]]

local DEFAULT_RAGDOLL_PRESET: string = "Arcade"
local DEFAULT_RAGDOLL_DURATION: number = 3
local RAGDOLL_LAUNCH_FORWARD: number = 40
local RAGDOLL_LAUNCH_UP: number = 30

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Sorted Keys

--[[
	Returns the keys of a table sorted alphabetically.
]]
--- @param source { [string]: any }
--- @return { string }
local function getSortedKeys(source)
	--[[ Collecting ]]

	local keys = {} --- @type { string }

	for key: string in pairs(source) do
		table.insert(keys, key)
	end

	--[[ Returning ]]

	table.sort(keys)

	return keys
end

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

--- @class AdminPanel_CommandBar_LibraryTests
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	if I.Env.IsClient then
		Module._registerDictionaries()
		Module._registerCommands()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Register Dictionaries

--[[
	Registers the preset names used for argument autocomplete.
]]
function Module._registerDictionaries()
	--[[ Dictionaries ]]

	I.AdminPanel_CommandBar.SetDictionary("Ume_CameraShakePresets", getSortedKeys(I.CameraShake.Presets), 1)
	I.AdminPanel_CommandBar.SetDictionary("Ume_RagdollPresets", getSortedKeys(I.Ragdoll.Presets), 1)
end

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers the `libtest` command with one variant per tested library.
]]
function Module._registerCommands()
	--[[ Variants ]]

	local variants = {
		{
			Aliases = { "camera_shake" },
			Args = {
				{ name = "preset", types = { "string" }, dict = "Ume_CameraShakePresets", requireDict = true, optional = true },
				{ name = "duration", types = { "number" }, optional = true },
			},
			Callback = Module._testCameraShake,
		},
		{
			Aliases = { "ragdoll" },
			Args = {
				{ name = "preset", types = { "string" }, dict = "Ume_RagdollPresets", requireDict = true, optional = true },
				{ name = "duration", types = { "number" }, optional = true },
			},
			Callback = Module._testRagdoll,
		},
		{
			Aliases = { "ui_emitter" },
			Callback = Module._testUIEmitter,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Ume_LibraryTests", {
		Aliases = { "libtest" },
		PermissionLevel = 1,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Test Camera Shake

--[[
	Plays a one-shot camera shake preset on the current camera.
]]
--- @return boolean
--- @return string
function Module._testCameraShake(presetName: string?, duration: number?)
	--[[ Data ]]

	local resolvedPresetName: string = presetName or DEFAULT_SHAKE_PRESET
	local preset = I.CameraShake.GetPreset(resolvedPresetName) --- @type CameraShake_Config?

	--[[ Checks ]]

	-- Check if the preset exists
	if not preset then
		return false, `Unknown camera shake preset $|cr$|{resolvedPresetName}#|`
	end

	-- Check if there is a camera to shake
	if not workspace.CurrentCamera then
		return false, "No current camera to shake"
	end

	--[[ Playing ]]

	local resolvedDuration: number = math.max(I.Number.ToNumberOr(duration, DEFAULT_SHAKE_DURATION), 0)
	local shaker = I.CameraShake.new(workspace.CurrentCamera) --- @type CameraShake_Shaker
	shaker:PlayOnce(preset, resolvedDuration)

	--[[ Returning ]]

	return true, `Camera shake $|cr$|{resolvedPresetName}#| played for $|cr$|{resolvedDuration}s#|`
end

--%%%%%%%%%%%%%%%%%%%% Test Ragdoll

--[[
	Ragdolls and launches the local character with a preset, then stands it back up after the duration.
]]
--- @return boolean
--- @return string
function Module._testRagdoll(presetName: string?, duration: number?)
	--[[ Data ]]

	local resolvedPresetName: string = presetName or DEFAULT_RAGDOLL_PRESET
	local preset = I.Ragdoll.GetPreset(resolvedPresetName) --- @type Ragdoll_Preset?
	local character: Model? = I.Env.LocalPlayer.Character
	local humanoid: Humanoid? = character and character:FindFirstChildOfClass("Humanoid")
	local rootPart: Instance? = character and character:FindFirstChild("HumanoidRootPart")

	--[[ Checks ]]

	-- Check if the preset exists
	if not preset then
		return false, `Unknown ragdoll preset $|cr$|{resolvedPresetName}#|`
	end

	-- Check if the character is alive
	if not character or not humanoid or humanoid.Health <= 0 or not rootPart or not rootPart:IsA("BasePart") then
		return false, "No living character to ragdoll"
	end

	--[[ Ragdolling ]]

	local resolvedDuration: number = math.max(I.Number.ToNumberOr(duration, DEFAULT_RAGDOLL_DURATION), 0.1)
	local velocity: Vector3 = rootPart.CFrame.LookVector * RAGDOLL_LAUNCH_FORWARD + Vector3.yAxis * RAGDOLL_LAUNCH_UP

	I.Ragdoll.Rig(character)
	I.Ragdoll.Start(character, {
		Preset = preset,
		Velocity = velocity,
		Duration = resolvedDuration,
	})

	--[[ Returning ]]

	return true, `Ragdoll $|cr$|{resolvedPresetName}#| started for $|cr$|{resolvedDuration}s#|`
end

--%%%%%%%%%%%%%%%%%%%% Test UI Emitter

--[[
	Toggles the UIEmitter showcase gui.
]]
--- @return boolean
--- @return string
function Module._testUIEmitter()
	--[[ Toggling ]]

	local opened: boolean = UIEmitterShowcase.Toggle()

	--[[ Returning ]]

	return true, if opened then "UI emitter showcase $|cr$|opened#|" else "UI emitter showcase $|cr$|closed#|"
end

return Module
