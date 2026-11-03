--%%%%%%%%%%%%%%%%%%%% Config

--- @class CameraShake_Config
---
--- # Strength #
---
--- @field Magnitude number
--- @field Roughness number
---
--- # Influence #
---
--- @field PositionInfluence Vector3?
--- @field RotationInfluence Vector3?
local _cameraShake_Config = {}

--%%%%%%%%%%%%%%%%%%%% Enums

--- @alias CameraShake_State
---| "Inactive" @ Shake is done and contributes no motion
---| "FadingIn" @ Shake is ramping up toward full strength
---| "Sustained" @ Shake is holding at full strength
---| "FadingOut" @ Shake is ramping down toward zero

--%%%%%%%%%%%%%%%%%%%% Presets

--- @alias CameraShake_Presets { [string]: CameraShake_Config }

--%%%%%%%%%%%%%%%%%%%% Instance Classes

--- @class CameraShake_Shake
---
--- # Strength #
---
--- @field Magnitude number
--- @field Roughness number
---
--- # Influence #
---
--- @field PositionInfluence Vector3
--- @field RotationInfluence Vector3
---
--- # Methods #
---
--- @field Play (self: CameraShake_Shake, fadeTime: number | nil) -> ()
--- @field PlayOnce (self: CameraShake_Shake, holdDuration: number, fadeInTime: number | nil, fadeOutTime: number | nil) -> ()
--- @field Stop (self: CameraShake_Shake, fadeTime: number | nil) -> ()
--- @field SetMagnitude (self: CameraShake_Shake, magnitude: number) -> ()
--- @field SetRoughness (self: CameraShake_Shake, roughness: number) -> ()
--- @field SetPositionInfluence (self: CameraShake_Shake, influence: Vector3) -> ()
--- @field SetRotationInfluence (self: CameraShake_Shake, influence: Vector3) -> ()
--- @field GetState (self: CameraShake_Shake) -> CameraShake_State
--- @field IsActive (self: CameraShake_Shake) -> boolean
local _cameraShake_Shake = {}

--- @class CameraShake_Shaker
--- @field Play (self: CameraShake_Shaker, config: CameraShake_Config, fadeTime: number | nil) -> CameraShake_Shake
--- @field PlayOnce (self: CameraShake_Shaker, config: CameraShake_Config, duration: number, fadeInTime: number | nil, fadeOutTime: number | nil) -> CameraShake_Shake
--- @field Stop (self: CameraShake_Shaker, shake: CameraShake_Shake | nil, fadeTime: number | nil) -> ()
--- @field StopAll (self: CameraShake_Shaker, fadeTime: number | nil) -> ()
--- @field Destroy (self: CameraShake_Shaker) -> ()
local _cameraShake_Shaker = {}
