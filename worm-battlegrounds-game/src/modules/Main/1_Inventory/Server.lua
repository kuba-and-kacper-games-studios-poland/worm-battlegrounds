--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Inventory"

--- @type Inventory_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Add = require(_scripts:FindFirstChild("Server"):FindFirstChild("Add")) --- @type Inventory_Server_Add
local Remove = require(_scripts:FindFirstChild("Server"):FindFirstChild("Remove")) --- @type Inventory_Server_Remove
local Get = require(_scripts:FindFirstChild("Server"):FindFirstChild("Get")) --- @type Inventory_Server_Get
local Unique = require(_scripts:FindFirstChild("Server"):FindFirstChild("Unique")) --- @type Inventory_Server_Unique
local Lock = require(_scripts:FindFirstChild("Server"):FindFirstChild("Lock")) --- @type Inventory_Server_Lock
local Use = require(_scripts:FindFirstChild("Server"):FindFirstChild("Use")) --- @type Inventory_Server_Use
local Transfer = require(_scripts:FindFirstChild("Server"):FindFirstChild("Transfer")) --- @type Inventory_Server_Transfer

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Rate Limits ]]

local actionLimit = { RateLimit = 10, Per = 1 } --- @type Network_RemoteOptions
local readLimit = { RateLimit = 20, Per = 1 } --- @type Network_RemoteOptions
local bulkLimit = { RateLimit = 2, Per = 1 } --- @type Network_RemoteOptions
local fullUpdateLimit = { RateLimit = 5, Per = 5 } --- @type Network_RemoteOptions

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
	----------- DATA -----------
	----------------------------

	--- @type Player_ProfileData_Inventory
	local _pt = I.Player.RegisterProfile("Inventory", {
		Standard = {}, --- @type { [string]: number }
		Unique = {}, --- @type { [string]: Inventory_UniqueItem }
		Locked = {}, --- @type { string }

		UniqueAmount = 0,
	})

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.Setup, Module.UpdateClientData)
	I.G_Player.OnPlayerAdded(I.Priority.Data, Unique.RecountUniques)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic

	--[[ Added Topics ]]

	I.Topic.Register("Inventory_ItemAdded", { "Player", "string", "string" })
	I.Topic.Register("Inventory_BulkAdded", { "Player", { Type = "table" } })

	I.Topic.Register("Inventory_UniqueAdded", { "Player", "string" })
	I.Topic.Register("Inventory_UniqueCreated", { "Player", "string" })

	--[[ Removed Topics ]]

	I.Topic.Register("Inventory_ItemRemoved", { "Player", "string", "string" })
	I.Topic.Register("Inventory_UniqueRemoved", { "Player", "string", { Type = "string", Optional = true } })
	I.Topic.Register("Inventory_BulkRemoved", { "Player", { Type = "table" } })

	--[[ Lock Topics ]]

	I.Topic.Register("Inventory_ItemLocked", { "Player", "string" })
	I.Topic.Register("Inventory_ItemUnlocked", { "Player", "string" })

	--[[ Use Topics ]]

	I.Topic.Register("Inventory_ItemUsed", { "Player", "string", "string" })
	I.Topic.Register("Inventory_ItemUsed-Standard", { "Player", "string", "string" })
	I.Topic.Register("Inventory_ItemUsed-Unique", { "Player", "string", "string" })

	--[[ Transfer Topics ]]

	I.Topic.Register("Inventory_Transferred", { "Player", "Player", "string", "string", "string" })

	--- @Network

	--[[ Remove Control ]]

	I.Network.GetFunction("Inventory_RemoveItem", { "Player", "string", { Type = "BigNum", Optional = true, Min = "1" }, { Type = "boolean", Optional = true } }, actionLimit)
	I.Network.GetFunction("Inventory_RemoveUnique", { "Player", "string", { Type = "BigNum", Optional = true, Min = "1" }, { Type = "boolean", Optional = true } }, actionLimit)
	I.Network.GetEvent("Inventory_RemoveBulk", { "Player", { Type = "table" } }, bulkLimit)
	I.Network.OnInvoke("Inventory_RemoveItem", Remove.RemoveItem_Client)
	I.Network.OnInvoke("Inventory_RemoveUnique", Remove.RemoveUnique_Client)
	I.Network.Fired("Inventory_RemoveBulk", Remove.RemoveBulk_Client)

	--[[ Get Control ]]

	I.Network.GetFunction("Inventory_GetItem", { "Player", "string" }, readLimit)
	I.Network.GetFunction("Inventory_GetUnique", { "Player", "string", { Type = "boolean", Optional = true } }, readLimit)
	I.Network.OnInvoke("Inventory_GetItem", Get.GetItem)
	I.Network.OnInvoke("Inventory_GetUnique", Get.GetUnique)

	--[[ Lock Control ]]

	I.Network.GetFunction("Inventory_LockItem", { "Player", "string", { Type = "boolean", Optional = true } }, actionLimit)
	I.Network.GetFunction("Inventory_UnlockItem", { "Player", "string", { Type = "boolean", Optional = true } }, actionLimit)
	I.Network.GetFunction("Inventory_LockSwitch", { "Player", "string", { Type = "boolean", Optional = true } }, actionLimit)
	I.Network.GetFunction("Inventory_IsLocked", { "Player", "string" }, readLimit)
	I.Network.OnInvoke("Inventory_LockItem", Lock.LockItem_Client)
	I.Network.OnInvoke("Inventory_UnlockItem", Lock.UnlockItem_Client)
	I.Network.OnInvoke("Inventory_LockSwitch", Lock.LockSwitch_Client)
	I.Network.OnInvoke("Inventory_IsLocked", Lock.IsLocked)

	--[[ Use Control ]]

	I.Network.GetFunction("Inventory_UseItem", { "Player", "string", { Type = "BigNum", Optional = true, Min = "1", Max = tostring(_settings.MAX_USE_QUANTITY) }, { Type = "boolean", Optional = true } }, actionLimit)
	I.Network.GetFunction("Inventory_UseUnique", { "Player", "string", { Type = "BigNum", Optional = true, Min = "1", Max = tostring(_settings.MAX_USE_QUANTITY) }, { Type = "boolean", Optional = true } }, actionLimit)
	I.Network.OnInvoke("Inventory_UseItem", Use.UseItem_Client)
	I.Network.OnInvoke("Inventory_UseUnique", Use.UseUnique_Client)

	--[[ Data Events ]]

	I.Network.GetEvent("Inventory_RequestUpdate", { "Player", { Type = "string", Optional = true } }, fullUpdateLimit)
	I.Network.Fired("Inventory_RequestUpdate", Module.UpdateClientData)

	I.Network.GetEvent("Inventory_UpdateClientData")
	I.Network.GetEvent("Inventory_UpdateClientChanges")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Inventory = {

		--[[ Standard Control ]]

		AddItem = Add.AddItem,
		AddItemBulk = Add.AddItemBulk,
		RemoveItem = Remove.RemoveItem,

		--[[ Unique Control ]]

		AddUnique = Add.AddUnique,
		CreateUnique = Add.CreateUnique,
		RemoveUnique = Remove.RemoveUnique,

		--[[ Other Control ]]

		RemoveBulk = Remove.RemoveBulk,

		-- Lock
		LockItem = Lock.LockItem,
		UnlockItem = Lock.UnlockItem,
		LockSwitch = Lock.LockSwitch,

		-- Use
		UseItem = Use.UseItem,
		UseUnique = Use.UseUnique,

		-- Transfer
		TransferItem = Transfer.TransferItem,
		TransferUnique = Transfer.TransferUnique,

		--[[ Methods ]]

		-- Get
		GetItem = Get.GetItem,
		GetUnique = Get.GetUnique,
		GetInventory = Get.GetInventory,
		HasItem = Get.HasItem,

		-- Lock
		IsLocked = Lock.IsLocked,

		-- Other
		HasEnoughUniqueInventorySpace = Unique.HasEnoughUniqueInventorySpace,
		RecountUniques = Unique.RecountUniques,
		UpdateClientData = Module.UpdateClientData,
		UpdateClientChanges = Module.UpdateClientChanges,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data Update

--%%%%%%%%%%%%%%%%%%%% Update Client Data

--[[
	**SERVER** |
	Sends Inventory data to player.
]]
--- @param dataType Inventory_DataType?
--- @return boolean
function Module.UpdateClientData(player: Player, dataType)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--[[ Sending Data ]]

	if inventoryData[dataType] ~= nil then
		I.Network.Fire("Inventory_UpdateClientData", player, dataType, inventoryData[dataType])

		-- Unique: Additional update to match the unique amount
		if dataType == "Unique" then
			I.Network.Fire("Inventory_UpdateClientData", player, "UniqueAmount", inventoryData.UniqueAmount)
		end
	else
		--- @param dataTable Inventory_NetworkData
		for loopDataType: string, dataTable in pairs(inventoryData) do
			I.Network.Fire("Inventory_UpdateClientData", player, loopDataType, dataTable)
		end
	end

	return true
end

--%%%%%%%%%%%%%%%%%%%% Update Client Changes

--[[
	**SERVER** |
	Sends only the given Standard item ids or Unique UUIDs to player, as they are saved now (`false` when removed).
	A Unique update also sends the new unique count.
]]
--- @param dataType Inventory_DataType
--- @param ids { string }
--- @return boolean
function Module.UpdateClientChanges(player: Player, dataType, ids)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--[[ Building ]]

	--- @type Inventory_NetworkChanges
	local changes = {}

	for _index: number, id: string in ipairs(ids) do
		changes[id] = inventoryData[dataType][id] or false
	end

	--[[ Sending Data ]]

	I.Network.Fire("Inventory_UpdateClientChanges", player, dataType, changes)

	-- Unique: Additional update to match the unique amount
	if dataType == "Unique" then
		I.Network.Fire("Inventory_UpdateClientData", player, "UniqueAmount", inventoryData.UniqueAmount)
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
