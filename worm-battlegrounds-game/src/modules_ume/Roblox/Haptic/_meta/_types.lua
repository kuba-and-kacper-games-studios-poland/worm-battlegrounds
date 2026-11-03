--- @alias Haptic_Mode
---| "Haptic" @ Plays only the haptic channel.
---| "Haptic_Sound" @ Plays haptic and sound channels together.
---| "Sound" @ Plays only the sound channel.
---| "Dynamic" @ Plays haptic when supported, otherwise sound.

--- @class Haptic_Preset
---
--- # Playback #
---
--- @field Mode Haptic_Mode
--- @field Type Enum.HapticEffectType?
--- @field Looped boolean?
--- @field Duration number?
---
--- # Spatial #
---
--- @field Position Vector3?
--- @field Radius number?
--- @field WaveformKeys { FloatCurveKey }?
---
--- # Sound #
---
--- @field SoundParams Sound_Params?
local _haptic_Preset = {}

--- @alias Haptic_Presets { [string]: Haptic_Preset }

--- @class Haptic_PresetOverrides
---
--- # Playback #
---
--- @field Mode Haptic_Mode?
--- @field Type Enum.HapticEffectType?
--- @field Looped boolean?
--- @field Duration number?
---
--- # Spatial #
---
--- @field Position Vector3?
--- @field Radius number?
--- @field WaveformKeys { FloatCurveKey }?
---
--- # Sound #
---
--- @field SoundParams Sound_Params?
local _haptic_PresetOverrides = {}

--- @class Haptic_ActivePlayback
---
--- # Playback #
---
--- @field Effect HapticEffect
--- @field HapticActive boolean
--- @field Sound Sound?
---
--- # Connections #
---
--- @field HapticConnection RBXScriptConnection?
--- @field SoundConnection RBXScriptConnection?
local _haptic_ActivePlayback = {}
