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
