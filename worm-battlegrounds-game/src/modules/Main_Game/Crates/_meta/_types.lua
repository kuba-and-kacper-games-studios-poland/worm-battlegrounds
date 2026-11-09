--%%%%%%%%%%%%%%%%%%%% Crates

--- @class Crates_CrateData
---
--- # General #
---
--- @field Name string
--- @field TabName string
--- @field Picture string
--- @field LayoutOrder number
--- @field Hidden boolean
---
--- # Contents #
---
--- @field Prices { [string]: Crates_Price }
--- @field OddsByCurrency { [string]: { [string]: number } }
--- @field Fixed { string }
local _crates_CrateData = {}

--- @class Crates_Price
---
--- # General #
---
--- @field One string
--- @field Three string
--- @field Ten string
local _crates_Price = {}

--- @class Crates_Result
---
--- # General #
---
--- @field ItemId string
--- @field Copies number
--- @field JustShiny boolean
local _crates_Result = {}
