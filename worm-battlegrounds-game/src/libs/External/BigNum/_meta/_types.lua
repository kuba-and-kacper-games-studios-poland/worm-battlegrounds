--%%%%%%%%%%%%%%%%%%%% Instance

--[[
	Arbitrary-size integer. Digits are stored little-endian in base 10^7 blocks at indices 0 .. len - 1.
	Supports `+ - * / ^ == < <= unary-` and `tostring`. `/` truncates toward zero.
]]
--- @class BigNum_Instance
---
--- # Value #
---
--- @field len number
--- @field signal "+" | "-"
local _bigNum_Instance = {}

--- @alias BigNum_Value number | string | BigNum_Instance

--%%%%%%%%%%%%%%%%%%%% Constants

--[[
	Constants shared between the BigNum scripts.
]]
--- @class BigNum_Constants
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
