--[[
    Created By:     Nari
]]

--- @type Ume
local I
local _localName = "Format"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

local DEFAULT_FORMAT_TYPE: string = "default"
local ABBREVIATE_LENGTH: number = 10

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type { [string]: (value: number | string) -> string }
local formatFunctions = {

	--[[ General ]]

	["default"] = function(value: number | string)
		local text: string = tostring(value)

		-- Leave values that are not numbers untouched
		if not I.Number.IsNumberString(text) then
			return text
		end

		return I.BN.DynamicFormat(text, ABBREVIATE_LENGTH, ",")
	end,

	--[[ Time ]]

	["time"] = function(value: number | string)
		return I.Time.FormatClean(value)
	end,
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

--- @class Ume_Library_Format : Ume_Library
local Format = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Stores Ume and assigns this library onto it.
]]
--- @param umeInstance Ume
function Format._injectUme(umeInstance)
	--[[ Storing ]]

	I = umeInstance

	--[[ Assigning ]]

	I.Format = Format --- @type Ume_Library_Format
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Table

--[[
	Formats every number and string in the table in place, recursing into nested tables.
]]
--- @param t { [any]: any }
function Format.Table(t, formatType: string?)
	--[[ Checks ]]

	-- Check if the value is a table
	if type(t) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Invalid (t) type. Expected (table), got ({typeof(t)})!`)
		return
	end

	--[[ Formatting ]]

	for key: any, value: any in pairs(t) do
		if type(value) == "table" then
			Format.Table(value, formatType)
		elseif type(value) == "string" or type(value) == "number" then
			t[key] = Format.Text(value, formatType)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Format Function Names

--[[
	Returns the names of every format type.
]]
--- @return { string }
function Format.GetFormatFunctionNames()
	--[[ Collecting ]]

	local names = {} --- @type { string }

	for formatName: string in pairs(formatFunctions) do
		table.insert(names, formatName)
	end

	--[[ Returning ]]

	table.sort(names)

	return names
end

--%%%%%%%%%%%%%%%%%%%% Text

--[[
	Formats a number or string with the given format type (`default` when unknown or omitted).
	Other value types are returned through `tostring`.
]]
--- @return string
function Format.Text(value: any, formatType: string?)
	--[[ Checks ]]

	-- Check if the value can be formatted
	if type(value) ~= "number" and type(value) ~= "string" then
		return tostring(value)
	end

	--[[ Returning ]]

	local formatFunction = formatFunctions[formatType or DEFAULT_FORMAT_TYPE] or formatFunctions[DEFAULT_FORMAT_TYPE]

	return formatFunction(value)
end

return Format
