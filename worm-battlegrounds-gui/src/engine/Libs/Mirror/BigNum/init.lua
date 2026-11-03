--[[
    Created By:     Frederico Macedo Pessoa, Marco Serpa Molinaro
    Edited By:      Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

local RADIX: number = 10 ^ 7
local RADIX_LEN: number = 7
local METATABLE_TAG: string = "BigNum"

--- @type { string }
local ABBREVIATIONS = { "k", "m", "b", "t", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

for first: number = string.byte("a"), string.byte("z") do
	for second: number = string.byte("a"), string.byte("z") do
		table.insert(ABBREVIATIONS, string.char(first, second))
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Helpers = require(_scripts:FindFirstChild("Helpers")) --- @type UmeGui_BigNum_Helpers
local Comparison = require(_scripts:FindFirstChild("Comparison")) --- @type UmeGui_BigNum_Comparison
local Arithmetic = require(_scripts:FindFirstChild("Arithmetic")) --- @type UmeGui_BigNum_Arithmetic
local Precise = require(_scripts:FindFirstChild("Precise")) --- @type UmeGui_BigNum_Precise
local Convert = require(_scripts:FindFirstChild("Convert")) --- @type UmeGui_BigNum_Convert
local Metatable = require(_scripts:FindFirstChild("Metatable")) --- @type UmeGui_BigNum_Metatable

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   __       __                  __            __
--  /  \     /  |                /  |          /  |
--  $$  \   /$$ |  ______    ____$$ | __    __ $$ |  ______
--  $$$  \ /$$$ | /      \  /    $$ |/  |  /  |$$ | /      \
--  $$$$  /$$$$ |/$$$$$$  |/$$$$$$$ |$$ |  $$ |$$ |/$$$$$$  |
--  $$ $$ $$/$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |$$    $$ |
--  $$ |$$$/ $$ |$$ \__$$ |$$ \__$$ |$$ \__$$ |$$ |$$$$$$$$/
--  $$ | $/  $$ |$$    $$/ $$    $$ |$$    $$/ $$ |$$       |
--  $$/      $$/  $$$$$$/   $$$$$$$/  $$$$$$/  $$/  $$$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- @class UmeGui_BigNum : Ume_Library
local BigNum = {

	--[[ Internal ]]

	--- @type UmeGui_BigNum_Constants
	_constants = {
		RADIX = RADIX,
		RADIX_LEN = RADIX_LEN,
		ABBREVIATIONS = ABBREVIATIONS,
	},

	--[[ Metatable ]]

	mt = {
		__metatable = METATABLE_TAG,

		__add = Metatable.Add,
		__sub = Metatable.Sub,
		__mul = Metatable.Mul,
		__div = Metatable.Div,
		__pow = Metatable.Pow,
		__unm = Metatable.Unm,

		__eq = Metatable.Eq,
		__lt = Metatable.Lt,
		__le = Metatable.Le,

		__tostring = Metatable.ToString,
	},

	--[[ Helpers ]]

	Copy = Helpers.Copy,
	Change = Helpers.Change,
	Put = Helpers.Put,

	--[[ Comparison ]]

	Eq = Comparison.Eq,
	Lt = Comparison.Lt,
	Le = Comparison.Le,
	Compare = Comparison.Compare,
	CompareAbs = Comparison.CompareAbs,

	--[[ Arithmetic ]]

	Add = Arithmetic.Add,
	Sub = Arithmetic.Sub,
	Mul = Arithmetic.Mul,
	Div = Arithmetic.Div,
	Pow = Arithmetic.Pow,

	--[[ Precise ]]

	Power = Precise.Power,
	MultiplyWithPrecision = Precise.MultiplyWithPrecision,
	DivideWithPrecision = Precise.DivideWithPrecision,
	PowerWithPrecision = Precise.PowerWithPrecision,
	Percentage = Precise.Percentage,

	--[[ Convert ]]

	AbbreviationConvert = Convert.AbbreviationConvert,
	AbbreviationConvertFormatted = Convert.AbbreviationConvertFormatted,
	ConvertFromAbbreviation = Convert.ConvertFromAbbreviation,
	FormatWithSeparator = Convert.FormatWithSeparator,
	DynamicFormat = Convert.DynamicFormat,
}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function BigNum._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.BN = BigNum --- @type UmeGui_BigNum
end

--%%%%%%%%%%%%%%%%%%%% New

--[[
	Creates a BigNum from a number, an integer / decimal / scientific string, or another BigNum (copied).
	Fractions are truncated toward zero. No value creates zero.
]]
--- @param value UmeGui_BigNum_Value?
--- @return UmeGui_BigNum_Instance
function BigNum.new(value)
	--[[ Creating ]]

	local bigNum = setmetatable({}, BigNum.mt)
	Helpers.Change(bigNum, value)

	--[[ Returning ]]

	return bigNum
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Big Num

--[[
	Returns whether the value is a BigNum instance.
]]
--- @return boolean
function BigNum.IsBigNum(value: any)
	return type(value) == "table" and getmetatable(value) == METATABLE_TAG
end

--%%%%%%%%%%%%%%%%%%%% To Big Num

--[[
	Returns the value itself when it is a BigNum, otherwise a new BigNum built from it.
]]
--- @param value UmeGui_BigNum_Value?
--- @return UmeGui_BigNum_Instance
function BigNum.ToBigNum(value)
	--[[ Returning ]]

	if BigNum.IsBigNum(value) then
		return value
	end

	return BigNum.new(value)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Setup

Helpers.Init(BigNum)
Arithmetic.Init(BigNum)
Precise.Init(BigNum)
Convert.Init(BigNum)
Metatable.Init(BigNum)

return BigNum
