--%%%%%%%%%%%%%%%%%%%% Shots

--- @class Combat_Shot
---
--- # General #
---
--- @field ParticipantId string
--- @field ItemId string
--- @field Row Arsenal_WeaponData
--- @field Shiny boolean
--- @field Variant Combat_Variant?
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
--- # Drawing #
---
--- @field Tumble boolean?
--- @field DrawScale number?
--- @field Variant Combat_Variant?
---
--- # Homing #
---
--- @field Target Vector3?
--- @field HomingSpeed number?
--- @field HomingMaxSpeed number?
--- @field HomingAccel number?
--- @field HomingTurn number?
--- @field HomingTurnGrowth number?
--- @field LockStep number?
--- @field LockPauseSteps number?
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
--- @field Whistled boolean
--- @field Whistle Sound?
---
--- # Homing #
---
--- @field Locked boolean
--- @field Diving boolean
local _combat_ClientShot = {}

--- @class Combat_Vortex
---
--- # General #
---
--- @field Center Vector3
--- @field Started number
--- @field Seconds number
---
--- # Look #
---
--- @field Arms { BasePart }
--- @field Angle number
local _combat_Vortex = {}

--- @class Combat_FlyingShot
---
--- # Look #
---
--- @field Model Model
--- @field Kind string
--- @field Carrier BasePart?
---
--- # Motion #
---
--- @field Last Vector3
--- @field Facing number
--- @field Heading Vector3
--- @field Drawn Vector3
local _combat_FlyingShot = {}

--%%%%%%%%%%%%%%%%%%%% Variants

--- @alias Combat_Variant "Shiny" | "Golden"
local _combat_Variant = {}

--- @class Combat_VariantLook
---
--- # Held #
---
--- @field Gild { Color3 }?
--- @field GildCover number?
--- @field Sheen { Color3 }
--- @field SheenPeriod number
--- @field Outline Color3
--- @field OutlineTransparency number
--- @field Twinkle Combat_VariantEffect
--- @field Dust Combat_VariantEffect?
---
--- # Shot #
---
--- @field Trail string
--- @field TrailColor ColorSequence
--- @field TrailWidth number
--- @field Glint Combat_VariantEffect
---
--- # Blast #
---
--- @field Blast { Combat_VariantEffect }
--- @field Sound string
local _combat_VariantLook = {}

--- @class Combat_VariantEffect
---
--- # General #
---
--- @field Effect string
--- @field Color ColorSequence
--- @field Scale number
---
--- # Timing #
---
--- @field Every number?
---
--- # Placing #
---
--- @field Ring number?
--- @field RingRadius number?
--- @field Front number?
local _combat_VariantEffect = {}

--- @class Combat_VariantShot
---
--- # General #
---
--- @field Look Combat_VariantLook
--- @field Name string
---
--- # Look #
---
--- @field Carrier BasePart?
--- @field NextGlint number
local _combat_VariantShot = {}

--- @class Combat_VariantDress
---
--- # General #
---
--- @field Look Combat_VariantLook
--- @field Probe BasePart?
---
--- # Look #
---
--- @field Sheens { BasePart }
--- @field Outline Highlight
---
--- # Timing #
---
--- @field NextTwinkle number
--- @field NextDust number
local _combat_VariantDress = {}
