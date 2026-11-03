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

--- @class Lighting_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function setActivePreset(player: Player, presetName: string, effectName: string?, propertyName: string?, tweenName: string?)
		--[[ Checks ]]

		-- Check if the effect exists (the player's client checks the preset)
		if effectName and lightingProperties[effectName] == nil then
			return false, `Invalid Effect name: $|cr$|{effectName}#|`
		end

		-- Check if a property comes with its effect
		if not effectName and propertyName then
			return false, `Effect property $|cr$|{propertyName}#| was passed without its parent Lighting Effect!`
		end

		-- Check if the property exists
		if propertyName and lightingProperties[effectName][propertyName] == nil then
			return false, `Invalid Effect $|cr$|{effectName}#| property name: $|cr$|{propertyName}#|`
		end

		-- Check if the tween exists
		if tweenName and not lightingTweens[tweenName] then
			return false, `Invalid Tween name: $|cr$|{tweenName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Lighting.SetActivePreset(player, presetName, effectName, propertyName, tweenName, true, true)

		-- Returning
		if value then
			if propertyName then
				return true, `Set $|cr$|{player.Name}#|'s Lighting Effect $|cr$|{effectName}#| property $|cr$|{propertyName}#| preset to: $|cr$|{presetName}#|`
			elseif effectName then
				return true, `Set $|cr$|{player.Name}#|'s Lighting Effect $|cr$|{effectName}#| preset to: $|cr$|{presetName}#|`
			else
				return true, `Set $|cr$|{player.Name}#|'s Lighting preset to: $|cr$|{presetName}#|`
			end
		else
			if propertyName then
				return false, `Failed to set $|cr$|{player.Name}#|'s Lighting Effect $|cr$|{effectName}#| property $|cr$|{propertyName}#| preset`
			elseif effectName then
				return false, `Failed to set $|cr$|{player.Name}#|'s Lighting Effect $|cr$|{effectName}#| preset`
			else
				return false, `Failed to set $|cr$|{player.Name}#|'s Lighting preset`
			end
		end
	end

	local function setValue(player: Player, effectName: string, propertyName: string, value: any, weight: number, tweenName: string?)
		--[[ Checks ]]

		if not lightingProperties[effectName] then
			return false, `Invalid Effect name: $|cr$|{effectName}#|`
		end

		if not lightingProperties[effectName][propertyName] then
			return false, `Invalid Effect $|cr$|{effectName}#| property name: $|cr$|{propertyName}#|`
		end

		if lightingProperties[effectName][propertyName] ~= typeof(value) then
			return false, `Invalid Effect $|cr$|{effectName}#| property type. Expected ($|cr$|{lightingProperties[effectName][propertyName]}#|), got ($|cr$|{value}#|: $|cr$|{typeof(value)}#|)`
		end

		if weight <= 1 then
			return false, `Weight $|cr$|{weight}#| cannot be less than or equal to $|cr$|1#|`
		end

		if tweenName and not lightingTweens[tweenName] then
			return false, `Invalid Tween name: $|cr$|{tweenName}#|`
		end

		--[[ Updating ]]

		-- Getting value
		local runValue: boolean = I.Lighting.SetValue(player, effectName, propertyName, { Value = value, Weight = weight }, tweenName, true, true)

		-- Returning
		if runValue then
			return true, `Set $|cr$|{player.Name}#|'s Lighting Effect $|cr$|{effectName}#| property $|cr$|{propertyName}#| value to: $|cr$|{value}#|`
		else
			return false, `Failed to set $|cr$|{player.Name}#|'s Lighting Effect $|cr$|{effectName}#| property $|cr$|{propertyName}#| value`
		end
	end

	local function clearValue(player: Player, effectName: string, propertyName: string, weight: number, tweenName: string?)
		--[[ Checks ]]

		if not lightingProperties[effectName] then
			return false, `Invalid Effect name: $|cr$|{effectName}#|`
		end

		if not lightingProperties[effectName][propertyName] then
			return false, `Invalid Effect $|cr$|{effectName}#| property name: $|cr$|{propertyName}#|`
		end

		if weight <= 1 then
			return false, `Weight $|cr$|{weight}#| cannot be less than or equal to $|cr$|1#|`
		end

		if tweenName and not lightingTweens[tweenName] then
			return false, `Invalid Tween name: $|cr$|{tweenName}#|`
		end

		--[[ Updating ]]

		-- Getting value
		local value: boolean = I.Lighting.ClearValue(player, effectName, propertyName, weight, tweenName, true, true)

		-- Returning
		if value then
			return true, `Cleared $|cr$|{player.Name}#|'s Lighting Effect $|cr$|{effectName}#| property $|cr$|{propertyName}#| value`
		else
			return false, `Failed to clear $|cr$|{player.Name}#|'s Lighting Effect $|cr$|{effectName}#| property $|cr$|{propertyName}#| value`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		-- Set
		{
			Aliases = { "set_active_preset" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "presetName", types = { "string" }, dict = "Lighting_PresetNames", requireDict = true },
				{ name = "effectName", types = { "string" }, dict = "Lighting_EffectNames", requireDict = true, optional = true },
				{ name = "propertyName", types = { "string" }, dict = "Lighting_EffectProperties-$|arg:-1#|", requireDict = true, optional = true },
				{ name = "tweenName", types = { "string" }, dict = "Lighting_TweenNames", optional = true },
			},
			Callback = setActivePreset,
		},
		{
			Aliases = { "set_value" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "effectName", types = { "string" }, dict = "Lighting_EffectNames", requireDict = true },
				{ name = "propertyName", types = { "string" }, dict = "Lighting_EffectProperties-$|arg:-1#|", requireDict = true },
				{ name = "value", types = { "string", "number", "boolean", "Color", "Vector3" } },
				{ name = "weight", types = { "number" } },
				{ name = "tweenName", types = { "string" }, dict = "Lighting_TweenNames", optional = true },
			},
			Callback = setValue,
		},

		-- Clear
		{
			Aliases = { "clear_value" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "effectName", types = { "string" }, dict = "Lighting_EffectNames", requireDict = true },
				{ name = "propertyName", types = { "string" }, dict = "Lighting_EffectProperties-$|arg:-1#|", requireDict = true },
				{ name = "weight", types = { "number" } },
				{ name = "tweenName", types = { "string" }, dict = "Lighting_TweenNames", optional = true },
			},
			Callback = clearValue,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Lighting_Server", {
		Aliases = { "s_lighting" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
