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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Lighting_LightingProperties
local lightingProperties = require(_data.LightingProperties)

--- @type { [string]: Lighting_LightingProperties }
local lightingPresets = {}
--- @type { [string]: Lighting_LightingProperties }
local lightingPresetAuthored = {}
for _, presetModule: ModuleScript in ipairs(I.Dirs.GlobalData.Lighting.Presets:GetChildren()) do
	if presetModule:IsA("ModuleScript") and not lightingPresets[presetModule.Name] then
		lightingPresets[presetModule.Name] = require(presetModule)
	end
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

--- @class Lighting_Client_Presets
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._loadPlacePresets()

	-- Keep only the authored properties of each preset for overlays
	--- @param presetData Lighting_LightingProperties
	for presetName: string, presetData in pairs(lightingPresets) do
		lightingPresetAuthored[presetName] = I.Table.DeepCopy(presetData)
	end

	Module._validateLightingPresets()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Validate Lighting Presets

--[[
	Validates lighting template and all lighting presets.
]]
function Module._validateLightingPresets()
	-- Default Lighting preset is missing
	if not lightingPresets[_settings.TEMPLATE_LIGHTING_ID] then
		warn(`[{_localName}::{script.Name}]: Template Lighting preset ({_settings.TEMPLATE_LIGHTING_ID}) is missing!`)
		return
	end

	--[[ Local Variables ]]

	local isTemplateLightingValid: boolean = true

	--%%%%%%%%%%%%%%%%%%%% Template Lighting Checks

	do
		--[[
			Validating that Template Lighting preset has all lighting properties.
		]]
		for effectName: string, propertiesTable: table in pairs(lightingProperties) do
			-- Effect data is missing
			if lightingPresets[_settings.TEMPLATE_LIGHTING_ID][effectName] == nil then
				warn(`[{_localName}::{script.Name}]: Effect data ({effectName}) is missing for ({_settings.TEMPLATE_LIGHTING_ID}) Template Lighting preset!`)
				isTemplateLightingValid = false
				continue
			end

			--[[ Properties Check ]]

			for propertyName: string, propertyType: string in pairs(propertiesTable) do
				-- Property data is missing
				if lightingPresets[_settings.TEMPLATE_LIGHTING_ID][effectName][propertyName] == nil then
					warn(`[{_localName}::{script.Name}]: Effect property ({effectName}::{propertyName}) is missing for ({_settings.TEMPLATE_LIGHTING_ID}) Template Lighting preset!`)
					isTemplateLightingValid = false
					continue
				end

				-- Property type is invalid
				if propertyType ~= typeof(lightingPresets[_settings.TEMPLATE_LIGHTING_ID][effectName][propertyName]) then
					warn(
						`[{_localName}::{script.Name}]: Effect property ({effectName}::{propertyName}) is invalid for ({_settings.TEMPLATE_LIGHTING_ID}) Template Lighting preset! Expected ({propertyType}), got ({lightingPresets[_settings.TEMPLATE_LIGHTING_ID][effectName][propertyName]}: {typeof(
							lightingPresets[_settings.TEMPLATE_LIGHTING_ID][effectName][propertyName]
						)})!`
					)
					isTemplateLightingValid = false
					continue
				end
			end
		end

		-- Return if template lighting is invalid
		if not isTemplateLightingValid then
			warn(`[{_localName}::{script.Name}]: Template Lighting preset ({_settings.TEMPLATE_LIGHTING_ID}) is invalid!`)
			return
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Cached Checks

	--- @param presetData Lighting_LightingProperties
	for presetName: string, presetData in pairs(lightingPresets) do
		for effectName: string, propertiesTable: table in pairs(lightingProperties) do
			--[[ Effect Table Check ]]

			-- Missing effect data for preset
			if not presetData[effectName] then
				-- Copying default values
				presetData[effectName] = I.Table.DeepCopy(lightingPresets[_settings.TEMPLATE_LIGHTING_ID][effectName])
				continue
			end

			--[[ Properties Check ]]

			for propertyName: string, propertyType: string in pairs(propertiesTable) do
				--[[ Property Check ]]

				-- Missing property data for effect
				if presetData[effectName][propertyName] == nil then
					-- Copying default value
					presetData[effectName][propertyName] = lightingPresets[_settings.TEMPLATE_LIGHTING_ID][effectName][propertyName]
					continue
				end

				--[[ Property Type Check ]]

				-- Property type is invalid
				if typeof(presetData[effectName][propertyName]) ~= propertyType then
					warn(
						`[{_localName}::{script.Name}]: Effect property ({effectName}::{propertyName}) is invalid for ({presetName}) Lighting Preset. Expected ({propertyType}), got ({presetData[effectName][propertyName]}: {typeof(
							presetData[effectName][propertyName]
						)})!`
					)

					-- Copying default value
					presetData[effectName][propertyName] = lightingPresets[_settings.TEMPLATE_LIGHTING_ID][effectName][propertyName]
					continue
				end
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Load Place Presets

