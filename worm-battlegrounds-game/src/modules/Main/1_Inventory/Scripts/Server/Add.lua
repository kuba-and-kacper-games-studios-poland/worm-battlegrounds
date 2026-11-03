--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Inventory"

--- @type Inventory_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local HttpService = I.S.HttpService

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

--- @class Inventory_Server_Add
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Standard Item Control

--%%%%%%%%%%%%%%%%%%%% Add Item

--[[
	**SERVER** |
	Adds item to player's inventory.
]]
--- @return boolean
function Module.AddItem(player: Player, itemId: string, quantity: string?, sendUpdate: boolean?)
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

	--[[ Input Check ]]

	-- Invalid quantity input
	if quantity and (type(quantity) ~= "string" or not I.Number.IsIntegerString(quantity)) then
		warn(`[{_localName}::{script.Name}]: ({quantity}) is not a valid Quantity!`)
		return false
	end

	--[[ Quantity Check ]]

	--- @type BigNum_Instance
	local quantityBN = quantity and I.BN.new(quantity) or I.BN.new("1")

	-- Invalid quantity
	if quantityBN <= zeroBN then
		warn(`[{_localName}::{script.Name}]: Quantity ({quantity}) cannot be less than or equal to (0)! | ({itemId})`)
		return false
	end

	--%%%%%%%%%%%%%%%%%%%% Adding

	--[[ Adding Item ]]

	-- Add to the held quantity, or start a new entry
	if inventoryData.Standard[itemId] then
		--[[ Getting Quantity ]]

		local currentBN = I.BN.new(inventoryData.Standard[itemId]) --- @type BigNum_Instance
		local totalBN = currentBN + quantityBN --- @type BigNum_Instance

		--[[ Updating Quantity ]]

		inventoryData.Standard[itemId] = tostring(totalBN)
	else
		--[[ New Item ]]

		inventoryData.Standard[itemId] = tostring(quantityBN)
	end

	--[[ Updating Client ]]

	-- Publish and update the client unless sendUpdate is false
	if sendUpdate == nil or sendUpdate == true then
		I.Topic.Publish("Inventory_ItemAdded", player, itemId, tostring(quantityBN))
		I.Inventory.UpdateClientChanges(player, "Standard", { itemId })
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Add Item Bulk

--[[
	**SERVER** |
	Adds items in bulk to player's inventory.
	Publishes and returns only what was actually added.
]]
--- @param itemsToAdd { [string]: string | number }
--- @return boolean
function Module.AddItemBulk(player: Player, itemsToAdd)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Local Variables ]]

	local added = {} --- @type { [string]: string }
	local addedIds = {} --- @type { string }

	--[[ Adding Items ]]

	for itemId: string, quantity: string | number in pairs(itemsToAdd) do
		local quantityStr: string = tostring(quantity)

		-- Keep only the items that were added
		if Module.AddItem(player, itemId, quantityStr, false) then
			added[itemId] = quantityStr
			table.insert(addedIds, itemId)
		end
	end

	--[[ Checks ]]

	-- Check if anything was added
	if next(added) == nil then
		return false
	end

	--[[ Updating Client ]]

	I.Topic.Publish("Inventory_BulkAdded", player, added)
	I.Inventory.UpdateClientChanges(player, "Standard", addedIds)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Unique Item Control

--%%%%%%%%%%%%%%%%%%%% Add Unique

