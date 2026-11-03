--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Inventory"

--- @type Inventory_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ BigNum ]]

local zeroBN = I.BN.new("0")
local maxUseQuantity = I.BN.new(_settings.MAX_USE_QUANTITY)

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

--- @class Inventory_Server_Use
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Use Item Client

--[[
	Validates client requests before using an item: only items with `UseByClientRequest`.
]]
--- @return boolean
function Module.UseItem_Client(player: Player, itemId: string, quantity: string?, useMax: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Item Data ]]

	--- @type Inventory_ItemData
	local itemData = I.G_Inventory.Items[itemId]

	--[[ Checks ]]

	-- Check if the item can be used by the client
	if not itemData or not itemData.UseByClientRequest then
		return false
	end

	--[[ Using ]]

	return Module.UseItem(player, itemId, quantity, useMax)
end

--%%%%%%%%%%%%%%%%%%%% Use Item

--[[
	**SERVER** |
	Runs `Use` function of the `itemId` and removes it from player's inventory.
	Topics and the client update are sent only after a successful `Use`; a failed `Use` gives the items back.
]]
--- @return boolean
function Module.UseItem(player: Player, itemId: string, quantity: string?, useMax: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--- @type Inventory_ItemData
	local itemData = I.G_Inventory.Items[itemId]

	--%%%%%%%%%%%%%%%%%%%% Checks

	--[[ General ]]

	-- Item is Invalid
	if not itemData then
		warn(`[{_localName}::{script.Name}]: ({itemId}) is not a valid itemId!`)
		return false
	end

	-- Item is not in the Inventory
	if not inventoryData.Standard[itemId] then
		warn(`[{_localName}::{script.Name}]: Item ({itemId}) is not in player's Inventory!`)
		return false
	end

	-- Item is Locked
	if table.find(inventoryData.Locked or {}, itemId) then
		return false
	end

	-- Missing `Use` Function
	if not itemData["Use"] or type(itemData["Use"]) ~= "function" then
		return false
	end

	--[[ Input Check ]]

	-- Invalid quantity input
	if quantity and (type(quantity) ~= "string" or not I.Number.IsIntegerString(quantity)) then
		warn(`[{_localName}::{script.Name}]: ({quantity}) is not a valid Quantity!`)
		return false
	end

	--[[ Quantity Check ]]

	--- @type BigNum_Instance
	local quantityBN

	-- Getting quantity
	if not useMax then
		quantityBN = quantity and I.BN.new(quantity) or I.BN.new("1")
	else
		quantityBN = I.BN.new(inventoryData.Standard[itemId])
	end

	-- Invalid Quantity
	if not quantityBN or quantityBN <= zeroBN then
		warn(`[{_localName}::{script.Name}]: Quantity ({quantity}) cannot be less than or equal to (0)! | ({itemId})`)
		return false
	end

	-- Max Use Quantity
	if quantityBN > maxUseQuantity then
		quantityBN = I.BN.new(_settings.MAX_USE_QUANTITY)
	end

	local quantityText: string = tostring(quantityBN)

	--[[ Requirements ]]

	-- Check the item's requirements when it has them
	if itemData["UseRequirements"] then
		-- Running Requirements in pcall to avoid errors
		local success: boolean
		local result: any | string?
		success, result = pcall(itemData["UseRequirements"], player, quantityText)

		-- Return if not succeeded
		if not success or not result then
			-- Warn with the error of a failed call
			if type(result) == "string" then
				warn(`[{_localName}::{script.Name}]: Item ({itemId}) use failed! - {result}`)
			end

			return false
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Using

	--[[ Removing ]]

	-- Take the items out quietly before running Use
	if not I.Inventory.RemoveItem(player, itemId, quantityText, false) then
		return false
	end

	--[[ Using Item ]]

	-- Using in pcall to avoid errors
	local success: boolean
	local result: any | string?
	success, result = pcall(itemData["Use"], player, quantityText)

	-- Give the items back quietly when Use failed
	if not success or not result then
		-- Warn with the error of a failed call
		if type(result) == "string" then
			warn(`[{_localName}::{script.Name}]: Item ({itemId}) use failed! - {result}`)
		end

		-- Warn when the items could not be given back
		if not I.Inventory.AddItem(player, itemId, quantityText, false) then
			warn(`[{_localName}::{script.Name}]: Failed to give back ({quantityText}) ({itemId}) to ({player.Name}) after a failed use!`)
		end

		return false
	end

	--[[ Publishing ]]

	I.Topic.Publish("Inventory_ItemRemoved", player, itemId, quantityText)
	I.Inventory.UpdateClientChanges(player, "Standard", { itemId })

	I.Topic.Publish("Inventory_ItemUsed", player, itemId, quantityText)
	I.Topic.Publish("Inventory_ItemUsed-Standard", player, itemId, quantityText)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Use Unique Client

--[[
	Validates client requests before using a unique item: only items with `UseByClientRequest`.
]]
--- @return boolean
function Module.UseUnique_Client(player: Player, uniqueUUID: string, quantity: string?, useMax: boolean?)
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

	-- Check if the item can be used by the client
	if not itemData or not itemData.UseByClientRequest then
		return false
	end

	--[[ Using ]]

	return Module.UseUnique(player, uniqueUUID, quantity, useMax)
end

--%%%%%%%%%%%%%%%%%%%% Use Unique

--[[
	**SERVER** |
	Runs `Use` function of the `itemId` and removes it from player's inventory.
	Topics and the client update are sent only after a successful `Use`; a failed `Use` gives the quantity back.
]]
--- @return boolean
function Module.UseUnique(player: Player, uniqueUUID: string, quantity: string?, useMax: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	local itemId: string = inventoryData.Unique[uniqueUUID] and inventoryData.Unique[uniqueUUID].Id
	local itemData = itemId and I.G_Inventory.Items[itemId] --- @type Inventory_ItemData

	--%%%%%%%%%%%%%%%%%%%% Checks

	--[[ Checks ]]

	-- Item is not in the Inventory
	if not inventoryData.Unique[uniqueUUID] then
		warn(`[{_localName}::{script.Name}]: Item ({uniqueUUID}) is not in players Inventory!`)
		return false
	end

	-- Item is Invalid
	if not itemData then
		warn(`[{_localName}::{script.Name}]: ({itemId}) is not a valid itemId!`)
		return false
	end

	-- Item is Locked
	if table.find(inventoryData.Locked or {}, uniqueUUID) then
		return false
	end

	-- Missing `Use` Function
	if not itemData["Use"] or type(itemData["Use"]) ~= "function" then
		return false
	end

	--[[ Input Check ]]

	-- Invalid quantity input
	if quantity and (type(quantity) ~= "string" or not I.Number.IsIntegerString(quantity)) then
		warn(`[{_localName}::{script.Name}]: ({quantity}) is not a valid Quantity!`)
		return false
	end

	--[[ Quantity Check ]]

	--- @type BigNum_Instance
	local quantityBN

	-- Getting quantity
	if not useMax then
		quantityBN = quantity and I.BN.new(quantity) or I.BN.new("1")
	else
		quantityBN = I.BN.new(inventoryData.Unique[uniqueUUID].Metadata._q)
	end

	-- Invalid Quantity
	if not quantityBN or quantityBN <= zeroBN then
		warn(`[{_localName}::{script.Name}]: Quantity ({quantity}) cannot be less than or equal to (0)! | ({itemId})`)
		return false
	end

	-- Max Use Quantity
	if quantityBN > maxUseQuantity then
		quantityBN = I.BN.new(_settings.MAX_USE_QUANTITY)
	end

	local quantityText: string = tostring(quantityBN)

	--[[ Requirements ]]

	-- Check the item's requirements when it has them
	if itemData["UseRequirements"] then
		-- Running Requirements in pcall to avoid errors
		local success: boolean
		local result: any | string?
		success, result = pcall(itemData["UseRequirements"], player, quantityText)

		-- Return if not succeeded
		if not success or not result then
			-- Warn with the error of a failed call
			if type(result) == "string" then
				warn(`[{_localName}::{script.Name}]: Item ({itemId}) use failed! - {result}`)
			end

			return false
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Using

	--[[ Restore Data ]]

	local restoreId: string = inventoryData.Unique[uniqueUUID].Id
	local restoreMetadata = I.Table.DeepCopy(inventoryData.Unique[uniqueUUID].Metadata) --- @type Inventory_UniqueMetadata

	restoreMetadata._q = quantityText

	--[[ Removing ]]

	-- Take the quantity out quietly before running Use
	if not I.Inventory.RemoveUnique(player, uniqueUUID, quantityText, false) then
		return false
	end

	--[[ Using Item ]]

	-- Using in pcall to avoid errors
	local success: boolean
	local result: any | string?
	success, result = pcall(itemData["Use"], player, quantityText)

	-- Give the quantity back quietly when Use failed
	if not success or not result then
		-- Warn with the error of a failed call
		if type(result) == "string" then
			warn(`[{_localName}::{script.Name}]: Item ({itemId}) use failed! - {result}`)
		end

		-- Warn when the quantity could not be given back
		if not I.Inventory.AddUnique(player, uniqueUUID, { Id = restoreId, Metadata = restoreMetadata }, false) then
			warn(`[{_localName}::{script.Name}]: Failed to give back ({quantityText}) of ({uniqueUUID}) to ({player.Name}) after a failed use!`)
		end

		return false
	end

	--[[ Publishing ]]

	I.Topic.Publish("Inventory_UniqueRemoved", player, uniqueUUID, quantityText)
	I.Inventory.UpdateClientChanges(player, "Unique", { uniqueUUID })

	I.Topic.Publish("Inventory_ItemUsed", player, itemId, quantityText)
	I.Topic.Publish("Inventory_ItemUsed-Unique", player, uniqueUUID, quantityText)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
