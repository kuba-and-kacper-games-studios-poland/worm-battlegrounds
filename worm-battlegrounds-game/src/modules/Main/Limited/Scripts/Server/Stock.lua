--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Limited"

--- @type Limited_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Stock ]]

local soldCounts = {} --- @type { [string]: number }
--- Real `DataStore` from `DataStoreService`, or `I.MockDataStores.DataStore` when `I.DataStoreAccess == false`.
local stockStore
local stockReady: boolean = false
local stockReadyEvent: BindableEvent = Instance.new("BindableEvent")
local refreshing: boolean = false

--[[ Replicator ]]

local globalRepFolder: Folder

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

--- @class Limited_Server_Stock
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._createGlobalReplicator()
	task.spawn(Module._initStock)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic

	I.Topic.Register("Limited_StockChanged", { "string", "number", "number" })
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Module._subscribeToSales()
	Module._mainLoop()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Main Loop

--[[
	Reloads every sold count from the DataStore each `REFRESH_INTERVAL` seconds,
	so sales and give-backs made on other servers show here even when a sale message is lost.
]]
function Module._mainLoop()
	--[[ Connections ]]

	I.DoEvery.Every(_settings.REFRESH_INTERVAL, function()
		-- Skip while the store isn't ready or the last refresh is still running
		if not stockReady or not stockStore or refreshing then
			return
		end

		refreshing = true

		local success: boolean
		local result: any | string?
		success, result = pcall(Module._loadStockCounts)

		refreshing = false

		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to refresh the sold counts! - ({result})`)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Global Replicator

--[[
	Creates the shared Limited folder (unparented until stock has loaded)
	and sets `<limitedId>_Sold` / `<limitedId>_Max` attributes.
]]
function Module._createGlobalReplicator()
	--[[ Creating ]]

	globalRepFolder = I.Dirs.Storage:FindFirstChild(_localName)
	if not globalRepFolder then
		globalRepFolder = Instance.new("Folder")
		globalRepFolder.Name = _localName
	else
		globalRepFolder.Parent = nil
	end

	--[[ Attributes ]]

	--- @param limitedData Limited_LimitedData
	for limitedId: string, limitedData in pairs(I.G_Limited.Data) do
		globalRepFolder:SetAttribute(`{limitedId}_Max`, limitedData.MaximumAmount)
		globalRepFolder:SetAttribute(`{limitedId}_Sold`, 0)
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Stock Store

--[[
	Gets and saves the Limited stock `DataStore`, or a mock in-memory store
	when DataStores are unavailable.
]]
function Module._getStockStore()
	--[[ Checks ]]

	-- Skip when the store is already set
	if stockStore then
		return
	end

	--[[ Mock DataStore ]]

	if not I.DataStoreAccess then
		stockStore = I.MockDataStores.DataStore.new()
		return
	end

	--[[ Real DataStore ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		return I.S.DataStoreService:GetDataStore(_settings.DATASTORE_NAME)
	end)

	if success then
		stockStore = result
	else
		warn(`[{_localName}::{script.Name}]: Failed while getting (Limited) DataStore! - {result}`)
	end
end

--%%%%%%%%%%%%%%%%%%%% Load Stock Counts

--[[
	Loads the saved global sold count of each limited and mirrors it onto the global replicator.
	A limited whose load fails keeps its last count and is tried again on the next refresh.
]]
function Module._loadStockCounts()
	--[[ Checks ]]

	-- Skip when there is no store
	if not stockStore then
		return
	end

	--[[ Loading ]]

	for limitedId: string in pairs(I.G_Limited.Data) do
		local success: boolean
		local result: any | string?
		success, result = pcall(function()
			return stockStore:GetAsync(limitedId)
		end)

		-- Skip a limited whose load failed
		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to load stock for ({limitedId})! - {result}`)
			continue
		end

		Module._setSold(limitedId, tonumber(result) or 0)
	end
end

--%%%%%%%%%%%%%%%%%%%% Init Stock

--[[
	Resolves the stock store, loads sold-counts, parents the replicator,
	then marks stock ready (even if the store could not be gotten).
]]
function Module._initStock()
	--[[ Loading ]]

	Module._getStockStore()
	Module._loadStockCounts()

	--[[ Replicating ]]

	globalRepFolder.Parent = I.Dirs.Storage

	--[[ Ready ]]

	stockReady = true
	stockReadyEvent:Fire()
end

--%%%%%%%%%%%%%%%%%%%% Subscribe To Sales

--[[
	Listens to the sale messages other servers publish, and applies each count that is higher than the one this server has.
]]
function Module._subscribeToSales()
	--[[ Checks ]]

	-- Skip without DataStore access (no cross-server messages)
	if not I.DataStoreAccess then
		return
	end

	--[[ Subscribing ]]

	task.spawn(function()
		local success: boolean
		local result: any | string?
		success, result = pcall(function()
			return I.S.MessagingService:SubscribeAsync(_settings.MESSAGING_TOPIC, Module._onSaleMessage)
		end)

		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to subscribe to sale messages! - {result}`)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Reserve

--[[
	Takes one copy of the limited from the global stock with `UpdateAsync`.
	Returns false when the store is missing or fails, or when the stock is sold out.
]]
--- @return boolean
function Module.Reserve(limitedId: string)
	--[[ Data ]]

	--- @type Limited_LimitedData
	local limitedData = I.G_Limited.Data[limitedId]

	--[[ Checks ]]

	Module.WaitForStockReady()

	-- Check if the stock store exists
	if not stockStore then
		return false
	end

	--[[ Reserving ]]

	local reserved: boolean = false
	local latestSold: number? = nil

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		return stockStore:UpdateAsync(limitedId, function(current: any)
			-- Decide again on every run, since UpdateAsync reruns the transform after a conflict
			reserved = false
			latestSold = tonumber(current) or 0

			-- Cancel the write when the stock is sold out
			if latestSold >= limitedData.MaximumAmount then
				return nil
			end

			reserved = true
			return latestSold + 1
		end)
	end)

	--[[ Checks ]]

	-- Check if the update went through
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to reserve stock for ({limitedId})! - {result}`)
		return false
	end

	-- Mirror the sold-out count and stop when nothing was reserved
	if not reserved then
		Module._setSold(limitedId, latestSold or limitedData.MaximumAmount)
		warn(`[{_localName}::{script.Name}]: Stock for ({limitedId}) is depleted!`)
		return false
	end

	--[[ Saving ]]

	local newSold: number = tonumber(result) or (latestSold + 1)
	Module._setSold(limitedId, newSold)

	--[[ Publishing ]]

	Module._publishSale(limitedId, newSold)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Release

