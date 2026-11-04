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
	elems["Slot"] = moduleGui:FindFirstChild("S_Slot", true) --- @type TextLabel
	elems["Items"] = moduleGui:FindFirstChild("U_Items", true) --- @type ScrollingFrame
	elems["Empty"] = moduleGui:FindFirstChild("S_Empty", true):FindFirstChild("Button") --- @type ImageButton
	prefabs["ItemTile"] = elems["Items"]:FindFirstChild("PREFAB | ItemTile") --- @type Frame

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
	Draws the picker when it opens: one tile per owned weapon and utility, with its rarity, uses and cooldown, and its
	copies toward shiny.
]]
function Module._onOpened(widgetName: string)
	--[[ Checks ]]

	-- Check if it's the picker
	if widgetName ~= _settings.PICKER_GUI_NAME then
		return
	end

	--[[ Clearing ]]

	for _index: number, child: Instance in ipairs(elems["Items"]:GetChildren()) do
		if child:IsA("Frame") and child ~= prefabs["ItemTile"] then
			child:Destroy()
		end
	end

	--[[ Texts ]]

	elems["Slot"].Text = `Slot {pickingSlot}: tap an item to put it in`

	--[[ Tiles ]]

	local standard = I.Inventory.Items and I.Inventory.Items.Standard or {} --- @type { [string]: string }
	for itemId: string, quantity: string in pairs(standard) do
		local item = I.G_Inventory.Items[itemId] --- @type Inventory_ItemData?
		if not item or not table.find(_settings.SLOT_CATEGORIES, item.Category) then
			continue
		end
		local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData
		local tile: Frame = prefabs["ItemTile"]:Clone()
		tile.Name = itemId
		tile.LayoutOrder = I.Rarity.GetRarityIndex(item.Rarity) or 0
		tile.Visible = true
		tile:FindFirstChild("S_Icon", true).Image = item.IconId
		tile:FindFirstChild("S_Name", true).Text = item.Name
		tile:FindFirstChild("S_Info", true).Text = Module._getInfo(row)
		tile:FindFirstChild("S_Copies", true).Text = `{math.min(tonumber(quantity) or 0, _settings.SHINY_COPIES)} / {_settings.SHINY_COPIES}`
		tile:FindFirstChild("S_Rarity", true).Text = item.Rarity
		tile:FindFirstChild("S_Rarity", true).TextColor3 = I.Rarity.GetLook(item.Rarity).Base
		tile.Parent = elems["Items"]
		I.Interact.OnPress(tile:FindFirstChild("Button"), function()
			Module._pick(itemId)
		end)
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
