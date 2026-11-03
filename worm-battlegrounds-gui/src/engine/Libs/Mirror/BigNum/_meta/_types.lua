--%%%%%%%%%%%%%%%%%%%% Instance

--[[
	Arbitrary-size integer. Digits are stored little-endian in base 10^7 blocks at indices 0 .. len - 1.
	Supports `+ - * / ^ == < <= unary-` and `tostring`. `/` truncates toward zero.
]]
--- @class UmeGui_BigNum_Instance
---
--- # Value #
---
--- @field len number
--- @field signal "+" | "-"
local _bigNum_Instance = {}

--- @alias UmeGui_BigNum_Value number | string | UmeGui_BigNum_Instance

--%%%%%%%%%%%%%%%%%%%% Constants

--[[
	Constants shared between the BigNum scripts.
]]
--- @class UmeGui_BigNum_Constants
---
--- # Radix #
---
--- @field RADIX number
--- @field RADIX_LEN number
---
--- # Abbreviations #
---
--- @field ABBREVIATIONS { string }
local _bigNum_Constants = {}
