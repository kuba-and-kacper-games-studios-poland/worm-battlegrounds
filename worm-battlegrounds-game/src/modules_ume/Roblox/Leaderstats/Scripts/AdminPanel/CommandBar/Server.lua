--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Leaderstats"

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

--- @class Leaderstats_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
	Module._registerCommandDictionaries()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Control Functions

	local function addValue(player: Player, valueName: string, baseValue: string | number, valueClass: string)
		-- Getting value
		local value: boolean = I.Leaderstats.AddValue(player, valueName, baseValue, valueClass)

		-- Formatting value
		local formattedBaseValue: string = I.Format.Text(baseValue)

		-- Returning
		if value then
			return true, `Added $|cr$|{valueClass}#| $|cr$|{valueName}#| with base value $|cr$|{formattedBaseValue}#| for $|cr$|{player.Name}#|`
		else
			return false, `Failed to add $|cr$|{valueClass}#| $|cr$|{valueName}#| with base value $|cr$|{formattedBaseValue}#| for $|cr$|{player.Name}#|`
		end
	end

	local function removeValue(player: Player, valueName: string)
		-- Getting value
		local value: boolean = I.Leaderstats.RemoveValue(player, valueName)

		-- Returning
		if value then
			return true, `Removed $|cr$|{player.Name}#|'s $|cr$|{valueName}#| value`
		else
			return false, `Failed to remove $|cr$|{player.Name}#|'s $|cr$|{valueName}#| value`
		end
	end

	local function setValue(player: Player, valueName: string, valueToSet: string | number)
		-- Getting value
		local value: boolean = I.Leaderstats.SetValue(player, valueName, valueToSet)
		local formattedValue: string = I.Format.Text(valueToSet)

		-- Returning
		if value then
			return true, `Set $|cr$|{player.Name}#|'s $|cr$|{valueName}#| value to: $|cr$|{formattedValue}#|`
		else
			return false, `Failed to set $|cr$|{player.Name}#|'s $|cr$|{valueName}#| value`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {
		--[[ Control ]]

		{
			Aliases = { "add_value" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "valueName", types = { "string" }, dict = "Leaderstats_ValueNames", dictNegate = "Leaderstats_ValueNames-$|arg:-1#|", requireDict = false },
				{ name = "baseValue", types = { "string", "number", "BigNum" } },
				{ name = "valueClass", types = { "string" }, dict = "Leaderstats_ValueClasses", requireDict = true },
			},
			Callback = addValue,
		},
		{
			Aliases = { "remove_value" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "valueName", types = { "string" }, dict = "Leaderstats_ValueNames-$|arg:-1#|", requireDict = true },
			},
			Callback = removeValue,
		},
		{
			Aliases = { "set_value" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "valueName", types = { "string" }, dict = "Leaderstats_ValueNames-$|arg:-1#|", requireDict = true },
				{ name = "value", types = { "string", "number", "BigNum" } },
			},
			Callback = setValue,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Leaderstats_Server", {
		Aliases = { "leaderstats" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%% Register Command Dictionaries

--[[
	Registers dictionaries used by module commands.
]]
function Module._registerCommandDictionaries()
	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Leaderstats_ValueClasses`, {
		"StringValue",
		"NumberValue",
		"IntValue",
	}, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
