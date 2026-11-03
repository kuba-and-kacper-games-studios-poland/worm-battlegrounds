--- @class Lighting_ValueTable
---
--- # General #
---
--- @field Id string?
---
--- # Value #
---
--- @field Value number | string | boolean | Color3 | Vector3
--- @field Weight number
---
--- # Color #
---
--- @field Color_Hue number
--- @field Color_Saturation number
--- @field Color_Value number
local _lighting_ValueTable = {}

--- @class Lighting_Layer : Lighting_ValueTable
--- @field Order number
local _lighting_Layer = {}

--%%%%%%%%%%%%%%%%%%%% Tweening

--- @alias Lighting_ClockTimeDirection "Shortest" | "Forward" | "Backward"
local _lighting_ClockTimeDirection = {}

--- @class Lighting_PlayingTween
---
--- # Tween #
---
--- @field Tween Tween
--- @field Goal any
---
--- # ClockTime #
---
--- @field Proxy NumberValue?
local _lighting_PlayingTween = {}

--%%%%%%%%%%%%%%%%%%%%

--- @class Lighting_LightingProperties
--- @field Lighting Lighting_LightingEffectProperties
--- @field Atmosphere Lighting_AtmosphereEffectProperties
--- @field Sky Lighting_SkyEffectProperties
--- @field BloomEffect Lighting_BloomEffectEffectProperties
--- @field BlurEffect Lighting_BlurEffectEffectProperties
--- @field ColorCorrectionEffect Lighting_ColorCorrectionEffectEffectProperties
--- @field DepthOfFieldEffect Lighting_DepthOfFieldEffectEffectProperties
--- @field SunRaysEffect Lighting_SunRaysEffectEffectProperties
local _lighting_LightingProperties = {}

--- @class Lighting_LightingEffectProperties
---
--- # Environment #
---
--- @field Ambient Color3
--- @field Brightness number
--- @field ColorShift_Bottom Color3
--- @field ColorShift_Top Color3
--- @field EnvironmentDiffuseScale number
--- @field EnvironmentSpecularScale number
--- @field GlobalShadows boolean
--- @field OutdoorAmbient Color3
--- @field ShadowSoftness number
---
--- # Time #
---
--- @field ClockTime number
--- @field GeographicLatitude number
---
--- # Exposure #
---
--- @field ExposureCompensation number
---
--- # Fog #
---
--- @field FogColor Color3
--- @field FogEnd number
--- @field FogStart number
local _lighting_LightingEffectProperties = {}

--- @class Lighting_AtmosphereEffectProperties
---
--- # Density #
---
--- @field Density number
--- @field Offset number
---
--- # Appearance #
---
--- @field Color Color3
--- @field Decay Color3
--- @field Glare number
--- @field Haze number
local _lighting_AtmosphereEffectProperties = {}

--- @class Lighting_SkyEffectProperties
---
--- # Celestial #
---
--- @field CelestialBodiesShown boolean
--- @field StarCount number
---
--- # Sun #
---
--- @field SunAngularSize number
--- @field SunTextureId string
---
--- # Moon #
---
--- @field MoonAngularSize number
--- @field MoonTextureId string
---
--- # Skybox #
---
--- @field SkyboxOrientation Vector3
--- @field SkyboxUp string
--- @field SkyboxDn string
--- @field SkyboxBk string
--- @field SkyboxFt string
--- @field SkyboxLf string
--- @field SkyboxRt string
local _lighting_SkyEffectProperties = {}

--- @class Lighting_BloomEffectEffectProperties
--- @field Enabled boolean
--- @field Intensity number
--- @field Size number
--- @field Threshold number
local _lighting_BloomEffectEffectProperties = {}

--- @class Lighting_BlurEffectEffectProperties
--- @field Enabled boolean
--- @field Size number
local _lighting_BlurEffectEffectProperties = {}

--- @class Lighting_ColorCorrectionEffectEffectProperties
--- @field Enabled boolean
--- @field Brightness number
--- @field Contrast number
--- @field Saturation number
--- @field TintColor Color3
local _lighting_ColorCorrectionEffectEffectProperties = {}

--- @class Lighting_DepthOfFieldEffectEffectProperties
--- @field Enabled boolean
--- @field FarIntensity number
--- @field FocusDistance number
--- @field InFocusRadius number
--- @field NearIntensity number
local _lighting_DepthOfFieldEffectEffectProperties = {}

--- @class Lighting_SunRaysEffectEffectProperties
--- @field Enabled boolean
--- @field Intensity number
--- @field Spread number
local _lighting_SunRaysEffectEffectProperties = {}
