--[[
    Created By:     Frederico Macedo Pessoa, Marco Serpa Molinaro
    Edited By:      Nari
]]

local _localName = "BigNum"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local RADIX_LEN: number

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Parse Number Text

--[[
	Parses a number string into its sign and integer digits, shifting by any `e` exponent
	and truncating the fraction toward zero.
]]
--- @return string
--- @return string
local function parseNumberText(text: string)
	--[[ Sign ]]

	text = string.gsub(text, "%s+", "")

	local sign: string = "+"
	local firstCharacter: string = string.sub(text, 1, 1)

	if firstCharacter == "+" or firstCharacter == "-" then
		sign = firstCharacter
		text = string.sub(text, 2)
	end

	-- Treat an empty string as zero
	if text == "" then
		return "+", "0"
	end

	--[[ Exponent ]]

	local mantissa: string, exponentText: string? = string.match(text, "^([^eE]*)[eE](.*)$")
	local exponent: number = 0

	if mantissa then
		local parsedExponent: number? = tonumber(exponentText)

		-- Check if the exponent is a number
		if not parsedExponent then
			error(`[{_localName}::{script.Name}]: ({text}) is not a valid number!`, 3)
		end

		text = mantissa
		exponent = math.floor(parsedExponent)
	end

	--[[ Fraction ]]

	local integerDigits: string, fractionDigits: string? = string.match(text, "^(%d*)%.(%d*)$")

	if not integerDigits then
		integerDigits = text
		fractionDigits = ""
	end

	-- Check if only digits are left
	if string.find(integerDigits, "[^%d]") or (integerDigits == "" and fractionDigits == "") then
		error(`[{_localName}::{script.Name}]: ({text}) is not a valid number!`, 3)
	end

	--[[ Shifting ]]

	local allDigits: string = integerDigits .. fractionDigits
	local integerLength: number = #integerDigits + exponent
	local digits: string

	if integerLength <= 0 then
		digits = "0"
	elseif integerLength >= #allDigits then
		digits = allDigits .. string.rep("0", integerLength - #allDigits)
	else
		digits = string.sub(allDigits, 1, integerLength)
	end

	--[[ Returning ]]

	digits = string.gsub(digits, "^0+", "")

	if digits == "" then
		return "+", "0"
	end

	return sign, digits
end

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

--- @class BigNum_Helpers
local Helpers = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param bigNum BigNum
function Helpers.Init(bigNum)
	RADIX_LEN = bigNum._constants.RADIX_LEN
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Copy

--[[
	Copies the digits and sign of `source` into `target`.
]]
--- @param source BigNum_Instance
--- @param target BigNum_Instance
function Helpers.Copy(source, target)
	--[[ Checks ]]

	-- Check if both values were passed
	if source == nil or target == nil then
		error(`[{_localName}::{script.Name}]: Copy expects two BigNums!`, 2)
	end

	-- Skip copying a value onto itself
	if rawequal(source, target) then
		return
	end

	--[[ Copying ]]

	local oldLength: number = target.len or 0

	for index: number = 0, source.len - 1 do
		target[index] = source[index]
	end

	for index: number = source.len, oldLength - 1 do
		target[index] = nil
	end

	target.len = source.len
	target.signal = source.signal or "+"
end

--%%%%%%%%%%%%%%%%%%%% Change

--[[
	Replaces the value of a BigNum with a number, a number string (decimal and `e` notation allowed,
	fractions truncated), or another BigNum. Nil sets it to zero. Zero is always positive.
]]
--- @param target BigNum_Instance
--- @param value BigNum_Value?
function Helpers.Change(target, value)
	--[[ Checks ]]

	-- Check if the target is a table
	if type(target) ~= "table" then
		error(`[{_localName}::{script.Name}]: Change expects a BigNum, got ({typeof(target)})!`, 2)
	end

	--[[ Copying ]]

	if type(value) == "table" and value.len ~= nil then
		Helpers.Copy(value, target)
		return
	end

	--[[ Checks ]]

	-- Check if the value can be parsed
	if value ~= nil and type(value) ~= "string" and type(value) ~= "number" then
		error(`[{_localName}::{script.Name}]: Cannot create a BigNum from ({typeof(value)})!`, 2)
	end

	-- Check if the number is finite
	if type(value) == "number" and (value ~= value or value == math.huge or value == -math.huge) then
		error(`[{_localName}::{script.Name}]: Cannot create a BigNum from ({value})!`, 2)
	end

	--[[ Parsing ]]

	local sign: string, digits: string = parseNumberText(if value == nil then "0" else tostring(value))

	--[[ Writing ]]

	local oldLength: number = target.len or 0
	local length: number = 0
	local endIndex: number = #digits

	while endIndex >= 1 do
		local startIndex: number = math.max(endIndex - RADIX_LEN + 1, 1)
		target[length] = tonumber(string.sub(digits, startIndex, endIndex))
		length += 1
		endIndex = startIndex - 1
	end

	for index: number = length, oldLength - 1 do
		target[index] = nil
	end

	target.len = length
	target.signal = sign
end

--%%%%%%%%%%%%%%%%%%%% Put

--[[
	Sets a BigNum to `int` at block `pos` with zeros below it (int * RADIX^pos). Used by the division estimator.
]]
--- @param target BigNum_Instance
function Helpers.Put(target, int: number, pos: number?)
	--[[ Checks ]]

	-- Check if the target was passed
	if target == nil then
		error(`[{_localName}::{script.Name}]: Put expects a BigNum!`, 2)
	end

	--[[ Local Variables ]]

	local position: number = math.max(pos or 0, 0)
	local oldLength: number = target.len or 0

	--[[ Writing ]]

	for index: number = 0, position - 1 do
		target[index] = 0
	end

	target[position] = int

	for index: number = position + 1, oldLength - 1 do
		target[index] = nil
	end

	target.len = position + 1
end

return Helpers
