--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _module = script:FindFirstAncestor(_localName)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local state --- @type AdminPanel_CommandBar_GlobalState

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Validate Items

--[[
	Removes non-string items from given dictionary table in-place and warns about each removed item.
]]
local function validateItems(dictTable: { string }, dictName: string)
	for i: number = #dictTable, 1, -1 do -- Reverse loop to avoid index shifting
		if type(dictTable[i]) ~= "string" then
			warn(`[{_localName}::{script.Name}]: Dictionary [{dictName}] - Item ({dictTable[i]}: {type(dictTable[i])}) is of invalid type!`)
			table.remove(dictTable, i)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Apply Metadata

--[[
	Copies metadata fields onto the given dictionary entry as strings.
]]
local function applyMetadata(dictEntry: table, metadata: table?)
	if not metadata then
		return
	end

	for name: string, value: string in pairs(metadata) do
		dictEntry[`{name}`] = `{value}`
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

--- @class AdminPanel_CommandBar_Global_Dictionary
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _shared AdminPanel_CommandBar_GlobalShared
function Module.Init(_shared)
	state = _shared.state
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Dictionary Control

--%%%%%%%%%%%%%%%%%%%% Set Dictionary

--[[
	Verifies given `dictTable` and sets it under the `dictName`, setting it to `nil` removes it.
	A dictionary set without `permissionLevel` keeps the last level passed for that name, or 0 when it never had one.
]]
function Module.SetDictionary(dictName: string, dictTable: { string }?, permissionLevel: number?, metadata: table?)
	--[[ Data ]]

	local argsDict = state.argsDict --- @type { [string]: AdminPanel_CommandBar_DictionaryEntry }
	local dictLevels = state.dictLevels --- @type { [string]: number }
	local passedLevel: number? = tonumber(`{permissionLevel}`)

	--[[ Permission Level ]]

	-- Remembering a passed level, so later calls without one keep it
	if passedLevel then
		dictLevels[dictName] = math.clamp(passedLevel, _settings.PERMISSION_LEVEL_RANGE.Min, _settings.PERMISSION_LEVEL_RANGE.Max)
	end

	--[[ Setting Dictionary ]]

	if dictTable then
		-- Ensuring the table in unique
		dictTable = I.Table.DeepCopy(dictTable)

		--[[ Validating ]]

		validateItems(dictTable, dictName)

		--[[ Saving ]]

		argsDict[dictName] = dictTable
		argsDict[dictName].permissionLevel = dictLevels[dictName] or 0
	else
		-- Forgetting the level of a removed dictionary
		dictLevels[dictName] = nil

		-- Return if dictionary is already nil
		if not argsDict[dictName] then
			return
		end

		-- Removing dictionary
		argsDict[dictName] = nil
	end

	--[[ Sorting ]]

	-- Sorting a dictionary that still exists
	if argsDict[dictName] then
		table.sort(argsDict[dictName], function(a: string, b: string)
			return a < b
		end)
	end

	--[[ Adding Metadata ]]

	-- Adding metadata to a dictionary that still exists
	if argsDict[dictName] then
		applyMetadata(argsDict[dictName], metadata)
	end

	--[[ Updating Client ]]

	_module:SetAttribute(`AdminPanel_DictionariesVersion_{I.Env.Key}`, math.random(-10 ^ 6, 10 ^ 6))
end

--%%%%%%%%%%%%%%%%%%%% Update Dictionary

--[[
	Updates the `dictName` dictionary.
	Without `permissionLevel` it keeps the last level passed for that name, even after the dictionary was emptied and re-created.
]]
function Module.UpdateDictionary(dictName: string, addTable: { string }?, removeTable: { string }?, permissionLevel: number?, metadata: table?)
	--[[ Data ]]

	local argsDict = state.argsDict --- @type { [string]: AdminPanel_CommandBar_DictionaryEntry }
	local dictLevels = state.dictLevels --- @type { [string]: number }
	local passedLevel: number? = tonumber(`{permissionLevel}`)

	-- Ensuring tables are unique
	addTable = addTable and I.Table.DeepCopy(addTable)
	removeTable = removeTable and I.Table.DeepCopy(removeTable)

	--[[ Permission Level ]]

	-- Remembering a passed level, so later calls without one keep it
	if passedLevel then
		dictLevels[dictName] = math.clamp(passedLevel, _settings.PERMISSION_LEVEL_RANGE.Min, _settings.PERMISSION_LEVEL_RANGE.Max)
	end

	--[[ Creating Dictionary Table ]]

	if not argsDict[dictName] then
		-- Return if there's no items to add
		if not addTable then
			return
		end

		-- Creating dictionary for new entries
		argsDict[dictName] = {}
	end

	-- Applying the remembered level, 0 for a name that never had one
	argsDict[dictName].permissionLevel = dictLevels[dictName] or 0

	--[[ Validating ]]

	-- Validating the items to add
	if addTable then
		validateItems(addTable, dictName)
	end

	-- Validating the items to remove
	if removeTable then
		validateItems(removeTable, dictName)
	end

	--[[ Updating ]]

	-- Removing
	if removeTable then
		-- Remove suggestion from the dictionary
		for _index: number, toRemove: string in ipairs(removeTable) do
			local itemPos: number? = table.find(argsDict[dictName], toRemove)

			-- Skip items that are not in the dictionary
			if itemPos then
				table.remove(argsDict[dictName], itemPos)
			end
		end
	end

	-- Adding
	if addTable then
		-- Adding new suggestions to the dictionary
		for _index: number, toAdd: string in ipairs(addTable) do
			-- Skip items already in the dictionary
			if not table.find(argsDict[dictName], toAdd) then
				table.insert(argsDict[dictName], toAdd)
			end
		end
	end

	--[[ Sorting ]]

	table.sort(argsDict[dictName], function(a: string, b: string)
		return a < b
	end)

	--[[ Adding Metadata ]]

	-- Adding metadata to a dictionary that still exists
	if argsDict[dictName] then
		applyMetadata(argsDict[dictName], metadata)
	end

	--[[ Empty Table ]]

	-- Removing if table is empty
	if #argsDict[dictName] == 0 then
		argsDict[dictName] = nil
	end

	--[[ Updating Client ]]

	_module:SetAttribute(`AdminPanel_DictionariesVersion_{I.Env.Key}`, math.random(-10 ^ 6, 10 ^ 6))
end

--%%%%%%%%%%%%%%%%%%%% Remove Dictionaries Bound To Player

--[[
	**SERVER** |
	Removes all dictionaries that are bound to player.
]]
function Module.RemoveDictionariesBoundToPlayer(player: Player)
	local argsDict = state.argsDict

	--- @param dictData AdminPanel_CommandBar_DictionaryEntry
	for dictName, dictData in pairs(argsDict) do
		-- Removing if matching
		if `{dictData.BoundTo}` == `{player.UserId}` then
			Module.SetDictionary(dictName, nil)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
