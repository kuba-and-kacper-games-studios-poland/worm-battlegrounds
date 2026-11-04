--%%%%%%%%%%%%%%%%%%%% Rows

--- @class MatchBoard_RowOption
---
--- # General #
---
--- @field Mode string
--- @field Size number
local _matchBoard_RowOption = {}

--- @class MatchBoard_MapRow
---
--- # General #
---
--- @field Name string
--- @field Sizes { number }
--- @field Thumbnail string
local _matchBoard_MapRow = {}

--- @class MatchBoard_Row
---
--- # General #
---
--- @field Id string
--- @field Config Configuration
--- @field Kind "Public" | "Custom"
---
--- # Match #
---
--- @field Mode string
--- @field Size number
--- @field MapId string
---
--- # Players #
---
--- @field Players { number }
--- @field Votes { [number]: boolean }
--- @field EndsAt number
--- @field Owner number?
local _matchBoard_Row = {}
