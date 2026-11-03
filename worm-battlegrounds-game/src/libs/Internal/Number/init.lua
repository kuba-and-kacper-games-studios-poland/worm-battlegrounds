--[[
    Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

local LOG10_SCALE_BASE: number = math.log10(1.0000000001)
local LN_10: number = math.log(10)
local LOG_SCALE_MAX: number = 9007199254740991
local LOG_SCALE_ENCODE_DIGITS: number = 15
local LOG_SCALE_DECODE_DIGITS: number = 9

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

--- @class Ume_Library_Number : Ume_Library
local Number = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function Number._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.Number = Number --- @type Ume_Library_Number
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Lerp

--[[
	Linearly interpolates from `a` to `b` with `t` clamped to [0, 1].
]]
--- @return number
function Number.Lerp(a: number, b: number, t: number)
	return a + (b - a) * math.clamp(t, 0, 1)
end

--%%%%%%%%%%%%%%%%%%%% Normalize

--[[
	Clamps `value` to the input range and maps it onto the output range.
	Reversed ranges are supported on both sides.
]]
--- @return number
function Number.Normalize(value: number, inputMin: number, inputMax: number, outputMin: number, outputMax: number)
	--[[ Checks ]]

	-- Map a zero-width input range onto the start of the output range
	if inputMin == inputMax then
		return outputMin
	end

	--[[ Calculating ]]

	local clampedValue: number = math.clamp(value, math.min(inputMin, inputMax), math.max(inputMin, inputMax))
	local alpha: number = (clampedValue - inputMin) / (inputMax - inputMin)

	--[[ Returning ]]

	return outputMin + alpha * (outputMax - outputMin)
end

--%%%%%%%%%%%%%%%%%%%% To Number Or

--[[
	Converts `value` with `tonumber` and returns it when it is finite, otherwise `default`.
]]
--- @return number
function Number.ToNumberOr(value: any, default: number)
	--[[ Converting ]]

	local converted: number? = tonumber(value)

	--[[ Checks ]]

	-- Check if the value is a finite number
	if not converted or converted ~= converted or converted == math.huge or converted == -math.huge then
		return default
	end

	--[[ Returning ]]

	return converted
end

--%%%%%%%%%%%%%%%%%%%% Is Integer String

--[[
	Returns whether `s` is a base-10 integer string with an optional leading minus.
]]
--- @return boolean
function Number.IsIntegerString(s: string)
	--[[ Checks ]]

	-- Check if the value is a string
	if type(s) ~= "string" then
		return false
	end

	--[[ Returning ]]

	return string.match(s, "^%-?%d+$") ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Is Number String

--[[
	Returns whether `s` is a base-10 number string that may include a fractional part.
]]
--- @return boolean
function Number.IsNumberString(s: string)
	--[[ Checks ]]

	-- Check if the value is a string
	if type(s) ~= "string" then
		return false
	end

	--[[ Returning ]]

	return string.match(s, "^%-?%d+$") ~= nil or string.match(s, "^%-?%d*%.%d+$") ~= nil
end

--%%%%%%%%%%%%%%%%%%%% To Log Scale

--[[
	Encodes a positive integer string as `floor(log(value) / log(1.0000000001))`, for storing huge values in an OrderedDataStore.
	Zero, empty, and non-integer strings encode to 0. One also encodes to 0.
]]
--- @return number
function Number.ToLogScale(value: string)
	--[[ Checks ]]

	-- Check if the value is a non-negative integer string
	if type(value) ~= "string" or string.match(value, "^%d+$") == nil then
		return 0
	end

	local stripped: string = string.gsub(value, "^0+", "")

	-- Check if the value is zero
	if stripped == "" then
		return 0
	end

	--[[ Calculating ]]

	local length: number = #stripped
	local take: number = math.min(LOG_SCALE_ENCODE_DIGITS, length)
	local head: number = tonumber(string.sub(stripped, 1, take)) or 0
	local mantissa: number = head / 10 ^ (take - 1)
	local log10Value: number = (length - 1) + math.log10(mantissa)
	local stored: number = math.floor(log10Value / LOG10_SCALE_BASE)

	-- Clamp at 2^53-1 so the integer stays exact and under the ordered page max (past ~391000 digits every value ties)
	if stored < 0 then
		stored = 0
	elseif stored > LOG_SCALE_MAX then
		stored = LOG_SCALE_MAX
	end

	--[[ Returning ]]

	return stored
end

--%%%%%%%%%%%%%%%%%%%% From Log Scale

--[[
	Decodes a `ToLogScale` integer back to an approximate positive integer string.
	Zero and invalid inputs return "0". The tail digits are padded with zeros, so huge values are not exact.
]]
--- @return string
function Number.FromLogScale(stored: number)
	--[[ Checks ]]

	-- Check if the value is a positive number
	if type(stored) ~= "number" or stored ~= stored or stored <= 0 then
		return "0"
	end

	stored = math.floor(stored)

	-- Clamp to the largest value `ToLogScale` can produce
	if stored > LOG_SCALE_MAX then
		stored = LOG_SCALE_MAX
	end

	--[[ Calculating ]]

	local log10Value: number = stored * LOG10_SCALE_BASE
	local exponent: number = math.floor(log10Value)
	local fraction: number = log10Value - exponent
	local mantissa: number = math.exp(fraction * LN_10)
	local scale: number = 10 ^ (LOG_SCALE_DECODE_DIGITS - 1)
	local leading: number = math.floor(mantissa * scale + 0.5)
	local digitCount: number = exponent + 1

	-- Carry an extra digit when the mantissa rounds up to 10
	if leading >= 10 ^ LOG_SCALE_DECODE_DIGITS then
		leading = math.floor(leading / 10)
		digitCount += 1
	end

	local text: string = string.format("%d", leading)

	--[[ Returning ]]

	if digitCount <= #text then
		return string.sub(text, 1, digitCount)
	end

	return text .. string.rep("0", digitCount - #text)
end

return Number
