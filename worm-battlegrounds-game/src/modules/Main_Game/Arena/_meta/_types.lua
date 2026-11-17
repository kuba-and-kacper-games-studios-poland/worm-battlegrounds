--%%%%%%%%%%%%%%%%%%%% Liquid

--- @class Arena_LiquidRect
---
--- # Cells #
---
--- @field Start number
--- @field Length number
--- @field Row number
--- @field Height number
---
--- # Look #
---
--- @field Kind number
local _arena_LiquidRect = {}

--%%%%%%%%%%%%%%%%%%%% Prediction

--- @class Arena_PendingCarve
---
--- # General #
---
--- @field Id number
---
--- # Blast #
---
--- @field Center Vector3
--- @field Radius number
local _arena_PendingCarve = {}

--- @class Arena_Prediction
---
--- # Pieces #
---
--- @field Pieces { BasePart }
---
--- # Carve #
---
--- @field CarveId number
local _arena_Prediction = {}

--%%%%%%%%%%%%%%%%%%%% Debris

--- @class Arena_Fall
---
--- # Parts #
---
--- @field Parts { BasePart }
---
--- # Fall #
---
--- @field Drop number
--- @field Started number
local _arena_Fall = {}

--%%%%%%%%%%%%%%%%%%%% Props

--- @class Arena_PropBox
---
--- # Box #
---
--- @field CFrame CFrame
--- @field Size Vector3
---
--- # Changes #
---
--- @field Version number
local _arena_PropBox = {}

--- @class Arena_PropState
---
--- # Carve #
---
--- @field Carve number
--- @field Busy boolean
--- @field Gone boolean
---
--- # Parts #
---
--- @field Pieces { [BasePart]: boolean }
--- @field Hidden { [BasePart]: boolean }
---
--- # Server #
---
--- @field Connection RBXScriptConnection?
local _arena_PropState = {}

--- @class Arena_ThrownGroup
---
--- # Parts #
---
--- @field Parts { BasePart }
--- @field Owned { [BasePart]: boolean }
--- @field Offsets { CFrame }
--- @field Transparencies { number }
--- @field Homes { [BasePart]: Instance }
--- @field Origins { [BasePart]: CFrame }
---
--- # Motion #
---
--- @field Frame CFrame
--- @field Start CFrame
--- @field Size Vector3
--- @field Velocity Vector3
--- @field Spin number
--- @field Drop number?
--- @field Still boolean
---
--- # Timing #
---
--- @field Started number
--- @field Last number
local _arena_ThrownGroup = {}
