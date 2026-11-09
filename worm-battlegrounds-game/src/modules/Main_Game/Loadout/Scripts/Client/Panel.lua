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

-- One card per slot, by slot number
local boxes = {} --- @type { [number]: ImageButton }

-- The slot whose picker is open, drawn in the selected look
local selectedSlot: number? = nil

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
	elems["TopRow"] = moduleGui:FindFirstChild("U_TopRow", true) --- @type Frame
	elems["BottomRow"] = moduleGui:FindFirstChild("U_BottomRow", true) --- @type Frame
	prefabs["Slot"] = elems["TopRow"]:FindFirstChild("PREFAB | Slot") --- @type ImageButton
	openPicker = opener

	--[[ Basic Weapon ]]

	-- The first cell: the basic weapon, always there, with no slot
	local basic: ImageButton = Module._makeCard(1)
	basic.Name = _settings.BASIC_WEAPON
	basic:FindFirstChild("S_Icon").Image = I.G_Arsenal.Get(_settings.BASIC_WEAPON).Icon
	basic:FindFirstChild("S_Name").Text = _settings.BASIC_WEAPON
	basic:FindFirstChild("S_Amount").Visible = false

	--[[ Slots ]]

	for slot: number = 1, _settings.MAX_SLOTS do
		local box: ImageButton = Module._makeCard(slot + 1)
		box.Name = `Slot{slot}`
		boxes[slot] = box
		I.Interact.OnPress(box, function()
			Module._onSlotPressed(slot)
		end)
	end

	--[[ Connections ]]

	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
	I.Topic.Subscribe("Inventory_DataUpdated-Standard", Module._refresh)
	I.Topic.Subscribe("WidgetManager_Closed", function(widgetName: string)
		if widgetName == _settings.PICKER_GUI_NAME then
			selectedSlot = nil
			Module._refresh()
		end
	end)
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

--%%%%%%%%%%%%%%%%%%%% Make Card

--[[
	Clones a slot card into its place on the panel: the first SLOTS_PER_ROW cells on the top row, the rest below,
	numbered from 1 like the match's loadout bar.
]]
--- @return ImageButton
function Module._makeCard(cell: number)
	--[[ Cloning ]]

	local card: ImageButton = prefabs["Slot"]:Clone()

	--[[ Applying ]]

	card.LayoutOrder = cell
	card.Visible = true
	card:FindFirstChild("S_Number").Text = tostring(cell)
	card.Parent = if cell <= _settings.SLOTS_PER_ROW then elems["TopRow"] else elems["BottomRow"]

	--[[ Returning ]]

	return card
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Draws every slot: its item's picture, name in its rarity's colour, copies and shiny mark; a + on an empty open
	slot; the lock and price on the next slot to open (later ones hide); the selected look while its picker is open.
]]
function Module._refresh()
	--[[ Checks ]]

	-- Check if the slots have arrived
	if not moduleRep then
		return
	end

	--[[ Applying ]]

	local unlocked: number = moduleRep:GetAttribute("Unlocked") or _settings.BASE_SLOTS
	for slot: number, box: ImageButton in pairs(boxes) do
		local itemId: string = moduleRep:GetAttribute(`Slot{slot}`) or ""
		local item = I.G_Inventory.Items[itemId] --- @type Inventory_ItemData?
		local copies: number = tonumber(I.Inventory.Items and I.Inventory.Items.Standard and I.Inventory.Items.Standard[itemId]) or 0
		local locked: boolean = slot > unlocked
		local empty: boolean = not item and not locked
		local selected: boolean = slot == selectedSlot
		local background: Frame = box:FindFirstChild("Background")
		local stroke: ImageLabel = background:FindFirstChild("Stroke")

		box.Visible = slot <= unlocked + 1
		box:FindFirstChild("S_Icon").Image = if item then item.IconId else ""
		box:FindFirstChild("S_Name").Text = if item then item.Name else ""
		box:FindFirstChild("S_Name").TextColor3 = if item then I.Rarity.GetLook(item.Rarity).Base else Color3.new(1, 1, 1)
		box:FindFirstChild("S_Amount").Text = if item then `x{copies}` else ""
		box:FindFirstChild("S_Number").Visible = item ~= nil
		box:FindFirstChild("S_Plus").Visible = empty
		box:FindFirstChild("S_Shiny").Visible = item ~= nil and copies >= _settings.SHINY_COPIES
		box:FindFirstChild("S_Lock").Visible = locked
		box:FindFirstChild("S_Price", true).Text = if _settings.SLOT_PRICES[slot] then `{_settings.SLOT_PRICES[slot]} coins` else ""
		background:FindFirstChild("Stroke2").Image = box:GetAttribute(if selected then "Look_SelectedStroke2" else "Look_Stroke2")
		stroke.Image = box:GetAttribute(if selected then "Look_SelectedStroke" else "Look_Stroke")
		stroke.ImageColor3 = box:GetAttribute(if selected then "Look_SelectedStrokeColor" elseif empty then "Look_EmptyStrokeColor" else "Look_StrokeColor")
	end
end

--%%%%%%%%%%%%%%%%%%%% On Slot Pressed

--[[
	Opens the picker for an open slot, showing that slot selected; for the next locked one, asks whether to open it
	with coins.
]]
function Module._onSlotPressed(slot: number)
	--[[ Local Variables ]]

	local unlocked: number = moduleRep and moduleRep:GetAttribute("Unlocked") or _settings.BASE_SLOTS

	--[[ Opening ]]

	if slot <= unlocked then
		selectedSlot = slot
		Module._refresh()
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
