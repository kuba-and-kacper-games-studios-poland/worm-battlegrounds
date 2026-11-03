--[[
    Created By:     Nari
]]

--- @type Ume
local I

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local Internal --- @type Validate_Internal

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

--- @class Validate_Constraints
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param internal Validate_Internal
--- @param umeInstance Ume
function Module.Init(internal, umeInstance)
	--[[ Storing ]]

	Internal = internal
	I = umeInstance
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Check

--[[
	Applies the constraints that belong to the matched type: Min / Max for numbers and BigNums,
	length limits for tables.
]]
--- @param spec Validate_SchemaSpec
--- @return boolean
--- @return string?
function Module.Check(value: any, matchedType: string, spec)
	--[[ Returning ]]

	if matchedType == "number" then
		return Module.CheckNumber(value, spec)
	end

	if matchedType == "BigNum" then
		return Module.CheckBigNum(value, spec)
	end

	if matchedType == "table" then
		return Module.CheckTableLength(value, spec)
	end

	return true, nil
end

--%%%%%%%%%%%%%%%%%%%% Check Number

--[[
	Checks a number against the spec's Min / Max.
]]
--- @param spec Validate_SchemaSpec
--- @return boolean
--- @return string?
function Module.CheckNumber(value: number, spec)
	--[[ Local Variables ]]

	local minValue: number? = tonumber(spec.Min)
	local maxValue: number? = tonumber(spec.Max)

	--[[ Checks ]]

	-- Check the lower bound
	if minValue and value < minValue then
		return false, "(Min)"
	end

	-- Check the upper bound
	if maxValue and value > maxValue then
		return false, "(Max)"
	end

	--[[ Returning ]]

	return true, nil
end

--%%%%%%%%%%%%%%%%%%%% Check Big Num

--[[
	Checks a BigNum value against the spec's Min / Max (numbers or integer strings).
]]
--- @param spec Validate_SchemaSpec
--- @return boolean
--- @return string?
function Module.CheckBigNum(value: any, spec)
	--[[ Local Variables ]]

	local comparand = Internal.BigNum.GetComparand(value) --- @type BigNum_Instance?

	--[[ Checks ]]

	-- Check if the value converts to a BigNum
	if not comparand then
		return false, "(type mismatch)"
	end

	-- Check the lower bound
	if spec.Min ~= nil and comparand < I.BN.new(spec.Min) then
		return false, "(Min)"
	end

	-- Check the upper bound
	if spec.Max ~= nil and comparand > I.BN.new(spec.Max) then
		return false, "(Max)"
	end

	--[[ Returning ]]

	return true, nil
end

--%%%%%%%%%%%%%%%%%%%% Check Table Length

--[[
	Checks the sequential length (`#`) of a table against Length / MinLength / MaxLength.
]]
--- @param value { [any]: any }
--- @param spec Validate_SchemaSpec
--- @return boolean
--- @return string?
function Module.CheckTableLength(value, spec)
	--[[ Local Variables ]]

	local length: number = #value

	--[[ Checks ]]

	-- Check the exact length
	if spec.Length ~= nil and length ~= spec.Length then
		return false, "(Length)"
	end

	-- Check the minimum length
	if spec.MinLength ~= nil and length < spec.MinLength then
		return false, "(MinLength)"
	end

	-- Check the maximum length
	if spec.MaxLength ~= nil and length > spec.MaxLength then
		return false, "(MaxLength)"
	end

	--[[ Returning ]]

	return true, nil
end

return Module
