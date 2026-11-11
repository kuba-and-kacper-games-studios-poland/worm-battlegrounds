--%%%%%%%%%%%%%%%%%%%% Profile

--- @class Atmosphere_Profile
---
--- # Lighting #
---
--- @field Preset string
---
--- # Music #
---
--- @field Music string
--- @field SuddenDeathMusic string?
---
--- # Particles #
---
--- @field WindColor Color3?
--- @field WindSound string?
--- @field Ambient { Atmosphere_AmbientRow }
--- @field Surface { Atmosphere_SurfaceRow }
--- @field Ceiling Atmosphere_CeilingRow?
local _atmosphere_Profile = {}

--- @class Atmosphere_AmbientRow
---
--- # General #
---
--- @field Effect string
---
--- # Area #
---
--- @field Bottom number
--- @field Top number
---
--- # Amount #
---
--- @field RateScale number
local _atmosphere_AmbientRow = {}

--- @class Atmosphere_SurfaceRow
---
--- # General #
---
--- @field Liquid string
--- @field Effect string
---
--- # Timing #
---
--- @field Every { number }
---
--- # Look #
---
--- @field Tint boolean
local _atmosphere_SurfaceRow = {}

--- @class Atmosphere_CeilingRow
---
--- # General #
---
--- @field Effect string
---
--- # Timing #
---
--- @field Every { number }
local _atmosphere_CeilingRow = {}

--%%%%%%%%%%%%%%%%%%%% Ambient

--- @class Atmosphere_Stream
---
--- # General #
---
--- @field Part BasePart
---
--- # Emitters #
---
--- @field Pulls { [ParticleEmitter]: Vector3 }
local _atmosphere_Stream = {}

--%%%%%%%%%%%%%%%%%%%% Liquids

--- @class Atmosphere_LiquidRect
---
--- # Box #
---
--- @field MinX number
--- @field MaxX number
--- @field MinY number
--- @field MaxY number
---
--- # Look #
---
--- @field Kind string
--- @field Color Color3
local _atmosphere_LiquidRect = {}

--%%%%%%%%%%%%%%%%%%%% Reactions

--- @class Atmosphere_Track
---
--- # General #
---
--- @field Kind string
---
--- # State #
---
--- @field LastY number
--- @field ReadyAt number
local _atmosphere_Track = {}
