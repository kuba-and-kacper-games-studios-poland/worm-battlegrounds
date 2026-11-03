--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Inventory"

--- @type Inventory_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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

--- @class Inventory_Server_Unique
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Unique Methods

--%%%%%%%%%%%%%%%%%%%% Recount Uniques

--[[
	**SERVER** |
	Counts the number of unique items that player has.
]]
function Module.RecountUniques(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--[[ Calculating ]]

	local totalAmount: number = 0
	--- @param _uniqueData Inventory_UniqueItem
	for _uniqueUUID: string, _uniqueData in pairs(inventoryData.Unique) do
		totalAmount += 1
	end

	--[[ Saving ]]

	inventoryData.UniqueAmount = totalAmount
end

--%%%%%%%%%%%%%%%%%%%% Has Enough Unique Inventory Space

--[[
	**SERVER** |
	Checks if player has enough unique inventory space in his inventory.
]]
--- @return boolean
function Module.HasEnoughUniqueInventorySpace(player: Player, quantity: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Checks ]]

	if type(quantity) ~= "string" or not I.Number.IsIntegerString(quantity) then
		warn(`[{_localName}::{script.Name}]: ({quantity}) is not a valid Quantity!`)
		return false
	end

	local amountBN = I.BN.new(quantity)
	if amountBN <= zeroBN then
		warn(`[{_localName}::{script.Name}]: Quantity ({quantity}) cannot be less than or equal to (0)!`)
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--[[ Recount Near Margin ]]

	if (_settings.MAX_UNIQUE_ITEMS - inventoryData.UniqueAmount) < _settings.RECOUNT_MARGIN then
		Module.RecountUniques(player)
	end

	--[[ Check Uniques Amount ]]

	local maxUniqueBN = I.BN.new(tostring(_settings.MAX_UNIQUE_ITEMS))
	local currentUniqueBN = I.BN.new(tostring(inventoryData.UniqueAmount))
	if currentUniqueBN + amountBN > maxUniqueBN then
		return false
	end

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
