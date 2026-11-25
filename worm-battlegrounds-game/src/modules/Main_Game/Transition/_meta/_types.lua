--%%%%%%%%%%%%%%%%%%%% Destination

--- @class Transition_Destination
---
--- # General #
---
--- @field Kicker string
--- @field Title string
--- @field MapId string?
---
--- # Match #
---
--- @field Mode string?
--- @field ModeIcon string?
--- @field Detail string?
---
--- # Searching #
---
--- @field Pool { string }?
local _transition_Destination = {}

--%%%%%%%%%%%%%%%%%%%% Looks

--- @class Transition_Look
---
--- # Scene #
---
--- @field Sky string?
--- @field Horizon number
---
--- # Colours #
---
--- @field Accent Color3
--- @field Weather string
local _transition_Look = {}

--- @class Transition_WeatherRow
---
--- # Amount #
---
--- @field Count number
--- @field Low boolean?
---
--- # Look #
---
--- @field Colors { Color3 }
--- @field Transparency NumberRange
--- @field Size NumberRange
--- @field Thick number?
---
--- # Motion #
---
--- @field Depth NumberRange
--- @field SpeedX NumberRange
--- @field SpeedY NumberRange
--- @field Wobble number
--- @field Bob number
--- @field Spin number
local _transition_WeatherRow = {}
