--[[
    Created By:     Nari
]]

local _localName = "Create"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local ReflectionService: ReflectionService = game:GetService("ReflectionService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local cachedClasses = {} --- @type { [string]: { [string]: Create_PropertyInfo } }

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

--- @class Create_PropertyIndex
local PropertyIndex = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Property Index

--[[
	Returns the property index of a class, built from ReflectionService on first access.
]]
--- @return { [string]: Create_PropertyInfo }?
function PropertyIndex.GetPropertyIndex(class: string)
	--[[ Checks ]]

	-- Return the cached index when the class was already read
	if cachedClasses[class] then
		return cachedClasses[class]
	end

	--[[ Reading ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(ReflectionService.GetPropertiesOfClass, ReflectionService, class)

	--[[ Checks ]]

	-- Check if the class is known to reflection
	if not success or type(result) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Failed to get properties of class ({class})! - ({result})`)
		return nil
	end

	--[[ Building ]]

	local propertyIndex = {} --- @type { [string]: Create_PropertyInfo }

	for _index: number, property: any in ipairs(result) do
		-- Skip entries without a name or type table
		if not property.Name or type(property.Type) ~= "table" then
			continue
		end

		propertyIndex[property.Name] = {
			ScriptType = property.Type.ScriptType or "",
			EngineType = property.Type.EngineType,
			EnumType = property.Type.EnumType,
			InstanceType = property.Type.InstanceType,
			Writable = type(property.Permits) == "table" and property.Permits.Write ~= nil,
		}
	end

	--[[ Saving ]]

	cachedClasses[class] = propertyIndex

	--[[ Returning ]]

	return propertyIndex
end

return PropertyIndex
