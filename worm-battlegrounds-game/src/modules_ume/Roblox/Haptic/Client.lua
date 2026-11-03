--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Haptic"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local HapticService = I.S.HapticService
local UserInputService = I.S.UserInputService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Haptic_Presets
local presets = require(I.Dirs.GlobalData.Haptic.Preset)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Haptics ]]

local hapticDir: Folder
local hapticEffects = {} --- @type { [string]: HapticEffect }
local hapticPresets = {} --- @type { [string]: Haptic_Preset }

--[[ Play Once ]]

local pooledEffects = {} --- @type { [string]: HapticEffect }
local autoDestroyEffects = {} --- @type { [string]: boolean }

--[[ Playback ]]

local activePlaybacks = {} --- @type { [string]: Haptic_ActivePlayback }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Resolve Preset

--[[
	Returns a preset with the provided overrides merged over its defaults.
]]
--- @param overrides Haptic_PresetOverrides?
--- @return Haptic_Preset
local function resolvePreset(hapticId: string, overrides)
	--- @type Haptic_Preset
	local preset = table.clone(presets[hapticId])

	if not overrides then
		return preset
	end

	for key: string, value in pairs(overrides) do
		if key == "SoundParams" and type(value) == "table" and type(preset.SoundParams) == "table" then
			preset.SoundParams = table.clone(preset.SoundParams)
			for soundKey: string, soundValue in pairs(value) do
				preset.SoundParams[soundKey] = soundValue
			end
		else
			preset[key] = value
		end
	end

	return preset
end

--%%%%%%%%%%%%%%%%%%%% Get Haptic UUID

--[[
	Returns the UUID when the haptic belongs to this module.
]]
--- @return string?
local function getHapticUUID(haptic: HapticEffect)
	if typeof(haptic) ~= "Instance" or not haptic:IsA("HapticEffect") then
		return nil
	end

	local hapticUUID: string? = haptic:GetAttribute("Haptic_UUID")
	if type(hapticUUID) ~= "string" or hapticEffects[hapticUUID] ~= haptic then
		return nil
	end

	return hapticUUID
end

--%%%%%%%%%%%%%%%%%%%% Has Haptic Support

--[[
	Returns whether a currently available input device supports vibration.
]]
--- @return boolean
local function hasHapticSupport()
	--[[ Input Types ]]

	local inputTypes = UserInputService:GetConnectedGamepads()
	if UserInputService.TouchEnabled and not table.find(inputTypes, Enum.UserInputType.Gamepad1) then
		table.insert(inputTypes, Enum.UserInputType.Gamepad1)
	end

	--[[ Support Check ]]

	for _, inputType: Enum.UserInputType in ipairs(inputTypes) do
		local success: boolean, isSupported: boolean = pcall(HapticService.IsVibrationSupported, HapticService, inputType)
		if success and isSupported then
			return true
		end
	end

	return false
end

--%%%%%%%%%%%%%%%%%%%% Destroy Effect

--[[
	Destroys a stopped haptic and forgets it.
]]
local function destroyEffect(hapticUUID: string)
	--[[ Destroying ]]

	hapticEffects[hapticUUID]:Destroy()

	--[[ Clearing ]]

	hapticEffects[hapticUUID] = nil
	hapticPresets[hapticUUID] = nil
	autoDestroyEffects[hapticUUID] = nil
end

--%%%%%%%%%%%%%%%%%%%% Cleanup Finished Playback

--[[
	Removes a playback after both of its selected channels have ended.
	Destroys the haptic when it was played once.
]]
--- @param playback Haptic_ActivePlayback
local function cleanupFinishedPlayback(hapticUUID: string, playback)
	--[[ Checks ]]

	-- Skip while a channel is still playing
	if playback.HapticActive or playback.Sound then
		return
	end

	-- Skip a playback that was replaced
	if activePlaybacks[hapticUUID] ~= playback then
		return
	end

	--[[ Clearing ]]

	activePlaybacks[hapticUUID] = nil

	-- Destroy a haptic that was played once
	if autoDestroyEffects[hapticUUID] then
		destroyEffect(hapticUUID)
	end
end

--%%%%%%%%%%%%%%%%%%%% Stop Playback

--[[
	Stops and clears both channels for a local playback.
]]
--- @return boolean
local function stopPlayback(hapticUUID: string)
	--- @type Haptic_ActivePlayback
	local playback = activePlaybacks[hapticUUID]
	if not playback then
		return false
	end

	--[[ Connections ]]

	if playback.HapticConnection then
		playback.HapticConnection:Disconnect()
		playback.HapticConnection = nil
	end
	if playback.SoundConnection then
		playback.SoundConnection:Disconnect()
		playback.SoundConnection = nil
	end

	--[[ Haptic ]]

	if playback.HapticActive then
		playback.Effect:Stop()
		playback.HapticActive = false
	end

	--[[ Sound ]]

	if playback.Sound then
		playback.Sound:Stop()
		playback.Sound:Destroy()
		playback.Sound = nil
	end

	activePlaybacks[hapticUUID] = nil
	return true
