--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Scaling"

--- @type Scaling_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Validation ]]

--- @type { [string]: boolean }
local KNOWN_CURVES = {
	["legacy"] = true,
	["linear"] = true,
	["polynomial"] = true,
	["exponential"] = true,
	["bandexponential"] = true,
	["piecewise"] = true,
	["power"] = true,
	["bigpower"] = true,
}

--- @type { string }
local NUMERIC_FIELDS = { "Base", "Growth", "Exponent", "Add", "Mul", "Min", "Max", "SoftCap", "SoftCapPower", "Precision" }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Check Segments

--[[
	Warns when a definition's Pieces or Bands entry has a non-numeric order key or value, or is below the previous entry.
	Returns whether every entry is valid.
]]
--- @param list { { [string]: any } }
--- @return boolean
local function _checkSegments(valueName: string, listName: string, list, orderKey: string, valueKey: string)
	--[[ Local Variables ]]

	local isValid: boolean = true
	local previous: number = -math.huge

	--[[ Checking ]]

	--- @param entry { [string]: any }
	for index: number, entry in ipairs(list) do
		local order: number? = tonumber(entry[orderKey])
		local value: any = entry[valueKey]

		-- Check if the order key is a number not below the previous one
		if order == nil or order < previous then
			warn(`[{_localName}::{script.Name}]: Value ({valueName}) {listName}[{index}].{orderKey} must be a number in ascending order!`)
			isValid = false
		end

		-- Check if a constant value parses as a number
		if type(value) ~= "function" and tonumber(value) == nil then
			warn(`[{_localName}::{script.Name}]: Value ({valueName}) {listName}[{index}].{valueKey} is not a number!`)
			isValid = false
		end

		previous = order or previous
	end

	--[[ Returning ]]

	return isValid
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

local Helpers = {}
local _getDepthScalarKind

--%%%%%%%%%%%%%%%%%%%% Clamp Precision

--[[
	Returns a BigNum precision value supported by the precision helpers.
]]
function Helpers.ClampPrecision(precision)
	return math.min(math.max(tonumber(precision) or _settings.PRECISION or 6, 0), 9)
end

--%%%%%%%%%%%%%%%%%%%% Get Scale

--[[
	Returns the fixed-point scale for a precision value.
]]
local function _getScale(precision)
	return "1" .. string.rep("0", Helpers.ClampPrecision(precision))
end

--%%%%%%%%%%%%%%%%%%%% Divide BigNums

--[[
	Returns quotient and remainder without relying on `/` preserving multiple returns.
]]
local function _divideBigNums(value, divisor)
	local quotient = I.BN.new()
	local remainder = I.BN.new()

	I.BN.Div(I.BN.new(value), I.BN.new(divisor), quotient, remainder)

	return quotient, remainder
end

--%%%%%%%%%%%%%%%%%%%% Normalize Decimal String

--[[
	Returns a normalized decimal string for fixed-point parsing.
]]
local function _normalizeDecimalString(value, precision)
	local valueString = tostring(value or 0)
	valueString = string.gsub(valueString, "%s+", "")

	if string.find(valueString, "[eE]") then
		valueString = string.format("%." .. Helpers.ClampPrecision(precision) .. "f", tonumber(valueString) or 0)
	end

	return valueString
end

--%%%%%%%%%%%%%%%%%%%% To Scaled Value

--[[
	Converts a number-like value into a fixed-point BigNum string.
]]
function Helpers.ToScaledValue(value, precision)
	precision = Helpers.ClampPrecision(precision)

	local valueString = _normalizeDecimalString(value, precision)
	local sign = ""

	if string.sub(valueString, 1, 1) == "-" then
		sign = "-"
		valueString = string.sub(valueString, 2)
	elseif string.sub(valueString, 1, 1) == "+" then
		valueString = string.sub(valueString, 2)
	end

	local dotPosition = string.find(valueString, "%.")
	local intPart = dotPosition and string.sub(valueString, 1, dotPosition - 1) or valueString
	local fracPart = dotPosition and string.sub(valueString, dotPosition + 1) or ""

	intPart = string.gsub(intPart, "[^0-9]", "")
	fracPart = string.gsub(fracPart, "[^0-9]", "")
	fracPart = string.sub(fracPart .. string.rep("0", precision), 1, precision)

	local scaledValue = (if intPart == "" then "0" else intPart) .. fracPart
	scaledValue = string.gsub(scaledValue, "^0+", "")

	if scaledValue == "" then
		return "0"
	end

	if sign == "-" then
		return "-" .. scaledValue
	end

	return scaledValue
