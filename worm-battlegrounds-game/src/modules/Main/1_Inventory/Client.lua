--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Inventory"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Data ]]

--[[
	**CLIENT** |
	Table containing current player items.
]]
local currentItems = {
	Standard = {}, --- @type { [string]: string }
	Unique = {}, --- @type { [string]: Inventory_UniqueItem }
	Locked = {}, --- @type { string }

	UniqueAmount = 0,
}

--[[
	List of all initial updated data types.\
	Used for tracking initial data updates upon joining.
]]
local initialUpdates = {} --- @type { string }

--[[ BigNum ]]

local zeroBN = I.BN.new("0")

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
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("Inventory_DataUpdated-Standard", { { Type = "table" }, "boolean" })
	I.Topic.Register("Inventory_DataUpdated-Unique", { { Type = "table" }, "boolean" })
	I.Topic.Register("Inventory_DataUpdated-Locked", { { Type = "table" }, "boolean" })

	--- @Network
	I.Network.GetEvent("Inventory_UpdateClientData", { "string", { Types = { "table", "number" } } })
	I.Network.Fired("Inventory_UpdateClientData", Module._onClientUpdate)

	I.Network.GetEvent("Inventory_UpdateClientChanges", { "string", { Type = "table" } })
	I.Network.Fired("Inventory_UpdateClientChanges", Module._onClientChanges)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Inventory = {

		--[[ Methods ]]

		HasItem = Module.HasItem,

		--[[ Data ]]

		Items = currentItems,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Client Update

--[[
	Receives inventory data from server and sends topic to update client data.
]]
--- @param dataType Inventory_DataType
--- @param itemTable Inventory_NetworkData
function Module._onClientUpdate(dataType, itemTable)
	--[[ Resolving ]]

	-- Resolve by data type; the unique count is only stored
	if dataType == "Standard" then
		Module._resolveStandard(itemTable)
	elseif dataType == "Unique" then
		Module._resolveUnique(itemTable)
	elseif dataType == "Locked" then
		Module._resolveLocked(itemTable)
	elseif dataType == "UniqueAmount" then
		currentItems.UniqueAmount = itemTable
	end
end

--%%%%%%%%%%%%%%%%%%%% On Client Changes

--[[
	Receives single-entry changes from server, merges them into `Items` and publishes them like a full update.
]]
--- @param changes Inventory_NetworkChanges
function Module._onClientChanges(dataType: string, changes)
	--[[ Resolving ]]

	-- Resolve by data type
	if dataType == "Standard" then
		Module._resolveStandardChanges(changes)
	elseif dataType == "Unique" then
		Module._resolveUniqueChanges(changes)
	end
end

--%%%%%%%%%%%%%%%%%%%% Resolve Standard

--[[
	Resolves Standard inventory updates and publishes them.
]]
function Module._resolveStandard(itemTable: table)
	--%%%%%%%%%%%%%%%%%%%% Initial Update

	local initialUpdate: boolean = not table.find(initialUpdates, "Standard")
	if initialUpdate then
		--[[ Saving ]]

		table.insert(initialUpdates, "Standard")
		currentItems.Standard = itemTable

		--[[ Publishing ]]

		I.Topic.Publish("Inventory_DataUpdated-Standard", itemTable, true)
		return
	end

	--%%%%%%%%%%%%%%%%%%%% Items Changed

	local changed = {} --- @type { [string]: string }

	--[[ New Items ]]

	for itemId: string, itemQuantity: string in pairs(itemTable) do
		--[[ New Item ]]

		if not currentItems.Standard[itemId] then
			changed[itemId] = itemQuantity
			continue
		end

		--[[ Existing Item ]]

		local oldQuantity: string = currentItems.Standard[itemId]

		--[[ Calculating Difference ]]

		local newQuantityBN = I.BN.new(itemQuantity)
		local oldQuantityBN = I.BN.new(oldQuantity)
		local differenceBN = newQuantityBN - oldQuantityBN

		--[[ Updating Changed ]]

		if differenceBN ~= zeroBN then
			changed[itemId] = tostring(differenceBN)
		end
	end

	--[[ Removed Items ]]

	for itemId: string, itemQuantity: string in pairs(currentItems.Standard) do
		if not itemTable[itemId] then
			changed[itemId] = `-{itemQuantity}`
		end
	end

	--[[ Saving ]]

	currentItems.Standard = itemTable

	--[[ Publishing ]]

	I.Topic.Publish("Inventory_DataUpdated-Standard", changed, false)
end

--%%%%%%%%%%%%%%%%%%%% Resolve Standard Changes

--[[
	Merges Standard entry changes into `Items` and publishes the differences.
]]
--- @param changes { [string]: string | boolean }
function Module._resolveStandardChanges(changes)
	--[[ Checks ]]

	-- Skip until the first full update arrived, which already holds these changes
	if not table.find(initialUpdates, "Standard") then
		return
	end

	--[[ Merging ]]

	--- @type { [string]: string }
	local changed = {}

	for itemId: string, newQuantity: string | boolean in pairs(changes) do
		--[[ Calculating Difference ]]

		local oldQuantityBN = I.BN.new(currentItems.Standard[itemId] or "0") --- @type BigNum_Instance
		local newQuantityBN = I.BN.new(newQuantity or "0") --- @type BigNum_Instance
		local differenceBN = newQuantityBN - oldQuantityBN --- @type BigNum_Instance

		--[[ Updating Changed ]]

		-- Keep only real differences
		if differenceBN ~= zeroBN then
			changed[itemId] = tostring(differenceBN)
		end

		--[[ Saving ]]

		currentItems.Standard[itemId] = newQuantity or nil
	end

	--[[ Publishing ]]

	I.Topic.Publish("Inventory_DataUpdated-Standard", changed, false)
end

--%%%%%%%%%%%%%%%%%%%% Resolve Unique

--[[
	Resolves Unique inventory updates and publishes them.
]]
function Module._resolveUnique(itemTable: table)
	--%%%%%%%%%%%%%%%%%%%% Initial Update

	local initialUpdate: boolean = not table.find(initialUpdates, "Unique")
	if initialUpdate then
		--[[ Saving ]]

		table.insert(initialUpdates, "Unique")
		currentItems.Unique = itemTable

		--[[ Preparing Data ]]

		local toSend = {} --- @type { [string]: string }
		for uniqueUUID: string, itemData in pairs(itemTable) do
			toSend[uniqueUUID] = (itemData.Metadata and itemData.Metadata._q) or "0"
		end

		--[[ Publishing ]]

		I.Topic.Publish("Inventory_DataUpdated-Unique", toSend, true)
		return
	end

	--%%%%%%%%%%%%%%%%%%%% Items Changed

	local changed = {} --- @type { [string]: string }

	--[[ New Items ]]

	for itemUUID: string, itemData in pairs(itemTable) do
		--[[ Getting Quantity ]]

		local newQuantity: string = itemData.Metadata and tostring(itemData.Metadata._q)
		if not newQuantity then
			continue
		end

		--[[ New Item ]]

		if not currentItems.Unique[itemUUID] then
			changed[itemUUID] = newQuantity
			continue
		end

		--[[ Existing Item ]]

		local oldQuantity: string = (currentItems.Unique[itemUUID].Metadata and currentItems.Unique[itemUUID].Metadata._q) or "0"

		--[[ Calculating Difference ]]

		local newQuantityBN = I.BN.new(newQuantity)
		local oldQuantityBN = I.BN.new(oldQuantity)
		local differenceBN = newQuantityBN - oldQuantityBN

		--[[ Updating Changed ]]

		if differenceBN ~= zeroBN then
			changed[itemUUID] = tostring(differenceBN)
		end
	end

	--[[ Removed Items ]]

	for itemUUID: string, itemData in pairs(currentItems.Unique) do
		if not itemTable[itemUUID] then
			local removedQty: string = (itemData.Metadata and itemData.Metadata._q) or "0"
			changed[itemUUID] = `-{removedQty}`
		end
	end

	--[[ Saving ]]

	currentItems.Unique = itemTable

	--[[ Publishing ]]

	I.Topic.Publish("Inventory_DataUpdated-Unique", changed, false)
end

--%%%%%%%%%%%%%%%%%%%% Resolve Unique Changes

--[[
	Merges Unique entry changes into `Items` and publishes the quantity differences.
]]
--- @param changes { [string]: Inventory_UniqueItem | boolean }
function Module._resolveUniqueChanges(changes)
	--[[ Checks ]]

	-- Skip until the first full update arrived, which already holds these changes
	if not table.find(initialUpdates, "Unique") then
		return
	end

	--[[ Merging ]]

	--- @type { [string]: string }
	local changed = {}

	--- @param newData Inventory_UniqueItem | boolean
	for itemUUID: string, newData in pairs(changes) do
		--[[ Getting Quantity ]]

		local oldData = currentItems.Unique[itemUUID] --- @type Inventory_UniqueItem?
		local oldQuantity: string = (oldData and oldData.Metadata and oldData.Metadata._q) or "0"
		local newQuantity: string = (newData and newData.Metadata and newData.Metadata._q) or "0"

		--[[ Calculating Difference ]]

		--- @type BigNum_Instance
		local differenceBN = I.BN.new(newQuantity) - I.BN.new(oldQuantity)

		--[[ Updating Changed ]]

		-- Keep only real differences
		if differenceBN ~= zeroBN then
			changed[itemUUID] = tostring(differenceBN)
		end

		--[[ Saving ]]

		currentItems.Unique[itemUUID] = newData or nil
	end

	--[[ Publishing ]]

	I.Topic.Publish("Inventory_DataUpdated-Unique", changed, false)
end

--%%%%%%%%%%%%%%%%%%%% Resolve Locked

--[[
	Resolves Locked inventory updates and publishes them.
]]
function Module._resolveLocked(itemTable: table)
	--%%%%%%%%%%%%%%%%%%%% Initial Update

	local initialUpdate: boolean = not table.find(initialUpdates, "Locked")
	if initialUpdate then
		--[[ Saving ]]

		table.insert(initialUpdates, "Locked")
		currentItems.Locked = itemTable

		--[[ Preparing Data ]]

		local toSend = {} --- @type { [string]: boolean }
		for _, itemId: string in ipairs(itemTable) do
			toSend[itemId] = true
		end

		--[[ Publishing ]]

		I.Topic.Publish("Inventory_DataUpdated-Locked", toSend, true)
		return
	end

	--%%%%%%%%%%%%%%%%%%%% Items Changed

	local changed = {} --- @type { [string]: boolean }

	--[[ Added - Locked ]]

	for _, itemId: string in ipairs(itemTable) do
		if not table.find(currentItems.Locked, itemId) then
			changed[itemId] = true
		end
	end

	--[[ Removed - Unlocked ]]

	for _, itemId: string in ipairs(currentItems.Locked) do
		if not table.find(itemTable, itemId) then
			changed[itemId] = false
		end
	end

	--[[ Saving ]]

	currentItems.Locked = itemTable

	--[[ Publishing ]]

	I.Topic.Publish("Inventory_DataUpdated-Locked", changed, false)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Has Item

--[[
	Returns whether the local player holds at least `quantity` (1 by default) of a standard item id or a unique UUID, read from `Items`.
]]
--- @return boolean
function Module.HasItem(itemId: string, quantity: string?)
	--[[ Checks ]]

	-- Invalid quantity input
	if quantity and (type(quantity) ~= "string" or not I.Number.IsIntegerString(quantity)) then
		warn(`[{_localName}::{script.Name}]: ({quantity}) is not a valid Quantity!`)
		return false
	end

	--[[ Data ]]

	--- @type Inventory_UniqueItem?
	local uniqueData = currentItems.Unique[itemId]

	--[[ Local Variables ]]

	local heldQuantity: string? = currentItems.Standard[itemId] or (uniqueData and uniqueData.Metadata._q)

	--[[ Checks ]]

	-- Check if the item is held at all
	if not heldQuantity then
		return false
	end

	--[[ Returning ]]

	return I.BN.new(heldQuantity) >= I.BN.new(quantity or "1")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
