--%%%%%%%%%%%%%%%%%%%% Progress

--- @class Progression_Progress
---
--- # Level #
---
--- @field Level number
--- @field Into number
--- @field For number
local _progression_Progress = {}

--%%%%%%%%%%%%%%%%%%%% Replay

--- @class Progression_XpLine
---
--- # General #
---
--- @field Key string
--- @field Label string
---
--- # Amount #
---
--- @field Count number
--- @field Amount number
local _progression_XpLine = {}

--- @class Progression_Replay
---
--- # Lines #
---
--- @field Lines { Progression_XpLine }
---
--- # Level #
---
--- @field Before Progression_Progress
--- @field After Progression_Progress
--- @field Costs { number }
local _progression_Replay = {}

--%%%%%%%%%%%%%%%%%%%% Frames

--- @class Progression_Tier
---
--- # General #
---
--- @field Name string
--- @field Level number
---
--- # Look #
---
--- @field Colors { Color3 }
--- @field Shine boolean
--- @field Spin boolean
local _progression_Tier = {}
