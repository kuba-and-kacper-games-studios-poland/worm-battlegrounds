--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

local _localName: string = "LoadoutPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- The basic weapon, then the items in slots 1 to 6 ("" is empty), as Loadout's Panel draws them
--- @type { string }
local ITEMS = { "Bazooka", "Grenade", "Shotgun", "", "Uzi", "Dynamite", "Jetpack" }

-- Cards in each row, as Loadout's SLOTS_PER_ROW
local SLOTS_PER_ROW: number = 2

-- U_EmoteSection's top in the gui, under all four rows of cards (Loadout's Panel moves it up a row per row not shown)
local EMOTES_TOP: number = 0.7764

-- The locked slot's price by slot and its diamond, as Loadout's Panel shows them (DIAMOND_SLOT_PRICES, DIAMOND_ICON)
--- @type { [number]: string }
local DIAMOND_PRICES = { [2] = "375", [3] = "1,000", [4] = "2,500", [5] = "6,000", [6] = "12,500" }
local DIAMOND_ICON: string = "rbxassetid://98200575516825"

-- The looks, plainest first (Loadout's LOOKS), and how a look not had yet opens on the example weapons
--- @type { string }
local LOOKS = { "Normal", "Shiny", "Golden" }

--- @type { [string]: string }
local LOOK_UNLOCKS = { Bazooka = "Level 90", Grenade = "Level 60" }

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

--- @class UmeGui_Guis_WormBattlegrounds_Loadout_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Unlocked", Label = "Open slots", Value = 3, Min = 3, Max = 6, Step = 1 },
		{ Control = "Slider", Id = "S_Selected", Label = "Picking slot (0: none)", Value = 1, Min = 0, Max = 6, Step = 1 },
		{ Control = "Toggle", Id = "S_Shiny", Label = "First item shiny", Value = false },
		{ Control = "Toggle", Id = "S_Golden", Label = "Second item golden", Value = false },
		{ Control = "Segmented", Id = "S_LookTab", Label = "Look tab", Options = { "Off", "Bazooka", "Slot 1" }, Value = "Bazooka" },
		{ Control = "Segmented", Id = "S_Worn", Label = "Worn look", Options = LOOKS, Value = "Golden" },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the panel as Loadout's Panel does: the basic weapon, then filled, empty, picked and locked slots, two a row
	(a lone last card on the right), a shiny card in its holo foil and a golden one in its gold rim, the lock's price
	centred with its picture, EMOTES right under the last row shown, and the look tab beside the Bazooka (it has every
	look) or slot 1 (Golden locked), the worn look selected.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local unlocked: number = preview.Values.S_Unlocked

	--[[ Slots ]]

	local cards = preview.Fill("PREFAB | Slot", #ITEMS + #LOOKS) --- @type { UmeGui_Subview }

	--- @param card UmeGui_Subview
	for cell: number, card in ipairs({ table.unpack(cards, 1, #ITEMS) }) do
		local root: ImageButton = card.Root.Instance
		local slot: number = cell - 1
		local item: string = ITEMS[cell]
		local locked: boolean = slot > unlocked
		local empty: boolean = item == "" and not locked
		local selected: boolean = slot > 0 and slot == preview.Values.S_Selected or cell == 1 and preview.Values.S_LookTab == "Bazooka"
		local golden: boolean = cell == 3 and preview.Values.S_Golden
		local shiny: boolean = cell == 2 and preview.Values.S_Shiny or golden
		local stroke: ImageLabel = root:FindFirstChild("Background"):FindFirstChild("Stroke")

		root.LayoutOrder = cell
		root.Visible = slot <= unlocked + 1
		root.Parent = preview.View:Get(`U_Row{math.ceil(cell / SLOTS_PER_ROW)}`).Instance
		card:Get("S_Number").Instance.Text = tostring(cell)
		card:Get("S_Number").Instance.Visible = item ~= "" and not locked
		card:Get("S_Name").Instance.Text = if locked then "" else item
		card:Get("S_Icon").Instance.Visible = item ~= "" and not locked
		card:Get("S_Amount").Instance.Text = if item ~= "" and not locked and cell > 1 then "x3" else ""
		card:Get("S_Amount").Instance.Visible = item ~= "" and not locked and cell > 1
		card:Get("S_Plus").Instance.Visible = empty
		card:Get("S_Shiny").Instance.Visible = shiny
		card:Get("S_ShinyText").Instance.Text = if golden then "Golden" else "Shiny"
		card:Get("S_ShinyGradient").Instance.Color = root:GetAttribute(if golden then "Look_GoldenTag" else "Look_ShinyTag")
		card:Get("S_Foil").Instance.Visible = shiny and not golden
		card:Get("S_Gold").Instance.Visible = golden
		card:Get("S_Lock").Instance.Visible = locked
		card:Get("S_Price").Instance.Text = DIAMOND_PRICES[slot] or ""
		card:Get("S_Price").Instance:FindFirstChild("CurrencyIcon").Image = DIAMOND_ICON
		root:FindFirstChild("Background"):FindFirstChild("Stroke2").Image = root:GetAttribute(if selected then "Look_SelectedStroke2" else "Look_Stroke2")
		stroke.Image = root:GetAttribute(if selected then "Look_SelectedStroke" else "Look_Stroke")
		stroke.ImageColor3 = root:GetAttribute(if selected then "Look_SelectedStrokeColor" elseif empty then "Look_EmptyStrokeColor" else "Look_StrokeColor")

		-- The lock's price and its picture centred as one, as Loadout's Panel does (again once its TextBounds arrive)
		Module._centrePrice(root)
		card:Get("S_Price").Instance:GetPropertyChangedSignal("TextBounds"):Connect(function()
			Module._centrePrice(root)
		end)
	end

	--[[ Emotes ]]

	local slots: Frame = preview.View:Get("U_Slots").Instance
	local shownRows: number = math.ceil((1 + math.min(unlocked + 1, #ITEMS - 1)) / SLOTS_PER_ROW)
	local maxRows: number = math.ceil(#ITEMS / SLOTS_PER_ROW)
	local padding: number = slots:FindFirstChildOfClass("UIListLayout").Padding.Scale
	local rowStep: number = (preview.View:Get("U_Row1").Instance.Size.Y.Scale + padding) * slots.Size.Y.Scale
	preview.View:Get("U_EmoteSection").Instance.Position = UDim2.fromScale(0, EMOTES_TOP - (maxRows - shownRows) * rowStep)

	--[[ Look Tab ]]

	Module._fillLooks(preview, { table.unpack(cards, #ITEMS + 1) }, rowStep)
end

--%%%%%%%%%%%%%%%%%%%% Fill Looks

--[[
	Fills the look tab as Loadout's Panel does: a slot card copy per look (no number, copies or +), the weapon's
	picture in each look's foil or rim, the worn one selected and tagged EQUIPPED, Golden locked on slot 1's Grenade with how it opens, and
	the tab moved down to the row of the card it opened from.
]]
--- @param preview UmeGui_Preview
--- @param cards { UmeGui_Subview }
function Module._fillLooks(preview, cards, rowStep: number)
	--[[ Local Variables ]]

	local tab: string = preview.Values.S_LookTab
	local looks: Frame = preview.View:Get("U_Looks").Instance
	local list: Frame = looks:FindFirstChild("S_Cards")
	local item: string = if tab == "Bazooka" then ITEMS[1] else ITEMS[2]
	local best: number = if tab == "Bazooka" then 3 else 2
	local worn: number = math.min(table.find(LOOKS, preview.Values.S_Worn) or 1, best)

	--[[ Placing ]]

	looks.Visible = tab ~= "Off"
	looks.Position = UDim2.fromScale(looks.Position.X.Scale, if tab == "Bazooka" then 0 else rowStep)

	--[[ Cards ]]

	--- @param card UmeGui_Subview
	for index: number, card in ipairs(cards) do
		local root: ImageButton = card.Root.Instance
		local look: string = LOOKS[index]
		local stroke: ImageLabel = root:FindFirstChild("Background"):FindFirstChild("Stroke")
		root.LayoutOrder = index
		root.Size = list:GetAttribute("Look_CardSize")
		root.Parent = list
		card:Get("S_Number").Instance.Visible = false
		card:Get("S_Amount").Instance.Visible = false
		card:Get("S_Plus").Instance.Visible = false
		card:Get("S_Shiny").Instance.Visible = index == worn
		card:Get("S_ShinyText").Instance.Text = "Equipped"
		card:Get("S_ShinyGradient").Instance.Color = list:GetAttribute("Look_WornTag")
		card:Get("S_Name").Instance.Text = look
		card:Get("S_Foil").Instance.Visible = look == "Shiny"
		card:Get("S_Gold").Instance.Visible = look == "Golden"
		card:Get("S_Lock").Instance.Visible = index > best
		card:Get("S_Price").Instance.Text = if index > best then LOOK_UNLOCKS[item] else ""
		card:Get("S_Price").Instance:FindFirstChild("CurrencyIcon").Visible = false
		root:FindFirstChild("Background"):FindFirstChild("Stroke2").Image = root:GetAttribute(if index == worn then "Look_SelectedStroke2" else "Look_Stroke2")
		stroke.Image = root:GetAttribute(if index == worn then "Look_SelectedStroke" else "Look_Stroke")
		stroke.ImageColor3 = root:GetAttribute(if index == worn then "Look_SelectedStrokeColor" else "Look_StrokeColor")
	end
end

--%%%%%%%%%%%%%%%%%%%% Centre Price

--[[
	Centres a locked slot's price and its picture under the lock as one, as Loadout's Panel does: the text moves right by
	half the picture and its gap (the card's Look_PriceGap of the picture's width), the picture that gap left of the text.
]]
function Module._centrePrice(root: ImageButton)
	--[[ Elements ]]

	local price: TextLabel = root:FindFirstChild("S_Price", true)
	local icon: ImageLabel = price:FindFirstChild("CurrencyIcon")

	--[[ Local Variables ]]

	local iconWidth: number = icon.AbsoluteSize.X
	local gap: number = iconWidth * root:GetAttribute("Look_PriceGap")

	--[[ Placing ]]

	price.Position = UDim2.new(0.5, (iconWidth + gap) / 2, price.Position.Y.Scale, 0)
	icon.Position = UDim2.new(0.5, -price.TextBounds.X / 2 - gap, 0.5, 0)
end

return Module
