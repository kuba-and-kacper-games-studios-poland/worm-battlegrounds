--[[
	Created By: 	Nari
]]
-- #selene: allow(shadowing)
--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Lighting"

--- @type Lighting_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Lighting = I.S.Lighting

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _data = script:FindFirstAncestor(_localName):FindFirstChild("Data")
local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Lighting_LightingProperties
local lightingProperties = require(_data.LightingProperties)
--- @type Lighting_Tweens
local lightingTweens = require(I.Dirs.GlobalData.Lighting.Tweens)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Tweening = require(_scripts:FindFirstChild("Client"):FindFirstChild("Tweening")) --- @type Lighting_Client_Tweening
local Presets = require(_scripts:FindFirstChild("Client"):FindFirstChild("Presets")) --- @type Lighting_Client_Presets
local Layers = require(_scripts:FindFirstChild("Client"):FindFirstChild("Layers")) --- @type Lighting_Client_Layers

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local lightingElems = {} --- @type { [string]: Instance }

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	--[[ Setup ]]

	Presets.Init()
	Module._createLightingElements()

	--[[ Default Lighting ]]

	-- Initial set to create all needed data/instances
	Module.SetActivePreset(_settings.DEFAULT_LIGHTING_ID)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network

	--[[ Events ]]

	I.Network.GetEvent("Lighting_UpdateActiveLighting", {
		{ Types = { "string", "TweenInfo", "table" }, Optional = true },
		{ Type = "string", Optional = true },
	})
	I.Network.Fired("Lighting_UpdateActiveLighting", Module.UpdateActiveLighting)

	I.Network.GetEvent("Lighting_SetActivePreset", {
		"string",
		{ Type = "string", Optional = true },
		{ Type = "string", Optional = true },
		{ Types = { "string", "TweenInfo", "table" }, Optional = true },
		{ Type = "boolean", Optional = true },
	})
	I.Network.Fired("Lighting_SetActivePreset", Module.SetActivePreset)

	I.Network.GetEvent("Lighting_SetValue", {
		"string",
		"string",
		{ Type = "table" },
		{ Types = { "string", "TweenInfo", "table" }, Optional = true },
		{ Type = "boolean", Optional = true },
	})
	I.Network.Fired("Lighting_SetValue", Module.SetValue)

	I.Network.GetEvent("Lighting_SetValueBulk", {
		{ Type = "table" },
		{ Types = { "string", "TweenInfo", "table" }, Optional = true },
	})
	I.Network.Fired("Lighting_SetValueBulk", Module.SetValueBulk)

	I.Network.GetEvent("Lighting_ClearValue", {
		"string",
		"string",
		"number",
		{ Types = { "string", "TweenInfo", "table" }, Optional = true },
		{ Type = "boolean", Optional = true },
		{ Type = "string", Optional = true },
	})
	I.Network.Fired("Lighting_ClearValue", Module.ClearValue)

	I.Network.GetEvent("Lighting_ClearValueBulk", {
		{ Type = "table" },
		{ Types = { "string", "TweenInfo", "table" }, Optional = true },
	})
	I.Network.Fired("Lighting_ClearValueBulk", Module.ClearValueBulk)

	--[[ Functions ]]

	I.Network.GetFunction("Lighting_UpdateActiveLighting-Return", {
		{ Types = { "string", "TweenInfo", "table" }, Optional = true },
		{ Type = "string", Optional = true },
	})
	I.Network.OnInvoke("Lighting_UpdateActiveLighting-Return", Module.UpdateActiveLighting)

	I.Network.GetFunction("Lighting_SetActivePreset-Return", {
		"string",
		{ Type = "string", Optional = true },
		{ Type = "string", Optional = true },
		{ Types = { "string", "TweenInfo", "table" }, Optional = true },
		{ Type = "boolean", Optional = true },
	})
	I.Network.OnInvoke("Lighting_SetActivePreset-Return", Module.SetActivePreset)

	I.Network.GetFunction("Lighting_SetValue-Return", {
		"string",
		"string",
		{ Type = "table" },
		{ Types = { "string", "TweenInfo", "table" }, Optional = true },
		{ Type = "boolean", Optional = true },
	})
	I.Network.OnInvoke("Lighting_SetValue-Return", Module.SetValue)

	I.Network.GetFunction("Lighting_SetValueBulk-Return", {
		{ Type = "table" },
		{ Types = { "string", "TweenInfo", "table" }, Optional = true },
	})
	I.Network.OnInvoke("Lighting_SetValueBulk-Return", Module.SetValueBulk)

	I.Network.GetFunction("Lighting_ClearValue-Return", {
		"string",
		"string",
		"number",
		{ Types = { "string", "TweenInfo", "table" }, Optional = true },
		{ Type = "boolean", Optional = true },
		{ Type = "string", Optional = true },
	})
	I.Network.OnInvoke("Lighting_ClearValue-Return", Module.ClearValue)

	I.Network.GetFunction("Lighting_ClearValueBulk-Return", {
		{ Type = "table" },
		{ Types = { "string", "TweenInfo", "table" }, Optional = true },
	})
	I.Network.OnInvoke("Lighting_ClearValueBulk-Return", Module.ClearValueBulk)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Lighting = {

		--[[ Control ]]

		UpdateActiveLighting = Module.UpdateActiveLighting,

		--[[ Set Control ]]

		SetActivePreset = Module.SetActivePreset,
		SetOverlayPreset = Module.SetOverlayPreset,

		SetValue = Module.SetValue,
		SetValueBulk = Module.SetValueBulk,

		--[[ Clear Control ]]

		ClearValue = Module.ClearValue,
		ClearValueBulk = Module.ClearValueBulk,
		ClearOverlayPreset = Module.ClearOverlayPreset,

		--[[ Methods ]]

		GetValue = Module.GetValue,

		--[[ Private ]]

		_lightingPresets = Presets.GetAll(),
		_activeLighting = Layers.GetAll(),
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Lighting Elements

--[[
	Creates all lighting effects instances.
]]
function Module._createLightingElements()
	--[[ Getting Lighting ]]

	lightingElems["Lighting"] = Lighting
	lightingElems["Lighting"]:ClearAllChildren() -- Removing all existing instances to create fresh ones

	--[[ Creating Effects ]]

	for _, elemClass in ipairs({
		"Atmosphere",
		"Sky",
		"BloomEffect",
		"BlurEffect",
		"ColorCorrectionEffect",
		"DepthOfFieldEffect",
		"SunRaysEffect",
	}) do
		local newEffect: Instance = Instance.new(elemClass)
		newEffect.Parent = lightingElems["Lighting"]
		lightingElems[elemClass] = newEffect
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update Active Lighting

--[[
	Updates Lighting so it matches the winning values of the layer stacks.
	Properties the tween doesn't cover are set at once; a property already tweening to its goal keeps its tween.
]]
--- @param tweenInfo string | TweenInfo | { [string]: TweenInfo | { [string]: TweenInfo } }
--- @param clockTimeDirection Lighting_ClockTimeDirection?
--- @return boolean
function Module.UpdateActiveLighting(tweenInfo, clockTimeDirection)
	--[[ Checks ]]

	-- Check if the ClockTime direction is known
	if clockTimeDirection ~= nil and clockTimeDirection ~= "Shortest" and clockTimeDirection ~= "Forward" and clockTimeDirection ~= "Backward" then
		warn(`[{_localName}::{script.Name}]: ({clockTimeDirection}) is not a valid ClockTime direction - using Shortest.`)
		clockTimeDirection = nil
	end

	--[[ Local Variables ]]

	-- Resolve a tween name from the Tweens data
	if type(tweenInfo) == "string" then
		tweenInfo = lightingTweens[tweenInfo]
	end

	--[[ Updating Lighting ]]

	--- @param propertiesTable { [string]: string }
	for effectName: string, propertiesTable in pairs(lightingProperties) do
		for propertyName: string, propertyType: string in pairs(propertiesTable) do
			--[[ Data ]]

			local goalValue: any = Layers.GetGoalValue(effectName, propertyName, propertyType, lightingElems[effectName])

			--[[ Checks ]]

			-- Skip properties with no value set
			if goalValue == nil then
				continue
			end

			--[[ Applying ]]

			local propertyTweenInfo: TweenInfo? = Tweening.GetPropertyTweenInfo(tweenInfo, effectName, propertyName)
			Tweening.Apply(lightingElems[effectName], effectName, propertyName, goalValue, propertyTweenInfo, clockTimeDirection)
		end
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Set Control

--%%%%%%%%%%%%%%%%%%%% Set Active Preset

--[[
	Updates active lighting to match the given preset, or the preset effect/property.
]]
--- @param tweenInfo TweenInfo | { [string]: TweenInfo }
function Module.SetActivePreset(presetName: string, effectName: string?, propertyName: string?, tweenInfo, updateLighting: boolean?)
	--[[ Data ]]

	--- @type Lighting_LightingProperties?
	local presetData = Presets.Get(presetName)

	--[[ Checks ]]

	do
		-- Invalid preset
		if presetData == nil then
			warn(`[{_localName}::{script.Name}]: ({presetName}) is not a valid Lighting preset!`)
			return false
		end

		-- Invalid effect
		if effectName and presetData[effectName] == nil then
			warn(`[{_localName}::{script.Name}]: ({effectName}) is not a valid Lighting Effect!`)
			return false
		end

		-- Invalid effect property
		if effectName and propertyName and presetData[effectName][propertyName] == nil then
			warn(`[{_localName}::{script.Name}]: ({propertyName}) is not a valid property for ({effectName}) Lighting Effect!`)
			return false
		end

		-- Property passed without effect
		if not effectName and propertyName then
			warn(`[{_localName}::{script.Name}]: Effect property ({propertyName}) was passed without its parent Lighting Effect!`)
			return false
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Preset Change

	if not effectName then
		--- @param propertiesTable Lighting_LightingProperties
		for effectName: string, propertiesTable in pairs(lightingProperties) do
			--[[ Updating Properties ]]

			for propertyName: string, _propertyType: string in pairs(propertiesTable) do
				Layers.SetDefault(effectName, propertyName, presetData[effectName][propertyName])
			end
		end

		--[[ Updating Lighting ]]

		if updateLighting == nil or updateLighting == true then
			Module.UpdateActiveLighting(tweenInfo)
		end

		return true
	end

	--%%%%%%%%%%%%%%%%%%%% Effect Change

	if effectName and not propertyName then
		--[[ Updating Properties ]]

		for propertyName: string, _propertyType: string in pairs(lightingProperties[effectName]) do
			Layers.SetDefault(effectName, propertyName, presetData[effectName][propertyName])
		end

		--[[ Updating Lighting ]]

		if updateLighting == nil or updateLighting == true then
			Module.UpdateActiveLighting(tweenInfo)
		end

		return true
	end

	--%%%%%%%%%%%%%%%%%%%% Effect Property Change

	if effectName and propertyName then
		--[[ Updating Properties ]]

		Layers.SetDefault(effectName, propertyName, presetData[effectName][propertyName])

		--[[ Updating Lighting ]]

		if updateLighting == nil or updateLighting == true then
			Module.UpdateActiveLighting(tweenInfo)
		end

		return true
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Overlay Preset

--[[
	Applies only the authored properties of a preset at the given weight on top of the current lighting.
	Its layers use `id` (defaults to the weight), so `ClearOverlayPreset` with the same id removes them.
]]
--- @param tweenInfo TweenInfo | { [string]: TweenInfo }
--- @return boolean
function Module.SetOverlayPreset(presetName: string, weight: number, tweenInfo, updateLighting: boolean?, id: string?)
	--[[ Checks ]]

	-- Check if the preset exists
	if not presetName or Presets.GetAuthored(presetName) == nil then
		warn(`[{_localName}::{script.Name}]: ({presetName}) is not a valid Lighting overlay preset!`)
		return false
	end

	-- Check if the weight is a number
	if not weight or type(weight) ~= "number" then
		warn(`[{_localName}::{script.Name}]: Invalid (weight) type. Expected (number), got ({weight}: {typeof(weight)})!`)
		return false
	end

	-- Check if the weight is above the default weight
	if weight <= 1 then
		warn(`[{_localName}::{script.Name}]: Weight cannot be equal to or less than (1)!`)
		return false
	end

	-- Check if the id is a string when given
	if id ~= nil and type(id) ~= "string" then
		warn(`[{_localName}::{script.Name}]: Invalid (id) type. Expected (string), got ({id}: {typeof(id)})!`)
		return false
	end

	--[[ Applying ]]

	--- @type Lighting_LightingProperties
	local authoredPreset = Presets.GetAuthored(presetName)

	--- @param effectTable { [string]: any }
	for effectName: string, effectTable in pairs(authoredPreset) do
		-- Skip values that are not effect tables
		if type(effectTable) ~= "table" then
			continue
		end

		for propertyName: string, propertyValue: any in pairs(effectTable) do
			Module.SetValue(effectName, propertyName, {
				Id = id,
				Value = propertyValue,
				Weight = weight,
			}, nil, false)
		end
	end

	--[[ Updating Lighting ]]

	if updateLighting == nil or updateLighting == true then
		Module.UpdateActiveLighting(tweenInfo)
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Set Value

--[[
	Sets value for effect property with additional weight and updates the active lighting.
	The layer is keyed by `valueTable.Id` (defaults to the weight); at equal weights the layer added last wins.
]]
--- @param valueTable Lighting_ValueTable
--- @param tweenInfo TweenInfo | { [string]: TweenInfo }
--- @return boolean
function Module.SetValue(effectName: string, propertyName: string, valueTable, tweenInfo, updateLighting: boolean?)
	--[[ Checks ]]

	do
		-- Invalid effect
		if not effectName or lightingProperties[effectName] == nil then
			warn(`[{_localName}::{script.Name}]: ({effectName}) is not a valid Lighting Effect!`)
			return false
		end

		-- Invalid effect property
		if not propertyName or lightingProperties[effectName][propertyName] == nil then
			warn(`[{_localName}::{script.Name}]: ({propertyName}) is not a valid property for ({effectName}) Lighting Effect!`)
			return false
		end
	end

	--[[ ValueTable Checks ]]

	do
		-- Invalid valueTable
		if not valueTable or type(valueTable) ~= "table" then
			warn(`[{_localName}::{script.Name}]: ({valueTable}) is not a valid (valueTable)!`)
			return false
		end

		--[[ Weight Checks ]]

		-- Weight is missing
		if not valueTable["Weight"] then
			warn(`[{_localName}::{script.Name}]: Weight is missing from the (valueTable)!`)
			return false
		end

		-- Invalid weight type
		if type(valueTable["Weight"]) ~= "number" then
			warn(`[{_localName}::{script.Name}]: Invalid (valueTable["Weight"]) type. Expected (number), got ({valueTable["Weight"]}: {typeof(valueTable["Weight"])})!`)
			return false
		end

		-- Invalid weight
		if valueTable["Weight"] <= 1 then
			warn(`[{_localName}::{script.Name}]: Weight ({valueTable["Weight"]}) cannot be equal to or less than (1)!`)
			return false
		end

		--[[ Id Checks ]]

		-- Invalid id type
		if valueTable["Id"] ~= nil and type(valueTable["Id"]) ~= "string" then
			warn(`[{_localName}::{script.Name}]: Invalid (valueTable["Id"]) type. Expected (string), got ({valueTable["Id"]}: {typeof(valueTable["Id"])})!`)
			return false
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Value Table Check

	--[[
		Checking if there are valid entries in the `valueTable` that can be used to update the property.
	]]
	do
		local totalValues: number = 0

		-- Default value, `false` included
		if valueTable.Value ~= nil then
			if lightingProperties[effectName][propertyName] ~= typeof(valueTable.Value) then
				warn(
					`[{_localName}::{script.Name}]: Invalid (valueTable["Value"]) type. Expected ({lightingProperties[effectName][propertyName]}), got ({valueTable["Value"]}: {typeof(valueTable["Value"])}) for ({effectName}||{propertyName}) Lighting Effect!`
				)
				return false
			end

			totalValues += 1
		end

		--[[ Color ]]

		-- Color Hue
		if valueTable.Color_Hue and lightingProperties[effectName][propertyName] == "Color3" then
			if typeof(valueTable.Color_Hue) ~= "number" then
				warn(
					`[{_localName}::{script.Name}]: Invalid (valueTable["Color_Hue"]) type. Expected (number), got ({valueTable["Color_Hue"]}: {typeof(valueTable["Color_Hue"])}) for ({effectName}||{propertyName}) Lighting Effect!`
				)
				return false
			end

			totalValues += 1
		end

		-- Color Saturation
		if valueTable.Color_Saturation and lightingProperties[effectName][propertyName] == "Color3" then
			if typeof(valueTable.Color_Saturation) ~= "number" then
				warn(
					`[{_localName}::{script.Name}]: Invalid (valueTable["Color_Saturation"]) type. Expected (number), got ({valueTable["Color_Saturation"]}: {typeof(valueTable["Color_Saturation"])}) for ({effectName}||{propertyName}) Lighting Effect!`
				)
				return false
			end

			totalValues += 1
		end

		-- Color Value
		if valueTable.Color_Value and lightingProperties[effectName][propertyName] == "Color3" then
			if typeof(valueTable.Color_Value) ~= "number" then
				warn(
					`[{_localName}::{script.Name}]: Invalid (valueTable["Color_Value"]) type. Expected (number), got ({valueTable["Color_Value"]}: {typeof(valueTable["Color_Value"])}) for ({effectName}||{propertyName}) Lighting Effect!`
				)
				return false
			end

			totalValues += 1
		end

		--[[ Values Check ]]

		-- Check if any value was set
		if totalValues == 0 then
			warn(`[{_localName}::{script.Name}]: No valid values were set for ({effectName}||{propertyName}) Lighting Effect!`)
			return false
		end
	end

	--[[ Saving ]]

	Layers.Set(effectName, propertyName, valueTable.Id or tostring(valueTable.Weight), valueTable)

	--[[ Updating Lighting ]]

	if updateLighting == nil or updateLighting == true then
		Module.UpdateActiveLighting(tweenInfo)
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Set Value Bulk

--[[
	Sets values for effect properties in bulk and then updates the lighting.\
	Table structure is the same as params for the `SetValue` function.
]]
--- @param tweenInfo TweenInfo | { [string]: TweenInfo }
--- @return { [string]: boolean }
function Module.SetValueBulk(valuesTable: table, tweenInfo)
	--[[ Setting Values ]]

	local changedValues = {} --- @type { [string]: boolean }
	for rowIndex: number, valueTable in ipairs(valuesTable) do
		local success: boolean = Module.SetValue(valueTable[1], valueTable[2], valueTable[3], nil, false)
		local weightPart: string = (type(valueTable[3]) == "table" and valueTable[3].Weight) and tostring(valueTable[3].Weight) or ""
		changedValues[`{rowIndex}_{valueTable[1]}_{valueTable[2] or ""}_{weightPart}`] = success == true
	end

	--[[ Updating Lighting ]]

	Module.UpdateActiveLighting(tweenInfo)

	--[[ Returning ]]

	return changedValues
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Clear Control

--%%%%%%%%%%%%%%%%%%%% Clear Value

--[[
	Clears the effect property's layer with the given id (defaults to the weight) and updates the lighting.
]]
--- @param tweenInfo TweenInfo | { [string]: TweenInfo }
--- @return boolean
function Module.ClearValue(effectName: string, propertyName: string, weight: number, tweenInfo, updateLighting: boolean?, id: string?)
	--[[ Checks ]]

	do
		-- Invalid effect
		if not effectName or lightingProperties[effectName] == nil then
			warn(`[{_localName}::{script.Name}]: ({effectName}) is not a valid Lighting Effect!`)
			return false
		end

		-- Invalid effect property
		if not propertyName or lightingProperties[effectName][propertyName] == nil then
			warn(`[{_localName}::{script.Name}]: ({propertyName}) is not a valid property for ({effectName}) Lighting Effect!`)
			return false
		end

		--[[ Weight Checks ]]

		-- Invalid weight type
		if not weight or type(weight) ~= "number" then
			warn(`[{_localName}::{script.Name}]: Invalid (weight) type. Expected (number), got ({weight}: {typeof(weight)})!`)
			return false
		end

		-- Invalid weight
		if weight <= 1 then
			warn(`[{_localName}::{script.Name}]: Weight cannot be equal to or less than (1)!`)
			return false
		end

		--[[ Id Checks ]]

		-- Invalid id type
		if id ~= nil and type(id) ~= "string" then
			warn(`[{_localName}::{script.Name}]: Invalid (id) type. Expected (string), got ({id}: {typeof(id)})!`)
			return false
		end
	end

	--[[ Removing ]]

	-- Check if the property had a layer with that id
	if not Layers.Clear(effectName, propertyName, id or tostring(weight)) then
		return false
	end

	--[[ Updating Lighting ]]

	if updateLighting == nil or updateLighting == true then
		Module.UpdateActiveLighting(tweenInfo)
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Clear Value Bulk

--[[
	Clears values for effect properties under given weight in bulk and updates the lighting.\
	Each row is `{ effectName, propertyName, weight, id? }`, the params of the `ClearValue` function.
]]
--- @param valuesTable { { any } }
--- @param tweenInfo TweenInfo | { [string]: TweenInfo }
--- @return { [string]: boolean }
function Module.ClearValueBulk(valuesTable, tweenInfo)
	--[[ Clearing Values ]]

	local changedValues = {} --- @type { [string]: boolean }

	--- @param valueTable { any }
	for rowIndex: number, valueTable in ipairs(valuesTable) do
		local success: boolean = Module.ClearValue(valueTable[1], valueTable[2], valueTable[3], nil, false, valueTable[4])
		local weightPart: string = valueTable[3] ~= nil and tostring(valueTable[3]) or ""
		changedValues[`{rowIndex}_{valueTable[1]}_{valueTable[2] or ""}_{weightPart}`] = success == true
	end

	--[[ Updating Lighting ]]

	Module.UpdateActiveLighting(tweenInfo)

	--[[ Returning ]]

	return changedValues
end

--%%%%%%%%%%%%%%%%%%%% Clear Overlay Preset

--[[
	Clears the authored overlay properties of a preset: the layers with the given id (defaults to the weight).
]]
--- @param tweenInfo TweenInfo | { [string]: TweenInfo }
--- @return boolean
function Module.ClearOverlayPreset(presetName: string, weight: number, tweenInfo, updateLighting: boolean?, id: string?)
	--[[ Checks ]]

	-- Check if the preset exists
	if not presetName or Presets.GetAuthored(presetName) == nil then
		warn(`[{_localName}::{script.Name}]: ({presetName}) is not a valid Lighting overlay preset!`)
		return false
	end

	-- Check if the weight is a number
	if not weight or type(weight) ~= "number" then
		warn(`[{_localName}::{script.Name}]: Invalid (weight) type. Expected (number), got ({weight}: {typeof(weight)})!`)
		return false
	end

	-- Check if the weight is above the default weight
	if weight <= 1 then
		warn(`[{_localName}::{script.Name}]: Weight cannot be equal to or less than (1)!`)
		return false
	end

	-- Check if the id is a string when given
	if id ~= nil and type(id) ~= "string" then
		warn(`[{_localName}::{script.Name}]: Invalid (id) type. Expected (string), got ({id}: {typeof(id)})!`)
		return false
	end

	--[[ Clearing ]]

	--- @type Lighting_LightingProperties
	local authoredPreset = Presets.GetAuthored(presetName)

	--- @param effectTable { [string]: any }
	for effectName: string, effectTable in pairs(authoredPreset) do
		-- Skip values that are not effect tables
		if type(effectTable) ~= "table" then
			continue
		end

		for propertyName: string in pairs(effectTable) do
			Module.ClearValue(effectName, propertyName, weight, nil, false, id)
		end
	end

	--[[ Updating Lighting ]]

	if updateLighting == nil or updateLighting == true then
		Module.UpdateActiveLighting(tweenInfo)
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Value

--[[
	**CLIENT** |
	Returns the value a property resolves to, with the weight and id of its top layer (the base preset's layer has no id).
]]
--- @return any
--- @return number?
--- @return string?
function Module.GetValue(effectName: string, propertyName: string)
	--[[ Checks ]]

	-- Check if the effect exists
	if lightingProperties[effectName] == nil then
		warn(`[{_localName}::{script.Name}]: ({effectName}) is not a valid Lighting Effect!`)
		return nil
	end

	-- Check if the property exists on the effect
	if lightingProperties[effectName][propertyName] == nil then
		warn(`[{_localName}::{script.Name}]: ({propertyName}) is not a valid property for ({effectName}) Lighting Effect!`)
		return nil
	end

	--[[ Data ]]

	--- @type Lighting_Layer?
	local topLayer = Layers.GetTop(effectName, propertyName)

	--[[ Checks ]]

	-- Check if the property has a layer
	if not topLayer then
		return nil
	end

	--[[ Returning ]]

	return Layers.GetGoalValue(effectName, propertyName, lightingProperties[effectName][propertyName], lightingElems[effectName]), topLayer.Weight, topLayer.Id
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
