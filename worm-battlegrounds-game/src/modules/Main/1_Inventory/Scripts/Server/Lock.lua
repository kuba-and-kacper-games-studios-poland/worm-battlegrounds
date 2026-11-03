--[[
    Created By: 	Nari
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

--- @class Inventory_Server_Lock
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Lock Item Client

--[[
	Locks item for a client request.
	The client can't turn off the Topic and the client update.
]]
--- @return boolean?
function Module.LockItem_Client(player: Player, itemId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Locking ]]

	return Module.LockItem(player, itemId, nil)
end

--%%%%%%%%%%%%%%%%%%%% Lock Item

--[[
	**SERVER** |
	Locks item for player.
]]
--- @return boolean?
function Module.LockItem(player: Player, itemId: string, sendUpdate: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	if not inventoryData.Locked then
		inventoryData.Locked = {}
	end

	--[[ Already Locked ]]

	if table.find(inventoryData.Locked, itemId) then
		return false
	end

	--[[ Item not in Inventory ]]

	if not inventoryData.Standard[itemId] and not inventoryData.Unique[itemId] then
		return false
	end

	--[[ Locking ]]

	table.insert(inventoryData.Locked, itemId)

	--[[ Updating ]]

	if sendUpdate == nil or sendUpdate == true then
		I.Topic.Publish("Inventory_ItemLocked", player, itemId)
		I.Inventory.UpdateClientData(player, "Locked")
	end

	return true
end

--%%%%%%%%%%%%%%%%%%%% Unlock Item Client

--[[
	Unlocks item for a client request.
	The client can't turn off the Topic and the client update.
]]
--- @return boolean?
function Module.UnlockItem_Client(player: Player, itemId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Unlocking ]]

	return Module.UnlockItem(player, itemId, nil)
end

--%%%%%%%%%%%%%%%%%%%% Unlock Item

--[[
	**SERVER** |
	Unlocks item for player.
]]
--- @return boolean?
function Module.UnlockItem(player: Player, itemId: string, sendUpdate: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--[[ Unlocking ]]

	local lockIndex: number? = table.find(inventoryData.Locked or {}, itemId)
	if not lockIndex then
		return false
	end
	table.remove(inventoryData.Locked, lockIndex)

	--[[ Updating ]]

	if sendUpdate == nil or sendUpdate == true then
		I.Topic.Publish("Inventory_ItemUnlocked", player, itemId)
		I.Inventory.UpdateClientData(player, "Locked")
	end

	return true
end

--%%%%%%%%%%%%%%%%%%%% Lock Switch Client

--[[
	Locks or unlocks item for a client request.
	The client can't turn off the Topic and the client update.
]]
--- @return boolean?
--- @return boolean?
function Module.LockSwitch_Client(player: Player, itemId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Switching ]]

	return Module.LockSwitch(player, itemId, nil)
end

--%%%%%%%%%%%%%%%%%%%% Lock Switch

--[[
	**SERVER** |
	Locks or unlocks item for player based on its current state.
]]
--- @return boolean?
--- @return boolean?
function Module.LockSwitch(player: Player, itemId: string, sendUpdate: boolean?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--[[ Lock Switch ]]

	if table.find(inventoryData.Locked or {}, itemId) then
		local success: boolean = Module.UnlockItem(player, itemId, sendUpdate)
		return success, false
	else
		local success: boolean = Module.LockItem(player, itemId, sendUpdate)
		return success, true
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Locked

--[[
	**SERVER** |
	Returns if item is locked.
]]
--- @return boolean?
function Module.IsLocked(player: Player, itemId: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return nil
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--[[ Returning ]]

	return table.find(inventoryData.Locked or {}, itemId) ~= nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
