--[[
    Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

--- @type { [string]: boolean }
local VALID_SPEC_FIELDS = {

	--[[ Type ]]

	Type = true,
	Types = true,
	Optional = true,
	ClassName = true,

	--[[ Bounds ]]

	Min = true,
	Max = true,

	--[[ Table ]]

	Length = true,
	MinLength = true,
	MaxLength = true,
	Elements = true,
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Is Non Negative Integer

--[[
	Returns whether the value is a whole number of zero or more.
]]
--- @return boolean
local function isNonNegativeInteger(value: any)
	return type(value) == "number" and value >= 0 and value % 1 == 0
end

--%%%%%%%%%%%%%%%%%%%% Is Non Empty String

--[[
	Returns whether the value is a string with at least one character.
]]
--- @return boolean
local function isNonEmptyString(value: any)
	return type(value) == "string" and value ~= ""
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

--- @class Validate_Schema
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Argument Count

--[[
	Returns the argument count of a packed table (`n`) or a plain array.
]]
--- @param argumentValues { [any]: any }
--- @return number
function Module.GetArgumentCount(argumentValues)
	--[[ Returning ]]

	if type(argumentValues.n) == "number" then
		return argumentValues.n
	end

	return #argumentValues
end

--%%%%%%%%%%%%%%%%%%%% Get Spec

--[[
	Normalizes a schema entry into a spec with a `Types` array, or returns nil when it is not a schema entry.
]]
--- @param entry Validate_SchemaEntry
--- @return Validate_SchemaSpec?
function Module.GetSpec(entry)
	--[[ Returning ]]

	if type(entry) == "string" then
		return { Types = { entry } }
	end

	if type(entry) ~= "table" then
		return nil
	end

	if entry.Types then
		return entry
	end

	-- Clone the single type form so the caller's schema is not modified
	if entry.Type then
		local spec = table.clone(entry)
		spec.Types = { entry.Type }
		spec.Type = nil
		return spec
	end

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Is Optional

--[[
	Returns whether the spec marks its position optional.
]]
--- @param spec Validate_SchemaSpec
--- @return boolean
function Module.IsOptional(spec)
	return spec.Optional == true
end

--%%%%%%%%%%%%%%%%%%%% Validate Entry

--[[
	Checks that a schema entry is well formed, recursing into `Elements`. Does not modify the entry.
]]
--- @return boolean
--- @return string?
function Module.ValidateEntry(entry: any)
	--[[ Checks ]]

	-- Accept a non-empty type name
	if type(entry) == "string" then
		if entry == "" then
			return false, "(empty type name)"
		end
		return true, nil
	end

	-- Check if the entry is a spec table
	if type(entry) ~= "table" then
		return false, "(entry must be string or table)"
	end

	--[[ Type ]]

	-- Check if exactly one of Type and Types is set
	if (entry.Type == nil) == (entry.Types == nil) then
		return false, "(exactly one of Type or Types must be set)"
	end

	-- Check if Type is a non-empty string
	if entry.Type ~= nil and not isNonEmptyString(entry.Type) then
		return false, "(Type must be non-empty string)"
	end

	if entry.Types ~= nil then
		-- Check if Types is a non-empty array
		if type(entry.Types) ~= "table" or #entry.Types == 0 then
			return false, "(Types must be non-empty array)"
		end

		for index: number, typeName: any in ipairs(entry.Types) do
			if not isNonEmptyString(typeName) then
				return false, `(Types[{index}] must be non-empty string)`
			end
		end
	end

	--[[ Fields ]]

	-- Check if Optional is a boolean
	if entry.Optional ~= nil and type(entry.Optional) ~= "boolean" then
		return false, "(Optional must be boolean)"
	end

	-- Check if the bounds are numbers or BigNum strings
	if entry.Min ~= nil and type(entry.Min) ~= "number" and type(entry.Min) ~= "string" then
		return false, "(Min must be number or string)"
	end
	if entry.Max ~= nil and type(entry.Max) ~= "number" and type(entry.Max) ~= "string" then
		return false, "(Max must be number or string)"
	end

	-- Check if the length limits are non-negative integers
	if entry.Length ~= nil and not isNonNegativeInteger(entry.Length) then
		return false, "(Length must be non-negative integer)"
	end
	if entry.MinLength ~= nil and not isNonNegativeInteger(entry.MinLength) then
		return false, "(MinLength must be non-negative integer)"
	end
	if entry.MaxLength ~= nil and not isNonNegativeInteger(entry.MaxLength) then
		return false, "(MaxLength must be non-negative integer)"
	end

	-- Check if ClassName is a non-empty string
	if entry.ClassName ~= nil and not isNonEmptyString(entry.ClassName) then
		return false, "(ClassName must be non-empty string)"
	end

	--[[ Elements ]]

	if entry.Elements ~= nil then
		-- Check if Elements is a table
		if type(entry.Elements) ~= "table" then
			return false, "(Elements must be array)"
		end

		for index: number, elementEntry: any in ipairs(entry.Elements) do
			local success: boolean, result: string? = Module.ValidateEntry(elementEntry)

			if not success then
				return false, `(Elements[{index}]){result}`
			end
		end
	end

	--[[ Unknown Fields ]]

	for key: any in pairs(entry) do
		if not VALID_SPEC_FIELDS[key] then
			return false, `(unknown field "{tostring(key)}")`
		end
	end

	--[[ Returning ]]

	return true, nil
end

return Module
