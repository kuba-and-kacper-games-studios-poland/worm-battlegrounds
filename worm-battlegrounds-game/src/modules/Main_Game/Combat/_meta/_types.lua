--%%%%%%%%%%%%%%%%%%%% Shots

--- @class Combat_Shot
---
--- # General #
---
--- @field ParticipantId string
--- @field ItemId string
--- @field Row Arsenal_WeaponData
--- @field Shiny boolean
---
--- # Aim #
---
--- @field Origin Vector3
--- @field Direction Vector3
--- @field Angle number
--- @field Power number
--- @field Facing number
--- @field Target Vector3?
---
--- # Result #
---
--- @field Damage number
--- @field Shooter Model
local _combat_Shot = {}

--- @class Combat_ShotOptions
---
--- # Shape #
---
--- @field Radius number
---
--- # Forces #
---
--- @field Wind number?
--- @field GravityScale number?
---
--- # Contacts #
---
--- @field Bounce number?
--- @field Pierce boolean?
--- @field Shooter Model?
--- @field GraceSteps number?
--- @field GhostSteps number?
---
--- # Rolling #
---
--- @field Drive number?
--- @field HopSpeed number?
---
--- # Homing #
---
--- @field Target Vector3?
--- @field HomingSpeed number?
--- @field LockStep number?
local _combat_ShotOptions = {}

--- @class Combat_Body
---
--- # General #
---
--- @field Id number
--- @field Kind string
--- @field Name string
--- @field Start number
--- @field Options Combat_ShotOptions
---
--- # Motion #
---
--- @field Step number
--- @field Position Vector3
--- @field Velocity Vector3
--- @field Angle number
--- @field Spin number
---
--- # Contacts #
---
--- @field Grounded boolean
--- @field Stopped boolean
--- @field Sunk boolean
--- @field SunkStep number
--- @field Ignore { Instance }
local _combat_Body = {}

--- @class Combat_BodyState
---
--- # Motion #
---
--- @field Step number
--- @field Position Vector3
--- @field Velocity Vector3
--- @field Angle number
--- @field Spin number
---
--- # Contacts #
---
--- @field Grounded boolean
--- @field Stopped boolean
--- @field Sunk boolean
--- @field IgnoreCount number
local _combat_BodyState = {}

--- @class Combat_World
---
--- # Casts #
---
--- @field Params RaycastParams
--- @field Exclude { Instance }
---
--- # Liquid #
---
--- @field IsLiquid (position: Vector3) -> boolean
local _combat_World = {}

--- @class Combat_Behavior
---
--- # General #
---
--- @field Run (shot: Combat_Shot) -> ()
local _combat_Behavior = {}

--%%%%%%%%%%%%%%%%%%%% Client

--- @class Combat_ClientShot
---
--- # Simulation #
---
--- @field Body Combat_Body
--- @field History { [number]: Combat_BodyState }
---
--- # Look #
---
--- @field Part Part
--- @field Offset Vector3
---
--- # Sound #
---
--- @field LastBounce number
local _combat_ClientShot = {}

--- @class Combat_FlyingShot
---
--- # Look #
---
--- @field Model Model
--- @field Kind string
---
--- # Motion #
---
--- @field Last Vector3
--- @field Facing number
--- @field Heading Vector3
--- @field Drawn Vector3
local _combat_FlyingShot = {}
