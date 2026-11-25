--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Loadout"

--- @type Loadout_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

--[[ General ]]

local moduleGui: ScreenGui

-- The slot the picker fills (0: opened from the Bazooka's card, which no other item replaces)
local pickingSlot: number = 1

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

--- @class Loadout_Client_Picker
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.PICKER_GUI_NAME]
	elems["Items"] = moduleGui:FindFirstChild("U_Items", true) --- @type ScrollingFrame
	elems["Empty"] = moduleGui:FindFirstChild("S_Empty", true) --- @type ImageButton
	prefabs["ItemRow"] = elems["Items"]:FindFirstChild("PREFAB | ItemRow") --- @type Frame
	prefabs["ItemCard"] = prefabs["ItemRow"]:FindFirstChild("PREFAB | ItemCard", true) --- @type ImageButton

	--[[ Connections ]]

	I.Topic.Subscribe("WidgetManager_Opened", Module._onOpened)
	I.Interact.OnPress(elems["Empty"], Module._empty)
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("WeaponLooks"):Connect(Module._redraw)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Open For

--[[
	Opens the picker to fill a slot, or for the Bazooka (slot 0), whose look the loadout's look tab picks beside it;
	already open, it's drawn again for that slot.
]]
function Module.OpenFor(slot: number)
	--[[ Saving ]]

	pickingSlot = slot

	--[[ Opening ]]

	if moduleGui.Enabled then
		Module._redraw()
		return
	end
	I.WidgetManager.Open(_settings.PICKER_GUI_NAME)
end

--%%%%%%%%%%%%%%%%%%%% Redraw

--[[
	Draws the open picker again: another slot picked, or a weapon's look changed on the look tab.
]]
function Module._redraw()
	--[[ Checks ]]

	-- Check if the picker is open
	if not moduleGui.Enabled then
		return
	end

	--[[ Drawing ]]

	Module._onOpened(_settings.PICKER_GUI_NAME)
end

--%%%%%%%%%%%%%%%%%%%% On Opened

