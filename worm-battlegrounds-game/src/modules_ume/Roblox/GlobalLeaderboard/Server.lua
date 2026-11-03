--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "GlobalLeaderboard"

--- @type GlobalLeaderboard_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local DataStoreService = I.S.DataStoreService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--%%%%%%%%%%%%%%%%%%%% Registered

--[[
	Table containing all created `OrderedDataStores`.
]]
--- @type { [string]: GlobalLeaderboard_OrderedDataStore }
local createdOrderedDataStores = {}

--[[
	Table containing update functions for all created `OrderedDataStores`.
]]
--- @type { [string]: GlobalLeaderboard_UpdateGroup }
local updateGroups = {}

--[[
	Table with all registered data store functions, to avoid duplicates.
]]
--- @type { string }
local allRegisteredFunctionsStoresNames = {}

--%%%%%%%%%%%%%%%%%%%% Cache

--[[
	Table containing cached `DataStorePages` stored by their Ids.
]]
--- @type { [string]: GlobalLeaderboard_DataStorePages }
local cachedPages = {}

--[[
	Table containing cached top pages of `DataStorePages` stored by their Ids.
]]
--- @type { [string]: { GlobalLeaderboard_PageData } }
local cachedItems = {}

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

	I.DoEvery.Get(_settings.UPDATE_DELAY):Connect(Module._runUpdateFunctions)
	I.OnStarted(I.Priority.Late, function()
		task.spawn(Module._runUpdateFunctions)
	end)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("GlobalLeaderboard_Updated", { "string" })

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.GlobalLeaderboard = {

		--[[ Control ]]

		Get = Module.Get,
		RegisterUpdateFunction = Module.RegisterUpdateFunction,
		ClearUpdateFunction = Module.ClearUpdateFunction,

		--[[ Methods ]]

		GetPages = Module.GetPages,
		GetItems = Module.GetItems,
		GetCachedItems = Module.GetCachedItems,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Run Update Functions

--[[
	Starts the next update function of every update group, each group in its own thread.
	Skips a group whose previous run is still going.
]]
function Module._runUpdateFunctions()
	--[[ Running ]]

	--- @param updateGroupData GlobalLeaderboard_UpdateGroup
	for _updateGroupName: string, updateGroupData in pairs(updateGroups) do
		-- Skip a group whose previous run is still going
		if updateGroupData.IsRunning then
			continue
		end

		task.spawn(Module._runUpdateGroup, updateGroupData)
	end
end

--%%%%%%%%%%%%%%%%%%%% Run Update Group

--[[
	Runs the next update function of one update group, then reads and caches its top page when `CacheOnUpdate` is set.
	Postpones the turn while the DataStore budget is low and skips the write while the server is empty.
]]
--- @param updateGroupData GlobalLeaderboard_UpdateGroup
function Module._runUpdateGroup(updateGroupData)
	--[[ Finding ]]

	local nextIndex: number = updateGroupData.CurrentUpdateIndex + 1

	-- Wrap around after the last function
	if nextIndex > updateGroupData.TotalUpdateFunctions then
		nextIndex = 1
	end

	local index: number = 0
	local storeFullId: string = ""
	local functionTable --- @type GlobalLeaderboard_UpdateGroup_FunctionTable?

	--- @param loopFunctionTable GlobalLeaderboard_UpdateGroup_FunctionTable
	for loopStoreFullId: string, loopFunctionTable in pairs(updateGroupData.FunctionTables) do
		index += 1

		-- Take the function at the next index
		if index == nextIndex then
			storeFullId = loopStoreFullId
			functionTable = loopFunctionTable
			break
		end
	end

	--[[ Checks ]]

	-- Check if the group has a function at that index
	if not functionTable then
		return
	end

	local playerCount: number = #I.S.Players:GetPlayers()

	-- Postpone this turn while the DataStore budget is low
	if not Module._hasBudget(functionTable, playerCount) then
		warn(`[{_localName}::{script.Name}]: DataStore budget is low - postponing update for ({storeFullId}) OrderedDataStore.`)
		return
	end

	--[[ Update Function ]]

	updateGroupData.IsRunning = true
	updateGroupData.CurrentUpdateIndex = nextIndex

	-- Skip the write while nobody is in the server
	if playerCount > 0 then
		local success: boolean
		local result: any | string?
		success, result = pcall(functionTable.UpdateFunction)
		if not success then
			warn(`[{_localName}::{script.Name}]: Update function failed for ({storeFullId}) OrderedDataStore! - {result}`)
			updateGroupData.IsRunning = false
			return
		end
	end

	--[[ Caching ]]

	if functionTable.CacheOnUpdate then
		local pages = Module.GetPages(functionTable.StoreName, functionTable.Scope, functionTable.IsAscending, functionTable.PageSize, true, false, false) --- @type GlobalLeaderboard_DataStorePages?
		local items = if pages then Module.GetItems(functionTable.StoreName, functionTable.Scope, functionTable.IsAscending, functionTable.PageSize, true, true, false, false) else nil --- @type { GlobalLeaderboard_PageData }?

		-- Publish when the top page was cached
		if pages and items then
			I.Topic.Publish("GlobalLeaderboard_Updated", storeFullId)
		end
	end

	--[[ Finishing ]]

	updateGroupData.IsRunning = false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Create

--[[
    **SERVER** |
    Creates and returns a global `OrderedDataStore`.
]]
--- @return GlobalLeaderboard_OrderedDataStore | nil
function Module.Get(storeName: string, scope: string?)
	--[[ Getting Full Name ]]

	local storeFullId: string = if scope then `{storeName}::{scope}` else storeName

	--[[ Getting Mock OrderedDataStore ]]

	if not I.DataStoreAccess then
		if not createdOrderedDataStores[storeFullId] then
			createdOrderedDataStores[storeFullId] = I.MockDataStores.OrderedDataStore.new()
		end

		return createdOrderedDataStores[storeFullId]
	end

	--[[ Getting OrderedDataStore ]]

	if not createdOrderedDataStores[storeFullId] then
		-- Getting formatted name
		local currentStoreName: string = `{_settings.LEADERBOARDS_PREFIX}_{storeName}_{I.Config.Map.LeaderboardStoreName}`

		-- Using pcall to catch any errors
		local success: boolean, result = pcall(function()
			return DataStoreService:GetOrderedDataStore(currentStoreName, scope)
		end)

		--[[ Saving ]]

		if success then
			--- @type OrderedDataStore
			local dataStore = result

			createdOrderedDataStores[storeFullId] = dataStore
		else
			warn(`[{_localName}::{script.Name}]: Failed while getting ({storeFullId}) OrderedDataStore! - {result}`)
		end
	end

	--[[ Returning ]]

	return createdOrderedDataStores[storeFullId]
end

--%%%%%%%%%%%%%%%%%%%% Register Update Function

--[[
	**SERVER** |
	Registers `UpdateFunction` for `storeName` under `updateGroup`.
]]
--- @param functionTable GlobalLeaderboard_RegisterUpdateFunction_Table
function Module.RegisterUpdateFunction(storeName: string, scope: string?, updateGroup: string, functionTable)
	--[[ General Checks ]]

	do
		if not storeName or type(storeName) ~= "string" then
			warn(`[{_localName}::{script.Name}]: Invalid (storeName) type. Expected (string), got ({storeName}: {typeof(storeName)})!`)
			return
		end

		-- Invalid scope
		if scope and type(scope) ~= "string" then
			warn(`[{_localName}::{script.Name}]: Invalid (scope) type. Expected (string), got ({scope}: {typeof(scope)})!`)
			return
		end

		-- Invalid updateGroup
		if not updateGroup or type(updateGroup) ~= "string" then
			warn(`[{_localName}::{script.Name}]: Invalid (updateGroup) type. Expected (string), got ({updateGroup}: {typeof(updateGroup)})!`)
			return
		end

		-- Invalid functionTable
		if not functionTable or type(functionTable) ~= "table" then
			warn(`[{_localName}::{script.Name}]: Invalid (functionTable) type. Expected (table), got ({functionTable}: {typeof(functionTable)})!`)
			return
		end
	end

	--[[ Function Table Checks ]]

	do
		--[[ General Checks ]]

		-- Missing UpdateFunction
		if not functionTable["UpdateFunction"] or type(functionTable["UpdateFunction"]) ~= "function" then
			warn(`[{_localName}::{script.Name}]: Invalid (UpdateFunction) type. Expected (function), got ({functionTable["UpdateFunction"]}: {typeof(functionTable["UpdateFunction"])})!`)
			return
		end

		-- Invalid isAscending
		if functionTable["IsAscending"] == nil or type(functionTable["IsAscending"]) ~= "boolean" then
			warn(`[{_localName}::{script.Name}]: Invalid (isAscending) type. Expected (boolean), got ({functionTable["IsAscending"]}: {typeof(functionTable["IsAscending"])})!`)
			return
		end

		--[[ PageSize Checks ]]

		if not functionTable["PageSize"] or type(functionTable["PageSize"]) ~= "number" then
			warn(`[{_localName}::{script.Name}]: Invalid (pageSize) type. Expected (number), got ({functionTable["PageSize"]}: {typeof(functionTable["PageSize"])})!`)
			return
		end
		if functionTable["PageSize"] > 100 then
			warn(`[{_localName}::{script.Name}]: (pageSize) cannot be greater than (100)!`)
			return
		end
		if functionTable["PageSize"] <= 0 then
			warn(`[{_localName}::{script.Name}]: (pageSize) cannot be less than (0)!`)
			return
		end
	end

	--[[ Getting Full Name ]]

	local storeFullId: string = if scope then `{storeName}::{scope}` else storeName

	--[[ Getting Data Store ]]

	-- Making sure the OrderedDataStore exists
	--- @type GlobalLeaderboard_OrderedDataStore | nil
	local dataStore = Module.Get(storeName, scope)
	if not dataStore then
		return
	end

	--[[ Creating Update Group ]]

	if not updateGroups[updateGroup] then
		updateGroups[updateGroup] = {
			FunctionTables = {},
			CurrentUpdateIndex = 0,
			TotalUpdateFunctions = 0,
			IsRunning = false,
		}
	end

	--[[ Storing Update Function ]]

	if not updateGroups[updateGroup].FunctionTables[storeFullId] and not table.find(allRegisteredFunctionsStoresNames, storeFullId) then
		-- Saving update function
		updateGroups[updateGroup].FunctionTables[storeFullId] = {
			--[[ Update Function ]]

			UpdateFunction = functionTable.UpdateFunction,
			CacheOnUpdate = functionTable.CacheOnUpdate == true,

			--[[ Info ]]

			StoreName = storeName,
			Scope = scope,
			IsAscending = functionTable.IsAscending == true,
			PageSize = tonumber(functionTable.PageSize) or 50,
		}
		updateGroups[updateGroup].TotalUpdateFunctions += 1

		-- Saving store name
		table.insert(allRegisteredFunctionsStoresNames, storeFullId)
	else
		warn(`[{_localName}::{script.Name}]: Update function for ({storeFullId}) OrderedDataStore is already set!`)
	end
end

--%%%%%%%%%%%%%%%%%%%% Clear Update Function

--[[
	**SERVER** |
	Clears registered `UpdateFunction` from `updateGroup`.
]]
function Module.ClearUpdateFunction(storeName: string, scope: string?, updateGroup: string)
	--[[ Getting Full Name ]]

	local storeFullId: string = if scope then `{storeName}::{scope}` else storeName

	--[[ Checks ]]

	do
		-- Invalid updateGroup
		if not updateGroup or not updateGroups[updateGroup] then
			warn(`[{_localName}::{script.Name}]: ({updateGroup}) is not a valid (updateGroup)!`)
			return
		end

		-- Update function not registered
		if not updateGroups[updateGroup].FunctionTables[storeFullId] then
			warn(`[{_localName}::{script.Name}]: OrderedDataStore ({storeFullId}) is not registered under the ({updateGroup}) update group!`)
			return
		end
	end

	--[[ Clearing ]]

	-- Clearing update function
	updateGroups[updateGroup].FunctionTables[storeFullId] = nil
	updateGroups[updateGroup].TotalUpdateFunctions -= 1

	-- Clearing store name
	local tablePos: number | nil = table.find(allRegisteredFunctionsStoresNames, storeFullId)
	if tablePos then
		table.remove(allRegisteredFunctionsStoresNames, tablePos)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Pages

--[[
	**SERVER** |
	Returns `DataStorePages` Instance.
]]
--- @return GlobalLeaderboard_DataStorePages | nil
function Module.GetPages(storeName: string, scope: string?, isAscending: boolean, pageSize: number, cache: boolean?, getCached: boolean?, respectCached: boolean?)
	--[[ Checks ]]

	do
		--[[ General Checks ]]

		-- Invalid storeName
		if not storeName or type(storeName) ~= "string" then
			warn(`[{_localName}::{script.Name}]: Invalid (storeName) type. Expected (string), got ({storeName}: {typeof(storeName)})!`)
			return nil
		end

		-- Invalid scope
		if scope and type(scope) ~= "string" then
			warn(`[{_localName}::{script.Name}]: Invalid (scope) type. Expected (string), got ({scope}: {typeof(scope)})!`)
			return nil
		end

		-- Invalid isAscending
		if isAscending == nil or type(isAscending) ~= "boolean" then
			warn(`[{_localName}::{script.Name}]: Invalid (isAscending) type. Expected (boolean), got ({isAscending}: {typeof(isAscending)})!`)
			return nil
		end

		--[[ PageSize Checks ]]

		if not pageSize or type(pageSize) ~= "number" then
			warn(`[{_localName}::{script.Name}]: Invalid (pageSize) type. Expected (number), got ({pageSize}: {typeof(pageSize)})!`)
			return nil
		end
		if pageSize > 100 then
			warn(`[{_localName}::{script.Name}]: (pageSize) cannot be greater than (100)!`)
			return nil
		end
		if pageSize <= 0 then
			warn(`[{_localName}::{script.Name}]: (pageSize) cannot be less than (0)!`)
			return nil
		end
	end

	--[[ Getting Full Name ]]

	local storeFullId: string = if scope then `{storeName}::{scope}` else storeName
	local storeCacheId: string = `{storeFullId}-{isAscending}-{pageSize}`

	--[[ Returning Cached ]]

	if getCached then
		if cachedPages[storeCacheId] then
			return cachedPages[storeCacheId]
		end

		if respectCached then
			return nil
		end
	end

	--[[ Data Store ]]

	--- @type GlobalLeaderboard_OrderedDataStore | nil
	local dataStore = Module.Get(storeName, scope)
	if not dataStore then
		return nil
	end

	--[[ Getting Pages ]]

	-- Using pcall to catch any errors
	local success: boolean, result = pcall(function()
		return dataStore:GetSortedAsync(isAscending, pageSize, _settings.MIN_PAGE_VALUE, _settings.MAX_PAGE_VALUE)
	end)

	--[[ Returning ]]

	if success and result then
		--- @type GlobalLeaderboard_DataStorePages
		local pages = result

		-- Caching result
		if cache then
			cachedPages[storeCacheId] = pages
		end

		-- Returning
		return pages
	else
		warn(`[{_localName}::{script.Name}]: Failed while getting pages for ({storeFullId}) OrderedDataStore! - {result}`)
		return nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Items

--[[
	**SERVER** |
	Returns top page of the `DataStorePages` Instance.
]]
--- @return { GlobalLeaderboard_PageData } | nil
function Module.GetItems(storeName: string, scope: string?, isAscending: boolean, pageSize: number, fromCachedPages: boolean?, cache: boolean?, getCached: boolean?, respectCached: boolean?)
	--[[ Checks ]]

	do
		--[[ General Checks ]]

		-- Invalid storeName
		if not storeName or type(storeName) ~= "string" then
			warn(`[{_localName}::{script.Name}]: Invalid (storeName) type. Expected (string), got ({storeName}: {typeof(storeName)})!`)
			return nil
		end

		-- Invalid scope
		if scope and type(scope) ~= "string" then
			warn(`[{_localName}::{script.Name}]: Invalid (scope) type. Expected (string), got ({scope}: {typeof(scope)})!`)
			return nil
		end

		-- Invalid isAscending
		if isAscending == nil or type(isAscending) ~= "boolean" then
			warn(`[{_localName}::{script.Name}]: Invalid (isAscending) type. Expected (boolean), got ({isAscending}: {typeof(isAscending)})!`)
			return nil
		end

		--[[ PageSize Checks ]]

		if not pageSize or type(pageSize) ~= "number" then
			warn(`[{_localName}::{script.Name}]: Invalid (pageSize) type. Expected (number), got ({pageSize}: {typeof(pageSize)})!`)
			return nil
		end
		if pageSize > 100 then
			warn(`[{_localName}::{script.Name}]: (pageSize) cannot be greater than (100)!`)
			return nil
		end
		if pageSize <= 0 then
			warn(`[{_localName}::{script.Name}]: (pageSize) cannot be less than (0)!`)
			return nil
		end
	end

	--[[ Getting Full Name ]]

	local storeFullId: string = if scope then `{storeName}::{scope}` else storeName
	local storeCacheId: string = `{storeFullId}-{isAscending}-{pageSize}`

	--[[ Returning Cached ]]

	if getCached then
		-- Returning cached
		if cachedItems[storeCacheId] then
			return cachedItems[storeCacheId]
		end

		-- No items are cached -> returning nil
		if respectCached then
			return nil
		end
	end

	--[[ Getting Pages ]]

	--- @type GlobalLeaderboard_DataStorePages | nil
	local pages = Module.GetPages(storeName, scope, isAscending, pageSize, cache, fromCachedPages, respectCached)
	if not pages then
		return nil
	end

	--[[ Getting Current Page ]]

	-- Using pcall to catch any errors
	local success: boolean, result = pcall(function()
		return pages:GetCurrentPage()
	end)

	--[[ Returning ]]

	if success and result then
		--- @type { GlobalLeaderboard_PageData }
		local currentPage = result

		-- Caching result
		if cache then
			cachedItems[storeCacheId] = currentPage
		end

		-- Returning
		return currentPage
	else
		warn(`[{_localName}::{script.Name}]: Failed while getting items for ({storeFullId}) OrderedDataStore! - {result}`)
		return nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Cached Items

--[[
	**SERVER** |
	Returns a copy of the cached top page of a store, or nil until a read with `cache` stored one. Never reads the store.
]]
--- @return { GlobalLeaderboard_PageData }?
function Module.GetCachedItems(storeName: string, scope: string?, isAscending: boolean, pageSize: number)
	--[[ Local Variables ]]

	local storeFullId: string = if scope then `{storeName}::{scope}` else storeName
	local storeCacheId: string = `{storeFullId}-{isAscending}-{pageSize}`

	--[[ Checks ]]

	-- Check if the page is cached yet
	if not cachedItems[storeCacheId] then
		return nil
	end

	--[[ Returning ]]

	return I.Table.DeepCopy(cachedItems[storeCacheId])
end

--%%%%%%%%%%%%%%%%%%%% Has Budget

--[[
	Returns whether the DataStore budget allows an update turn: a write per player, and one sorted read when the page is cached after it.
	Mock stores always have budget.
]]
--- @param functionTable GlobalLeaderboard_UpdateGroup_FunctionTable
--- @return boolean
function Module._hasBudget(functionTable, playerCount: number)
	--[[ Checks ]]

	-- Check if the stores are mocked
	if not I.DataStoreAccess then
		return true
	end

	--[[ Local Variables ]]

	local writeBudget: number = DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementSortedAsync)
	local readBudget: number = DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetSortedAsync)

	--[[ Returning ]]

	return writeBudget >= playerCount and (not functionTable.CacheOnUpdate or readBudget >= 1)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