--[[
	Gives one reserved copy of the limited back to the global stock (never below 0),
	used when a purchase fails after its copy was reserved.
]]
--- @return boolean
function Module.Release(limitedId: string)
	--[[ Checks ]]

	-- Check if the stock store exists
	if not stockStore then
		return false
	end

	--[[ Releasing ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(function()
		return stockStore:UpdateAsync(limitedId, function(current: any)
			return math.max(0, (tonumber(current) or 0) - 1)
		end)
	end)

	--[[ Checks ]]

	-- Check if the update went through
	if not success then
		warn(`[{_localName}::{script.Name}]: Failed to give back a copy of ({limitedId})! - {result}`)
		return false
	end

	--[[ Saving ]]

	Module._setSold(limitedId, tonumber(result) or 0)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Wait For Stock Ready

--[[
	Yields until `_initStock` has finished (store resolved, counts loaded or skipped, replicator parented).
]]
function Module.WaitForStockReady()
	--[[ Checks ]]

	-- Skip when stock already loaded
	if stockReady then
		return
	end

	--[[ Waiting ]]

	stockReadyEvent.Event:Wait()
end

--%%%%%%%%%%%%%%%%%%%% Set Sold

--[[
	Saves the sold count of the limited, mirrors it onto the global replicator,
	and publishes `Limited_StockChanged` when it changed after the stock loaded.
]]
function Module._setSold(limitedId: string, sold: number)
	--[[ Local Variables ]]

	local previousSold: number? = soldCounts[limitedId]

	--[[ Saving ]]

	soldCounts[limitedId] = sold
	globalRepFolder:SetAttribute(`{limitedId}_Sold`, sold)

	--[[ Publishing ]]

	-- Skip the topic during the first load and when the count didn't change
	if not stockReady or previousSold == sold then
		return
	end

	I.Topic.Publish("Limited_StockChanged", limitedId, sold, I.G_Limited.Data[limitedId].MaximumAmount)
end

--%%%%%%%%%%%%%%%%%%%% Publish Sale

--[[
	Tells every other server the new sold count of the limited, in a new thread.
]]
function Module._publishSale(limitedId: string, sold: number)
	--[[ Checks ]]

	-- Skip without DataStore access (no cross-server messages)
	if not I.DataStoreAccess then
		return
	end

	--[[ Publishing ]]

	task.spawn(function()
		local success: boolean
		local result: any | string?
		success, result = pcall(function()
			I.S.MessagingService:PublishAsync(_settings.MESSAGING_TOPIC, { Id = limitedId, Sold = sold })
		end)

		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to publish the sale of ({limitedId})! - {result}`)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% On Sale Message

--[[
	Applies a sale message from another server when it names a known limited and a higher count than this server has.
]]
--- @param message Limited_SaleMessage
function Module._onSaleMessage(message)
	--[[ Data ]]

	local payload: any = message.Data

	--[[ Checks ]]

	-- Check if the message has a known limited and a number
	if typeof(payload) ~= "table" or typeof(payload.Id) ~= "string" or typeof(payload.Sold) ~= "number" or not I.G_Limited.Data[payload.Id] then
		return
	end

	-- Skip counts that aren't higher than this server's (messages can arrive out of order)
	if payload.Sold <= (soldCounts[payload.Id] or 0) then
		return
	end

	--[[ Saving ]]

	Module._setSold(payload.Id, math.min(payload.Sold, I.G_Limited.Data[payload.Id].MaximumAmount))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Remaining

--[[
	Returns how many copies of `limitedId` are still available globally.
]]
--- @return number
function Module.GetRemaining(limitedId: string)
	--[[ Data ]]

	--- @type Limited_LimitedData
	local limitedData = I.G_Limited.Data[limitedId]

	--[[ Checks ]]

	-- Invalid Id
	if not limitedData then
		return 0
	end

	-- Stock not loaded
	if not stockReady or not stockStore then
		return 0
	end

	--[[ Returning ]]

	return math.max(0, limitedData.MaximumAmount - (soldCounts[limitedId] or 0))
end

--%%%%%%%%%%%%%%%%%%%% Get Sold

--[[
	Returns how many copies of `limitedId` this server knows were sold.
]]
--- @return number
function Module.GetSold(limitedId: string)
	return soldCounts[limitedId] or 0
end

--%%%%%%%%%%%%%%%%%%%% Is Ready

--[[
	Returns whether the stock loaded and a store exists.
]]
--- @return boolean
function Module.IsReady()
	return stockReady and stockStore ~= nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
