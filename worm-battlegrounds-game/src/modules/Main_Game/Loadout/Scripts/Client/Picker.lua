--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Loadout"

--- @type Loadout_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }
local prefabs = {} --- @type { [string]: Instance }

-- The slot the picker fills
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

	local moduleGui: ScreenGui = I.UserInterface.UI[_settings.PICKER_GUI_NAME]
	elems["Items"] = moduleGui:FindFirstChild("U_Items", true) --- @type ScrollingFrame
	elems["Empty"] = moduleGui:FindFirstChild("S_Empty", true) --- @type ImageButton
	prefabs["ItemRow"] = elems["Items"]:FindFirstChild("PREFAB | ItemRow") --- @type Frame
	prefabs["ItemCard"] = prefabs["ItemRow"]:FindFirstChild("PREFAB | ItemCard", true) --- @type ImageButton

	--[[ Connections ]]

	I.Topic.Subscribe("WidgetManager_Opened", Module._onOpened)
	I.Interact.OnPress(elems["Empty"], Module._empty)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Open For

--[[
	Opens the picker to fill a slot.
]]
function Module.OpenFor(slot: number)
	--[[ Saving ]]

	pickingSlot = slot

	--[[ Opening ]]

	I.WidgetManager.Open(_settings.PICKER_GUI_NAME)
end

--%%%%%%%%%%%%%%%%%%%% On Opened

--[[
	Draws the picker when it opens: a card per weapon and utility, owned ones first by rarity with their copies, the
	one in this slot selected and those in other slots in the equipped look, then the ones not owned yet, locked.
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
		if itemId ~= _settings.BASIC_WEAPON and table.find(_settings.SLOT_CATEGORIES, item.Category) then
			table.insert(itemIds, itemId)
		end
	end
	table.sort(itemIds, function(a: string, b: string): boolean
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
		local item = I.G_Inventory.Items[itemId] --- @type Inventory_ItemData
		local owned: boolean = standard[itemId] ~= nil
		local inSlot: number? = Module._getSlotOf(loadoutRep, itemId)
		local look: string = if inSlot == pickingSlot then "Selected" elseif inSlot then "Equipped" else ""

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
		card:FindFirstChild("S_Icon").Image = item.IconId
		card:FindFirstChild("S_Name").Text = item.Name
		card:FindFirstChild("S_Amount").Text = if owned then `x{standard[itemId]}` else ""
		card:FindFirstChild("S_Rarity").ImageColor3 = I.Rarity.GetLook(item.Rarity).Base
		card:FindFirstChild("S_Locked").Visible = not owned
		background:FindFirstChild("Stroke2").Image = card:GetAttribute(`Look_{look}Stroke2`)
		background:FindFirstChild("Stroke").Image = card:GetAttribute(`Look_{look}Stroke`)
		background:FindFirstChild("Stroke").ImageColor3 = card:GetAttribute(`Look_{look}StrokeColor`)
		card:SetAttribute("HoverInfo_Title", `{item.Name}: {Module._getInfo(I.G_Arsenal.Get(itemId))}`)
		card:SetAttribute("HoverInfo_Rarity", item.Rarity)
		card.Parent = row:FindFirstChild("Content")
		if owned then
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
