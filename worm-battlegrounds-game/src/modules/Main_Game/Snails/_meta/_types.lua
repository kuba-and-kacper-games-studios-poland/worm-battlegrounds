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
--- @field DamageTaken number?
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
