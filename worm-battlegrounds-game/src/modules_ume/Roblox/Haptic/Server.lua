--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Haptic"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Haptic_Presets
local presets = require(I.Dirs.GlobalData.Haptic.Preset)
--- @type Sound_SoundsList
local soundsList = require(I.Dirs.GlobalData.Sound.SoundsList)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local validPresets = {} --- @type { [string]: boolean }

--[[ Modes ]]

local validModes = {
	Haptic = true,
	Haptic_Sound = true,
	Sound = true,
	Dynamic = true,
} --- @type { [string]: boolean }

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

--%%%%%%%%%%%%%%%%%%%% Preset Uses Sound

--[[
	Returns whether a preset mode can play its configured sound.
]]
--- @param preset Haptic_Preset
--- @return boolean
local function presetUsesSound(preset)
	return preset.Mode == "Haptic_Sound" or preset.Mode == "Sound" or preset.Mode == "Dynamic"
end

--%%%%%%%%%%%%%%%%%%%% Validate Preset

--[[
	Validates a haptic preset before it can be played.
]]
--- @param preset Haptic_Preset
--- @return boolean
local function validatePreset(presetId: string, preset)
	--[[ Checks ]]

	if type(presetId) ~= "string" or presetId == "" then
		warn(`[{_localName}::{script.Name}]: ({presetId}) is not a valid Haptic preset id!`)
		return false
	end

	if type(preset) ~= "table" then
		warn(`[{_localName}::{script.Name}]: ({presetId}) is not a valid Haptic preset table!`)
		return false
	end

	if not validModes[preset.Mode] then
		warn(`[{_localName}::{script.Name}]: ({preset.Mode}) is not a valid mode for Haptic preset ({presetId})!`)
		return false
	end

	if preset.Duration ~= nil and (type(preset.Duration) ~= "number" or preset.Duration <= 0) then
		warn(`[{_localName}::{script.Name}]: Duration for Haptic preset ({presetId}) must be greater than zero!`)
		return false
	end

	if presetUsesSound(preset) and type(preset.SoundParams) ~= "table" then
		warn(`[{_localName}::{script.Name}]: SoundParams are missing for Haptic preset ({presetId})!`)
		return false
	end

	if preset.SoundParams and (type(preset.SoundParams.Name) ~= "string" or not soundsList[preset.SoundParams.Name]) then
		warn(`[{_localName}::{script.Name}]: ({preset.SoundParams.Name}) is not a valid sound Name for Haptic preset ({presetId})!`)
		return false
	end

	if preset.Type ~= nil and (typeof(preset.Type) ~= "EnumItem" or preset.Type.EnumType ~= Enum.HapticEffectType) then
		warn(`[{_localName}::{script.Name}]: Type for Haptic preset ({presetId}) must be an Enum.HapticEffectType!`)
		return false
	end

	if preset.Looped ~= nil and type(preset.Looped) ~= "boolean" then
		warn(`[{_localName}::{script.Name}]: Looped for Haptic preset ({presetId}) must be a boolean!`)
		return false
	end

	if preset.Position ~= nil and typeof(preset.Position) ~= "Vector3" then
		warn(`[{_localName}::{script.Name}]: Position for Haptic preset ({presetId}) must be a Vector3!`)
		return false
	end

	if preset.Radius ~= nil and (type(preset.Radius) ~= "number" or preset.Radius < 0) then
		warn(`[{_localName}::{script.Name}]: Radius for Haptic preset ({presetId}) must be zero or greater!`)
		return false
	end

	if preset.WaveformKeys ~= nil and (type(preset.WaveformKeys) ~= "table" or #preset.WaveformKeys == 0) then
		warn(`[{_localName}::{script.Name}]: WaveformKeys for Haptic preset ({presetId}) must be a non-empty table!`)
		return false
	end

	if preset.Type == Enum.HapticEffectType.Custom and not preset.WaveformKeys then
		warn(`[{_localName}::{script.Name}]: Custom Haptic preset ({presetId}) requires WaveformKeys!`)
		return false
	end

	if preset.SoundParams and preset.SoundParams.Volume ~= nil and (type(preset.SoundParams.Volume) ~= "number" or preset.SoundParams.Volume < 0) then
		warn(`[{_localName}::{script.Name}]: SoundParams.Volume for Haptic preset ({presetId}) must be zero or greater!`)
		return false
	end

	if preset.SoundParams and preset.SoundParams.SoundGroup ~= nil and type(preset.SoundParams.SoundGroup) ~= "string" then
		warn(`[{_localName}::{script.Name}]: SoundParams.SoundGroup for Haptic preset ({presetId}) must be a string!`)
		return false
	end

	if preset.SoundParams and preset.SoundParams.PlaybackSpeed ~= nil and (type(preset.SoundParams.PlaybackSpeed) ~= "number" or preset.SoundParams.PlaybackSpeed <= 0) then
		warn(`[{_localName}::{script.Name}]: SoundParams.PlaybackSpeed for Haptic preset ({presetId}) must be greater than zero!`)
		return false
	end

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

	Module._validatePresets()

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Haptic_Play")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Haptic = {

		--[[ Control ]]

		Play = Module.Play,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Validate Presets

--[[
	Caches every preset that the server can safely forward to a client.
]]
function Module._validatePresets()
	for presetId: string, preset in pairs(presets) do
		if not validatePreset(presetId, preset) then
			continue
		end

		validPresets[presetId] = true
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Requests a haptic preset with optional overrides to play once for the player.
	Rejects a looped preset without a Duration, since the server can't stop it.
]]
--- @param overrides Haptic_PresetOverrides?
--- @return boolean
function Module.Play(player: Player, hapticId: string, overrides)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Check if the preset exists and passed validation
	if type(hapticId) ~= "string" or not validPresets[hapticId] then
		warn(`[{_localName}::{script.Name}]: ({hapticId}) is not a valid Haptic preset!`)
		return false
	end

	-- Check if overrides are a table
	if overrides ~= nil and type(overrides) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Overrides for Haptic preset ({hapticId}) must be a table!`)
		return false
	end

	--[[ Data ]]

	--- @type Haptic_Preset
	local preset = resolvePreset(hapticId, overrides)

	--[[ Checks ]]

	-- Check if the preset with its overrides is valid
	if not validatePreset(hapticId, preset) then
		return false
	end

	-- Check if a looped preset ends on its own
	if preset.Looped and not preset.Duration then
		warn(`[{_localName}::{script.Name}]: Looped Haptic preset ({hapticId}) needs a Duration to play for a player!`)
		return false
	end

	--[[ Playing ]]

	I.Network.Fire("Haptic_Play", player, hapticId, overrides)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
