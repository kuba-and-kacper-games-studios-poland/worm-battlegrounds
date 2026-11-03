--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local state --- @type AdminPanel_CommandBar_GlobalState

local utils --- @type AdminPanel_CommandBar_Utils
local Permissions --- @type AdminPanel_Global_Permissions

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

--- @class AdminPanel_CommandBar_Global_Methods
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _shared AdminPanel_CommandBar_GlobalShared
function Module.Init(_shared)
	state = _shared.state

	utils = _shared.utils
	Permissions = _shared.Permissions
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Data

--[[
	Returns command data from the selected environment.
]]
--- @return { AdminPanel_CommandBar_CommandData_Global } | { [string]: AdminPanel_CommandBar_DictionaryEntry }
function Module.GetData(dataType: string, env: string)
	--[[ Commands ]]

	if dataType == "Commands" then
		if env == "Client" then
			return Module.GetCommands(I.Env.LocalPlayer)
		elseif env == "Server" then
			return I.Network.Invoke("_AdminPanel_CommandBar_GetCommands")
		end
	end

	--[[ Dictionaries ]]

	if dataType == "Dictionaries" then
		if env == "Client" then
			return Module.GetDictionaries(I.Env.LocalPlayer)
		elseif env == "Server" then
			return I.Network.Invoke("_AdminPanel_CommandBar_GetDictionaries")
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Commands

--[[
	Returns commands available for player permission level, none below `OPEN_PERMISSION_LEVEL`.
	The cleaned copy is built once per permission level and reused until a command is registered or unregistered.
]]
--- @return { AdminPanel_CommandBar_CommandData_Global }
function Module.GetCommands(player: Player)
	-- Check if player is valid | SERVER
	if I.Env.IsServer and not I.Player.Valid(player) then
		return {}
	end

	--[[ Getting Permission Level ]]

	local permissionLevel: number = Permissions.GetPermissionLevel(player)

	--[[ Checks ]]

	-- Check if the player may open the command bar
	if permissionLevel < _settings.OPEN_PERMISSION_LEVEL then
		return {}
	end

	-- Return the copy already built for this permission level
	if state.commandsCache[permissionLevel] then
		return state.commandsCache[permissionLevel]
	end

	--[[ Cloning Commands ]]

	local tableToSend = {} --- @type { AdminPanel_CommandBar_CommandData_Global }

	--- @param commandData AdminPanel_CommandBar_CommandData_Global
	for _, commandData in ipairs(state.commands) do
		--[[ Checks ]]

		-- Skip commands above the permission level before copying them
		if commandData.baseVariant.permissionLevel > permissionLevel then
			continue
		end

		--[[ Copying ]]

		--- @type AdminPanel_CommandBar_CommandData_Global
		local commandCopy = I.Table.DeepCopy(commandData)

		--[[ Cleaning ]]

		-- Clear Variants
		utils.RemoveVariantsByPermissionLevel(commandCopy.baseVariant, permissionLevel)

		-- General table clear
		commandCopy.callbacksUUIDs = nil
		commandCopy.uuid = nil

		-- Cleaning variants
		utils.CleanupVariants(commandCopy.baseVariant)

		--[[ Saving ]]

		table.insert(tableToSend, commandCopy)
	end

	--[[ Caching ]]

	state.commandsCache[permissionLevel] = tableToSend

	--[[ Returning ]]

	return tableToSend
end

--%%%%%%%%%%%%%%%%%%%% Get Dictionaries

--[[
	Returns dictionaries available for player permission level, none below `OPEN_PERMISSION_LEVEL`.
]]
--- @return { [string]: AdminPanel_CommandBar_DictionaryEntry }
function Module.GetDictionaries(player: Player)
	-- Check if player is valid | SERVER
	if I.Env.IsServer and not I.Player.Valid(player) then
		return {}
	end

	--[[ Getting Permission Level ]]

	local permissionLevel: number = Permissions.GetPermissionLevel(player)

	--[[ Checks ]]

	-- Check if the player may open the command bar
	if permissionLevel < _settings.OPEN_PERMISSION_LEVEL then
		return {}
	end

	--[[ Collecting ]]

	--- @type { [string]: AdminPanel_CommandBar_DictionaryEntry }
	local tableToSend = {}

	--- @param dictData AdminPanel_CommandBar_DictionaryEntry
	for dictName: string, dictData in pairs(state.argsDict) do
		-- Keep dictionaries at or below the player's level
		if permissionLevel >= dictData.permissionLevel then
			tableToSend[dictName] = dictData
		end
	end

	--[[ Returning ]]

	return tableToSend
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
