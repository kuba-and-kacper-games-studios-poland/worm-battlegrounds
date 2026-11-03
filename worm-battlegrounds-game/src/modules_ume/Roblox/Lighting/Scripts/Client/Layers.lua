--[[
	Created By: 	Nari
]]

-- --- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Lighting"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Lighting ]]

local activeLighting = {} --- @type { [string]: { [string]: { Lighting_Layer } } }

--[[ Layers ]]

local lastLayerOrder: number = 0

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Return Data By Weight

--[[
	Returns table with the higher weight.
]]
--- @param currentData { [string]: any }?
--- @param newData Lighting_Layer
--- @return { [string]: any }?
local function returnDataByWeight(currentData, newData, valueName: string)
	--[[ New Data ]]

	if not currentData then
		-- No current data -> set it as the new data
		if newData[valueName] then
			return {
				Value = newData[valueName],
				Weight = newData.Weight,
			}
		end

		-- Return nothing if value is missing
		return nil
	end

	--[[ Existing Data ]]

	-- Return new data if its weight is higher
	if newData.Weight > currentData.Weight then
		return {
			Value = newData[valueName],
			Weight = newData.Weight,
		}
	end

	-- Nothing changed
	return currentData
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

--- @class Lighting_Client_Layers
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Default

--[[
	Sets the property's base layer (weight `1`, the active preset's value), creating its stack when needed.
]]
function Module.SetDefault(effectName: string, propertyName: string, value: any)
	--[[ Data ]]

	activeLighting[effectName] = activeLighting[effectName] or {}
	activeLighting[effectName][propertyName] = activeLighting[effectName][propertyName] or {}

	local stack = activeLighting[effectName][propertyName] --- @type { Lighting_Layer }

	--[[ Local Variables ]]

	local totalItems: number = #stack

	local isEmpty: boolean = totalItems == 0
	local isLastNotDefault: boolean = not isEmpty and stack[totalItems].Weight ~= 1

	--[[ New Value ]]

	if isEmpty or isLastNotDefault then
		table.insert(stack, {
			Value = value,
			Weight = 1,
		})

		return
	end

	--[[ Existing Value ]]

	stack[totalItems].Value = value
end

--%%%%%%%%%%%%%%%%%%%% Set

--[[
	Adds or updates the property's layer with `layerId`, then sorts the stack: highest weight first,
	and at equal weights the layer added last.
]]
--- @param valueTable Lighting_ValueTable
function Module.Set(effectName: string, propertyName: string, layerId: string, valueTable)
	--[[ Data ]]

	activeLighting[effectName] = activeLighting[effectName] or {}
	activeLighting[effectName][propertyName] = activeLighting[effectName][propertyName] or {}

	local stack = activeLighting[effectName][propertyName] --- @type { Lighting_Layer }
	local layer --- @type Lighting_Layer?

	--[[ Finding ]]

	--- @param existingLayer Lighting_Layer
	for _index: number, existingLayer in ipairs(stack) do
		if existingLayer.Id == layerId then
			layer = existingLayer
			break
		end
	end

	-- Creating a new layer, ordered after every earlier one
	if not layer then
		lastLayerOrder += 1
		layer = {
			Id = layerId,
			Order = lastLayerOrder,
		}
		table.insert(stack, layer)
	end

	--[[ Updating Values ]]

	layer["Weight"] = valueTable.Weight
	layer["Value"] = valueTable.Value
	layer["Color_Hue"] = valueTable.Color_Hue
	layer["Color_Saturation"] = valueTable.Color_Saturation
	layer["Color_Value"] = valueTable.Color_Value

	--[[ Sorting ]]

	-- Highest weight first, then the layer added last
	table.sort(stack, function(a, b)
		if a.Weight ~= b.Weight then
			return a.Weight > b.Weight
		end
		return (a.Order or 0) > (b.Order or 0)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	Removes the property's layer with `layerId`. Returns false when there is no such layer.
]]
--- @return boolean
function Module.Clear(effectName: string, propertyName: string, layerId: string)
	--[[ Data ]]

	--- @type { Lighting_Layer }?
	local stack = activeLighting[effectName] and activeLighting[effectName][propertyName]

	--[[ Checks ]]

	-- Check if the property has a stack
	if not stack then
		return false
	end

	--[[ Finding ]]

	local layerPos: number? = nil

	--- @param existingLayer Lighting_Layer
	for index: number, existingLayer in ipairs(stack) do
		if existingLayer.Id == layerId then
			layerPos = index
			break
		end
	end

	--[[ Checks ]]

	-- Check if a layer has that id
	if not layerPos then
		return false
	end

	--[[ Removing ]]

	table.remove(stack, layerPos)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Top