end

--%%%%%%%%%%%%%%%%%%%% Play Haptic Channel

--[[
	Starts and tracks the reusable haptic channel for a playback.
]]
--- @param playback Haptic_ActivePlayback
local function playHapticChannel(hapticUUID: string, playback)
	playback.HapticActive = true
	playback.HapticConnection = playback.Effect.Ended:Connect(function()
		if activePlaybacks[hapticUUID] ~= playback then
			return
		end

		playback.HapticConnection:Disconnect()
		playback.HapticConnection = nil
		playback.HapticActive = false

		cleanupFinishedPlayback(hapticUUID, playback)
	end)

	playback.Effect:Play()
end

--%%%%%%%%%%%%%%%%%%%% Play Sound Channel

--[[
	Starts and tracks the sound channel configured by a haptic preset.
]]
--- @param preset Haptic_Preset
--- @param playback Haptic_ActivePlayback
--- @return boolean
local function playSoundChannel(hapticUUID: string, preset, playback)
	local sound: Sound = I.Sound.Play(preset.SoundParams)
	if not sound then
		return false
	end

	playback.Sound = sound
	playback.SoundConnection = sound.Ended:Connect(function()
		if activePlaybacks[hapticUUID] ~= playback then
			return
		end

		playback.SoundConnection:Disconnect()
		playback.SoundConnection = nil
		sound:Destroy()
		playback.Sound = nil

		cleanupFinishedPlayback(hapticUUID, playback)
	end)

	return true
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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._createDirectory()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Haptic_Play", { "string", { Type = "table", Optional = true } })
	I.Network.Fired("Haptic_Play", Module.PlayOnce)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Haptic = {

		--[[ Control ]]

		Create = Module.Create,
		Play = Module.Play,
		PlayOnce = Module.PlayOnce,
		Stop = Module.Stop,
		Destroy = Module.Destroy,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Directory

--[[
	Creates the local directory that stores haptic instances.
]]
function Module._createDirectory()
	hapticDir = I.Dirs.UmeWorkspace:FindFirstChild(_localName)
	if hapticDir then
		hapticDir:ClearAllChildren()
	else
		hapticDir = Instance.new("Folder")
		hapticDir.Name = _localName
		hapticDir.Parent = I.Dirs.UmeWorkspace
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Create

--[[
	**CLIENT** |
	Creates and stores a uniquely identified haptic from a preset and optional overrides.
]]
--- @param overrides Haptic_PresetOverrides?
--- @return HapticEffect
function Module.Create(hapticId: string, overrides)
	--[[ Checks ]]

	if type(hapticId) ~= "string" or not presets[hapticId] then
		warn(`[{_localName}::{script.Name}]: ({hapticId}) is not a valid Haptic preset!`)
		return nil
	end

	if overrides ~= nil and type(overrides) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Overrides for Haptic preset ({hapticId}) must be a table!`)
		return nil
	end

	--[[ Creating ]]

	--- @type Haptic_Preset
	local preset = resolvePreset(hapticId, overrides)
	local hapticUUID: string = I.Obfuscate.GetRandomString(16)
	while hapticEffects[hapticUUID] do
		hapticUUID = I.Obfuscate.GetRandomString(16)
	end

	local effect: HapticEffect = Instance.new("HapticEffect")
	effect.Name = hapticUUID
	effect:SetAttribute("Haptic_UUID", hapticUUID)
	effect.Type = preset.Type or Enum.HapticEffectType.GameplayCollision
	effect.Looped = preset.Looped == true
	effect.Position = preset.Position or Vector3.zero
	effect.Radius = preset.Radius or 1
	effect.Parent = hapticDir

	if preset.WaveformKeys then
		local success: boolean, message: string = pcall(effect.SetWaveformKeys, effect, preset.WaveformKeys)
		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to set waveform keys for Haptic preset ({hapticId})! - {message}`)
			effect:Destroy()
			return nil
		end
	end

	hapticEffects[hapticUUID] = effect
	hapticPresets[hapticUUID] = preset
	return effect