--[[
	**SERVER** |
	Adds existing unique item to player's inventory (a trade, a transfer, a restore), keeping its `_cts` and `_fo`.\
	Returns UUID that was used for the Item.
]]
--- @param uniqueData Inventory_UniqueItem
--- @return boolean
--- @return string?
function Module.AddUnique(player: Player, uniqueUUID: string, uniqueData, sendUpdate: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--%%%%%%%%%%%%%%%%%%%% Checks

	--[[ General ]]

	-- Item is Invalid
	if not uniqueData.Id or not I.G_Inventory.Items[uniqueData.Id] then
		warn(`[{_localName}::{script.Name}]: ({uniqueData.Id}) is not a valid itemId!`)
		return false
	end

	-- Missing Metadata
	if not uniqueData.Metadata or type(uniqueData.Metadata) ~= "table" then
		warn(`[{_localName}::{script.Name}]: ({uniqueUUID}) is not a valid Metadata!`)
		return false
	end

	--[[ Input Check ]]

	local quantity: string = `{uniqueData.Metadata._q or "1"}`

	-- Invalid quantity input
	if not I.Number.IsIntegerString(quantity) then
		warn(`[{_localName}::{script.Name}]: ({quantity}) is not a valid Quantity!`)
		return false
	end

	--[[ Quantity Check ]]

	--- @type BigNum_Instance
	local quantityBN = I.BN.new(quantity)

	-- Invalid quantity
	if quantityBN <= zeroBN then
		warn(`[{_localName}::{script.Name}]: Quantity ({quantity}) cannot be less than or equal to (0)! | ({uniqueUUID})`)
		return false
	end

	--%%%%%%%%%%%%%%%%%%%% Adding

	local newUniqueUUID: string = uniqueUUID

	--[[ Adding Unique ]]

	--- @type Inventory_UniqueItem
	local existingUnique = inventoryData.Unique[uniqueUUID]

	-- Check if an entry already uses this UUID
	if existingUnique then
		--[[ Unique Variables ]]

		local sameTimestamp: boolean = existingUnique.Metadata._cts == uniqueData.Metadata._cts
		local sameOwner: boolean = existingUnique.Metadata._fo == uniqueData.Metadata._fo

		--[[
			Unique Item Already Exists
		]]

		-- Merge into the entry when it is the same unique
		if sameTimestamp and sameOwner then
			--[[ Getting Quantity ]]

			--- @type BigNum_Instance
			local currentBN = I.BN.new(existingUnique.Metadata._q)

			--- @type BigNum_Instance
			local finalBN = currentBN + quantityBN

			--[[ Updating Quantity ]]

			existingUnique.Metadata._q = tostring(finalBN)
		else
			--[[
				Different identity under the same UUID — create a new Unique
			]]

			existingUnique = nil
		end
	end

	--[[ New Unique ]]

	-- Create a new entry when nothing was merged
	if not existingUnique then
		-- Creating new Unique
		local success: boolean
		success, newUniqueUUID = Module.CreateUnique(player, uniqueData.Id, uniqueUUID, uniqueData.Metadata, false)

		-- Creating failed
		if not success then
			return false
		end
	end

	--[[ Updating Client ]]

	-- Publish and update the client unless sendUpdate is false
	if sendUpdate == nil or sendUpdate == true then
		I.Topic.Publish("Inventory_UniqueAdded", player, newUniqueUUID)
		I.Inventory.UpdateClientChanges(player, "Unique", { newUniqueUUID })
	end

	--[[ Returning ]]

	return true, newUniqueUUID
end

--%%%%%%%%%%%%%%%%%%%% Create Unique

--[[
	**SERVER** |
	Creates new unique item in player's inventory from a copy of `metadata`; `_cts` and `_fo` are set only when missing.\
	Returns UUID that was used for the Item.
]]
--- @param metadata Inventory_UniqueMetadata?
--- @return boolean
--- @return string?
function Module.CreateUnique(player: Player, itemId: string, setUUID: string?, metadata, sendUpdate: boolean?)
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

	-- Unique Inventory capacity
	if (_settings.MAX_UNIQUE_ITEMS - inventoryData.UniqueAmount) < _settings.RECOUNT_MARGIN then
		-- Recounting
		I.Inventory.RecountUniques(player)

		-- Limit Reached!
		if inventoryData.UniqueAmount >= _settings.MAX_UNIQUE_ITEMS then
			return false
		end
	end

	--[[ Copying Metadata ]]

	--- @type Inventory_UniqueMetadata
	local finalMetadata = {}

	-- Copy the caller's metadata so its table is never stored or changed
	if type(metadata) == "table" then
		finalMetadata = I.Table.DeepCopy(metadata)
	end

	--[[ Input Check ]]

	-- Check the quantity when one is given
	if finalMetadata._q then
		-- Making sure it's always a string
		finalMetadata._q = `{finalMetadata._q}`

		-- Invalid quantity input
		if type(finalMetadata._q) ~= "string" or not I.Number.IsIntegerString(finalMetadata._q) then
			warn(`[{_localName}::{script.Name}]: ({finalMetadata._q}) is not a valid Quantity!`)
			finalMetadata._q = "1"
		end
	end

	--[[ Quantity Check ]]

	-- Check the quantity when one is given
	if finalMetadata._q then
		--- @type BigNum_Instance
		local quantityBN = I.BN.new(finalMetadata._q)

		-- Invalid quantity
		if quantityBN <= zeroBN then
			warn(`[{_localName}::{script.Name}]: Quantity ({finalMetadata._q}) cannot be less than or equal to (0)! | ({itemId})`)
			finalMetadata._q = "1"
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Creating Data

	--[[ Generating UUID ]]

	local newUniqueUUID: string = setUUID and `{setUUID}`

	-- Generate a free UUID when none was given or it is taken
	if not newUniqueUUID or inventoryData.Unique[newUniqueUUID] then
		repeat
			newUniqueUUID = HttpService:GenerateGUID(false)
		until inventoryData.Unique[newUniqueUUID] == nil
	end

	--[[ Creating Metadata ]]

	-- Quantity
	finalMetadata._q = `{finalMetadata._q or "1"}`

	-- Stamp the creation time unless the unique already has one
	if finalMetadata._cts == nil then
		finalMetadata._cts = os.time()
	end

	-- Stamp the first owner unless the unique already has one
	if finalMetadata._fo == nil then
		finalMetadata._fo = player.UserId
	end

	--%%%%%%%%%%%%%%%%%%%% Adding Item

	--[[ Adding to Inventory ]]

	inventoryData.Unique[newUniqueUUID] = {
		Id = itemId,
		Metadata = finalMetadata,
	}
	inventoryData.UniqueAmount += 1

	--[[ Updating Client ]]

	-- Publish and update the client unless sendUpdate is false
	if sendUpdate == nil or sendUpdate == true then
		I.Topic.Publish("Inventory_UniqueCreated", player, newUniqueUUID)
		I.Inventory.UpdateClientChanges(player, "Unique", { newUniqueUUID })
	end

	--[[ Returning ]]

	return true, newUniqueUUID
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