end

--%%%%%%%%%%%%%%%%%%%% From Scaled Value

--[[
	Converts a fixed-point BigNum string into an integer BigNum string.
]]
function Helpers.FromScaledValue(value, precision, rounding)
	precision = Helpers.ClampPrecision(precision)
	rounding = rounding or "Floor"

	local scale = I.BN.new(_getScale(precision))
	local quotient, remainder = _divideBigNums(value, scale)
	local result = I.BN.new(quotient)
	local hasRemainder = tostring(remainder) ~= "0"
	local isNegative = string.sub(tostring(I.BN.new(value)), 1, 1) == "-"
	local one = I.BN.new("1")

	if rounding == "Floor" and hasRemainder and isNegative then
		result -= one
	elseif rounding == "Ceil" and hasRemainder and not isNegative then
		result += one
	elseif rounding == "Round" and hasRemainder then
		local doubledRemainder = I.BN.new(remainder) * I.BN.new("2")
		if doubledRemainder >= scale then
			if isNegative then
				result -= one
			else
				result += one
			end
		end
	end

	return tostring(result)
end

--%%%%%%%%%%%%%%%%%%%% To Decimal String

--[[
	Converts a fixed-point BigNum string into a decimal string (`precision` digits after the point), keeping the sign.
]]
--- @return string
function Helpers._toDecimalString(value: string, precision: number)
	--[[ Local Variables ]]

	local digits: string = tostring(I.BN.new(value))
	local sign: string = ""

	-- Split off the sign
	if string.sub(digits, 1, 1) == "-" then
		sign = "-"
		digits = string.sub(digits, 2)
	end

	--[[ Checks ]]

	-- Return whole numbers as they are
	if precision == 0 then
		return sign .. digits
	end

	--[[ Formatting ]]

	-- Pad so at least one digit stays before the point
	digits = string.rep("0", precision + 1 - #digits) .. digits

	--[[ Returning ]]

	return sign .. string.sub(digits, 1, -precision - 1) .. "." .. string.sub(digits, -precision)
end

--%%%%%%%%%%%%%%%%%%%% To BigNum String

--[[
	Converts a number-like value into an integer BigNum string.
]]
function Helpers.ToBigNumString(value, precision, rounding)
	return Helpers.FromScaledValue(Helpers.ToScaledValue(value, precision), precision, rounding)
end

--%%%%%%%%%%%%%%%%%%%% Scaled Multiply

--[[
	Multiplies two fixed-point BigNum strings.
]]
function Helpers.ScaledMultiply(valueA, valueB, precision)
	local product = I.BN.new(valueA) * I.BN.new(valueB)
	local quotient = _divideBigNums(product, I.BN.new(_getScale(precision)))

	return tostring(quotient)
end

--%%%%%%%%%%%%%%%%%%%% Scaled Add

--[[
	Adds two fixed-point BigNum strings.
]]
function Helpers.ScaledAdd(valueA, valueB)
	return tostring(I.BN.new(valueA) + I.BN.new(valueB))
end

--%%%%%%%%%%%%%%%%%%%% Scaled Power

--[[
	Raises a fixed-point BigNum string to a non-negative integer exponent.
]]
function Helpers.ScaledPower(value, exponent, precision)
	exponent = math.max(math.floor(tonumber(exponent) or 0), 0)

	local result = Helpers.ToScaledValue(1, precision)
	local current = tostring(value)

	while exponent > 0 do
		if exponent % 2 == 1 then
			result = Helpers.ScaledMultiply(result, current, precision)
		end

		current = Helpers.ScaledMultiply(current, current, precision)
		exponent = math.floor(exponent / 2)
	end

	return result
end

--%%%%%%%%%%%%%%%%%%%% Resolve Value

--[[
	Resolves a constant or function value.
]]
--- @param context Scaling_Context
function Helpers.ResolveValue(value, context, fallback)
	if type(value) == "function" then
		value = value(context)
	end

	if value == nil then
		value = fallback
	end

	return value
end

--%%%%%%%%%%%%%%%%%%%% Resolve Definition

--[[
	Returns the value definition associated with a name or the definition table passed in.
	Warns and returns nil when a name has no definition.
]]
--- @param valueData string | Scaling_ValueDefinition
--- @return Scaling_ValueDefinition?
function Helpers.ResolveDefinition(valueData)
	--[[ Checks ]]

	-- Return a definition table as it is
	if type(valueData) == "table" then
		return valueData
	end

	-- Check if the named definition exists
	if type(valueData) ~= "string" or not _settings.VALUES[valueData] then
		warn(`[{_localName}::{script.Name}]: Value definition ({valueData}) is missing!`)
		return nil
	end

	--[[ Returning ]]

	return _settings.VALUES[valueData]
end

--%%%%%%%%%%%%%%%%%%%% Validate Definition

--[[
	Warns about each problem in a value definition: an unknown curve, a constant that doesn't parse as a number,
	an `Input` that isn't a key name, and Pieces or Bands that are missing, non-numeric or out of order. Returns whether it is valid.
]]
--- @param definition Scaling_ValueDefinition
--- @return boolean
function Helpers.ValidateDefinition(valueName: string, definition)
	--[[ Local Variables ]]

	local isValid: boolean = true
	local curveName: string = Helpers.GetCurveName(definition)

	--[[ Curve ]]

	-- Check if the curve is a known kind or a function
	if type(definition.Curve) ~= "function" and not KNOWN_CURVES[curveName] then
		warn(`[{_localName}::{script.Name}]: Value ({valueName}) Curve ({definition.Curve}) is not supported!`)
		isValid = false
	end

	--[[ Numeric Fields ]]

	for _index: number, fieldName: string in ipairs(NUMERIC_FIELDS) do
		local value: any = definition[fieldName]

		-- Check if a constant parses as a number
		if value ~= nil and type(value) ~= "function" and tonumber(value) == nil then
			warn(`[{_localName}::{script.Name}]: Value ({valueName}) {fieldName} ({value}) is not a number!`)
			isValid = false
		end
	end

	--[[ Input ]]

	-- Check if the input names a context key
	if definition.Input ~= nil and (type(definition.Input) ~= "string" or definition.Input == "") then
		warn(`[{_localName}::{script.Name}]: Value ({valueName}) Input ({definition.Input}) must be a context key name!`)
		isValid = false
	end

	--[[ Segments ]]

	-- Check if a piecewise curve has pieces
	if curveName == "piecewise" and (type(definition.Pieces) ~= "table" or #definition.Pieces == 0) then
		warn(`[{_localName}::{script.Name}]: Value ({valueName}) Piecewise curve has no Pieces!`)
		isValid = false
	end

	-- Check if a band curve has bands
	if curveName == "bandexponential" and (type(definition.Bands) ~= "table" or #definition.Bands == 0) then
		warn(`[{_localName}::{script.Name}]: Value ({valueName}) BandExponential curve has no Bands!`)
		isValid = false
	end

	-- Check the pieces and bands that are given
	if type(definition.Pieces) == "table" and not _checkSegments(valueName, "Pieces", definition.Pieces, "At", "Value") then
		isValid = false
	end
	if type(definition.Bands) == "table" and not _checkSegments(valueName, "Bands", definition.Bands, "FirstLevel", "Base") then
		isValid = false
	end

	--[[ Returning ]]

	return isValid
end

--%%%%%%%%%%%%%%%%%%%% Get Input Value

--[[
	Returns the curve input from the context.
]]
--- @param context Scaling_Context
--- @param definition Scaling_ValueDefinition
function Helpers.GetInputValue(context, definition)
	local inputName = definition.Input or "Level"
	return tonumber(context[inputName]) or 1
end

--%%%%%%%%%%%%%%%%%%%% Get Curve Name

--[[
	Returns normalized curve name.
]]
--- @param definition Scaling_ValueDefinition
function Helpers.GetCurveName(definition)
	if type(definition.Curve) == "function" then
		return "Custom"
	end

	return string.lower(tostring(definition.Curve or "Legacy"))
end

--%%%%%%%%%%%%%%%%%%%% Get Base Fallback

--[[
	Returns the default base for the selected curve.
]]
function Helpers.GetBaseFallback(curveName)
	if curveName == "legacy" or curveName == "power" or curveName == "bigpower" then
		return 3
	elseif curveName == "exponential" then
		return 1
	end

	return 0
end

--%%%%%%%%%%%%%%%%%%%% Get Scalar Value

--[[
	Returns the combined scalar multiplier as a fixed-point BigNum string.
]]
--- @param context Scaling_Context
--- @param definition Scaling_ValueDefinition
function Helpers.GetScalarValue(context, definition, precision)
	local scalarValue = Helpers.ToScaledValue(1, precision)

	if type(definition.Scalars) ~= "table" then
		return scalarValue
	end

	for scalarName, scalarData in pairs(definition.Scalars) do
		local depthScalarKind = _getDepthScalarKind(scalarData)

		if depthScalarKind == "FishDepth" then
			scalarValue = Helpers.ScaledMultiply(scalarValue, Helpers.GetFishDepthScalarScaled(context, precision), precision)
			continue
		end

		if depthScalarKind == "PlayerDepth" then
			scalarValue = Helpers.ScaledMultiply(scalarValue, Helpers.GetPlayerDepthScalarScaled(context, precision), precision)
			continue
		end

		local currentScalar

		if type(scalarData) == "table" then
			if scalarData.Values then
				local inputName = scalarData.Input or scalarName
				local inputValue = context[inputName]
				currentScalar = scalarData.Values[tostring(inputValue)] or scalarData.Default or 1
			else
				currentScalar = Helpers.ResolveValue(scalarData.Value, context, scalarData.Default or 1)
			end
		else
			currentScalar = Helpers.ResolveValue(scalarData, context, 1)
		end

		scalarValue = Helpers.ScaledMultiply(scalarValue, Helpers.ToScaledValue(currentScalar, precision), precision)
	end

	return scalarValue
end

--%%%%%%%%%%%%%%%%%%%% Multiply Value

--[[
	Multiplies an integer BigNum string by a fixed-point scalar and rounds the product to an integer.
	`rounding` defaults to Floor.
]]
--- @param rounding Scaling_RoundingType?
--- @return string
function Helpers.MultiplyValue(value: string, scalarValue: string, precision: number, rounding)
	--[[ Calculating ]]

	local valueScaled: string = Helpers.ToScaledValue(value, precision)
	local scaledValue: string = Helpers.ScaledMultiply(valueScaled, scalarValue, precision)

	--[[ Returning ]]

	return Helpers.FromScaledValue(scaledValue, precision, rounding)
end

--%%%%%%%%%%%%%%%%%%%% Apply Soft Cap

--[[
	Applies a soft cap after base curve and scalar calculation.
]]
--- @param context Scaling_Context
--- @param definition Scaling_ValueDefinition
function Helpers.ApplySoftCap(value, context, definition, precision)
	if definition.SoftCap == nil then
		return value
	end

	local softCap = Helpers.ToBigNumString(Helpers.ResolveValue(definition.SoftCap, context, nil), precision, "Floor")
	if I.BN.new(value) <= I.BN.new(softCap) then
		return value
	end

	local softCapPower = tonumber(Helpers.ResolveValue(definition.SoftCapPower, context, 0.5)) or 0.5
	local overCapValue = tostring(I.BN.new(value) - I.BN.new(softCap))
	local reducedValue = tostring(I.BN.PowerWithPrecision(overCapValue, softCapPower, precision))

	return tostring(I.BN.new(softCap) + I.BN.new(reducedValue))
end

--%%%%%%%%%%%%%%%%%%%% Apply Clamp

--[[
	Applies min and max limits using BigNum comparisons.
]]
--- @param context Scaling_Context
--- @param definition Scaling_ValueDefinition
function Helpers.ApplyClamp(value, context, definition, precision)
	local result = I.BN.new(value)

	if definition.Min ~= nil then
		local minValue = I.BN.new(Helpers.ToBigNumString(Helpers.ResolveValue(definition.Min, context, nil), precision, "Floor"))
		if result < minValue then
			result = minValue
		end
	end

	if definition.Max ~= nil then
		local maxValue = I.BN.new(Helpers.ToBigNumString(Helpers.ResolveValue(definition.Max, context, nil), precision, "Floor"))
		if result > maxValue then
			result = maxValue
		end
	end

	return tostring(result)
end

--%%%%%%%%%%%%%%%%%%%% Apply Rounding

--[[
	Returns an integer BigNum string. Curves are already rounded before this point.
]]
function Helpers.ApplyRounding(value)
	return tostring(I.BN.new(value))
end

--%%%%%%%%%%%%%%%%%%%% Format Return

--[[
	Formats every result as a BigNum string.
]]
function Helpers.FormatReturn(value)
	return tostring(I.BN.new(value))
end

--%%%%%%%%%%%%%%%%%%%% Calculate Legacy Curve

--[[
	Calculates the original exponential scaling formula, rounding the `mul` step with `rounding`.
]]
--- @param rounding Scaling_RoundingType?
--- @return string
function Helpers.CalculateLegacyCurve(exp: number, base: number | string, growth: number | string, add: number | string, mul: number | string, precision: number, rounding)
	--[[ Calculating ]]

	local newExp: number = ((tonumber(exp) or 1) * (tonumber(growth) or 1)) + (tonumber(add) or 0)
	local newBase: string = tostring(I.BN.PowerWithPrecision(tonumber(base) or 3, newExp, precision))
	local dividedValue: string = tostring(I.BN.DivideWithPrecision(newBase, tonumber(base) or 3, precision))

	--[[ Returning ]]

	return Helpers.MultiplyValue(dividedValue, Helpers.ToScaledValue(mul or 1, precision), precision, rounding)
end

--%%%%%%%%%%%%%%%%%%%% Calculate Linear Curve

--[[
	Calculates a linear curve using fixed-point BigNum arithmetic.
]]
--- @param context Scaling_Context
--- @param definition Scaling_ValueDefinition
local function _calculateLinearCurve(context, definition, inputValue, precision)
	local baseValue = Helpers.ToScaledValue(Helpers.ResolveValue(definition.Base, context, 0), precision)
	local growthValue = Helpers.ToScaledValue(Helpers.ResolveValue(definition.Growth, context, 1), precision)
	local inputScaled = Helpers.ToScaledValue(inputValue, precision)
	local addValue = Helpers.ToScaledValue(Helpers.ResolveValue(definition.Add, context, 0), precision)
	local multiplierValue = Helpers.ToScaledValue(Helpers.ResolveValue(definition.Mul, context, 1), precision)

	local scaledValue = Helpers.ScaledAdd(baseValue, Helpers.ScaledMultiply(inputScaled, growthValue, precision))
	scaledValue = Helpers.ScaledAdd(scaledValue, addValue)
	scaledValue = Helpers.ScaledMultiply(scaledValue, multiplierValue, precision)

	return Helpers.FromScaledValue(scaledValue, precision, definition.Round or _settings.ROUNDING)
end

--%%%%%%%%%%%%%%%%%%%% Calculate Polynomial Curve

--[[
	Calculates `(Base + (Input * Growth + Add) ^ Exponent) * Mul` in fixed point and rounds once at the end.
	A whole, non-negative exponent stays exact; any other exponent goes through `I.BN.PowerWithPrecision` with the decimal term.
]]
--- @param context Scaling_Context
--- @param definition Scaling_ValueDefinition
--- @return string
local function _calculatePolynomialCurve(context, definition, inputValue: number, precision: number)
	--[[ Local Variables ]]

	local baseValue: string = Helpers.ToScaledValue(Helpers.ResolveValue(definition.Base, context, 0), precision)
	local growthValue: string = Helpers.ToScaledValue(Helpers.ResolveValue(definition.Growth, context, 1), precision)
	local inputScaled: string = Helpers.ToScaledValue(inputValue, precision)
	local addValue: string = Helpers.ToScaledValue(Helpers.ResolveValue(definition.Add, context, 0), precision)
	local multiplierValue: string = Helpers.ToScaledValue(Helpers.ResolveValue(definition.Mul, context, 1), precision)
	local exponentValue: number = tonumber(Helpers.ResolveValue(definition.Exponent, context, 1)) or 1

	--[[ Calculating ]]

	local termScaled: string = Helpers.ScaledAdd(Helpers.ScaledMultiply(inputScaled, growthValue, precision), addValue)
	local poweredScaled: string

	-- Keep a whole exponent exact in fixed point; raise the decimal term for any other exponent
	if exponentValue >= 0 and exponentValue == math.floor(exponentValue) then
		poweredScaled = Helpers.ScaledPower(termScaled, exponentValue, precision)
	else
		local poweredValue: string = tostring(I.BN.PowerWithPrecision(Helpers._toDecimalString(termScaled, precision), exponentValue, precision))
		poweredScaled = Helpers.ToScaledValue(poweredValue, precision)
	end

	local scaledValue: string = Helpers.ScaledAdd(baseValue, poweredScaled)
	scaledValue = Helpers.ScaledMultiply(scaledValue, multiplierValue, precision)

	--[[ Returning ]]

	return Helpers.FromScaledValue(scaledValue, precision, definition.Round or _settings.ROUNDING)
end

--%%%%%%%%%%%%%%%%%%%% Calculate Exponential Curve

--[[
	Calculates `Base * Growth ^ (Input + Add) * Mul` with fixed-point BigNum arithmetic.
]]
--- @param context Scaling_Context
--- @param definition Scaling_ValueDefinition
local function _calculateExponentialCurve(context, definition, inputValue, precision)
	local baseValue = Helpers.ToScaledValue(Helpers.ResolveValue(definition.Base, context, 1), precision)
	local growthValue = Helpers.ToScaledValue(Helpers.ResolveValue(definition.Growth, context, 1), precision)
	local addValue = tonumber(Helpers.ResolveValue(definition.Add, context, 0)) or 0
	local multiplierValue = Helpers.ToScaledValue(Helpers.ResolveValue(definition.Mul, context, 1), precision)

	local exponent = math.max(inputValue + addValue, 0)
	local growthPowerScaled = Helpers.ScaledPower(growthValue, exponent, precision)
	local scaledValue = Helpers.ScaledMultiply(baseValue, growthPowerScaled, precision)
	scaledValue = Helpers.ScaledMultiply(scaledValue, multiplierValue, precision)

	return Helpers.FromScaledValue(scaledValue, precision, definition.Round or _settings.ROUNDING)
end

--%%%%%%%%%%%%%%%%%%%% Calculate Band Exponential Curve

--[[
	Calculates an exponential curve that resets to a new BigNum base at each configured level band.
]]
--- @param context Scaling_Context
--- @param definition Scaling_ValueDefinition
--- @return string
local function _calculateBandExponentialCurve(context, definition, inputValue: number, precision: number)
	--[[ Finding Band ]]

	--- @type Scaling_BandDefinition?
	local selectedBand = definition.Bands and definition.Bands[1]

	-- Return 0 when no band is defined
	if not selectedBand then
		return "0"
	end

	--- @param band Scaling_BandDefinition
	for _index: number, band in ipairs(definition.Bands) do
		-- Take the last band the input has reached
		if inputValue >= band.FirstLevel then
			selectedBand = band
		end
	end

	--[[ Local Variables ]]

	local baseValue: string = Helpers.ToScaledValue(Helpers.ResolveValue(selectedBand.Base, context, 0), precision)
	local growthValue: string = Helpers.ToScaledValue(Helpers.ResolveValue(definition.Growth, context, 1), precision)
	local multiplierValue: string = Helpers.ToScaledValue(Helpers.ResolveValue(definition.Mul, context, 1), precision)
	local exponent: number = math.max(inputValue - selectedBand.FirstLevel, 0)

	--[[ Calculating ]]

	local scaledValue: string = Helpers.ScaledMultiply(baseValue, Helpers.ScaledPower(growthValue, exponent, precision), precision)
	scaledValue = Helpers.ScaledMultiply(scaledValue, multiplierValue, precision)

	--[[ Returning ]]

	return Helpers.FromScaledValue(scaledValue, precision, definition.Round or _settings.ROUNDING)
end

--%%%%%%%%%%%%%%%%%%%% Calculate Curve

--[[
	Calculates the base curve value before scalars, caps, clamps, or rounding.
]]
--- @param context Scaling_Context
--- @param definition Scaling_ValueDefinition
--- @return string
function Helpers.CalculateCurve(context, definition, inputValue: number, precision: number)
	--[[ Local Variables ]]

	local curveName: string = Helpers.GetCurveName(definition)
	local rounding = definition.Round or _settings.ROUNDING --- @type Scaling_RoundingType?

	--[[ Calculating ]]

	if type(definition.Curve) == "function" then
		return Helpers.ToBigNumString(definition.Curve(context), precision, rounding)
	elseif curveName == "legacy" then
		return Helpers.CalculateLegacyCurve(
			inputValue,
			Helpers.ResolveValue(definition.Base, context, 3),
			Helpers.ResolveValue(definition.Growth, context, 1),
			Helpers.ResolveValue(definition.Add, context, 0),
			Helpers.ResolveValue(definition.Mul, context, 1),
			precision,
			rounding
		)
	elseif curveName == "linear" then
		return _calculateLinearCurve(context, definition, inputValue, precision)
	elseif curveName == "polynomial" then
		return _calculatePolynomialCurve(context, definition, inputValue, precision)
	elseif curveName == "exponential" then
		return _calculateExponentialCurve(context, definition, inputValue, precision)
	elseif curveName == "bandexponential" then
		return _calculateBandExponentialCurve(context, definition, inputValue, precision)
	elseif curveName == "piecewise" and type(definition.Pieces) == "table" then
		--- @type Scaling_PieceDefinition?
		local selectedPiece = definition.Pieces[1]

		--- @param piece Scaling_PieceDefinition
		for _index: number, piece in ipairs(definition.Pieces) do
			-- Take the last piece the input has reached
			if inputValue >= (tonumber(piece.At) or 0) then
				selectedPiece = piece
			end
		end

		return Helpers.ToBigNumString(Helpers.ResolveValue(selectedPiece and selectedPiece.Value, context, 0), precision, rounding)
	elseif curveName == "power" or curveName == "bigpower" then
		local exponent: number = (inputValue * (tonumber(Helpers.ResolveValue(definition.Growth, context, 1)) or 1)) + (tonumber(Helpers.ResolveValue(definition.Add, context, 0)) or 0)
		local poweredValue: string = tostring(I.BN.PowerWithPrecision(tonumber(Helpers.ResolveValue(definition.Base, context, 3)) or 3, exponent, precision))

		return Helpers.MultiplyValue(poweredValue, Helpers.ToScaledValue(Helpers.ResolveValue(definition.Mul, context, 1), precision), precision, rounding)
	end

	--[[ Unsupported ]]

	warn(`[{_localName}::{script.Name}]: ({curveName}) Curve is not supported by BigNum scaling!`)
	return "0"
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Depth Scalars

--%%%%%%%%%%%%%%%%%%%% Get Depth Scalar Kind

--[[
	Returns depth scalar kind from a scalar definition entry.
]]
--- @param scalarData Scaling_ScalarDefinition | Scaling_ScalarKind | Scaling_ValueInput
_getDepthScalarKind = function(scalarData)
	if type(scalarData) == "string" then
		if scalarData == "FishDepth" or scalarData == "PlayerDepth" then
			return scalarData
		end
		return nil
	end

	if type(scalarData) == "table" and scalarData.Kind then
		return scalarData.Kind
	end

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Depth Scalar Scaled

--[[
	Returns `1 + log10(max(depth, 1)) / divisor` as a fixed-point BigNum string.
]]
--- @param context Scaling_Context
function Helpers.GetDepthScalarScaled(context, precision, divisor)
	local depthValue = context.Depth
	if not depthValue or I.BN.new(depthValue) < I.BN.new("1") then
		depthValue = "1"
	end

	local depthNumber: number = tonumber(depthValue) or 1
	local scalar: number = 1 + math.log10(math.max(depthNumber, 1)) / divisor

	return Helpers.ToScaledValue(scalar, precision)
end

--%%%%%%%%%%%%%%%%%%%% Get Fish Depth Scalar Scaled

--[[
	Returns fish depth scalar `1 + log10(max(depth, 1)) / 12` as fixed-point BigNum string.
]]
--- @param context Scaling_Context
function Helpers.GetFishDepthScalarScaled(context, precision)
	return Helpers.GetDepthScalarScaled(context, precision, 12)
end

--%%%%%%%%%%%%%%%%%%%% Get Player Depth Scalar Scaled

--[[
	Returns player depth scalar `1 + log10(max(depth, 1)) / 6` as fixed-point BigNum string.
]]
--- @param context Scaling_Context
function Helpers.GetPlayerDepthScalarScaled(context, precision)
	return Helpers.GetDepthScalarScaled(context, precision, 6)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Helpers
