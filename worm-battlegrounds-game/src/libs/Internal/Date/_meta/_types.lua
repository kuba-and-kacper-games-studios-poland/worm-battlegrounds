--%%%%%%%%%%%%%%%%%%%% Date Table

--[[
	Date table in the `os.date("*t")` / `os.date("!*t")` shape.
]]
--- @class Date_DateTable
---
--- # Date #
---
--- @field year number
--- @field month number
--- @field day number
--- @field wday number
--- @field yday number?
---
--- # Time #
---
--- @field hour number
--- @field min number
--- @field sec number
--- @field isdst boolean?
local _date_DateTable = {}
