--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Inventory"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

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

--- @class Inventory_Server_Remove
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Standard Item Control

--%%%%%%%%%%%%%%%%%%%% Remove Item Client

--[[
	Validates client requests before removing an item from a player's inventory.
	The client can't turn off the Topic and the client update.
]]
--- @return boolean
function Module.RemoveItem_Client(player: Player, itemId: string, quantity: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Item Data ]]

	--- @type Inventory_ItemData
	local itemData = I.G_Inventory.Items[itemId]

	--[[ Checks ]]

	-- Check if the item can be removed by the client
	if not itemData or not itemData.RemoveByClientRequest then
		return false
	end

	--[[ Removing ]]

	return Module.RemoveItem(player, itemId, quantity, nil)
end

--%%%%%%%%%%%%%%%%%%%% Remove Item

--[[
	**SERVER** |
	Removes item from player's inventory.
]]
--- @return boolean
function Module.RemoveItem(player: Player, itemId: string, quantity: string?, sendUpdate: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--%%%%%%%%%%%%%%%%%%%% Checks

	--[[ General ]]

	-- Item is not in the Inventory
	if not inventoryData.Standard[itemId] then
		warn(`[{_localName}::{script.Name}]: Item ({itemId}) is not in player's Inventory!`)
		return false
	end

	-- Item is Locked
	if table.find(inventoryData.Locked or {}, itemId) then
		return false
	end

	--[[ Input Check ]]

	quantity = quantity or "1"

	-- Invalid quantity input
	if type(quantity) ~= "string" or not I.Number.IsIntegerString(quantity) then
		warn(`[{_localName}::{script.Name}]: ({quantity}) is not a valid Quantity!`)
		return false
	end

	--[[ Quantity Check ]]

	local quantityBN = I.BN.new(quantity) --- @type BigNum_Instance
	local currentBN = I.BN.new(inventoryData.Standard[itemId]) --- @type BigNum_Instance

	-- Invalid quantity
	if quantityBN <= zeroBN then
		warn(`[{_localName}::{script.Name}]: Quantity ({quantity}) cannot be less than or equal to (0)! | ({itemId})`)
		return false
	end

	-- Not enough
	if quantityBN > currentBN then
		return false
	end

	--%%%%%%%%%%%%%%%%%%%% Removing

	--[[ Calculating Quantity ]]

	--- @type BigNum_Instance
	local finalBN = currentBN - quantityBN

	--[[ Removing Item ]]

	-- Keep what is left, or drop the item at 0
	if finalBN > zeroBN then
		inventoryData.Standard[itemId] = tostring(finalBN)
	else
		inventoryData.Standard[itemId] = nil
	end

	--[[ Updating Client ]]

	-- Publish and update the client unless sendUpdate is false
	if sendUpdate == nil or sendUpdate == true then
		I.Topic.Publish("Inventory_ItemRemoved", player, itemId, quantity)
		I.Inventory.UpdateClientChanges(player, "Standard", { itemId })
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Unique Item Control

--%%%%%%%%%%%%%%%%%%%% Remove Unique Client

--[[
	Validates client requests before removing a unique item from a player's inventory.
	The client can't turn off the Topic and the client update.
]]
--- @return boolean
function Module.RemoveUnique_Client(player: Player, uniqueUUID: string, quantity: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--- @type Inventory_UniqueItem
	local uniqueData = inventoryData.Unique[uniqueUUID]

	--- @type Inventory_ItemData
	local itemData = uniqueData and I.G_Inventory.Items[uniqueData.Id]

	--[[ Checks ]]

	-- Check if the item can be removed by the client
	if not itemData or not itemData.RemoveByClientRequest then
		return false
	end

	--[[ Returning ]]

	return Module.RemoveUnique(player, uniqueUUID, quantity, nil)
end

--%%%%%%%%%%%%%%%%%%%% Remove Unique

--[[
	**SERVER** |
	Removes unique item from player's inventory.
]]
--- @return boolean
function Module.RemoveUnique(player: Player, uniqueUUID: string, quantity: string?, sendUpdate: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--%%%%%%%%%%%%%%%%%%%% Checks

	--[[ General ]]

	-- Item is not in the Inventory
	if not inventoryData.Unique[uniqueUUID] then
		warn(`[{_localName}::{script.Name}]: Item ({uniqueUUID}) is not in player's Inventory!`)
		return false
	end

	-- Item is Locked
	if table.find(inventoryData.Locked or {}, uniqueUUID) then
		return false
	end

	--[[ Input Check ]]

	-- Check the quantity when one is given
	if quantity then
		-- Making sure it's always a string
		quantity = `{quantity}`

		-- Invalid quantity input
		if type(quantity) ~= "string" or not I.Number.IsIntegerString(quantity) then
			warn(`[{_localName}::{script.Name}]: ({quantity}) is not a valid Quantity!`)
			return false
		end
	end

	--[[ Quantity Check ]]

	local quantityBN = quantity and I.BN.new(quantity) or I.BN.new(inventoryData.Unique[uniqueUUID].Metadata._q) --- @type BigNum_Instance
	local currentBN = I.BN.new(inventoryData.Unique[uniqueUUID].Metadata._q) --- @type BigNum_Instance

	-- Invalid quantity
	if quantityBN <= zeroBN then
		warn(`[{_localName}::{script.Name}]: Quantity ({quantity}) cannot be less than or equal to (0)! | ({uniqueUUID})`)
		return false
	end

	-- Not enough
	if quantityBN > currentBN then
		return false
	end

	--%%%%%%%%%%%%%%%%%%%% Removing

	--[[ Calculating Quantity ]]

	--- @type BigNum_Instance
	local finalBN = currentBN - quantityBN

	--[[ Removing Item ]]

	-- Keep what is left, or drop the unique at 0
	if finalBN > zeroBN then
		inventoryData.Unique[uniqueUUID].Metadata._q = tostring(finalBN)
	else
		inventoryData.Unique[uniqueUUID] = nil
		inventoryData.UniqueAmount = math.max(0, inventoryData.UniqueAmount - 1)
	end

	--[[ Updating Client ]]

	-- Publish and update the client unless sendUpdate is false
	if sendUpdate == nil or sendUpdate == true then
		I.Topic.Publish("Inventory_UniqueRemoved", player, uniqueUUID, quantity)
		I.Inventory.UpdateClientChanges(player, "Unique", { uniqueUUID })
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Other

--%%%%%%%%%%%%%%%%%%%% Remove Bulk Client

--[[
	Validates each client bulk-removal request before removing items from a player's inventory.
]]
--- @param removeTable { [string]: string }
--- @return boolean
function Module.RemoveBulk_Client(player: Player, removeTable)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--[[ Checks ]]

	-- Check if anything was asked for
	if next(removeTable) == nil then
		return false
	end

	for itemId: string, _quantity: any in pairs(removeTable) do
		--- @type Inventory_ItemData
		local itemData

		-- Find the item data by item id, or by the unique's item id
		if I.G_Inventory.Items[itemId] then
			itemData = I.G_Inventory.Items[itemId]
		else
			--- @type Inventory_UniqueItem
			local uniqueData = inventoryData.Unique[itemId]
			itemData = uniqueData and I.G_Inventory.Items[uniqueData.Id]
		end

		-- Check if every item can be removed by the client
		if not itemData or not itemData.RemoveByClientRequest then
			return false
		end
	end

	--[[ Returning ]]

	return Module.RemoveBulk(player, removeTable)
end

--%%%%%%%%%%%%%%%%%%%% Remove Bulk

--[[
	**SERVER** |
	Removes items in bulk from player's inventory.
	Publishes and returns only what was actually removed.
]]
--- @param removeTable { [string]: string }
--- @return boolean
function Module.RemoveBulk(player: Player, removeTable)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Local Variables ]]

	local removed = {} --- @type { [string]: string }
	local removedStandard = {} --- @type { string }
	local removedUnique = {} --- @type { string }

	--[[ Removing ]]

	for itemId: string, quantity: any in pairs(removeTable) do
		local quantityStr: string? = quantity ~= nil and `{quantity}` or nil

		-- Remove by item id, or by unique UUID, keeping only what was removed
		if I.G_Inventory.Items[itemId] then
			-- If the ItemId is actual Item Id
			if Module.RemoveItem(player, itemId, quantityStr, false) then
				removed[itemId] = quantityStr
				table.insert(removedStandard, itemId)
			end
		else
			-- If the ItemId is an UniqueUUID
			if Module.RemoveUnique(player, itemId, quantityStr, false) then
				removed[itemId] = quantityStr
				table.insert(removedUnique, itemId)
			end
		end
	end

	--[[ Checks ]]

	-- Check if anything was removed
	if next(removed) == nil then
		return false
	end

	--[[ Publishing ]]

	I.Topic.Publish("Inventory_BulkRemoved", player, removed)

	-- Send the removed Standard items to the client
	if #removedStandard > 0 then
		I.Inventory.UpdateClientChanges(player, "Standard", removedStandard)
	end

	-- Send the removed Unique items to the client
	if #removedUnique > 0 then
		I.Inventory.UpdateClientChanges(player, "Unique", removedUnique)
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
