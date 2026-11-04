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

--[[ General ]]

local moduleGui: ScreenGui
local moduleRep: Folder?

-- One box per slot, by slot number
local boxes = {} --- @type { [number]: Frame }

-- Opens the picker for a slot
local openPicker: (slot: number) -> ()

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

--- @class Loadout_Client_Panel
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

--- @param opener (slot: number) -> ()
function Module.Start(opener)
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.PANEL_GUI_NAME]
	elems["Slots"] = moduleGui:FindFirstChild("U_Slots", true) --- @type Frame
	elems["Bazooka"] = elems["Slots"]:FindFirstChild("S_Bazooka") --- @type Frame
	prefabs["Slot"] = elems["Slots"]:FindFirstChild("PREFAB | Slot") --- @type Frame
	openPicker = opener

	--[[ Building ]]

	elems["Bazooka"]:FindFirstChild("S_Icon", true).Image = I.G_Arsenal.Get("Bazooka").Icon
	for slot: number = 1, _settings.MAX_SLOTS do
		local box: Frame = prefabs["Slot"]:Clone()
		box.Name = `Slot{slot}`
		box.LayoutOrder = slot + 1
		box.Visible = true
		box.Parent = elems["Slots"]
		boxes[slot] = box
		I.Interact.OnPress(box:FindFirstChild("Button"), function()
			Module._onSlotPressed(slot)
		end)
	end

	--[[ Connections ]]

	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
	I.Topic.Subscribe("Inventory_DataUpdated-Standard", Module._refresh)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Replicator

--[[
	Follows the player's Loadout folder: their slots and how many are open.
]]
function Module._connectReplicator()
	--[[ Data ]]

	moduleRep = I.Replicator.GetFolder(_localName)
	if not moduleRep then
		return
	end

	--[[ Connections ]]

	moduleRep.AttributeChanged:Connect(Module._refresh)
	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Draws every slot: its item's picture, name and rarity, whether it's shiny, or the lock and price of a slot that
	isn't open yet.
]]
function Module._refresh()
	--[[ Checks ]]

	-- Check if the slots have arrived
	if not moduleRep then
		return
	end

	--[[ Applying ]]

	local unlocked: number = moduleRep:GetAttribute("Unlocked") or _settings.BASE_SLOTS
	for slot: number, box: Frame in pairs(boxes) do
		local itemId: string = moduleRep:GetAttribute(`Slot{slot}`) or ""
		local item = I.G_Inventory.Items[itemId] --- @type Inventory_ItemData?
		local copies: number = tonumber(I.Inventory.Items and I.Inventory.Items.Standard and I.Inventory.Items.Standard[itemId]) or 0
		local lock: Frame = box:FindFirstChild("S_Lock", true)
		box:FindFirstChild("S_Icon", true).Image = if item then item.IconId else ""
		box:FindFirstChild("S_Name", true).Text = if item then item.Name else "Empty"
		box:FindFirstChild("S_Shiny", true).Visible = copies >= _settings.SHINY_COPIES
		box.Visible = slot <= unlocked + 1
		lock.Visible = slot > unlocked
		lock:FindFirstChild("S_Price", true).Text = if _settings.SLOT_PRICES[slot] then `{_settings.SLOT_PRICES[slot]} coins` else ""
	end
end

--%%%%%%%%%%%%%%%%%%%% On Slot Pressed

--[[
	Opens the picker for an open slot; for the next locked one, asks whether to open it with coins.
]]
function Module._onSlotPressed(slot: number)
	--[[ Local Variables ]]

	local unlocked: number = moduleRep and moduleRep:GetAttribute("Unlocked") or _settings.BASE_SLOTS

	--[[ Opening ]]

	if slot <= unlocked then
		openPicker(slot)
		return
	end

	--[[ Unlocking ]]

	I.WidgetManager.ShowConfirmation(`Open slot {slot} for {_settings.SLOT_PRICES[slot]} coins?`, function()
		if not I.Network.Invoke("Loadout_UnlockSlot", slot) then
			I.WidgetManager.ShowMessage("Not enough coins yet.")
		end
	end)
end

return Module
