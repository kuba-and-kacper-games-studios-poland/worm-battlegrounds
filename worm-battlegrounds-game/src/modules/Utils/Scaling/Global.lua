--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Scaling"

--- @type Scaling_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

local Helpers = require(script:FindFirstAncestor(_localName):FindFirstChild("Scripts"):FindFirstChild("Helpers"))

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._validateDefinitions()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Scaling = {

		--[[ Control ]]

		Register = Module.Register,

		--[[ Methods ]]

		Calculate = Module.Calculate,
		GetBreakdown = Module.GetBreakdown,
		GetDefinition = Module.GetDefinition,
		GetDefinitions = Module.GetDefinitions,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Validate Definitions

--[[
	Checks every definition in `Settings.VALUES` and warns about bad curves, fields, pieces and bands by value name.
]]
function Module._validateDefinitions()
	--[[ Validating ]]

	--- @param definition Scaling_ValueDefinition
	for valueName: string, definition in pairs(_settings.VALUES) do
		Helpers.ValidateDefinition(valueName, definition)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Register

--[[
	Registers or replaces a named value definition on this side, warning about any problem in it.
]]
--- @param definition Scaling_ValueDefinition
function Module.Register(valueName: string, definition)
	--[[ Checks ]]

	-- Check if the name is a string
	if type(valueName) ~= "string" then
		warn(`[{_localName}::{script.Name}]: valueName must be a string!`)
		return
	end

	-- Check if the definition is a table
	if type(definition) ~= "table" then
		warn(`[{_localName}::{script.Name}]: definition must be a table!`)
		return
	end

	--[[ Validating ]]

	Helpers.ValidateDefinition(valueName, definition)

	--[[ Saving ]]

	_settings.VALUES[valueName] = definition
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Definitions

--[[
	Returns all registered value definitions.
]]
--- @return { [string]: Scaling_ValueDefinition }
function Module.GetDefinitions()
	return I.Table.DeepCopy(_settings.VALUES)
end

--%%%%%%%%%%%%%%%%%%%% Get Definition

--[[
	Returns a copy of a named value definition, or nil when it is missing.
]]
--- @return Scaling_ValueDefinition?
function Module.GetDefinition(valueName: string)
	--[[ Checks ]]

	-- Check if the definition exists
	if not _settings.VALUES[valueName] then
		warn(`[{_localName}::{script.Name}]: Value definition ({valueName}) is missing!`)
		return nil
	end

	--[[ Returning ]]

	return I.Table.DeepCopy(_settings.VALUES[valueName])
end

--%%%%%%%%%%%%%%%%%%%% Calculate

--[[
	Returns the calculated value for a named value definition, or nil when the definition is missing.
	Skips the breakdown terms, so each function input runs once.
]]
--- @param valueData string | Scaling_ValueDefinition
--- @param context Scaling_Context?
--- @return string?
function Module.Calculate(valueData, context)
	--[[ Calculating ]]

	--- @type Scaling_Result?
	local result = Module._calculateResult(valueData, context, false)

	--[[ Returning ]]

	return result and result.Value
end

--%%%%%%%%%%%%%%%%%%%% Get Breakdown

--[[
	Returns calculation result with intermediate values for balancing, or nil when the definition is missing.
]]
--- @param valueData string | Scaling_ValueDefinition
--- @param context Scaling_Context?
--- @return Scaling_Result?
function Module.GetBreakdown(valueData, context)
	return Module._calculateResult(valueData, context, true)
end

--%%%%%%%%%%%%%%%%%%%% Calculate Result

--[[
	Runs a definition's curve, scalars, soft cap, clamp and rounding. Returns nil when the definition is missing.
	With `withTerms`, also resolves the Base, Growth, Exponent, Add and Mul terms for the breakdown.
]]
--- @param valueData string | Scaling_ValueDefinition
--- @param context Scaling_Context?
--- @return Scaling_Result?
function Module._calculateResult(valueData, context, withTerms: boolean)
	--[[ Normalize Values ]]

	-- Treat a non-table context as the level
	if type(context) ~= "table" then
		context = {
			Level = tonumber(context) or 1,
		}
	end

	--- @type Scaling_ValueDefinition?
	local definition = Helpers.ResolveDefinition(valueData)

	--[[ Checks ]]

	-- Check if the definition exists
	if not definition then
		return nil
	end

	--[[ Local Variables ]]

	local curveName: string = Helpers.GetCurveName(definition)
	local precision: number = Helpers.ClampPrecision(definition.Precision)
	local rounding = definition.Round or _settings.ROUNDING or "None" --- @type Scaling_RoundingType
	local inputValue: number = Helpers.GetInputValue(context, definition)
	local scalarValue: string = Helpers.GetScalarValue(context, definition, precision)

	--[[ Calculate Values ]]

	local rawValue: string = Helpers.CalculateCurve(context, definition, inputValue, precision)
	local scaledValue: string = Helpers.MultiplyValue(rawValue, scalarValue, precision, rounding)
	local softCappedValue: string = Helpers.ApplySoftCap(scaledValue, context, definition, precision)
	local clampedValue: string = Helpers.ApplyClamp(softCappedValue, context, definition, precision)
	local roundedValue: string = Helpers.ApplyRounding(clampedValue, rounding, precision)

	--[[ Building ]]

	--- @type Scaling_Result
	local result = {
		Value = Helpers.FormatReturn(roundedValue),
		RawValue = scaledValue,
		Curve = curveName,
		InputValue = inputValue,
		ScalarValue = scalarValue,
		Precision = precision,
		Round = rounding,
		Context = context,
		Definition = definition,
	}

	--[[ Breakdown Terms ]]

	-- Resolve the terms only for a breakdown, so Calculate runs each function input once
	if withTerms then
		result.BaseValue = Helpers.ResolveValue(definition.Base, context, Helpers.GetBaseFallback(curveName))
		result.GrowthValue = Helpers.ResolveValue(definition.Growth, context, 1)
		result.ExponentValue = Helpers.ResolveValue(definition.Exponent, context, 1)
		result.AddValue = Helpers.ResolveValue(definition.Add, context, 0)
		result.MultiplierValue = Helpers.ResolveValue(definition.Mul, context, 1)
	end

	--[[ Returning ]]

	return result
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