--[[
	Draws the picker when it opens: a card per weapon and utility, owned ones first by rarity with their copies (each
	in the look it wears: a Shiny one in its holo foil, a Golden one in its gold rim), the one in this slot selected
	and those in other slots in the equipped look, then the ones not owned yet, locked. Opened from the Bazooka, the
	Bazooka is selected, no card replaces it and Empty hides.
]]
function Module._onOpened(widgetName: string)
	--[[ Checks ]]

	-- Check if it's the picker
	if widgetName ~= _settings.PICKER_GUI_NAME then
		return
	end

	--[[ Data ]]

	local standard = I.Inventory.Items and I.Inventory.Items.Standard or {} --- @type { [string]: string }
	local loadoutRep: Folder? = I.Replicator.GetFolder(_localName)

	--[[ Empty ]]

	elems["Empty"].Visible = pickingSlot ~= 0

	--[[ Clearing ]]

	for _index: number, child: Instance in ipairs(elems["Items"]:GetChildren()) do
		if child:IsA("Frame") and child.Name:sub(1, 3) == "Row" then
			child:Destroy()
		end
	end

	--[[ Sorting ]]

	local itemIds = {} --- @type { string }
	for itemId: string in pairs(I.G_Inventory.Items) do
		local item = I.G_Inventory.Items[itemId] --- @type Inventory_ItemData
		local shown: boolean = not item.Disabled or standard[itemId] ~= nil
		if shown and table.find(_settings.SLOT_CATEGORIES, item.Category) then
			table.insert(itemIds, itemId)
		end
	end
	if not table.find(itemIds, _settings.BASIC_WEAPON) then
		table.insert(itemIds, _settings.BASIC_WEAPON)
	end
	table.sort(itemIds, function(a: string, b: string): boolean
		-- The Bazooka first: every player holds it, always in the first slot
		if (a == _settings.BASIC_WEAPON) ~= (b == _settings.BASIC_WEAPON) then
			return a == _settings.BASIC_WEAPON
		end
		local ownedA: boolean = standard[a] ~= nil
		local ownedB: boolean = standard[b] ~= nil
		if ownedA ~= ownedB then
			return ownedA
		end
		local rarityA: number = I.Rarity.GetRarityIndex(I.G_Inventory.Items[a].Rarity) or 0
		local rarityB: number = I.Rarity.GetRarityIndex(I.G_Inventory.Items[b].Rarity) or 0
		if rarityA ~= rarityB then
			return rarityA > rarityB
		end
		return I.G_Inventory.Items[a].Name < I.G_Inventory.Items[b].Name
	end)

	--[[ Cards ]]

	local row: Frame
	for index: number, itemId: string in ipairs(itemIds) do
		local item = I.G_Inventory.Items[itemId] --- @type Inventory_ItemData?
		local basic: boolean = itemId == _settings.BASIC_WEAPON
		local name: string = if item then item.Name else itemId
		local rarity: string = if item then item.Rarity else _settings.BASIC_WEAPON_RARITY
		local owned: boolean = basic or standard[itemId] ~= nil
		local inSlot: number? = Module._getSlotOf(loadoutRep, itemId)
		local look: string = if inSlot == pickingSlot or basic and pickingSlot == 0 then "Selected" elseif inSlot or basic then "Equipped" else ""

		-- A new row every ITEMS_PER_ROW cards
		if (index - 1) % _settings.ITEMS_PER_ROW == 0 then
			row = prefabs["ItemRow"]:Clone()
			row.Name = `Row{index}`
			row.LayoutOrder = index
			row.Visible = true
			row:FindFirstChild("PREFAB | ItemCard", true):Destroy()
			row.Parent = elems["Items"]
		end

		local card: ImageButton = prefabs["ItemCard"]:Clone()
		local background: Frame = card:FindFirstChild("Background")
		card.Name = itemId
		card.LayoutOrder = index
		card.Visible = true
		card:FindFirstChild("S_Icon").Image = if item then item.IconId else I.G_Arsenal.Get(itemId).Icon
		card:FindFirstChild("S_Name").Text = name
		card:FindFirstChild("S_Amount").Text = if standard[itemId] then `x{standard[itemId]}` else ""
		card:FindFirstChild("S_Rarity").ImageColor3 = I.Rarity.GetLook(rarity).Base
		card:FindFirstChild("S_Locked").Visible = not owned
		local worn: string = I.G_Loadout.GetWornLook(I.S.Players.LocalPlayer, itemId)
		background:FindFirstChild("S_Foil").Visible = worn == "Shiny"
		background:FindFirstChild("S_Gold").Visible = worn == "Golden"
		background:FindFirstChild("Stroke2").Image = card:GetAttribute(`Look_{look}Stroke2`)
		background:FindFirstChild("Stroke").Image = card:GetAttribute(`Look_{look}Stroke`)
		background:FindFirstChild("Stroke").ImageColor3 = card:GetAttribute(`Look_{look}StrokeColor`)
		card:SetAttribute("HoverInfo_Title", `{name}: {Module._getInfo(I.G_Arsenal.Get(itemId))}`)
		card:SetAttribute("HoverInfo_Rarity", rarity)
		card.Parent = row:FindFirstChild("Content")
		-- The Bazooka shows, but stays in its own slot, and nothing replaces it
		if owned and not basic and pickingSlot ~= 0 then
			I.Interact.OnPress(card, function()
				Module._pick(itemId)
			end)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Pick

--[[
	Puts an item in the slot and closes the picker.
]]
function Module._pick(itemId: string)
	--[[ Sending ]]

	I.Network.Fire("Loadout_Set", pickingSlot, itemId)

	--[[ Closing ]]

	I.WidgetManager.Close(_settings.PICKER_GUI_NAME)
end

--%%%%%%%%%%%%%%%%%%%% Empty

--[[
	Empties the slot and closes the picker.
]]
function Module._empty()
	--[[ Sending ]]

	I.Network.Fire("Loadout_Set", pickingSlot, nil)

	--[[ Closing ]]

	I.WidgetManager.Close(_settings.PICKER_GUI_NAME)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Slot Of

--[[
	Returns the slot that holds an item, or nil.
]]
--- @return number?
function Module._getSlotOf(loadoutRep: Folder?, itemId: string)
	--[[ Searching ]]

	for slot: number = 1, _settings.MAX_SLOTS do
		if loadoutRep and loadoutRep:GetAttribute(`Slot{slot}`) == itemId then
			return slot
		end
	end

	--[[ Returning ]]

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Get Info

--[[
	Returns an item's uses and cooldown in a few words: "3 uses · 1 turn cooldown".
]]
--- @param row Arsenal_WeaponData?
--- @return string
function Module._getInfo(row)
	--[[ Checks ]]

	-- Check if the item has arsenal numbers
	if not row then
		return ""
	end

	--[[ Local Variables ]]

	local uses: string = if row.Uses < 0 then "Unlimited" else `{row.Uses} use{if row.Uses == 1 then "" else "s"}`
	local cooldown: number = row.Cooldown or 0

	--[[ Returning ]]

	return if cooldown > 0 then `{uses} · {cooldown} turn cooldown` else uses
end

return Module
