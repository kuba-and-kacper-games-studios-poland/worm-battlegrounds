--[[
    Created By:     Nari
]]

local _localName = "Table"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Deep Copy

--[[
	Recursively copies `t` without metatables, reusing copies for shared and cyclic subtables.
]]
--- @param seen { [any]: any }
--- @return any
local function deepCopy(t: any, seen)
	--[[ Checks ]]

	-- Return non-table values as they are
	if type(t) ~= "table" then
		return t
	end

	-- Reuse the copy of a table that was already visited
	if seen[t] then
		return seen[t]
	end

	--[[ Copying ]]

	local output = {}
	seen[t] = output

	for key: any, value: any in pairs(t) do
		output[key] = deepCopy(value, seen)
	end

	--[[ Returning ]]

	return output
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

--- @class Ume_Library_Table : Ume_Library
local Table = {}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function Table._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.Table = Table --- @type Ume_Library_Table
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Deep Copy

--[[
	Deep copies a table without metatables.
	Cyclic references and shared subtables are preserved in the copy.
]]
--- @param t { [any]: any }
--- @return { [any]: any }
function Table.DeepCopy(t)
	--[[ Checks ]]

	-- Check if the value is a table
	if type(t) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Invalid (t) type. Expected (table), got ({typeof(t)})!`)
		return t
	end

	--[[ Returning ]]

	return deepCopy(t, {})
end

--%%%%%%%%%%%%%%%%%%%% Sum

--[[
	Sums every numeric value in the table, including numeric strings.
]]
--- @param t { [any]: any }
--- @return number
function Table.Sum(t)
	--[[ Checks ]]

	-- Check if the value is a table
	if type(t) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Invalid (t) type. Expected (table), got ({typeof(t)})!`)
		return 0
	end

	--[[ Summing ]]

	local sum: number = 0

	for _key: any, value: any in pairs(t) do
		local numberValue: number? = tonumber(value)

		-- Skip values that are not numbers
		if not numberValue then
			continue
		end

		sum += numberValue
	end

	--[[ Returning ]]

	return sum
end

--%%%%%%%%%%%%%%%%%%%% Packed Length

--[[
	Returns the total key count of the table, including non-array keys.
]]
--- @param t { [any]: any }
--- @return number
function Table.PackedLength(t)
	--[[ Checks ]]

	-- Check if the value is a table
	if type(t) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Invalid (t) type. Expected (table), got ({typeof(t)})!`)
		return 0
	end

	--[[ Counting ]]

	local count: number = 0

	for _key: any in pairs(t) do
		count += 1
	end

	--[[ Returning ]]

	return count
end

--%%%%%%%%%%%%%%%%%%%% Safe Concat

--[[
	Concatenates `t[i]` through `t[j]` with `sep`, converting every value with `tostring`.
]]
--- @param t { any }
--- @return string
function Table.SafeConcat(t, sep: string?, i: number?, j: number?)
	--[[ Checks ]]

	-- Check if the value is a table
	if type(t) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Invalid (t) type. Expected (table), got ({typeof(t)})!`)
		return ""
	end

	--[[ Concatenating ]]

	local parts = {} --- @type { string }

	for index: number = i or 1, j or #t do
		table.insert(parts, tostring(t[index]))
	end

	--[[ Returning ]]

	return table.concat(parts, sep or "")
end

--%%%%%%%%%%%%%%%%%%%% Equal

--[[
	Performs a shallow comparison of two tables.
]]
--- @param t1 { [any]: any }
--- @param t2 { [any]: any }
--- @return boolean
function Table.Equal(t1, t2)
	--[[ Checks ]]

	-- Check if both values are tables
	if type(t1) ~= "table" or type(t2) ~= "table" then
		return false
	end

	--[[ Comparing ]]

	for key: any, value: any in pairs(t1) do
		if t2[key] ~= value then
			return false
		end
	end

	for key: any, value: any in pairs(t2) do
		if t1[key] ~= value then
			return false
		end
	end

	--[[ Returning ]]

	return true
end

return Table
