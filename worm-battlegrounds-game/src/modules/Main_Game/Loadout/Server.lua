--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Loadout"

--- @type Loadout_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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

	--- @type Player_ProfileData
	local _pt = I.Player.ProfileTemplate
	_pt["Loadout"] = {
		Slots = { "", "", "", "", "", "" },
		CoinSlots = { Slot4 = false },
	}

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnPlayerAdded(I.Priority.Replicator, Module._createReplicator)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Loadout_Set", { "Player", { Type = "number", Min = 1, Max = _settings.MAX_SLOTS }, { Type = "string", Optional = true } }, { RateLimit = 5 })
	I.Network.Fired("Loadout_Set", Module.Set)
	I.Network.GetFunction("Loadout_UnlockSlot", { "Player", { Type = "number", Min = _settings.BASE_SLOTS + 1, Max = _settings.MAX_SLOTS } }, { RateLimit = 1 })
	I.Network.OnInvoke("Loadout_UnlockSlot", Module.UnlockSlot)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Loadout = {

		--[[ Control ]]

		Set = Module.Set,
		UnlockSlot = Module.UnlockSlot,

		--[[ Methods ]]

		GetUnlocked = Module.GetUnlocked,
		GetMatchLoadout = Module.GetMatchLoadout,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	for _index: number, passName: string in ipairs(_settings.SLOT_PASSES) do
		I.Topic.Subscribe(`Marketplace_GamePassPurchaseSucceeded-{passName}`, Module._publish)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Create Replicator

--[[
	Makes the player's Loadout folder, then writes their slots into it on a thread of its own, since the slot passes'
	check is a web call that would hold up the player's load.
]]
function Module._createReplicator(player: Player)
	--[[ Creating ]]

	I.Replicator.CreateFolder(player, _localName)

	--[[ Publishing ]]

	task.spawn(Module._publish, player)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set

--[[
	**SERVER** |
	Puts an item in a slot, or empties it with nil. The slot must be open, and the item an owned weapon or utility that
	isn't the Bazooka and isn't in another slot.
]]
--- @return boolean
function Module.Set(player: Player, slot: number, itemId: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Loadout"]

	--[[ Checks ]]

	-- Check if the slot is open
	if slot % 1 ~= 0 or slot > Module.GetUnlocked(player) then
		return false
	end

	-- Check if the item may go in a slot
	if itemId and not Module._canSlot(player, itemId) then
		return false
	end

	-- Check if another slot already holds it
	if itemId and table.find(moduleData["Slots"], itemId) and moduleData["Slots"][slot] ~= itemId then
		return false
	end

	--[[ Saving ]]

	moduleData["Slots"][slot] = itemId or ""

	--[[ Publishing ]]

	Module._publish(player)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Unlock Slot

--[[
	**SERVER** |
	Opens the coin slot (COIN_SLOT_PRICE) as the next slot, once per player. Returns whether it's open now.
]]
--- @return boolean
function Module.UnlockSlot(player: Player, slot: number)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Loadout"]

	--[[ Checks ]]

	-- Check if it's the next slot to open and the coin slot isn't open yet
	if slot ~= Module.GetUnlocked(player) + 1 or slot > _settings.MAX_SLOTS or Module._coinSlotsOpen(player) > 0 then
		return false
	end

	-- Check if the player can pay
	if not I.Currency.Subtract(player, "Coins", _settings.COIN_SLOT_PRICE) then
		return false
	end

	--[[ Saving ]]

	moduleData["CoinSlots"]["Slot4"] = true

	--[[ Publishing ]]

	Module._publish(player)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Writes a player's slots (Slot1 to Slot6, an item id or "") into their Loadout folder, with how many are open
	(Unlocked) and whether the coin slot is open (CoinSlotOpen).
]]
function Module._publish(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Loadout"]

	--[[ Saving ]]

	for slot: number = 1, _settings.MAX_SLOTS do
		I.Replicator.Set(player, _localName, `Slot{slot}`, moduleData["Slots"][slot] or "")
	end
	I.Replicator.Set(player, _localName, "Unlocked", Module.GetUnlocked(player))
	I.Replicator.Set(player, _localName, "CoinSlotOpen", Module._coinSlotsOpen(player) > 0)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Unlocked

--[[
	**SERVER** |
	Returns how many slots a player has open: 3, plus one for the coin slot, plus one per slot game pass owned, up to
	MAX_SLOTS.
]]
--- @return number
function Module.GetUnlocked(player: Player)
	--[[ Counting ]]

	local unlocked: number = _settings.BASE_SLOTS + Module._coinSlotsOpen(player)
	for _index: number, passName: string in ipairs(_settings.SLOT_PASSES) do
		if I.G_Marketplace.PlayerOwnsGamePass(player, passName) then
			unlocked += 1
		end
	end

	--[[ Returning ]]

	return math.min(unlocked, _settings.MAX_SLOTS)
end

--%%%%%%%%%%%%%%%%%%%% Get Match Loadout

--[[
	**SERVER** |
	Returns what a player takes into a match: the items in their open slots, in order, and which of them are shiny
	(SHINY_COPIES or more copies). Items they no longer own are left out.
]]
--- @return { string }, { [string]: boolean }
function Module.GetMatchLoadout(player: Player)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Loadout"]

	--[[ Local Variables ]]

	local items = {} --- @type { string }
	local shiny = {} --- @type { [string]: boolean }

	--[[ Collecting ]]

	for slot: number = 1, Module.GetUnlocked(player) do
		local itemId: string = moduleData["Slots"][slot] or ""
		if itemId ~= "" and Module._canSlot(player, itemId) then
			table.insert(items, itemId)
			shiny[itemId] = (tonumber(I.Inventory.GetItem(player, itemId)) or 0) >= _settings.SHINY_COPIES
		end
	end

	--[[ Returning ]]

	return items, shiny
end

--%%%%%%%%%%%%%%%%%%%% Coin Slots Open

--[[
	Returns how many slots a player opened with coins: the coin slot, plus slot 5 from before it became a pass slot.
]]
--- @return number
function Module._coinSlotsOpen(player: Player)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Loadout"]

	--[[ Counting ]]

	local count: number = 0
	for _key: string, open: boolean in pairs(moduleData["CoinSlots"]) do
		if open then
			count += 1
		end
	end

	--[[ Returning ]]

	return count
end

--%%%%%%%%%%%%%%%%%%%% Can Slot

--[[
	Returns whether an item may go in a slot: an owned weapon or utility from the inventory (never the Bazooka).
]]
--- @return boolean
function Module._canSlot(player: Player, itemId: string)
	--[[ Data ]]

	local item = I.G_Inventory.Items[itemId] --- @type Inventory_ItemData?

	--[[ Returning ]]

	return item ~= nil and table.find(_settings.SLOT_CATEGORIES, item.Category) ~= nil and I.Inventory.HasItem(player, itemId)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
