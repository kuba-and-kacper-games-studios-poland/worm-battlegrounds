--[[
    Created By:     Nari
]]

--- @type Ume
local I
local _localName = "Validate"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local BigNum = require(_scripts:FindFirstChild("BigNum")) --- @type Validate_BigNum
local Schema = require(_scripts:FindFirstChild("Schema")) --- @type Validate_Schema
local Match = require(_scripts:FindFirstChild("Match")) --- @type Validate_Match
local Constraints = require(_scripts:FindFirstChild("Constraints")) --- @type Validate_Constraints
local ValidateValue = require(_scripts:FindFirstChild("ValidateValue")) --- @type Validate_ValidateValue

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type Validate_Internal
local Internal = {

	--[[ Scripts ]]

	BigNum = BigNum,
	Schema = Schema,
	Match = Match,
	Constraints = Constraints,
	ValidateValue = ValidateValue,
}

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

--- @class Ume_Library_Validate : Ume_Library
local Validate = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Stores Ume for the scripts and assigns this library onto it.
]]
--- @param umeInstance Ume
function Validate._injectUme(umeInstance)
	--[[ Storing ]]

	I = umeInstance

	BigNum.Init(I)
	Match.Init(Internal)
	Constraints.Init(Internal, I)
	ValidateValue.Init(Internal)

	--[[ Assigning ]]

	I.Validate = Validate --- @type Ume_Library_Validate
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Types

--[[
	Checks that an argument schema is a well-formed array of type names or `Validate_SchemaSpec` tables.
	Unknown fields, wrong field types, and malformed nested `Elements` fail. Values are not checked.
]]
--- @param argumentSchema Validate_ArgumentSchema
--- @return boolean
--- @return string?
function Validate.Types(argumentSchema)
	--[[ Checks ]]

	-- Check if the schema is a table
	if type(argumentSchema) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Invalid (argumentSchema) type. Expected (table), got ({typeof(argumentSchema)})!`)
		return false, "(bad argumentSchema)"
	end

	--[[ Entries ]]

	for index: number, entry: any in ipairs(argumentSchema) do
		local success: boolean, result: string? = Schema.ValidateEntry(entry)

		if not success then
			warn(`[{_localName}::{script.Name}]: Invalid schema entry at index ({index})! - {result}`)
			return false, `({index}){result}`
		end
	end

	--[[ Keys ]]

	for key: any in pairs(argumentSchema) do
		-- Check if the key is part of the array
		if type(key) ~= "number" or key < 1 or key > #argumentSchema or key % 1 ~= 0 then
			warn(`[{_localName}::{script.Name}]: Non-array key in (argumentSchema): ({key}: {typeof(key)})!`)
			return false, `(non-array key "{tostring(key)}")`
		end
	end

	--[[ Returning ]]

	return true, nil
end

--%%%%%%%%%%%%%%%%%%%% Args

--[[
	Validates sequential arguments (`table.pack(...)` or a plain array) against an argument schema.
	`BigNum` slots accept a BigNum instance or an integer string. Errors are prefixed with the
	1-based argument index, for example `(2)(Min)`.
]]
--- @param argumentValues { [any]: any }
--- @param argumentSchema Validate_ArgumentSchema
--- @return boolean
--- @return string?
function Validate.Args(argumentValues, argumentSchema)
	--[[ Specs ]]

	local specs = Validate.Compile(argumentSchema) --- @type { Validate_SchemaSpec }?

	-- Check if the schema compiled
	if not specs then
		return false, "(invalid schema)"
	end

	--[[ Returning ]]

	return Validate.CompiledArgs(argumentValues, specs)
end

--%%%%%%%%%%%%%%%%%%%% Compile

--[[
	Turns an argument schema into its spec list once, so `CompiledArgs` can check values without rebuilding it.
	Returns nil and warns when an entry isn't a schema entry.
]]
--- @param argumentSchema Validate_ArgumentSchema
--- @return { Validate_SchemaSpec }?
function Validate.Compile(argumentSchema)
	--[[ Checks ]]

	-- Check if the schema is a table
	if type(argumentSchema) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Invalid (argumentSchema) type. Expected (table), got ({typeof(argumentSchema)})!`)
		return nil
	end

	--[[ Specs ]]

	local specs = {} --- @type { Validate_SchemaSpec }

	for index: number, entry: any in ipairs(argumentSchema) do
		local spec = Schema.GetSpec(entry) --- @type Validate_SchemaSpec?

		-- Check if the schema entry is valid
		if not spec then
			warn(`[{_localName}::{script.Name}]: Invalid schema entry at index ({index})!`)
			return nil
		end

		specs[index] = spec
	end

	--[[ Returning ]]

	return specs
end

--%%%%%%%%%%%%%%%%%%%% Compiled Args

--[[
	Validates sequential arguments against a spec list from `Compile`. Same results as `Args`.
]]
--- @param argumentValues { [any]: any }
--- @param specs { Validate_SchemaSpec }
--- @return boolean
--- @return string?
function Validate.CompiledArgs(argumentValues, specs)
	--[[ Checks ]]

	-- Check if the values are a table
	if type(argumentValues) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Invalid (argumentValues) type. Expected (table), got ({typeof(argumentValues)})!`)
		return false, "(bad argumentValues)"
	end

	local argumentCount: number = Schema.GetArgumentCount(argumentValues)

	-- Check if there are more arguments than slots
	if argumentCount > #specs then
		return false, "(too many arguments)"
	end

	--[[ Validating ]]

	--- @param spec Validate_SchemaSpec
	for index: number, spec in ipairs(specs) do
		local value: any = argumentValues[index]

		-- Skip missing optional arguments
		if value == nil and Schema.IsOptional(spec) then
			continue
		end

		-- Check if a required trailing argument is missing
		if index > argumentCount then
			return false, `(missing argument {index})`
		end

		local success: boolean
		local result: string?
		success, result = ValidateValue.Validate(value, spec)

		if not success then
			return false, `({index}){result}`
		end
	end

	--[[ Returning ]]

	return true, nil
end

return Validate
