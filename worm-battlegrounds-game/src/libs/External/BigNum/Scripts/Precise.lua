--[[
    Created By:     Nari
]]

local _localName = "BigNum"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

local MAX_PRECISION: number = 9
local DEFAULT_PERCENTAGE_PRECISION: number = 2
local DEFAULT_POWER_PRECISION: number = 6
local MAX_EXPONENT_DECIMALS: number = 2
local MAX_EXACT_INTEGER: number = 2 ^ 53

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local BigNum --- @type BigNum

local powersOfTen = {} --- @type { [number]: BigNum_Instance }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Clamp Precision

--[[
	Returns the precision as a whole number between 0 and 9, or `default` when it is not a number.
]]
--- @return number
local function clampPrecision(precision: any, default: number)
	return math.clamp(math.floor(tonumber(precision) or default), 0, MAX_PRECISION)
end

--%%%%%%%%%%%%%%%%%%%% Power Of Ten

--[[
	Returns 10^exponent as a BigNum. Precision-sized powers are cached, so do not modify the result.
]]
--- @return BigNum_Instance
local function powerOfTen(exponent: number)
	--[[ Checks ]]

	-- Return the cached power when there is one
	if powersOfTen[exponent] then
		return powersOfTen[exponent]
	end

	--[[ Creating ]]

	local value = BigNum.new("1" .. string.rep("0", exponent))

	if exponent <= MAX_PRECISION * 2 then
		powersOfTen[exponent] = value
	end

	--[[ Returning ]]

	return value
end

--%%%%%%%%%%%%%%%%%%%% Divide Rounded

--[[
	Returns `numerator / denominator` rounded half away from zero.
]]
--- @param numerator BigNum_Instance
--- @param denominator BigNum_Instance
--- @return BigNum_Instance
local function divideRounded(numerator, denominator)
	--[[ Local Variables ]]

	local quotient = numerator / denominator
	local doubledRemainder = (numerator - quotient * denominator) * BigNum.new(2)
	local absDoubledRemainder = if doubledRemainder.signal == "-" then -doubledRemainder else doubledRemainder
	local absDenominator = if denominator.signal == "-" then -denominator else denominator

	--[[ Rounding ]]

	-- Round away from zero once the remainder reaches half of the divisor
	if absDoubledRemainder >= absDenominator then
		if (numerator.signal == "-") == (denominator.signal == "-") then
			quotient = quotient + BigNum.new(1)
		else
			quotient = quotient - BigNum.new(1)
		end
	end

	--[[ Returning ]]

	return quotient
end

--%%%%%%%%%%%%%%%%%%%% To Scaled

--[[
	Converts a number, number string, or BigNum into a BigNum of `round(value * 10^precision)`, half away from zero.
	Numbers that fit in an integer use `math.round`. Everything else works on the decimal text, so decimal strings and huge values keep every digit.
]]
--- @param value BigNum_Value
--- @return BigNum_Instance
local function toScaled(value, precision: number)
	--[[ Checks ]]

	-- Check if the value can be converted
	if not BigNum.IsBigNum(value) and type(value) ~= "number" and type(value) ~= "string" then
		error(`[{_localName}::{script.Name}]: Expected a number, string, or BigNum, got ({typeof(value)})!`, 3)
	end

	--[[ Number ]]

	if type(value) == "number" then
		local scaledNumber: number = value * 10 ^ precision

		-- Round in place while the result stays an exact integer
		if math.abs(scaledNumber) < MAX_EXACT_INTEGER then
			return BigNum.new(math.round(scaledNumber))
		end
	end

	--[[ Text ]]

	-- Shift one extra decimal so the digit after `precision` decides the rounding
	local text: string = tostring(value)
	local shift: number = precision + 1
	local mantissa: string?, exponent: string? = string.match(text, "^(.-)[eE]([%+%-]?%d+)$")
	local shifted = if mantissa and exponent then BigNum.new(`{mantissa}e{tonumber(exponent) + shift}`) else BigNum.new(`{text}e{shift}`)

	--[[ Returning ]]

	return divideRounded(shifted, BigNum.new(10))