--[[
	Returns the property's winning layer, or nil when its stack is empty.
]]
--- @return Lighting_Layer?
function Module.GetTop(effectName: string, propertyName: string)
	return activeLighting[effectName] and activeLighting[effectName][propertyName] and activeLighting[effectName][propertyName][1]
end

--%%%%%%%%%%%%%%%%%%%% Get Goal Value

--[[
	Returns the value a property's stack resolves to: the top layer's value, or for colors the highest-weight
	color with the highest-weight HSV shifts above it (falling back to the instance's color). Returns nil when the stack is empty.
]]
--- @return any
function Module.GetGoalValue(effectName: string, propertyName: string, propertyType: string, instance: Instance)
	--[[ Data ]]

	--- @type { Lighting_Layer }?
	local stack = activeLighting[effectName] and activeLighting[effectName][propertyName]

	--[[ Checks ]]

	-- Check if the property has a layer
	if not stack or #stack == 0 then
		return nil
	end

	-- Non-color properties take the top layer's value
	if propertyType ~= "Color3" then
		return stack[1].Value
	end

	--[[ Getting Values ]]

	local foundColor --- @type { [string]: any }?
	local foundColor_Hue --- @type { [string]: any }?
	local foundColor_Saturation --- @type { [string]: any }?
	local foundColor_Value --- @type { [string]: any }?

	-- Getting values with highest weight
	--- @param layer Lighting_Layer
	for _index: number, layer in ipairs(stack) do
		foundColor = returnDataByWeight(foundColor, layer, "Value")
		foundColor_Hue = returnDataByWeight(foundColor_Hue, layer, "Color_Hue")
		foundColor_Saturation = returnDataByWeight(foundColor_Saturation, layer, "Color_Saturation")
		foundColor_Value = returnDataByWeight(foundColor_Value, layer, "Color_Value")
	end

	--[[ Creating Color ]]

	local baseWeight: number = (foundColor and foundColor.Weight) or 1
	local currentColor: any = instance[propertyName]
	local baseColor: Color3 = if foundColor and foundColor.Value then foundColor.Value elseif typeof(currentColor) == "Color3" then currentColor else Color3.new(1, 1, 1)

	-- Getting hsv values of the base color
	local hue: number
	local saturation: number
	local value: number
	hue, saturation, value = baseColor:ToHSV()

	-- Higher-weight HSV shifts replace the base color's channels
	hue = if foundColor_Hue and foundColor_Hue.Weight > baseWeight then foundColor_Hue.Value else hue
	saturation = if foundColor_Saturation and foundColor_Saturation.Weight > baseWeight then foundColor_Saturation.Value else saturation
	value = if foundColor_Value and foundColor_Value.Weight > baseWeight then foundColor_Value.Value else value

	--[[ Returning ]]

	return Color3.fromHSV(hue, saturation, value)
end

--%%%%%%%%%%%%%%%%%%%% Get All

--[[
	Returns every property's layer stack, by effect and property.
]]
--- @return { [string]: { [string]: { Lighting_Layer } } }
function Module.GetAll()
	return activeLighting
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
