--%%%%%%%%%%%%%%%%%%%% Presets

--[[
	Ball socket limits for one joint group.
]]
--- @class Ragdoll_JointLimits
---
--- # Limits #
---
--- @field UpperAngle number
--- @field TwistLowerAngle number
--- @field TwistUpperAngle number
---
--- # Damping #
---
--- @field MaxFrictionTorque number
local _ragdoll_JointLimits = {}

--[[
	How a ragdoll feels: joint limits, launch motion, and collider physics.
]]
--- @class Ragdoll_Preset
---
--- # Joints #
---
--- @field Joints { [string]: Ragdoll_JointLimits }
--- @field Root Ragdoll_JointLimits
--- @field KeepUpright boolean
---
--- # Rig Sockets #
---
--- @field LimitScale number
--- @field FrictionScale number
---
--- # Launch #
---
--- @field LaunchMultiplier number
--- @field SpinSpeed number
--- @field LimbFlail number
---
--- # Collider #
---
--- @field ColliderDensity number
--- @field ColliderFriction number
--- @field ColliderElasticity number
local _ragdoll_Preset = {}

--%%%%%%%%%%%%%%%%%%%% Start Options

--[[
	Options for `Ragdoll.Start`. Every field is optional.
]]
--- @class Ragdoll_StartOptions
---
--- # Feel #
---
--- @field Preset string | Ragdoll_Preset | nil
---
--- # Launch #
---
--- @field Velocity Vector3?
---
--- # Timing #
---
--- @field Duration number?
local _ragdoll_StartOptions = {}

--%%%%%%%%%%%%%%%%%%%% Collision

--[[
	Collision state of one body part saved before ragdolling.
]]
--- @class Ragdoll_SavedCollision
---
--- # Part #
---
--- @field Part BasePart
--- @field CanCollide boolean
local _ragdoll_SavedCollision = {}

--%%%%%%%%%%%%%%%%%%%% Saved Limits

--[[
	Original limits of a socket the rig shipped with, restored after ragdolling.
]]
--- @class Ragdoll_SavedLimits : Ragdoll_JointLimits
---
--- # Toggles #
---
--- @field LimitsEnabled boolean
--- @field TwistLimitsEnabled boolean
local _ragdoll_SavedLimits = {}

--%%%%%%%%%%%%%%%%%%%% Rig Cache

--[[
	Per-model cache of the joints, constraints, and state the ragdoll toggles.
]]
--- @class Ragdoll_RigCache
---
--- # Joints #
---
--- @field Motors { Motor6D }
--- @field AnimationJoints { AnimationConstraint }
---
--- # Constraints #
---
--- @field Sockets { BallSocketConstraint }
--- @field ForeignSockets { BallSocketConstraint }
--- @field SavedLimits { [BallSocketConstraint]: Ragdoll_SavedLimits }?
--- @field RootSocket BallSocketConstraint?
--- @field RootSocketOwned boolean
--- @field RootAlign AlignOrientation?
--- @field RootWelds { WeldConstraint }
---
--- # Collision #
---
--- @field Colliders { BasePart }?
--- @field SavedCollision { Ragdoll_SavedCollision }?
---
--- # State #
---
--- @field Active boolean
--- @field Scanned boolean
--- @field FoundFolder boolean
--- @field EndsAt number?
local _ragdoll_RigCache = {}
