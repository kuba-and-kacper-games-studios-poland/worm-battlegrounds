--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
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
		CoinSlots = {},
		SlotsKept = false,
		Looks = {},
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
	I.Network.GetEvent("Loadout_SetLook", { "Player", "string", "string" }, { RateLimit = 5 })
	I.Network.Fired("Loadout_SetLook", Module.SetLook)
	I.Network.GetFunction("Loadout_UnlockSlot", { "Player", { Type = "number", Min = _settings.BASE_SLOTS + 1, Max = _settings.MAX_SLOTS } }, { RateLimit = 1 })
	I.Network.OnInvoke("Loadout_UnlockSlot", Module.UnlockSlot)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Loadout = {

		--[[ Control ]]

		Set = Module.Set,
		SetLook = Module.SetLook,
		UnlockSlot = Module.UnlockSlot,
		AddBoughtSlot = Module.AddBoughtSlot,
		OpenAllSlots = Module.OpenAllSlots,

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
	Module._keepSlots(player)

	--[[ Publishing ]]

	task.spawn(Module._publish, player)
end

--%%%%%%%%%%%%%%%%%%%% Keep Slots

--[[
	Once per player: one who played before the base dropped to BASE_SLOTS (2026-11-25), their tutorial match played or a
	slot filled, keeps the slots they had (KEPT_SLOTS more, saved as diamond slots); a new player starts at the base.
]]
function Module._keepSlots(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Loadout"]

	--[[ Checks ]]

	-- Check if it was decided already
	if moduleData["SlotsKept"] then
		return
	end

	--[[ Saving ]]

	moduleData["SlotsKept"] = true
	local played: boolean = profileData["Tutorial"]["MatchDone"] == true
	for _index: number, itemId: string in ipairs(moduleData["Slots"]) do
		played = played or itemId ~= ""
	end
	if played then
		for kept: number = 1, _settings.KEPT_SLOTS do
			moduleData["CoinSlots"][`Kept{kept}`] = true
		end
	end
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

--%%%%%%%%%%%%%%%%%%%% Set Look

--[[
	**SERVER** |
	Picks the look a weapon wears (LOOKS): any up to the best the player has for it, saved as "Look:Best" so a better
	look opening later shows instead. Only the look changes: the damage follows the best look owned.
]]
--- @return boolean
function Module.SetLook(player: Player, itemId: string, look: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Loadout"]

	--[[ Checks ]]

	-- Check if it's the Bazooka or an item a slot takes
	if itemId ~= _settings.BASIC_WEAPON and not Module._canSlot(player, itemId) then
		return false
	end

	--[[ Local Variables ]]

	local best: string = I.G_Loadout.GetBestLook(player, itemId)
	local rank: number = I.G_Loadout.GetLookRank(look)

	--[[ Checks ]]

	-- Check if the look is one the player has
	if rank == 0 or rank > I.G_Loadout.GetLookRank(best) then
		return false
	end

	--[[ Saving ]]

	moduleData["Looks"][itemId] = if look == best then nil else `{look}:{best}`

	--[[ Publishing ]]

	Module._publish(player)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Unlock Slot

--[[
	**SERVER** |
	Opens the next locked slot with diamonds (its DIAMOND_SLOT_PRICES), saved as a diamond slot. Returns whether it's open now.
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

	-- Check if it's the next slot to open
	if slot ~= Module.GetUnlocked(player) + 1 or not _settings.DIAMOND_SLOT_PRICES[slot] then
		return false
	end

	-- Check if the player can pay
	if not I.Currency.Subtract(player, "Diamonds", _settings.DIAMOND_SLOT_PRICES[slot]) then
		return false
	end

	--[[ Saving ]]

	-- Each true diamond slot opens one, so a name an older save already uses gets a number after it
	local key: string = `Slot{slot}`
	while moduleData["CoinSlots"][key] == true do
		key ..= "_"
	end
	moduleData["CoinSlots"][key] = true

	--[[ Publishing ]]

	Module._publish(player)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Add Bought Slot

--[[
	**SERVER** |
	Opens one more slot for a slot product bought with Robux (SLOT_PRODUCTS, Marketplace's `LoadoutSlot<n>` Reward),
	saved beside the diamond slots, since each true one opens a slot. Returns whether it was saved.
]]
--- @return boolean
function Module.AddBoughtSlot(player: Player, slot: number)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Loadout"]

	--[[ Saving ]]

	-- A name an older save already uses gets a number after it, so each purchase opens its own slot
	local key: string = `Robux{slot}`
	while moduleData["CoinSlots"][key] == true do
		key ..= "_"
	end
	moduleData["CoinSlots"][key] = true

	--[[ Publishing ]]

	Module._publish(player)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Open All Slots

--[[
	**SERVER** |
	Opens every slot for a player for good, whatever passes they own (the admin `loadout unlock_slots` command): each
	slot past the base is saved as a diamond slot, since each true diamond slot opens one.
]]
--- @return boolean
function Module.OpenAllSlots(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return false
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Loadout"]

	--[[ Saving ]]

	for slot: number = _settings.BASE_SLOTS + 1, _settings.MAX_SLOTS do
		moduleData["CoinSlots"][`Slot{slot}`] = true
	end

	--[[ Publishing ]]

	Module._publish(player)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Publish

--[[
	Writes a player's slots (Slot1 to Slot6, an item id or "") into their Loadout folder, with how many are open
	(Unlocked), and the looks they picked on the Player (WeaponLooks, JSON), where every screen's stage reads them.
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
	player:SetAttribute("WeaponLooks", I.S.HttpService:JSONEncode(moduleData["Looks"]))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Unlocked

--[[
	**SERVER** |
	Returns how many slots a player has open: BASE_SLOTS, plus one per saved slot (bought with diamonds or a slot
	product, or kept from before 2026-11-25), plus one per old slot game pass owned, up to MAX_SLOTS.
]]
--- @return number
function Module.GetUnlocked(player: Player)
	--[[ Counting ]]

	local unlocked: number = _settings.BASE_SLOTS + Module._diamondSlotsOpen(player)
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
	Returns what a player takes into a match: the items in their open slots, in order, which of them are shiny
	(SHINY_COPIES or more copies) and which golden (GOLDEN_COPIES or more, shiny too), the level rewards' looks
	counted too (Progression's WEAPON_REWARDS and the looks an admin gave, the basic weapon's among them), and the
	look each one wears (the one picked on the panel's look tab: "Normal", "Shiny" or "Golden"). Items they no longer
	own are left out.
]]
--- @return { string }
--- @return { [string]: boolean }
--- @return { [string]: boolean }
--- @return { [string]: string }
function Module.GetMatchLoadout(player: Player)
	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Loadout"]

	--[[ Local Variables ]]

	local items = {} --- @type { string }
	local shiny = {} --- @type { [string]: boolean }
	local golden = {} --- @type { [string]: boolean }
	local looks = {} --- @type { [string]: string }

	--[[ Collecting ]]

	for slot: number = 1, Module.GetUnlocked(player) do
		local itemId: string = moduleData["Slots"][slot] or ""
		if itemId ~= "" and Module._canSlot(player, itemId) then
			local copies: number = tonumber(I.Inventory.GetItem(player, itemId)) or 0
			local reward: string? = I.G_Progression.GetPlayerWeaponVariant(player, itemId)
			table.insert(items, itemId)
			shiny[itemId] = copies >= _settings.SHINY_COPIES or reward ~= nil
			golden[itemId] = copies >= _settings.GOLDEN_COPIES or reward == "Golden"
			looks[itemId] = I.G_Loadout.GetWornLook(player, itemId)
		end
	end

	-- The basic weapon takes no slot, so only its level rewards (or an admin) make it special
	local basic: string? = I.G_Progression.GetPlayerWeaponVariant(player, _settings.BASIC_WEAPON)
	shiny[_settings.BASIC_WEAPON] = basic ~= nil
	golden[_settings.BASIC_WEAPON] = basic == "Golden"
	looks[_settings.BASIC_WEAPON] = I.G_Loadout.GetWornLook(player, _settings.BASIC_WEAPON)

	--[[ Returning ]]

	return items, shiny, golden, looks
end

--%%%%%%%%%%%%%%%%%%%% Diamond Slots Open

--[[
	Returns how many slots a player opened with diamonds, or kept from before the base dropped (each true diamond slot).
]]
--- @return number
function Module._diamondSlotsOpen(player: Player)
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
