--%%%%%%%%%%%%%%%%%%%% Participants

--- @class Snails_Participant
---
--- # General #
---
--- @field Id string
--- @field UserId number
--- @field DisplayName string
---
--- # Team #
---
--- @field Team number
--- @field Color Color3
---
--- # Control #
---
--- @field IsBot boolean
---
--- # Looks #
---
--- @field Skin string?
--- @field Shiny boolean?
--- @field Vip boolean?
--- @field Level number?
---
--- # Combat #
---
--- @field MaxHealth number?
local _snails_Participant = {}

--%%%%%%%%%%%%%%%%%%%% Gear

--- @class Snails_Gear
---
--- # Showing #
---
--- @field Attribute string
---
--- # Placing #
---
--- @field Offset Vector3
local _snails_Gear = {}

--%%%%%%%%%%%%%%%%%%%% Sounds

--- @class Snails_SoundState
---
--- # Hurt #
---
--- @field Health number
---
--- # Moving #
---
--- @field LastRise number
--- @field Walked number
---
--- # Jetpack #
---
--- @field Climbing number
--- @field Resting number
--- @field Jetpack Sound?
local _snails_SoundState = {}

--%%%%%%%%%%%%%%%%%%%% Effects

--- @class Snails_EffectState
---
--- # Healing #
---
--- @field Health number
---
--- # Moving #
---
--- @field LastRise number
--- @field Trails { Trail }
---
--- # Jetpack #
---
--- @field Jet { Trail }
--- @field Climbing number
--- @field Resting number
--- @field Jetting boolean
--- @field Exhaust { ParticleEmitter }
local _snails_EffectState = {}

--%%%%%%%%%%%%%%%%%%%% Tags

--- @class Snails_TagTurn
---
--- # General #
---
--- @field Model Model
--- @field Tag BillboardGui
--- @field Root BasePart
--- @field Arrow ImageLabel
---
--- # Start #
---
--- @field Start Vector3
--- @field StartedAt number
--- @field ServerStart number
---
--- # Acting #
---
--- @field CameraAt Vector3
--- @field AimBase number?
--- @field SawTurn boolean
--- @field Hidden boolean
local _snails_TagTurn = {}

--%%%%%%%%%%%%%%%%%%%% Flight

--- @class Snails_FlightState
---
--- # Simulation #
---
--- @field Body Combat_Body
--- @field World Combat_World
local _snails_FlightState = {}
