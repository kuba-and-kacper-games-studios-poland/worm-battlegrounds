--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Inventory"

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

--- @class Inventory_Server_Transfer
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Transfer Item

--[[
	**SERVER** |
	Moves standard items from one player to another without yielding; the sender gets them back when the receiver can't take them.
	Unless `sendUpdate` is false, publishes the Removed and Added Topics for each side, then `Inventory_Transferred`.
]]
--- @return boolean
function Module.TransferItem(fromPlayer: Player, toPlayer: Player, itemId: string, quantity: string?, sendUpdate: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(fromPlayer) then
		return false
	end

	--[[ Checks ]]

	-- Check if the receiver is valid
	if not I.Player.Valid(toPlayer) then
		return false
	end

	-- Check if the players differ
	if fromPlayer == toPlayer then
		warn(`[{_localName}::{script.Name}]: Cannot transfer ({itemId}) from ({fromPlayer.Name}) to the same player!`)
		return false
	end

	--[[ Local Variables ]]

	local quantityText: string = quantity or "1"

	--[[ Moving ]]

	-- Take the items from the sender (fails when locked, not held, not enough or invalid)
	if not I.Inventory.RemoveItem(fromPlayer, itemId, quantityText, false) then
		return false
	end

	-- Give the items back to the sender when the receiver can't take them
	if not I.Inventory.AddItem(toPlayer, itemId, quantityText, false) then
		-- Warn when the sender can't get them back either
		if not I.Inventory.AddItem(fromPlayer, itemId, quantityText, false) then
			warn(`[{_localName}::{script.Name}]: Failed to give back ({quantityText}) ({itemId}) to ({fromPlayer.Name}) after a failed transfer!`)
		end

		return false
	end

	--[[ Publishing ]]

	-- Publish and update both clients unless sendUpdate is false
	if sendUpdate == nil or sendUpdate == true then
		I.Topic.Publish("Inventory_ItemRemoved", fromPlayer, itemId, quantityText)
		I.Topic.Publish("Inventory_ItemAdded", toPlayer, itemId, quantityText)
		I.Topic.Publish("Inventory_Transferred", fromPlayer, toPlayer, itemId, quantityText, itemId)

		I.Inventory.UpdateClientChanges(fromPlayer, "Standard", { itemId })
		I.Inventory.UpdateClientChanges(toPlayer, "Standard", { itemId })
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Transfer Unique

--[[
	**SERVER** |
	Moves a unique item, or part of its quantity, from one player to another without yielding, keeping its `_cts` and `_fo`.\
	Returns the UUID the receiver holds it under. Publishes like `TransferItem`.
]]
--- @return boolean
--- @return string?
function Module.TransferUnique(fromPlayer: Player, toPlayer: Player, uniqueUUID: string, quantity: string?, sendUpdate: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(fromPlayer) then
		return false
	end

	--[[ Checks ]]

	-- Check if the receiver is valid
	if not I.Player.Valid(toPlayer) then
		return false
	end

	-- Check if the players differ
	if fromPlayer == toPlayer then
		warn(`[{_localName}::{script.Name}]: Cannot transfer ({uniqueUUID}) from ({fromPlayer.Name}) to the same player!`)
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local fromInventoryData = I.Player.GetProfile(fromPlayer, "Inventory").Data

	--- @type Inventory_UniqueItem
	local uniqueData = fromInventoryData.Unique[uniqueUUID]

	--[[ Checks ]]

	-- Item is not in the Inventory
	if not uniqueData then
		warn(`[{_localName}::{script.Name}]: Item ({uniqueUUID}) is not in ({fromPlayer.Name})'s Inventory!`)
		return false
	end

	--[[ Transfer Data ]]

	local quantityText: string = quantity and `{quantity}` or uniqueData.Metadata._q
	local transferData = { Id = uniqueData.Id, Metadata = I.Table.DeepCopy(uniqueData.Metadata) } --- @type Inventory_UniqueItem

	transferData.Metadata._q = quantityText

	--[[ Moving ]]

	-- Take the quantity from the sender (fails when locked, not enough or invalid)
	if not I.Inventory.RemoveUnique(fromPlayer, uniqueUUID, quantityText, false) then
		return false
	end

	local success: boolean
	local newUniqueUUID: string?
	success, newUniqueUUID = I.Inventory.AddUnique(toPlayer, uniqueUUID, transferData, false)

	-- Give the quantity back to the sender when the receiver can't take it
	if not success then
		-- Warn when the sender can't get it back either
		if not I.Inventory.AddUnique(fromPlayer, uniqueUUID, transferData, false) then
			warn(`[{_localName}::{script.Name}]: Failed to give back ({quantityText}) of ({uniqueUUID}) to ({fromPlayer.Name}) after a failed transfer!`)
		end

		return false
	end

	--[[ Publishing ]]

	-- Publish and update both clients unless sendUpdate is false
	if sendUpdate == nil or sendUpdate == true then
		I.Topic.Publish("Inventory_UniqueRemoved", fromPlayer, uniqueUUID, quantityText)
		I.Topic.Publish("Inventory_UniqueAdded", toPlayer, newUniqueUUID)
		I.Topic.Publish("Inventory_Transferred", fromPlayer, toPlayer, uniqueUUID, quantityText, newUniqueUUID)

		I.Inventory.UpdateClientChanges(fromPlayer, "Unique", { uniqueUUID })
		I.Inventory.UpdateClientChanges(toPlayer, "Unique", { newUniqueUUID })
	end

	--[[ Returning ]]

	return true, newUniqueUUID
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
