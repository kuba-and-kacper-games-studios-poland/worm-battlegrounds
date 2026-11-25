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
local moduleRep: Folder?

-- One card per slot, by slot number, and the basic weapon's card before them
local boxes = {} --- @type { [number]: ImageButton }
local basicCard: ImageButton

-- The slot whose picker is open (0 for the Bazooka), drawn in the selected look
local selectedSlot: number? = nil

-- Opens the picker for a slot
local openPicker: (slot: number) -> ()

-- The slot products' live Robux prices, by product, once Roblox answers
local productPrices = {} --- @type { [string]: string }

-- The panel's rows of cards, top first
local rows = {} --- @type { Frame }

-- Where EMOTES sits in the gui, under every row of cards
local emotesTop: number

-- The panel's own DisplayOrder, under WidgetManager's dim while no picker is open
local panelOrder: number

--[[ Look Tab ]]

-- The look tab's cards, by look (LOOKS)
local lookCards = {} --- @type { [string]: ImageButton }

-- The weapon the look tab shows (nil while it's shut, with the picker), and the cell of the card it opened from (1 is the Bazooka)
local lookItem: string? = nil
local lookCell: number = 1

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
	elems["EmoteSection"] = moduleGui:FindFirstChild("U_EmoteSection", true) --- @type Frame
	elems["Looks"] = moduleGui:FindFirstChild("U_Looks", true) --- @type Frame
	elems["LookCards"] = elems["Looks"]:FindFirstChild("S_Cards") --- @type Frame
	while elems["Slots"]:FindFirstChild(`U_Row{#rows + 1}`) do
		table.insert(rows, elems["Slots"]:FindFirstChild(`U_Row{#rows + 1}`))
	end
	prefabs["Slot"] = rows[1]:FindFirstChild("PREFAB | Slot") --- @type ImageButton
	emotesTop = elems["EmoteSection"].Position.Y.Scale
	panelOrder = moduleGui.DisplayOrder
	openPicker = opener

	--[[ Basic Weapon ]]

	-- The first cell: the basic weapon, always there, with no slot
	basicCard = Module._makeCard(1)
	basicCard.Name = _settings.BASIC_WEAPON
	basicCard:FindFirstChild("S_Icon").Image = I.G_Arsenal.Get(_settings.BASIC_WEAPON).Icon
	basicCard:FindFirstChild("S_Name").Text = _settings.BASIC_WEAPON
	basicCard:FindFirstChild("S_Amount").Visible = false
	I.Interact.OnPress(basicCard, function()
		Module.OpenPicker(0)
	end)

	--[[ Look Tab ]]

	-- One copy of the slot card per look, its number, copies and + left out
	for index: number, look: string in ipairs(_settings.LOOKS) do
		local card: ImageButton = prefabs["Slot"]:Clone()
		card.Name = look
		card.LayoutOrder = index
		card.Size = elems["LookCards"]:GetAttribute("Look_CardSize")
		card.Visible = true
		card:FindFirstChild("S_Number").Visible = false
		card:FindFirstChild("S_Amount").Visible = false
		card:FindFirstChild("S_Plus").Visible = false
		card:FindFirstChild("CurrencyIcon", true).Visible = false
		card.Parent = elems["LookCards"]
		lookCards[look] = card
		I.Interact.OnPress(card, function()
			Module._pickLook(look)
		end)
	end

	--[[ Slots ]]

	for slot: number = 1, _settings.MAX_SLOTS do
		local box: ImageButton = Module._makeCard(slot + 1)
		box.Name = `Slot{slot}`
		boxes[slot] = box
		I.Interact.OnPress(box, function()
			Module._onSlotPressed(slot)
		end)

		-- The lock's price and its picture stay centred as one whenever the price or the card's size changes
		box:FindFirstChild("S_Price", true):GetPropertyChangedSignal("TextBounds"):Connect(function()
			Module._centrePrice(box)
		end)
	end

	--[[ Connections ]]

	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
	I.Topic.Subscribe("Inventory_DataUpdated-Standard", Module._refresh)
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("Level"):Connect(Module._refresh)
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("WeaponVariants"):Connect(Module._refresh)
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("WeaponLooks"):Connect(Module._refresh)
	I.Topic.Subscribe("WidgetManager_Closed", function(widgetName: string)
		if widgetName == _settings.PICKER_GUI_NAME then
			selectedSlot = nil
			Module._closeLooks()
		end
	end)
	I.Topic.Subscribe("WidgetManager_Opened", function(widgetName: string)
		if widgetName ~= _settings.PICKER_GUI_NAME then
			Module._closeLooks()
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
	Clones a slot card into its row on the panel (SLOTS_PER_ROW a row, right-aligned), numbered from 1 like the
	match's loadout bar.
]]
--- @return ImageButton
function Module._makeCard(cell: number)
	--[[ Cloning ]]

	local card: ImageButton = prefabs["Slot"]:Clone()

	--[[ Applying ]]

	card.LayoutOrder = cell
	card.Visible = true
	card:FindFirstChild("S_Number").Text = tostring(cell)
	card.Parent = rows[math.ceil(cell / _settings.SLOTS_PER_ROW)]

	--[[ Returning ]]

	return card
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Draws every slot: its item's picture, name in its rarity's colour, copies, and the look it wears (the one picked on
	the look tab, up to its best: I.G_Loadout.GetWornLook), its Shiny or Golden mark and card (the holo foil, or the
	gold rim); a + on an empty open slot; the lock and price on the next slot to open (later ones hide): its diamonds
	(DIAMOND_SLOT_PRICES) beside the diamond; the selected look while its picker or look tab is open. The basic
	weapon's card wears its look too. EMOTES follows the last row shown, hidden while the picker is open, when the
	panel draws over the picker's dim; and the look tab is drawn.
]]
function Module._refresh()
	--[[ Checks ]]

	-- Check if the slots have arrived
	if not moduleRep then
		return
	end

	--[[ Basic Weapon ]]

	local localPlayer: Player = I.S.Players.LocalPlayer
	local basicLook: string = I.G_Loadout.GetWornLook(localPlayer, _settings.BASIC_WEAPON)
	Module._drawVariant(basicCard, if basicLook ~= "Normal" then basicLook else nil)
	Module._drawStroke(basicCard, selectedSlot == 0, false)

	--[[ Applying ]]

	local unlocked: number = moduleRep:GetAttribute("Unlocked") or _settings.BASE_SLOTS
	local diamonds: string? = _settings.DIAMOND_SLOT_PRICES[unlocked + 1]
	local price: string = if diamonds then I.Format.Text(diamonds) else ""

	-- Ask for the next slot's Robux price now, so the slot's question can name it
	local nextProduct: string? = _settings.SLOT_PRODUCTS[unlocked + 1]
	if nextProduct then
		Module._getProductPrice(nextProduct)
	end
	for slot: number, box: ImageButton in pairs(boxes) do
		local itemId: string = moduleRep:GetAttribute(`Slot{slot}`) or ""
		local item = I.G_Inventory.Items[itemId] --- @type Inventory_ItemData?
		local copies: number = tonumber(I.Inventory.Items and I.Inventory.Items.Standard and I.Inventory.Items.Standard[itemId]) or 0
		local locked: boolean = slot > unlocked
		local empty: boolean = not item and not locked
		local selected: boolean = slot == selectedSlot
		local look: string = if item then I.G_Loadout.GetWornLook(localPlayer, itemId) else "Normal"

		box.Visible = slot <= unlocked + 1
		box:FindFirstChild("S_Icon").Image = if item then item.IconId else ""
		box:FindFirstChild("S_Name").Text = if item then item.Name else ""
		box:FindFirstChild("S_Name").TextColor3 = if item then I.Rarity.GetLook(item.Rarity).Base else Color3.new(1, 1, 1)
		box:FindFirstChild("S_Amount").Text = if item then `x{copies}` else ""
		box:FindFirstChild("S_Amount").Visible = item ~= nil
		box:FindFirstChild("S_Number").Visible = item ~= nil
		box:FindFirstChild("S_Plus").Visible = empty
		Module._drawVariant(box, if look ~= "Normal" then look else nil)
		box:FindFirstChild("S_Lock").Visible = locked
		box:FindFirstChild("S_Price", true).Text = price
		box:FindFirstChild("CurrencyIcon", true).Image = _settings.DIAMOND_ICON
		Module._drawStroke(box, selected, empty)

		-- The price and its picture centred as one (again once the new price's TextBounds arrive)
		Module._centrePrice(box)
	end

	--[[ Emotes ]]

	-- EMOTES moves up a row for each row of cards not shown (the basic weapon, the open slots and the next one)
	local shownRows: number = math.ceil((1 + math.min(unlocked + 1, _settings.MAX_SLOTS)) / _settings.SLOTS_PER_ROW)
	local padding: number = elems["Slots"]:FindFirstChildOfClass("UIListLayout").Padding.Scale
	local rowStep: number = (rows[1].Size.Y.Scale + padding) * elems["Slots"].Size.Y.Scale
	elems["EmoteSection"].Position = UDim2.fromScale(0, emotesTop - (#rows - shownRows) * rowStep)

	--[[ Picking ]]

	-- While the picker is open the panel draws over its dim, and EMOTES makes way
	moduleGui.DisplayOrder = if selectedSlot then _settings.PICKING_DISPLAY_ORDER else panelOrder
	elems["EmoteSection"].Visible = selectedSlot == nil

	--[[ Look Tab ]]

	Module._drawLooks(rowStep)
end

--%%%%%%%%%%%%%%%%%%%% Draw Looks

--[[
	Shows the look tab beside the card it opened from, its top on that card's row, while its weapon has a look past
	Normal: one card per look in its foil or rim, the worn one selected and tagged EQUIPPED, a look not had yet locked with how it opens
	("Level 90", "100 copies").
]]
function Module._drawLooks(rowStep: number)
	--[[ Local Variables ]]

	local localPlayer: Player = I.S.Players.LocalPlayer
	local best: string = if lookItem then I.G_Loadout.GetBestLook(localPlayer, lookItem) else "Normal"

	--[[ Checks ]]

	-- Check if the tab is open on a weapon with a look to pick
	elems["Looks"].Visible = lookItem ~= nil and best ~= "Normal"
	if not lookItem or best == "Normal" then
		return
	end

	--[[ Local Variables ]]

	local worn: string = I.G_Loadout.GetWornLook(localPlayer, lookItem)
	local item = I.G_Inventory.Items[lookItem] --- @type Inventory_ItemData?
	local icon: string = if lookItem == _settings.BASIC_WEAPON then I.G_Arsenal.Get(lookItem).Icon elseif item then item.IconId else ""
	local row: number = math.ceil(lookCell / _settings.SLOTS_PER_ROW)

	--[[ Placing ]]

	elems["Looks"].Position = UDim2.fromScale(elems["Looks"].Position.X.Scale, (row - 1) * rowStep)

	--[[ Cards ]]

	for look: string, card: ImageButton in pairs(lookCards) do
		local had: boolean = I.G_Loadout.GetLookRank(look) <= I.G_Loadout.GetLookRank(best)
		card:FindFirstChild("S_Icon").Image = icon
		card:FindFirstChild("S_Name").Text = look
		Module._drawVariant(card, if look ~= "Normal" then look else nil)

		-- The worn look's tag says EQUIPPED, in the picker's equipped green
		card:FindFirstChild("S_Shiny").Visible = look == worn
		card:FindFirstChild("S_ShinyText", true).Text = "Equipped"
		card:FindFirstChild("S_ShinyGradient", true).Color = elems["LookCards"]:GetAttribute("Look_WornTag")
		card:FindFirstChild("S_Lock").Visible = not had
		card:FindFirstChild("S_Price", true).Text = if had then "" else I.G_Loadout.GetLookUnlock(lookItem, look)
		Module._drawStroke(card, look == worn, false)
	end
end

--%%%%%%%%%%%%%%%%%%%% Draw Stroke

--[[
	Draws a card's outline: the selected look (white), the empty slot's darker one, or the usual grey.
]]
function Module._drawStroke(box: ImageButton, selected: boolean, empty: boolean)
	--[[ Local Variables ]]

	local background: Frame = box:FindFirstChild("Background")
	local stroke: ImageLabel = background:FindFirstChild("Stroke")

	--[[ Applying ]]

	background:FindFirstChild("Stroke2").Image = box:GetAttribute(if selected then "Look_SelectedStroke2" else "Look_Stroke2")
	stroke.Image = box:GetAttribute(if selected then "Look_SelectedStroke" else "Look_Stroke")
	stroke.ImageColor3 = box:GetAttribute(if selected then "Look_SelectedStrokeColor" elseif empty then "Look_EmptyStrokeColor" else "Look_StrokeColor")
end

--%%%%%%%%%%%%%%%%%%%% Draw Variant

--[[
	Shows a card's Shiny or Golden tag (its word in the variant's colours) and its holo foil or gold rim, or neither.
]]
function Module._drawVariant(box: ImageButton, variant: string?)
	--[[ Local Variables ]]

	local background: Frame = box:FindFirstChild("Background")
	local tag: Frame = box:FindFirstChild("S_Shiny")

	--[[ Applying ]]

	tag.Visible = variant ~= nil
	tag:FindFirstChild("S_ShinyText").Text = variant or ""
	tag:FindFirstChild("S_ShinyGradient").Color = box:GetAttribute(if variant == "Golden" then "Look_GoldenTag" else "Look_ShinyTag")
	background:FindFirstChild("S_Foil").Visible = variant == "Shiny"
	background:FindFirstChild("S_Gold").Visible = variant == "Golden"
end

--%%%%%%%%%%%%%%%%%%%% Open Picker

--[[
	**CLIENT** |
	Opens the picker for an open slot, or for the Bazooka (slot 0), showing its card selected, and the look tab beside
	it for the weapon in it.
]]
function Module.OpenPicker(slot: number)
	--[[ Data ]]

	local itemId: string = if slot == 0 then _settings.BASIC_WEAPON else moduleRep and moduleRep:GetAttribute(`Slot{slot}`) or ""

	--[[ Saving ]]

	selectedSlot = slot
	lookItem = if itemId ~= "" then itemId else nil
	lookCell = slot + 1

	--[[ Opening ]]

	Module._refresh()
	openPicker(slot)
end

--%%%%%%%%%%%%%%%%%%%% Pick Look

--[[
	Asks the server to put the look tab's weapon in a look the player has; the cards redraw when its WeaponLooks
	attribute changes.
]]
function Module._pickLook(look: string)
	--[[ Checks ]]

	-- Check if the tab is open on a weapon
	if not lookItem then
		return
	end

	-- Check if the look is one the player has
	if I.G_Loadout.GetLookRank(look) > I.G_Loadout.GetLookRank(I.G_Loadout.GetBestLook(I.S.Players.LocalPlayer, lookItem)) then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("Loadout_SetLook", lookItem, look)
end

--%%%%%%%%%%%%%%%%%%%% Close Looks

--[[
	Shuts the look tab.
]]
function Module._closeLooks()
	--[[ Saving ]]

	lookItem = nil

	--[[ Drawing ]]

	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%% On Slot Pressed

--[[
	Opens the picker for an open slot; for the next locked one, asks whether to open it with its diamonds (naming the
	Robux price too), and when the diamonds aren't there offers the slot's own product (SLOT_PRODUCTS) instead.
]]
function Module._onSlotPressed(slot: number)
	--[[ Local Variables ]]

	local unlocked: number = moduleRep and moduleRep:GetAttribute("Unlocked") or _settings.BASE_SLOTS

	--[[ Opening ]]

	if slot <= unlocked then
		Module.OpenPicker(slot)
		return
	end

	--[[ Local Variables ]]

	local diamonds: string? = _settings.DIAMOND_SLOT_PRICES[slot]
	local product: string? = _settings.SLOT_PRODUCTS[slot]
	local robux: string? = if product then Module._getProductPrice(product) else nil
	local orRobux: string = if robux and robux ~= "..." and robux ~= "-" then ` (or R$ {robux})` else ""

	--[[ Checks ]]

	-- Check if the slot has a price (MAX_SLOTS reached)
	if not diamonds then
		return
	end

	--[[ Unlocking ]]

	I.WidgetManager.ShowConfirmation(`Open slot {slot} for {I.Format.Text(diamonds)} diamonds?{orRobux}`, function()
		if I.Network.Invoke("Loadout_UnlockSlot", slot) then
			return
		end
		-- Not enough diamonds: the same slot for Robux, when it has a product
		if not product then
			I.WidgetManager.ShowMessage("Not enough diamonds yet.")
			return
		end
		task.defer(function()
			I.WidgetManager.ShowConfirmation(`Not enough diamonds yet. Open slot {slot} now with Robux{if orRobux ~= "" then ` for R$ {robux}` else ""}?`, function()
				I.Network.Fire("Marketplace_PromptProductPurchase", product)
			end)
		end)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Centre Price

--[[
	Centres a locked slot's price and its diamond picture under the lock as one, whatever the price's length
	("2,500", "199", "..."): the text moves right by half the picture and its gap (the card's Look_PriceGap of the
	picture's width), and the picture sits that gap left of the text's first letter.
]]
function Module._centrePrice(box: ImageButton)
	--[[ Elements ]]

	local price: TextLabel = box:FindFirstChild("S_Price", true)
	local icon: ImageLabel = price:FindFirstChild("CurrencyIcon")

	--[[ Local Variables ]]

	local iconWidth: number = icon.AbsoluteSize.X
	local gap: number = iconWidth * box:GetAttribute("Look_PriceGap")

	--[[ Placing ]]

	price.Position = UDim2.new(0.5, (iconWidth + gap) / 2, price.Position.Y.Scale, 0)
	icon.Position = UDim2.new(0.5, -price.TextBounds.X / 2 - gap, 0.5, 0)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Product Price

--[[
	Returns a slot product's Robux price, or "..." while Roblox hasn't answered yet; the first call asks, then redraws
	the panel with the price.
]]
--- @return string
function Module._getProductPrice(productName: string)
	--[[ Checks ]]

	-- Check if the price is known or already asked for
	if productPrices[productName] then
		return productPrices[productName]
	end

	--[[ Fetching ]]

	productPrices[productName] = "..."
	task.spawn(function()
		local price: (string | number)? = I.G_Marketplace.GetProductPrice(productName, Enum.InfoType.Product, false)
		productPrices[productName] = if price then I.Format.Text(tostring(price)) else "-"
		Module._refresh()
	end)

	--[[ Returning ]]

	return productPrices[productName]
end

return Module
