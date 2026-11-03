--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Lighting"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _data = script:FindFirstAncestor(_localName):FindFirstChild("Data")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type Lighting_LightingProperties
local lightingProperties = require(_data.LightingProperties)
--- @type Lighting_Tweens
local lightingTweens = require(I.Dirs.GlobalData.Lighting.Tweens)

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

--- @class Lighting_CommandBar_Client
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommandDictionaries()
	Module._registerCommands()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Command Dictionaries

--[[
	Registers dictionaries used by module commands.
]]
function Module._registerCommandDictionaries()
	if not I.Env.IsClient then
		return
	end

	--%%%%%%%%%%%%%%%%%%%% Lighting Presets

	do
		--[[ Getting Values ]]

		local allPresetNames = {} --- @type { string }
		for presetName: string, _presetData in pairs(I.Lighting._lightingPresets) do
			table.insert(allPresetNames, presetName)
		end

		--[[ Updating Directories ]]

		I.AdminPanel_CommandBar.SetDictionary("Lighting_PresetNames", allPresetNames, 255)
	end

	--%%%%%%%%%%%%%%%%%%%% Lighting Tweens

	do
		--[[ Getting Values ]]

		local allTweenNames = {} --- @type { string }
		for tweenName: string, _tweenInfo in pairs(lightingTweens) do
			table.insert(allTweenNames, tweenName)
		end

		--[[ Updating Directories ]]

		I.AdminPanel_CommandBar.SetDictionary("Lighting_TweenNames", allTweenNames, 255)
	end

	--%%%%%%%%%%%%%%%%%%%% Lighting Effects / Properties

	do
		--[[ Getting Values ]]

		local allEffectNames = {} --- @type { string }
		local allEffectProperties = {} --- @type { [string]: { string } }

		for effectName: string, propertiesTable: table in pairs(lightingProperties) do
			-- Creating table for storing values
			if not allEffectProperties[effectName] then
				allEffectProperties[effectName] = {}
			end

			-- Saving all valid properties
			for valueName: string, valueType: string in pairs(propertiesTable) do
				if valueType == "string" or valueType == "number" or valueType == "boolean" or valueType == "Color3" or valueType == "Vector3" then
					table.insert(allEffectProperties[effectName], valueName)
				end
			end

			-- Saving effect name
			table.insert(allEffectNames, effectName)
		end

		--[[ Updating Directories ]]

		I.AdminPanel_CommandBar.SetDictionary("Lighting_EffectNames", allEffectNames, 255)

		-- Creating separate properties dict for each effect
		for effectName: string, effectProperties: table in pairs(allEffectProperties) do
			I.AdminPanel_CommandBar.SetDictionary(`Lighting_EffectProperties-{effectName}`, effectProperties, 255)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers the client command that lists this client's lighting layers.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Dump

	--[[
		Lists each property's layers, winning layer first: only properties with layers above the base preset, or every property with `all`.
	]]
	--- @return boolean
	--- @return string
	local function dump(all: boolean?)
		--[[ Data ]]

		--- @type { [string]: { [string]: { Lighting_Layer } } }
		local activeLighting = I.Lighting._activeLighting

		--[[ Sorting ]]

		local effectNames = {} --- @type { string }
		for effectName: string in pairs(activeLighting) do
			table.insert(effectNames, effectName)
		end
		table.sort(effectNames)

		--[[ Formatting ]]

		local lines = { "Lighting layers (winning first)" } --- @type { string }

		for _index: number, effectName: string in ipairs(effectNames) do
			local propertyNames = {} --- @type { string }
			for propertyName: string in pairs(activeLighting[effectName]) do
				table.insert(propertyNames, propertyName)
			end
			table.sort(propertyNames)

			for _propertyIndex: number, propertyName: string in ipairs(propertyNames) do
				--- @type { Lighting_Layer }
				local stack = activeLighting[effectName][propertyName]

				-- Skip properties with only the base preset's layer
				if not all and #stack <= 1 then
					continue
				end

				local layerTexts = {} --- @type { string }

				--- @param layer Lighting_Layer
				for _layerIndex: number, layer in ipairs(stack) do
					local hsvText: string = if layer.Color_Hue or layer.Color_Saturation or layer.Color_Value then ` (h {layer.Color_Hue or "-"} s {layer.Color_Saturation or "-"} v {layer.Color_Value or "-"})` else ""

					table.insert(layerTexts, `{layer.Id or "base"} @{layer.Weight} = {tostring(layer.Value)}{hsvText}`)
				end

				table.insert(lines, `$|cr$|{effectName}.{propertyName}#|: {table.concat(layerTexts, "  >  ")}`)
			end
		end

		-- Say so when only the base preset is applied
		if #lines == 1 then
			table.insert(lines, "Only the base preset is applied")
		end

		--[[ Returning ]]

		return true, table.concat(lines, "\n")
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {
		{
			Aliases = { "dump" },
			PermissionLevel = 255,
			Args = {
				{ name = "all", types = { "boolean" }, optional = true },
			},
			Callback = dump,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Lighting_Client", {
		Aliases = { "lighting" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
