--[[
    Created By:     Nari
]]

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

--- @class Create_ValueMatchesProperty
local ValueMatchesProperty = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Enum Category

--[[
	Returns the enum category name of an EnumItem (`Enum.Material.Plastic` -> "Material").
]]
--- @return string
function ValueMatchesProperty.GetEnumCategory(enumItem: EnumItem)
	--[[ Local Variables ]]

	local rawType: string = tostring(enumItem.EnumType)

	--[[ Returning ]]

	return string.match(rawType, "^Enum%.([^%.]+)$") or rawType
end

--%%%%%%%%%%%%%%%%%%%% Matches

--[[
	Returns whether `value` fits the property's reflected script, enum, and instance types.
]]
--- @param info Create_PropertyInfo
--- @return boolean
function ValueMatchesProperty.Matches(info, value: any)
	--[[ Local Variables ]]

	local scriptType: string = info.ScriptType
	local valueType: string = typeof(value)

	--[[ Checks ]]

	-- Only Instance properties accept nil
	if value == nil then
		return scriptType == "Instance"
	end

	--[[ Enum Item ]]

	if scriptType == "EnumItem" then
		return valueType == "EnumItem" and (not info.EnumType or ValueMatchesProperty.GetEnumCategory(value) == info.EnumType)
	end

	--[[ Instance ]]

	if scriptType == "Instance" then
		return valueType == "Instance" and (not info.InstanceType or value:IsA(info.InstanceType))
	end

	--[[ Returning ]]

	return valueType == scriptType
end

return ValueMatchesProperty
