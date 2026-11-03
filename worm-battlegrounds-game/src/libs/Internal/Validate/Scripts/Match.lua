--[[
    Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

--- @type { [string]: boolean }
local LUA_TYPES = {
	["string"] = true,
	["number"] = true,
	["boolean"] = true,
	["function"] = true,
	["thread"] = true,
	["buffer"] = true,
	["nil"] = true,
}

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

--- @class Validate_Match
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param internal Validate_Internal
function Module.Init(internal)
	Internal = internal
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Type

--[[
	Returns whether the value matches one type name. Accepts Luau types, `typeof` names,
	`BigNum`, and Instance class names (`Part`); `Instance` is narrowed by the spec's `ClassName`.
]]
--- @param spec Validate_SchemaSpec
--- @return boolean
function Module.IsType(value: any, typeName: string, spec)
	--[[ BigNum ]]

	if typeName == "BigNum" then
		return Internal.BigNum.IsBigNumValue(value)
	end

	-- Keep BigNum instances out of plain table slots
	if typeName == "table" then
		return type(value) == "table" and not Internal.BigNum.IsBigNum(value)
	end

	--[[ Luau ]]

	if LUA_TYPES[typeName] then
		return type(value) == typeName
	end

	--[[ Roblox ]]

	local valueType: string = typeof(value)

	if valueType == typeName then
		return typeName ~= "Instance" or spec.ClassName == nil or value:IsA(spec.ClassName)
	end

	--[[ Returning ]]

	return valueType == "Instance" and value:IsA(typeName)
end

return Module
