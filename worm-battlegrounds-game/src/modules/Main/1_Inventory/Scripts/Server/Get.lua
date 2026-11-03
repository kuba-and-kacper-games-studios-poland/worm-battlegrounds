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

--- @class Inventory_Server_Get
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Methods

--%%%%%%%%%%%%%%%%%%%% Get Item

--[[
	**SERVER** |
	Returns quantity of the `itemId` that player has.
]]
--- @return string?
function Module.GetItem(player: Player, itemId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--[[ Returning ]]

	return inventoryData.Standard[itemId]
end

--%%%%%%%%%%%%%%%%%%%% Get Unique

--[[
	**SERVER** |
	Returns `uniqueUUID` item data table from player's inventory.
]]
--- @return Inventory_UniqueItem?
function Module.GetUnique(player: Player, uniqueUUID: string, clonedData: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--[[ Returning ]]

	return clonedData and I.Table.DeepCopy(inventoryData.Unique[uniqueUUID]) or inventoryData.Unique[uniqueUUID]
end

--%%%%%%%%%%%%%%%%%%%% Get Inventory

--[[
	**SERVER** |
	Returns player inventory data or specified type data.
]]
--- @param dataType Inventory_DataType?
--- @return Inventory_Data?
function Module.GetInventory(player: Player, dataType, clonedData: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--[[ Returning Inventory ]]

	if inventoryData[dataType] ~= nil then
		return clonedData and I.Table.DeepCopy(inventoryData[dataType]) or inventoryData[dataType]
	else
		return clonedData and I.Table.DeepCopy(inventoryData) or inventoryData
	end
end

--%%%%%%%%%%%%%%%%%%%% Has Item

--[[
	Returns whether player holds at least `quantity` (1 by default) of a standard item id or a unique UUID.
]]
--- @return boolean
function Module.HasItem(player: Player, itemId: string, quantity: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	-- Invalid quantity input
	if quantity and (type(quantity) ~= "string" or not I.Number.IsIntegerString(quantity)) then
		warn(`[{_localName}::{script.Name}]: ({quantity}) is not a valid Quantity!`)
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--- @type Inventory_UniqueItem?
	local uniqueData = inventoryData.Unique[itemId]

	--[[ Local Variables ]]

	local heldQuantity: string? = inventoryData.Standard[itemId] or (uniqueData and uniqueData.Metadata._q)

	--[[ Checks ]]

	-- Check if the item is held at all
	if not heldQuantity then
		return false
	end

	--[[ Returning ]]

	return I.BN.new(heldQuantity) >= I.BN.new(quantity or "1")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
