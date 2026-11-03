--[[
    Created By:     Nari
]]

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

--- @class Validate_ValidateValue
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param internal Validate_Internal
function Module.Init(internal)
	Internal = internal
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Validate

--[[
	Validates one value against one schema entry, recursing into table `Elements`.
	Errors carry the failing element path, for example `[2][1](Min)`.
]]
--- @param entry Validate_SchemaEntry
--- @return boolean
--- @return string?
function Module.Validate(value: any, entry)
	--[[ Data ]]

	local spec = Internal.Schema.GetSpec(entry) --- @type Validate_SchemaSpec?

	--[[ Checks ]]

	-- Check if the schema entry is valid
	if not spec then
		return false, "(invalid schema entry)"
	end

	--[[ Matching ]]

	local matchedType: string? = nil

	for _index: number, typeName: string in ipairs(spec.Types) do
		if Internal.Match.IsType(value, typeName, spec) then
			matchedType = typeName
			break
		end
	end

	--[[ Checks ]]

	-- Check if any type matched
	if not matchedType then
		return false, "(type mismatch)"
	end

	--[[ Constraints ]]

	local success: boolean, result: string? = Internal.Constraints.Check(value, matchedType, spec)

	if not success then
		return false, result
	end

	--[[ Elements ]]

	if matchedType == "table" and spec.Elements then
		for index: number, elementEntry: any in ipairs(spec.Elements) do
			local elementValue: any = value[index]
			local elementSpec = Internal.Schema.GetSpec(elementEntry) --- @type Validate_SchemaSpec?

			-- Skip missing optional elements
			if elementValue == nil and elementSpec and Internal.Schema.IsOptional(elementSpec) then
				continue
			end

			local elementSuccess: boolean, elementResult: string? = Module.Validate(elementValue, elementEntry)

			if not elementSuccess then
				return false, `[{index}]{elementResult}`
			end
		end
	end

	--[[ Returning ]]

	return true, nil
end

return Module