--[[
	Reads the place's presets over the Lua presets with the same name: the Lighting Manager's active preset (Lighting
	itself) and the ones it stored in its presets folder, or, in a place it hasn't set up, Lighting as the default.
]]
function Module._loadPlacePresets()
	--[[ Checks ]]

	-- Skip when the place's lighting isn't used
	if not _settings.OVERWRITE_DEFAULT_LIGHTING then
		return
	end

	--[[ Data ]]

	local config: Instance? = Lighting:FindFirstChild(_settings.PLACE_CONFIG_NAME)
	local presetsFolder: Instance? = Lighting:FindFirstChild(_settings.PLACE_PRESETS_FOLDER)

	--[[ Reading ]]

	-- Without the Lighting Manager, the place's lighting is the default preset
	if not config or not config:IsA("Configuration") then
		Module._readPlacePreset(_settings.DEFAULT_LIGHTING_ID, Lighting, Lighting)
		return
	end

	-- The active preset is Lighting itself, named by its config
	Module._readPlacePreset(config:GetAttribute(_settings.PLACE_ID_ATTRIBUTE) or _settings.DEFAULT_LIGHTING_ID, Lighting, Lighting)

	-- Each stored preset keeps its Lighting values on its own config
	if presetsFolder then
		for _index: number, folder: Instance in ipairs(presetsFolder:GetChildren()) do
			local folderConfig: Instance? = folder:FindFirstChild(_settings.PLACE_CONFIG_NAME)
			if folderConfig and folderConfig:IsA("Configuration") then
				Module._readPlacePreset(folderConfig:GetAttribute(_settings.PLACE_ID_ATTRIBUTE) or folder.Name, folderConfig, folder)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Read Place Preset

--[[
	Saves one place preset: Lighting's values from `source` (Lighting, or a config's attributes), every other effect's
	from its instance in `container`. As in the Lighting Manager, a post effect with no instance is off and a missing
	Atmosphere has no density.
]]
function Module._readPlacePreset(presetName: string, source: Instance, container: Instance)
	--[[ Local Variables ]]

	local presetData = {} --- @type Lighting_LightingProperties

	--[[ Reading ]]

	--- @param propertiesTable { [string]: string }
	for effectName: string, propertiesTable in pairs(lightingProperties) do
		local effect: any = if effectName == "Lighting" then source else container:FindFirstChildOfClass(effectName)
		presetData[effectName] = {}

		-- Turn off an effect the preset has no instance for
		if not effect then
			if propertiesTable.Enabled then
				presetData[effectName].Enabled = false
			elseif effectName == "Atmosphere" then
				presetData[effectName].Density = 0
			end
			continue
		end

		for propertyName: string, _propertyType: string in pairs(propertiesTable) do
			presetData[effectName][propertyName] = if effect:IsA("Configuration") then effect:GetAttribute(propertyName) else effect[propertyName]
		end
	end

	--[[ Saving ]]

	lightingPresets[presetName] = presetData
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns the preset with every property filled in, or nil when there is no preset with that name.
]]
--- @return Lighting_LightingProperties?
function Module.Get(presetName: string)
	return lightingPresets[presetName]
end

--%%%%%%%%%%%%%%%%%%%% Get Authored

--[[
	Returns only the properties the preset's file sets, or nil when there is no preset with that name.
]]
--- @return Lighting_LightingProperties?
function Module.GetAuthored(presetName: string)
	return lightingPresetAuthored[presetName]
end

--%%%%%%%%%%%%%%%%%%%% Get All

--[[
	Returns every preset by name, with every property filled in.
]]
--- @return { [string]: Lighting_LightingProperties }
function Module.GetAll()
	return lightingPresets
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
