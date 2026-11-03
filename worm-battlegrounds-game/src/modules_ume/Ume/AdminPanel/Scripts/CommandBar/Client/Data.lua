--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _module = script:FindFirstAncestor(_localName)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local shared --- @type AdminPanel_CommandBar_ClientShared
local state --- @type AdminPanel_CommandBar_ClientState

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

--- @class AdminPanel_CommandBar_Client_Data
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _shared AdminPanel_CommandBar_ClientShared
function Module.Init(_shared)
	shared = _shared
	state = _shared.state
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data Control

--%%%%%%%%%%%%%%%%%%%% Update Commands Data

--[[
	Updates local commands data.
	When no data comes back (the server dropped the request), the current copy stays and the next refresh asks again.
]]
function Module.UpdateCommandsData(env: string)
	--[[ Data ]]

	local commands = state.commands --- @type { AdminPanel_CommandBar_CommandData_Global }
	local aliases = state.aliases --- @type { [string]: AdminPanel_CommandBar_CommandData_Global }

	--[[ Getting Version ]]

	local versionKey: string = `Commands-{env}`
	local previousVersion: number? = state.dataVersions[versionKey]
	local newVersion: number? = _module:GetAttribute(`AdminPanel_CommandsVersion_{env}`)

	-- Skip when the local copy is up to date
	if previousVersion == newVersion then
		return
	end

	-- Updating
	state.dataVersions[versionKey] = newVersion

	--[[ Fetching ]]

	local newData = I.AdminPanel_CommandBar.GetData("Commands", env) --- @type { AdminPanel_CommandBar_CommandData_Global }?
	local isServerData: boolean = env == "Server"

	-- Keep the current copy and ask again on the next refresh when no data came back
	if not newData then
		state.dataVersions[versionKey] = previousVersion
		return
	end

	--%%%%%%%%%%%%%%%%%%%% Replacing Env Snapshot

	for i: number = #commands, 1, -1 do -- Reverse loop to avoid index shifting
		--- @type AdminPanel_CommandBar_CommandData_Global
		local commandData = commands[i]

		-- Skip commands from the other side
		if commandData._isServerData ~= isServerData then
			continue
		end

		-- Removing aliases
		for _index: number, alias: string in ipairs(commandData.baseVariant.aliases) do
			aliases[alias] = nil
		end

		-- Removing command
		table.remove(commands, i)
	end

	--%%%%%%%%%%%%%%%%%%%% Adding New

	--- @param commandData AdminPanel_CommandBar_CommandData_Global
	for _index: number, commandData in ipairs(newData) do
		commandData._isServerData = isServerData
		table.insert(commands, commandData)
	end

	--%%%%%%%%%%%%%%%%%%%% Storing Aliases

	--- @param commandData AdminPanel_CommandBar_CommandData_Global
	for _index: number, commandData in ipairs(commands) do
		for _aliasIndex: number, alias: string in ipairs(commandData.baseVariant.aliases) do
			-- Check if exists
			if aliases[alias] and aliases[alias] ~= commandData then
				warn(`[{_localName}::{script.Name}]: Alias ({alias}) is duplicated!`)
				continue
			end

			-- Saving
			aliases[alias] = commandData
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Updating

	shared.Input.ProcessInput()
end

--%%%%%%%%%%%%%%%%%%%% Update Dictionaries Data

--[[
	Updates local dictionaries data and stores a lowercase copy of each one for suggestions.
	When no data comes back (the server dropped the request), the current copy stays and the next refresh asks again.
]]
function Module.UpdateDictionariesData(env: string)
	--[[ Data ]]

	local dictionaries = state.dictionaries --- @type { [string]: AdminPanel_CommandBar_DictionaryEntry }

	--[[ Getting Version ]]

	local versionKey: string = `Dictionaries-{env}`
	local previousVersion: number? = state.dataVersions[versionKey]
	local newVersion: number? = _module:GetAttribute(`AdminPanel_DictionariesVersion_{env}`)

	-- Skip when the local copy is up to date
	if previousVersion == newVersion then
		return
	end

	-- Updating
	state.dataVersions[versionKey] = newVersion

	--[[ Fetching ]]

	local newData = I.AdminPanel_CommandBar.GetData("Dictionaries", env) --- @type { [string]: AdminPanel_CommandBar_DictionaryEntry }?
	local isServerData: boolean = env == "Server"

	-- Keep the current copy and ask again on the next refresh when no data came back
	if not newData then
		state.dataVersions[versionKey] = previousVersion
		return
	end

	--%%%%%%%%%%%%%%%%%%%% Removing Missing

	--- @param dictData AdminPanel_CommandBar_DictionaryEntry
	for dictName: string, dictData in pairs(dictionaries) do
		-- Skip if protected
		if dictData.Protected then
			continue
		end

		--[[ Updating ]]

		-- Remove if missing
		if dictData._isServerData == isServerData and not newData[dictName] then
			dictionaries[dictName] = nil
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Updating / Adding New

	--- @param dictData AdminPanel_CommandBar_DictionaryEntry
	for dictName: string, dictData in pairs(newData) do
		--[[ Checks ]]

		-- Skip if exists and is protected
		if dictionaries[dictName] and dictionaries[dictName].Protected then
			continue
		end

		--[[ Lowering ]]

		local lowered = {} --- @type { string }

		for index: number, entry: string in ipairs(dictData) do
			lowered[index] = entry:lower()
		end

		--[[ Updating ]]

		dictData._isServerData = isServerData
		dictData._lowered = lowered
		dictionaries[dictName] = dictData
	end

	--%%%%%%%%%%%%%%%%%%%% Updating

	shared.Input.ProcessInput()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