end

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Plays a created haptic instance and returns it.
	Returns nil when neither channel could play.
]]
--- @return HapticEffect?
function Module.Play(haptic: HapticEffect)
	--[[ Checks ]]

	local hapticUUID: string? = getHapticUUID(haptic)

	-- Check if the haptic was created by this module
	if not hapticUUID then
		warn(`[{_localName}::{script.Name}]: ({haptic}) is not a created HapticEffect!`)
		return nil
	end

	--[[ Data ]]

	--- @type Haptic_Preset
	local preset = hapticPresets[hapticUUID]

	--[[ Restarting ]]

	stopPlayback(hapticUUID)

	--[[ Channels ]]

	local playHaptic: boolean = preset.Mode == "Haptic" or preset.Mode == "Haptic_Sound"
	local playSound: boolean = preset.Mode == "Sound" or preset.Mode == "Haptic_Sound"

	-- Play the haptic where it is supported, the sound otherwise
	if preset.Mode == "Dynamic" then
		playHaptic = hasHapticSupport()
		playSound = not playHaptic
	end

	--[[ Tracking ]]

	--- @type Haptic_ActivePlayback
	local playback = {
		Effect = haptic,
		HapticActive = false,
		Sound = nil,
		HapticConnection = nil,
		SoundConnection = nil,
	}
	activePlaybacks[hapticUUID] = playback

	--[[ Playing ]]

	if playHaptic then
		playHapticChannel(hapticUUID, playback)
	end
	if playSound then
		playSoundChannel(hapticUUID, preset, playback)
	end

	-- Stop tracking when neither channel played
	if not playback.HapticActive and not playback.Sound then
		activePlaybacks[hapticUUID] = nil
		return nil
	end

	--[[ Duration ]]

	if preset.Duration then
		task.delay(preset.Duration, function()
			-- Skip a playback that already ended or was replaced
			if activePlaybacks[hapticUUID] ~= playback then
				return
			end

			stopPlayback(hapticUUID)

			-- Destroy a haptic that was played once
			if autoDestroyEffects[hapticUUID] then
				destroyEffect(hapticUUID)
			end
		end)
	end

	--[[ Returning ]]

	return haptic
end

--%%%%%%%%%%%%%%%%%%%% Play Once

--[[
	**CLIENT** |
	Plays a preset once and cleans it up, for one-shot feedback that needs no Stop or Destroy.
	Without overrides it reuses one haptic per preset; with overrides it creates one and destroys it when it ends.
]]
--- @param overrides Haptic_PresetOverrides?
--- @return boolean
function Module.PlayOnce(hapticId: string, overrides)
	--[[ Pooled Haptic ]]

	-- Reuse the preset's haptic when there are no overrides
	if overrides == nil and pooledEffects[hapticId] then
		return Module.Play(pooledEffects[hapticId]) ~= nil
	end

	--[[ Creating ]]

	local haptic: HapticEffect? = Module.Create(hapticId, overrides)

	-- Check if the preset could be created
	if not haptic then
		return false
	end

	--[[ Data ]]

	local hapticUUID: string = haptic:GetAttribute("Haptic_UUID")
	local preset = hapticPresets[hapticUUID] --- @type Haptic_Preset

	--[[ Checks ]]

	-- Check if the haptic can end without a Stop
	if preset.Looped and not preset.Duration then
		warn(`[{_localName}::{script.Name}]: Looped Haptic preset ({hapticId}) needs a Duration to play once!`)
		destroyEffect(hapticUUID)
		return false
	end

	--[[ Saving ]]

	-- Keep the preset's haptic, or mark a one-off haptic for destroying when it ends
	if overrides == nil then
		pooledEffects[hapticId] = haptic
	else
		autoDestroyEffects[hapticUUID] = true
	end

	--[[ Playing ]]

	-- Destroy a one-off haptic that played nothing
	if not Module.Play(haptic) then
		if overrides ~= nil then
			destroyEffect(hapticUUID)
		end
		return false
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Stop

--[[
	**CLIENT** |
	Stops a created haptic without destroying it.
]]
--- @return boolean
function Module.Stop(haptic: HapticEffect)
	local hapticUUID: string? = getHapticUUID(haptic)
	if not hapticUUID then
		warn(`[{_localName}::{script.Name}]: ({haptic}) is not a created HapticEffect!`)
		return false
	end

	return stopPlayback(hapticUUID)
end

--%%%%%%%%%%%%%%%%%%%% Destroy

--[[
	**CLIENT** |
	Stops and destroys a created haptic instance.
]]
--- @return boolean
function Module.Destroy(haptic: HapticEffect)
	local hapticUUID: string? = getHapticUUID(haptic)
	if not hapticUUID then
		warn(`[{_localName}::{script.Name}]: ({haptic}) is not a created HapticEffect!`)
		return false
	end

	stopPlayback(hapticUUID)
	hapticEffects[hapticUUID] = nil
	hapticPresets[hapticUUID] = nil
	haptic:Destroy()

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
