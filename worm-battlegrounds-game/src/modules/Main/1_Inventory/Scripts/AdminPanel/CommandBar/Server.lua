--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Inventory"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ BigNum ]]

local zeroBN = I.BN.new("0")

--[[ Dictionaries ]]

local DICTIONARY_REBUILD_DELAY: number = 1
local pendingRebuilds = {} --- @type { [Player]: boolean }

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

--- @class Inventory_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.Late, Module._updateCommandDictionariesForPlayer)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic

	--[[ Added Topics ]]

	I.Topic.Subscribe("Inventory_ItemAdded", function(player: Player, _itemId: string, _quantity: string)
		Module._queueCommandDictionariesUpdate(player)
	end)
	I.Topic.Subscribe("Inventory_BulkAdded", function(player: Player, _addedItems: table)
		Module._queueCommandDictionariesUpdate(player)
	end)

	I.Topic.Subscribe("Inventory_UniqueAdded", function(player: Player, _uniqueUUID: string)
		Module._queueCommandDictionariesUpdate(player)
	end)
	I.Topic.Subscribe("Inventory_UniqueCreated", function(player: Player, _uniqueUUID: string)
		Module._queueCommandDictionariesUpdate(player)
	end)

	--[[ Removed Topics ]]

	I.Topic.Subscribe("Inventory_ItemRemoved", function(player: Player, _itemId: string, _quantity: string)
		Module._queueCommandDictionariesUpdate(player)
	end)
	I.Topic.Subscribe("Inventory_UniqueRemoved", function(player: Player, _uniqueUUID: string, _quantity: string?)
		Module._queueCommandDictionariesUpdate(player)
	end)
	I.Topic.Subscribe("Inventory_BulkRemoved", function(player: Player, _removedItems: table)
		Module._queueCommandDictionariesUpdate(player)
	end)

	--[[ Lock Topics ]]

	I.Topic.Subscribe("Inventory_ItemLocked", function(player: Player, _itemId: string)
		Module._queueCommandDictionariesUpdate(player)
	end)
	I.Topic.Subscribe("Inventory_ItemUnlocked", function(player: Player, _itemId: string)
		Module._queueCommandDictionariesUpdate(player)
	end)

	Module._registerCommands()
	Module._registerCommandDictionaries()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Item Control Functions - Standard

	local function addStandard(player: Player, itemId: string, quantity: string?)
		--[[ Checks ]]

		if not I.G_Inventory.Items[itemId] then
			return false, `Invalid ItemId: $|cr$|{itemId}#|`
		end

		local quantityBN = quantity and I.BN.new(quantity) or I.BN.new("1")
		if quantityBN <= zeroBN then
			return false, `Invalid Quantity: $|cr$|{quantity}#| cannot be less than or equal to $|cr$|0#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Inventory.AddItem(player, itemId, quantity, true)

		-- Returning
		if value then
			return true, `Added $|cr$|x{quantity or "1"}#| $|cr$|{itemId}#| to $|cr$|{player.Name}#|'s Inventory`
		else
			return false, `Failed to add $|cr$|x{quantity or "1"}#| $|cr$|{itemId}#| to $|cr$|{player.Name}#|'s Inventory`
		end
	end

	local function removeStandard(player: Player, itemId: string, quantity: string?)
		--[[ Checks ]]

		if not I.Inventory.GetItem(player, itemId) then
			return false, `Item $|cr$|{itemId}#| is not in $|cr$|{player.Name}#|'s Inventory`
		end

		local quantityBN = quantity and I.BN.new(quantity) or I.BN.new("1")
		if quantityBN <= zeroBN then
			return false, `Invalid Quantity: $|cr$|{quantity}#| cannot be less than or equal to $|cr$|0#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Inventory.RemoveItem(player, itemId, quantity, true)

		-- Returning
		if value then
			return true, `Removed $|cr$|x{quantity or "1"}#| $|cr$|{itemId}#| from $|cr$|{player.Name}#|'s Inventory`
		else
			return false, `Failed to remove $|cr$|x{quantity or "1"}#| $|cr$|{itemId}#| from $|cr$|{player.Name}#|'s Inventory`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Item Control Functions - Unique

	local function addUnique(player: Player, uniqueUUID: string, quantity: string?)
		--[[ Data ]]

		--- @type Inventory_UniqueItem
		local existingItem = I.Inventory.GetUnique(player, uniqueUUID)

		--[[ Checks ]]

		if not existingItem then
			return false, `Item $|cr$|{uniqueUUID}#| is not in $|cr$|{player.Name}#|'s Inventory`
		end

		local quantityBN = quantity and I.BN.new(quantity) or I.BN.new("1")
		if quantityBN <= zeroBN then
			return false, `Invalid Quantity: $|cr$|{quantity}#| cannot be less than or equal to $|cr$|0#|`
		end

		--[[ Getting Data ]]

		--- @type Inventory_UniqueMetadata
		local newMetadata = {
			-- Quantity
			_q = quantity or "1",

			-- Copying other info
			_cts = existingItem.Metadata._cts,
			_fo = existingItem.Metadata._fo,
		}

		--[[ Executing ]]

		-- Getting value
		local value: boolean, newUUID: string = I.Inventory.AddUnique(player, uniqueUUID, {
			Id = existingItem.Id,
			Metadata = newMetadata,
		}, true)

		-- Returning
		if value then
			if uniqueUUID == newUUID then
				return true, `Added $|cr$|x{quantity or "1"}#| to Unique Item $|cr$|{existingItem.Id}#| (UUID: $|cr$|{uniqueUUID}#|) for $|cr$|{player.Name}#|`
			else
				return true, `Created Unique Item $|cr$|{existingItem.Id}#| (UUID: $|cr$|{newUUID}#|) for $|cr$|{player.Name}#| because identity did not match`
			end
		else
			return false, `Failed to add $|cr$|x{quantity or "1"}#| to Unique Item $|cr$|{existingItem.Id}#| (UUID: $|cr$|{uniqueUUID}#|) for $|cr$|{player.Name}#|`
		end
	end

	local function createUnique(player: Player, itemId: string, setUUID: string?, quantity: string?)
		--[[ Checks ]]

		if not I.G_Inventory.Items[itemId] then
			return false, `Invalid ItemId: $|cr$|{itemId}#|`
		end

		local quantityBN = quantity and I.BN.new(quantity) or I.BN.new("1")
		if quantityBN <= zeroBN then
			return false, `Invalid Quantity: $|cr$|{quantity}#| cannot be less than or equal to $|cr$|0#|`
		end

		if setUUID and I.Inventory.GetUnique(player, setUUID) then
			return false, `Item $|cr$|{setUUID}#| already exists in $|cr$|{player.Name}#|'s Inventory`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean, newUUID: string = I.Inventory.CreateUnique(player, itemId, setUUID, {
			_q = quantity or "1",
		}, true)

		-- Returning
		if value then
			return true, `Created Unique Item $|cr$|{itemId}#| (UUID: $|cr$|{newUUID}#|) $|cr$|x{quantity or "1"}#| for $|cr$|{player.Name}#|`
		else
			return false, `Failed to create Unique Item $|cr$|{itemId}#| for $|cr$|{player.Name}#|`
		end
	end

	local function removeUnique(player: Player, uniqueUUID: string, quantity: string?)
		--[[ Data ]]

		--- @type Inventory_UniqueItem
		local existingItem = I.Inventory.GetUnique(player, uniqueUUID)

		--[[ Checks ]]

		if not existingItem then
			return false, `Unique Item $|cr$|{uniqueUUID}#| is not in $|cr$|{player.Name}#|'s Inventory`
		end

		local quantityBN = quantity and I.BN.new(quantity) or I.BN.new("1")
		if quantityBN <= zeroBN then
			return false, `Invalid Quantity: $|cr$|{quantity}#| cannot be less than or equal to $|cr$|0#|`
		end

		--[[ Getting Data ]]

		local itemId: string = existingItem.Id
		local removeQuantity: string = quantity or existingItem.Metadata._q

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Inventory.RemoveUnique(player, uniqueUUID, quantity, true)

		-- Returning
		if value then
			return true, `Removed $|cr$|x{removeQuantity}#| $|cr$|{itemId}#| (UUID: $|cr$|{uniqueUUID}#|) from $|cr$|{player.Name}#|'s Inventory`
		else
			return false, `Failed to remove $|cr$|x{removeQuantity}#| $|cr$|{itemId}#| (UUID: $|cr$|{uniqueUUID}#|) from $|cr$|{player.Name}#|'s Inventory`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Lock Control Functions

	local function lock(player: Player, itemId: string)
		--[[ Checks ]]

		if not I.Inventory.GetItem(player, itemId) and not I.Inventory.GetUnique(player, itemId) then
			return false, `Item $|cr$|{itemId}#| is not in $|cr$|{player.Name}#|'s Inventory`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Inventory.LockItem(player, itemId, true)

		-- Returning
		if value then
			return true, `Locked Item $|cr$|{itemId}#| for $|cr$|{player.Name}#|`
		else
			return false, `Failed to lock Item $|cr$|{itemId}#| for $|cr$|{player.Name}#|`
		end
	end

	local function unlock(player: Player, itemId: string)
		--[[ Checks ]]

		if not I.Inventory.GetItem(player, itemId) and not I.Inventory.GetUnique(player, itemId) then
			return false, `Item $|cr$|{itemId}#| is not in $|cr$|{player.Name}#|'s Inventory`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Inventory.UnlockItem(player, itemId, true)

		-- Returning
		if value then
			return true, `Unlocked Item $|cr$|{itemId}#| for $|cr$|{player.Name}#|`
		else
			return false, `Failed to unlock Item $|cr$|{itemId}#| for $|cr$|{player.Name}#|`
		end
	end

	local function lockSwitch(player: Player, itemId: string)
		--[[ Checks ]]

		if not I.Inventory.GetItem(player, itemId) and not I.Inventory.GetUnique(player, itemId) then
			return false, `Item $|cr$|{itemId}#| is not in $|cr$|{player.Name}#|'s Inventory`
		end

		--[[ Executing ]]

		-- Getting value
		local success: boolean, value: boolean = I.Inventory.LockSwitch(player, itemId, true)

		-- Returning
		if success and value ~= nil then
			if value then
				return true, `Locked Item $|cr$|{itemId}#| for $|cr$|{player.Name}#|`
			else
				return true, `Unlocked Item $|cr$|{itemId}#| for $|cr$|{player.Name}#|`
			end
		else
			return false, `Failed to change Item $|cr$|{itemId}#| lock state for $|cr$|{player.Name}#|`
		end
	end

	local function isLocked(player: Player, itemId: string)
		--[[ Checks ]]

		if not I.Inventory.GetItem(player, itemId) and not I.Inventory.GetUnique(player, itemId) then
			return false, `Item $|cr$|{itemId}#| is not in $|cr$|{player.Name}#|'s Inventory`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Inventory.IsLocked(player, itemId)

		-- Returning
		if value ~= nil then
			if value then
				return true, `Item $|cr$|{itemId}#| is $|cr$|locked#| for $|cr$|{player.Name}#|`
			else
				return true, `Item $|cr$|{itemId}#| is $|cr$|not locked#| for $|cr$|{player.Name}#|`
			end
		else
			return false, `Failed to get Item $|cr$|{itemId}#| lock state for $|cr$|{player.Name}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Use Control Functions

	local function useStandard(player: Player, itemId: string, quantity: string?)
		--[[ Checks ]]

		if not I.G_Inventory.Items[itemId] then
			return false, `Invalid ItemId: $|cr$|{itemId}#|`
		end

		if not I.Inventory.GetItem(player, itemId) then
			return false, `Item $|cr$|{itemId}#| is not in $|cr$|{player.Name}#|'s Inventory`
		end

		if quantity then
			local quantityBN = I.BN.new(quantity)
			if quantityBN <= zeroBN then
				return false, `Invalid Quantity: $|cr$|{quantity}#| cannot be less than or equal to $|cr$|0#|`
			end
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Inventory.UseItem(player, itemId, quantity, false)

		-- Formatting value
		local quantityFormatted: string = I.Format.Text(quantity or "1")

		-- Returning
		if value then
			return true, `Used $|cr$|x{quantityFormatted}#| $|cr$|{itemId}#| for $|cr$|{player.Name}#|`
		else
			return false, `Failed to use $|cr$|x{quantityFormatted}#| $|cr$|{itemId}#| for $|cr$|{player.Name}#|`
		end
	end

	local function useUnique(player: Player, uniqueUUID: string, quantity: string?)
		--[[ Data ]]

		--- @type Inventory_UniqueItem
		local uniqueData = I.Inventory.GetUnique(player, uniqueUUID)

		--[[ Checks ]]

		if not uniqueData then
			return false, `Unique Item $|cr$|{uniqueUUID}#| is not in $|cr$|{player.Name}#|'s Inventory`
		end

		if not I.G_Inventory.Items[uniqueData.Id] then
			return false, `Invalid ItemId: $|cr$|{uniqueData.Id}#|`
		end

		if quantity then
			local quantityBN = I.BN.new(quantity)
			if quantityBN <= zeroBN then
				return false, `Invalid Quantity: $|cr$|{quantity}#| cannot be less than or equal to $|cr$|0#|`
			end
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Inventory.UseUnique(player, uniqueUUID, quantity, false)

		-- Formatting value
		local quantityFormatted: string = I.Format.Text(quantity or "1")

		-- Returning
		if value then
			return true, `Used $|cr$|x{quantityFormatted}#| $|cr$|{uniqueData.Id}#| (UUID: $|cr$|{uniqueUUID}#|) for $|cr$|{player.Name}#|`
		else
			return false, `Failed to use $|cr$|x{quantityFormatted}#| $|cr$|{uniqueData.Id}#| (UUID: $|cr$|{uniqueUUID}#|) for $|cr$|{player.Name}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Methods Functions

	local function getItem(player: Player, itemId: string)
		--[[ Checks ]]

		-- Invalid itemId
		if not I.G_Inventory.Items[itemId] then
			return false, `Invalid ItemId: $|cr$|{itemId}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: string? = I.Inventory.GetItem(player, itemId)

		-- Returning
		if value then
			-- Formatting values
			local formatted: string = I.Format.Text(value)

			return true, `$|cr$|{player.Name}#| has $|cr$|x{formatted}#| $|cr$|{itemId}#|`
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s $|cr$|{itemId}#| data`
		end
	end

	local function getUnique(player: Player, uniqueUUID: string)
		--[[ Executing ]]

		-- Getting value
		--- @type Inventory_UniqueItem
		local value = I.Inventory.GetUnique(player, uniqueUUID, true)

		-- Returning
		if value then
			-- Formatting values
			value.Metadata._q = I.Format.Text(value.Metadata._q)
			value.Metadata._cts = I.Date.UnixToDateLocal(value.Metadata._cts, "DD-MM-YYYY HH:mm")

			return true, { `Getting $|cr$|{player.Name}#|'s $|cr$|{uniqueUUID}#| Unique Item data...`, value, "_multilineOutput" }
		else
			return false, `Failed to get $|cr$|{player.Name}#|'s $|cr$|{uniqueUUID}#| Unique Item data`
		end
	end

	local function getInventory(player: Player, dataType: string?)
		--[[ Checks ]]

		-- Invalid dataType
		if dataType and I.Player.ProfileTemplates["Inventory"][dataType] == nil then
			return false, `Invalid Data type: $|cr$|{dataType}#|`
		end

		--[[ Executing ]]

		-- Getting value
		--- @type Inventory_Data
		local value = I.Inventory.GetInventory(player, dataType)

		-- Returning
		if value then
			if dataType then
				return true, { `Getting $|cr$|{player.Name}#|'s $|cr$|{dataType}#| Inventory data...`, value, "_multilineOutput" }
			else
				return true, { `Getting $|cr$|{player.Name}#|'s Inventory data...`, value, "_multilineOutput" }
			end
		else
			if dataType then
				return false, `Failed to get $|cr$|{player.Name}#|'s $|cr$|{dataType}#| Inventory data`
			else
				return false, `Failed to get $|cr$|{player.Name}#|'s Inventory data`
			end
		end
	end

	local function updateClientData(player: Player, dataType: string?)
		--[[ Checks ]]

		-- Invalid dataType
		if dataType and I.Player.ProfileTemplates["Inventory"][dataType] == nil then
			return false, `Invalid Data type: $|cr$|{dataType}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: boolean = I.Inventory.UpdateClientData(player, dataType)

		-- Returning
		if value then
			if dataType then
				return true, `Updated $|cr$|{player.Name}#|'s $|cr$|{dataType}#| Inventory data`
			else
				return true, `Updated $|cr$|{player.Name}#|'s Inventory data`
			end
		else
			if dataType then
				return false, `Failed to update $|cr$|{player.Name}#|'s $|cr$|{dataType}#| Inventory data`
			else
				return false, `Failed to update $|cr$|{player.Name}#|'s Inventory data`
			end
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Standard Control ]]

		{
			Aliases = { "add_standard" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "itemId", types = { "string" }, dict = "Inventory_ItemNames", requireDict = true },
				{ name = "quantity", types = { "BigNum" }, optional = true },
			},
			Callback = addStandard,
		},
		{
			Aliases = { "remove_standard" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "itemId", types = { "string" }, dict = "Inventory_StandardItems-$|arg:-1#|", requireDict = true },
				{ name = "quantity", types = { "BigNum" }, optional = true },
			},
			Callback = removeStandard,
		},

		--[[ Unique Control ]]

		{
			Aliases = { "add_unique" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "uniqueUUID", types = { "string" }, dict = "Inventory_UniqueItems-$|arg:-1#|", requireDict = true },
				{ name = "quantity", types = { "BigNum" }, optional = true },
			},
			Callback = addUnique,
		},
		{
			Aliases = { "create_unique" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "itemId", types = { "string" }, dict = "Inventory_ItemNames", requireDict = true },
				{ name = "setUUID", types = { "string" }, optional = true },
				{ name = "quantity", types = { "BigNum" }, optional = true },
			},
			Callback = createUnique,
		},
		{
			Aliases = { "remove_unique" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "uniqueUUID", types = { "string" }, dict = "Inventory_UniqueItems-$|arg:-1#|", requireDict = true },
				{ name = "quantity", types = { "BigNum" }, optional = true },
			},
			Callback = removeUnique,
		},

		--[[ Lock Control ]]

		{
			Aliases = { "lock" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "itemId", types = { "string" }, dict = "Inventory_Items-$|arg:-1#|", dictNegate = `Inventory_LockedItems-$|arg:-1#|`, requireDict = true },
			},
			Callback = lock,
		},
		{
			Aliases = { "unlock" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "itemId", types = { "string" }, dict = "Inventory_LockedItems-$|arg:-1#|", requireDict = true },
			},
			Callback = unlock,
		},
		{
			Aliases = { "lock_switch" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "itemId", types = { "string" }, dict = "Inventory_Items-$|arg:-1#|", requireDict = true },
			},
			Callback = lockSwitch,
		},
		{
			Aliases = { "is_locked" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "itemId", types = { "string" }, dict = "Inventory_Items-$|arg:-1#|", requireDict = true },
			},
			Callback = isLocked,
		},

		--[[ Use Control ]]

		{
			Aliases = { "use_standard" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "itemId", types = { "string" }, dict = "Inventory_StandardItems-$|arg:-1#|", requireDict = true },
				{ name = "quantity", types = { "BigNum" }, optional = true },
			},
			Callback = useStandard,
		},
		{
			Aliases = { "use_unique" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "uniqueUUID", types = { "string" }, dict = "Inventory_UniqueItems-$|arg:-1#|", requireDict = true },
				{ name = "quantity", types = { "BigNum" }, optional = true },
			},
			Callback = useUnique,
		},

		--[[ Methods ]]

		{
			Aliases = { "get" },

			Variants = {
				{
					Aliases = { "item" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "itemId", types = { "string" }, dict = "Inventory_StandardItems-$|arg:-1#|", requireDict = true },
					},
					Callback = getItem,
				},
				{
					Aliases = { "unique" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "uniqueUUID", types = { "string" }, dict = "Inventory_UniqueItems-$|arg:-1#|", requireDict = true },
					},
					Callback = getUnique,
				},
				{
					Aliases = { "inventory" },
					Args = {
						{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
						{ name = "dataType", types = { "string" }, dict = "Inventory_DataTypes", requireDict = true, optional = true },
					},
					Callback = getInventory,
				},
			},
		},

		{
			Aliases = { "update_client_data" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "dataType", types = { "string" }, dict = "Inventory_DataTypes", requireDict = true, optional = true },
			},
			Callback = updateClientData,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("Inventory_Server", {
		Aliases = { "inventory" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%% Register Command Dictionaries

--[[
	Registers dictionaries used by module commands.
]]
function Module._registerCommandDictionaries()
	--[[ Getting Values ]]

	local allItemNames = {} --- @type { string }
	--- @param _itemData Inventory_ItemData
	for itemId: string, _itemData in pairs(I.G_Inventory.Items) do
		table.insert(allItemNames, itemId)
	end

	local allDataTypes = {} --- @type { string }
	for dataTypeName: string, _data: any in pairs(I.Player.ProfileTemplates["Inventory"]) do
		table.insert(allDataTypes, dataTypeName)
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Inventory_ItemNames`, allItemNames, 255)
	I.AdminPanel_CommandBar.SetDictionary(`Inventory_DataTypes`, allDataTypes, 255)
end

--%%%%%%%%%%%%%%%%%%%% Queue Command Dictionaries Update

--[[
	Rebuilds the player's command dictionaries once, a short delay after the first inventory change in a burst.
]]
function Module._queueCommandDictionariesUpdate(player: Player)
	--[[ Checks ]]

	-- Skip when a rebuild is already queued
	if pendingRebuilds[player] then
		return
	end

	--[[ Queueing ]]

	pendingRebuilds[player] = true

	-- Clear the flag first, so it never outlives the player
	task.delay(DICTIONARY_REBUILD_DELAY, function()
		pendingRebuilds[player] = nil
		Module._updateCommandDictionariesForPlayer(player)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Update Command Dictionaries For Player

--[[
	Updates dictionaries used by module commands for player.
]]
function Module._updateCommandDictionariesForPlayer(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData_Inventory
	local inventoryData = I.Player.GetProfile(player, "Inventory").Data

	--[[ Getting Values ]]

	local allPlayersItemsIds = {} --- @type { string }

	local allPlayerStandardItemIds = {} --- @type { string }
	for itemId: string, _quantity: string in pairs(inventoryData.Standard) do
		table.insert(allPlayersItemsIds, itemId)
		table.insert(allPlayerStandardItemIds, itemId)
	end

	local allPlayerUniqueItemIds = {} --- @type { string }
	--- @param _uniqueData Inventory_UniqueItem
	for itemUUID: string, _uniqueData in pairs(inventoryData.Unique) do
		table.insert(allPlayersItemsIds, itemUUID)
		table.insert(allPlayerUniqueItemIds, itemUUID)
	end

	local allPlayerLockedItemIds: { string } = I.Table.DeepCopy(inventoryData.Locked or {})

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary(`Inventory_Items-{player.Name}`, allPlayersItemsIds, 255, { BoundTo = player.UserId })
	I.AdminPanel_CommandBar.SetDictionary(`Inventory_StandardItems-{player.Name}`, allPlayerStandardItemIds, 255, { BoundTo = player.UserId })
	I.AdminPanel_CommandBar.SetDictionary(`Inventory_UniqueItems-{player.Name}`, allPlayerUniqueItemIds, 255, { BoundTo = player.UserId })

	I.AdminPanel_CommandBar.SetDictionary(`Inventory_LockedItems-{player.Name}`, allPlayerLockedItemIds, 255, { BoundTo = player.UserId })
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
