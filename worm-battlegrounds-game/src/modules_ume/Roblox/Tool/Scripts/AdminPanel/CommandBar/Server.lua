--[[
    Created By:     Nari 
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Tool"

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

--- @class Tool_CommandBar_Server
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

	local function add(player: Player, toolModelName: string, scriptNames: { string }?, setUUID: string?)
		--[[ Checks ]]

		if setUUID and I.Tool.Get(player, setUUID) then
			return false, `$|cr$|{player.Name}#| already has a Tool with UUID: $|cr$|{setUUID}#|`
		end

		if not I.Tool._toolsModels[toolModelName] then
			return false, `Invalid Tool model: $|cr$|{toolModelName}#|`
		end

		if scriptNames and type(scriptNames) == "string" then
			scriptNames = { scriptNames }
		end

		if scriptNames then
			for _, scriptName: string in ipairs(scriptNames) do
				if type(scriptName) ~= "string" then
					return false, `One of the passed Script names is not a string: $|cr$|{scriptName}#|`
				end

				if not table.find(I.Tool._allScriptNames, scriptName) then
					return false, `Invalid Script name: $|cr$|{scriptName}#|`
				end
			end
		end

		--[[ Executing ]]

		-- Getting value
		local value: string = I.Tool.Add(player, toolModelName, scriptNames, setUUID)

		-- Returning
		if value then
			return true, `Added Tool $|cr$|{toolModelName}#| (UUID: $|cr$|{value}#|) for $|cr$|{player.Name}#|`
		else
			if setUUID then
				return false, `Failed to add Tool $|cr$|{toolModelName}#| (UUID: $|cr$|{setUUID}#|) for $|cr$|{player.Name}#|`
			else
				return false, `Failed to add Tool $|cr$|{toolModelName}#| for $|cr$|{player.Name}#|`
			end
		end
	end

	local function remove(player: Player, toolUUID: string)
		--[[ Checks ]]

		if not I.Tool.Get(player, toolUUID) then
			return false, `$|cr$|{player.Name}#| does not have a Tool with UUID: $|cr$|{toolUUID}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Tool.Remove(player, toolUUID)

		-- Returning
		if value then
			return true, `Removed Tool (UUID: $|cr$|{toolUUID}#|) for $|cr$|{player.Name}#|`
		else
			return false, `Failed to remove Tool (UUID: $|cr$|{toolUUID}#|) for $|cr$|{player.Name}#|`
		end
	end

	local function removeAll(player: Player)
		-- Getting value
		local success: boolean, value: { string } = I.Tool.RemoveAll(player)

		-- Returning
		if success then
			return true, {
				`Removing all Tools for $|cr$|{player.Name}#|..`,
				`Removed $|cr$|{#value}#| Tools:`,
				value,
				"_multilineOutput",
			}
		else
			return false, `Failed to remove all Tools for $|cr$|{player.Name}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Script Control Functions

	local function setScripts(player: Player, toolUUID: string, scriptNames: { string }?)
		--[[ Checks ]]

		if not I.Tool.Get(player, toolUUID) then
			return false, `$|cr$|{player.Name}#| does not have a Tool with UUID: $|cr$|{toolUUID}#|`
		end

		if scriptNames and type(scriptNames) == "string" then
			scriptNames = { scriptNames }
		end

		if scriptNames then
			for _, scriptName: string in ipairs(scriptNames) do
				if type(scriptName) ~= "string" then
					return false, `One of the passed Script names is not a string: $|cr$|{scriptName}#|`
				end

				if not table.find(I.Tool._allScriptNames, scriptName) then
					return false, `Invalid Script name: $|cr$|{scriptName}#|`
				end
			end
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Tool.SetScripts(player, toolUUID, scriptNames)

		-- Returning
		if value then
			return true, { `Set $|cr$|{player.Name}#|'s Tool (UUID: $|cr$|{toolUUID}#|) scripts to:`, `[$|cr$|{table.concat(scriptNames, ", ")}#|]`, "_multilineOutput" }
		else
			return false, `Failed to set $|cr$|{player.Name}#|'s Tool (UUID: $|cr$|{toolUUID}#|) scripts`
		end
	end

	local function addScripts(player: Player, toolUUID: string, scriptNames: { string }?)
		--[[ Checks ]]

		if not I.Tool.Get(player, toolUUID) then
			return false, `$|cr$|{player.Name}#| does not have a Tool with UUID: $|cr$|{toolUUID}#|`
		end

		if scriptNames and type(scriptNames) == "string" then
			scriptNames = { scriptNames }
		end

		if scriptNames then
			for _, scriptName: string in ipairs(scriptNames) do
				if type(scriptName) ~= "string" then
					return false, `One of the passed Script names is not a string: $|cr$|{scriptName}#|`
				end

				if not table.find(I.Tool._allScriptNames, scriptName) then
					return false, `Invalid Script name: $|cr$|{scriptName}#|`
				end
			end
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Tool.AddScripts(player, toolUUID, scriptNames)

		-- Returning
		if value then
			return true, { `Added scripts to $|cr$|{player.Name}#|'s Tool (UUID: $|cr$|{toolUUID}#|):`, `[$|cr$|{table.concat(scriptNames, ", ")}#|]`, "_multilineOutput" }
		else
			return false, `Failed to add scripts to $|cr$|{player.Name}#|'s Tool (UUID: $|cr$|{toolUUID}#|)`
		end
	end

	local function removeScripts(player: Player, toolUUID: string, scriptNames: { string }?)
		--[[ Checks ]]

		if not I.Tool.Get(player, toolUUID) then
			return false, `$|cr$|{player.Name}#| does not have a Tool with UUID: $|cr$|{toolUUID}#|`
		end

		--[[ Updating Variables ]]

		-- Ensuring table
		if scriptNames and type(scriptNames) == "string" then
			scriptNames = { scriptNames }
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Tool.RemoveScripts(player, toolUUID, scriptNames)

		-- Returning
		if value then
			return true, { `Removed scripts from $|cr$|{player.Name}#|'s Tool (UUID: $|cr$|{toolUUID}#|)`, `[$|cr$|{table.concat(scriptNames, ", ")}#|]`, "_multilineOutput" }
		else
			return false, `Failed to remove scripts from $|cr$|{player.Name}#|'s Tool (UUID: $|cr$|{toolUUID}#|)`
		end
	end

	local function removeAllScripts(player: Player, toolUUID: string)
		--[[ Checks ]]

		if not I.Tool.Get(player, toolUUID) then
			return false, `$|cr$|{player.Name}#| does not have a Tool with UUID: $|cr$|{toolUUID}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Tool.RemoveAllScripts(player, toolUUID)

		-- Returning
		if value then
			return true, `Removed all scripts from $|cr$|{player.Name}#|'s Tool (UUID: $|cr$|{toolUUID}#|)`
		else
			return false, `Failed to remove all scripts from $|cr$|{player.Name}#|'s Tool (UUID: $|cr$|{toolUUID}#|)`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Methods Functions

	local function getEquipped(player: Player)
		-- Getting value
		local value: Tool = I.Tool.GetEquipped(player)
		local toolUUID: string = value and value:GetAttribute("Tool_ServerUUID")

		-- Returning
		if value then
			if toolUUID then
				return true, `$|cr$|{player.Name}#|'s equipped Tool UUID is: $|cr$|{toolUUID}#|`
			else
				return false, `Tool equipped by $|cr$|{player.Name}#| is invalid`
			end
		else
			return true, `$|cr$|{player.Name}#| has no equipped Tool`
		end
	end

	local function getScripts(player: Player, toolUUID: string)
		-- Getting value
		local value: { string } = I.Tool.GetScripts(player, toolUUID)

		-- Returning
		if value then
			return true, { `Getting scripts for $|cr$|{player.Name}#|'s $|cr$|{toolUUID}#| Tool...`, value, "_multilineOutput" }
		else
			return false, `Failed to get scripts for $|cr$|{player.Name}#|'s $|cr$|{toolUUID}#| Tool`
		end
	end

	local function getAllUUIDs(player: Player)
		-- Getting value
		local value: { string } = I.Tool.GetAll(player)

		-- Returning
		if value then
			return true, { `Getting $|cr$|{player.Name}#|'s ToolUUIDs`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s ToolUUIDs`
		end
	end

	local function getAllScripts(player: Player)
		-- Getting value
		local value: table = I.Tool.GetAllScripts(player)

		-- Returning
		if value then
			return true, { `Getting $|cr$|{player.Name}#|'s Tool scripts`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s Tool scripts`
		end
	end

	local function has(player: Player, toolUUID: string)
		-- Getting value
		local value: boolean = I.Tool.Has(player, toolUUID)

		-- Returning
		if value then
			return true, `$|cr$|{player.Name}#| has Tool $|cr$|{toolUUID}#|`
		else
			return true, `$|cr$|{player.Name}#| does not have Tool $|cr$|{toolUUID}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Control ]]

		{
			Aliases = { "add" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "toolModel", types = { "string" }, dict = "Tool_ModelNames", requireDict = true },
				{ name = "scriptNames", types = { "string", "table" }, dict = "Tool_ScriptNames", requireDict = true, optional = true },
				{ name = "setUUID", types = { "string" }, optional = true },
			},
			Callback = add,
		},
		{
			Aliases = { "remove" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "toolUUID", types = { "string" }, dict = "Tool_UUIDs-$|arg:-1#|", requireDict = true },
			},
			Callback = remove,
		},
		{
			Aliases = { "remove_all" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = removeAll,
		},

		--[[ Scripts Control ]]

		{
			Aliases = { "scripts" },

			Variants = {
				{
					Aliases = { "set" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "toolUUID", types = { "string" }, dict = "Tool_UUIDs-$|arg:-1#|", requireDict = true },
						{ name = "scriptNames", types = { "string", "table" }, dict = "Tool_ScriptNames", requireDict = true },
					},
					Callback = setScripts,
				},
				{
					Aliases = { "add" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "toolUUID", types = { "string" }, dict = "Tool_UUIDs-$|arg:-1#|", requireDict = true },
						{ name = "scriptNames", types = { "string", "table" }, dict = "Tool_ScriptNames", dictNegate = `Tool_ToolScripts-$|arg:-2#|-$|arg:-1#|`, requireDict = true },
					},
					Callback = addScripts,
				},
				{
					Aliases = { "remove" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "toolUUID", types = { "string" }, dict = "Tool_UUIDs-$|arg:-1#|", requireDict = true },
						{ name = "scriptNames", types = { "string", "table" }, dict = "Tool_ToolScripts-$|arg:-2#|-$|arg:-1#|", requireDict = true },
					},
					Callback = removeScripts,
				},
				{
					Aliases = { "remove_all" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "toolUUID", types = { "string" }, dict = "Tool_UUIDs-$|arg:-1#|", requireDict = true },
					},
					Callback = removeAllScripts,
				},
			},
		},

		--[[ Methods ]]

		{
			Aliases = { "get" },

			Variants = {
				{
					Aliases = { "equipped" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = getEquipped,
				},
				{
					Aliases = { "scripts" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "toolUUID", types = { "string" }, dict = "Tool_UUIDs-$|arg:-1#|", requireDict = true },
					},
					Callback = getScripts,
				},

				{
					Aliases = { "all_uuids" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = getAllUUIDs,
				},
				{
					Aliases = { "all_scripts" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
					},
					Callback = getAllScripts,
				},
			},
		},
		{
			Aliases = { "has" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "toolUUID", types = { "string" }, dict = "Tool_UUIDs-$|arg:-1#|", requireDict = true },
			},
			Callback = has,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Tool_Server", {
		Aliases = { "tool" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%% Register Command Dictionaries

--[[
	Registers dictionaries used by module commands.
]]
function Module._registerCommandDictionaries()
	--[[ Getting Values ]]

	local allModelNames = {} --- @type { string }

	-- Models names
	for modelName: string, _toolModel: Tool in pairs(I.Tool._toolsModels) do
		table.insert(allModelNames, modelName)
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Tool_ScriptNames`, I.Tool._allScriptNames, 255)
	I.AdminPanel_CommandBar.SetDictionary(`Tool_ModelNames`, allModelNames, 255)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