end

--%%%%%%%%%%%%%%%%%%%% Is Zero

--[[
	Returns whether a BigNum is zero.
]]
--- @param bigNum BigNum_Instance
--- @return boolean
local function isZero(bigNum)
	return bigNum.len == 1 and bigNum[0] == 0
end

--%%%%%%%%%%%%%%%%%%%% Integer Root

--[[
	Returns floor(value^(1/degree)) for a non-negative BigNum, using Newton's method from an upper bound.
]]
--- @param value BigNum_Instance
--- @return BigNum_Instance
local function integerRoot(value, degree: number)
	--[[ Checks ]]

	-- Skip the search when the root is the value itself
	if degree == 1 or isZero(value) then
		return value
	end

	--[[ Local Variables ]]

	local degreeBigNum = BigNum.new(degree)
	local degreeMinusOne = BigNum.new(degree - 1)
	local estimate = powerOfTen(math.ceil(#tostring(value) / degree))

	--[[ Iterating ]]

	while true do
		local nextEstimate = (degreeMinusOne * estimate + value / BigNum.Power(estimate, degree - 1)) / degreeBigNum

		-- Stop once the estimate no longer decreases
		if nextEstimate >= estimate then
			return estimate
		end

		estimate = nextEstimate
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Greatest Common Divisor

--[[
	Returns the greatest common divisor of two whole numbers.
]]
--- @return number
local function getGreatestCommonDivisor(a: number, b: number)
	--[[ Calculating ]]

	while b ~= 0 do
		a, b = b, a % b
	end

	--[[ Returning ]]

	return a
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

--- @class BigNum_Precise
local Precise = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param bigNum BigNum
function Precise.Init(bigNum)
	BigNum = bigNum
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Power

--[[
	Returns `base ^ exponent` for a whole exponent (negative exponents count as 0). The base is rounded to a whole number.
]]
--- @param base BigNum_Value
--- @return BigNum_Instance
function Precise.Power(base, exponent: number)
	--[[ Local Variables ]]

	local remaining: number = math.floor(math.max(tonumber(exponent) or 0, 0))
	local square = toScaled(base, 0)
	local result = BigNum.new(1)

	--[[ Calculating ]]

	while remaining > 0 do
		if remaining % 2 == 1 then
			result = result * square
		end

		remaining = remaining // 2

		if remaining > 0 then
			square = square * square
		end
	end

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%% Multiply With Precision

--[[
	Returns `a * b` as a whole BigNum (truncated). Each input is rounded to `precision` decimals (0–9, default 0) first.
]]
--- @param a BigNum_Value
--- @param b BigNum_Value
--- @return BigNum_Instance
function Precise.MultiplyWithPrecision(a, b, precision: number?)
	--[[ Local Variables ]]

	local resolvedPrecision: number = clampPrecision(precision, 0)

	--[[ Returning ]]

	return (toScaled(a, resolvedPrecision) * toScaled(b, resolvedPrecision)) / powerOfTen(resolvedPrecision * 2)
end

--%%%%%%%%%%%%%%%%%%%% Divide With Precision

--[[
	Returns `a / b` as a whole BigNum (truncated toward zero). Each input is rounded to `precision` decimals (0–9, default 0) first.
]]
--- @param a BigNum_Value
--- @param b BigNum_Value
--- @return BigNum_Instance
function Precise.DivideWithPrecision(a, b, precision: number?)
	--[[ Local Variables ]]

	local resolvedPrecision: number = clampPrecision(precision, 0)
	local divisor = toScaled(b, resolvedPrecision)

	--[[ Checks ]]

	-- Check if the divisor is zero
	if isZero(divisor) then
		error(`[{_localName}::{script.Name}]: Division by zero!`, 2)
	end

	--[[ Returning ]]

	return toScaled(a, resolvedPrecision) / divisor
end

--%%%%%%%%%%%%%%%%%%%% Power With Precision

--[[
	Returns `base ^ exponent` as a whole BigNum (truncated), supporting decimal bases and exponents.
	The exponent is rounded to 2 decimals and may be negative. `precision` (0–9, default 6) is the number of
	decimals the base is rounded to and used while taking roots.
]]
--- @param base BigNum_Value
--- @return BigNum_Instance
function Precise.PowerWithPrecision(base, exponent: number, precision: number?)
	--[[ Local Variables ]]

	local resolvedPrecision: number = clampPrecision(precision, DEFAULT_POWER_PRECISION)
	local resolvedExponent: number = tonumber(exponent) or 0

	--[[ Checks ]]

	-- Check if the exponent is finite
	if resolvedExponent ~= resolvedExponent or math.abs(resolvedExponent) == math.huge then
		error(`[{_localName}::{script.Name}]: Exponent must be a finite number!`, 2)
	end

	-- Return 1 for a zero exponent
	if resolvedExponent == 0 then
		return BigNum.new(1)
	end

	--[[ Exponent ]]

	local exponentScale: number = 10 ^ MAX_EXPONENT_DECIMALS
	local numerator: number = math.round(math.abs(resolvedExponent) * exponentScale)
	local divisor: number = getGreatestCommonDivisor(numerator, exponentScale)
	local power: number = numerator // divisor
	local degree: number = exponentScale // divisor

	--[[ Base ]]

	local scaledBase = toScaled(base, resolvedPrecision)

	--[[ Checks ]]

	-- Check if a root of a negative base is requested
	if scaledBase.signal == "-" and not isZero(scaledBase) and degree > 1 then
		error(`[{_localName}::{script.Name}]: Cannot take a fractional power of a negative base!`, 2)
	end

	--[[ Calculating ]]

	-- Scale base^power so its root lands at base^(power/degree) * 10^precision
	local shift: number = resolvedPrecision * (degree - power)
	local radicand = Precise.Power(scaledBase, power)

	if shift >= 0 then
		radicand *= powerOfTen(shift)
	else
		radicand /= powerOfTen(-shift)
	end

	local scaledResult = integerRoot(radicand, degree)

	--[[ Negative Exponent ]]

	if resolvedExponent < 0 then
		-- Check if the result can be inverted
		if isZero(scaledResult) then
			error(`[{_localName}::{script.Name}]: Zero cannot be raised to a negative exponent!`, 2)
		end

		scaledResult = powerOfTen(resolvedPrecision * 2) / scaledResult
	end

	--[[ Returning ]]

	return scaledResult / powerOfTen(resolvedPrecision)
end

--%%%%%%%%%%%%%%%%%%%% Percentage

--[[
	Returns `a / b` as a regular number rounded to `precision` decimals (0–9, default 2), for example 2 / 3 -> 0.67.
	The division runs on BigNums scaled by 10^precision, so huge values keep their ratio. Returns 0 when `b` is 0.
]]
--- @param a BigNum_Value
--- @param b BigNum_Value
--- @return number
function Precise.Percentage(a, b, precision: number?)
	--[[ Local Variables ]]

	local resolvedPrecision: number = clampPrecision(precision, DEFAULT_PERCENTAGE_PRECISION)
	local precisionBigNum = powerOfTen(resolvedPrecision)
	local scaledA = toScaled(a, resolvedPrecision) * precisionBigNum
	local scaledB = toScaled(b, resolvedPrecision)

	--[[ Checks ]]

	-- Return 0 when dividing by zero
	if isZero(scaledB) then
		return 0
	end

	--[[ Returning ]]

	local result: number = tonumber(tostring(divideRounded(scaledA, scaledB))) or 0

	return result / 10 ^ resolvedPrecision
end

return Precise
