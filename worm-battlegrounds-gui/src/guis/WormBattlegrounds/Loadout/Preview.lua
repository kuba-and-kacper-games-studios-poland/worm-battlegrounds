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

-- The locked slot's price and picture: coins for slot 4, Robux for slots 5 and 6, as Loadout's Panel shows them
local COIN_PRICE: string = "2,500"
local ROBUX_PRICE: string = "149"
local COIN_ICON: string = "rbxassetid://123804836570291"
local ROBUX_ICON: string = "rbxasset://textures/ui/common/robux@3x.png"

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
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the panel as Loadout's Panel does: the basic weapon, then filled, empty, picked and locked slots, two a row
	(a lone last card on the right), and EMOTES right under the last row shown.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local unlocked: number = preview.Values.S_Unlocked

	--[[ Slots ]]

	local cards = preview.Fill("PREFAB | Slot", #ITEMS) --- @type { UmeGui_Subview }

	--- @param card UmeGui_Subview
	for cell: number, card in ipairs(cards) do
		local root: ImageButton = card.Root.Instance
		local slot: number = cell - 1
		local item: string = ITEMS[cell]
		local locked: boolean = slot > unlocked
		local empty: boolean = item == "" and not locked
		local selected: boolean = slot > 0 and slot == preview.Values.S_Selected
		local stroke: ImageLabel = root:FindFirstChild("Background"):FindFirstChild("Stroke")

		root.LayoutOrder = cell
		root.Visible = slot <= unlocked + 1
		root.Parent = preview.View:Get(`U_Row{math.ceil(cell / SLOTS_PER_ROW)}`).Instance
		card:Get("S_Number").Instance.Text = tostring(cell)
		card:Get("S_Number").Instance.Visible = item ~= "" and not locked
		card:Get("S_Name").Instance.Text = if locked then "" else item
		card:Get("S_Icon").Instance.Visible = item ~= "" and not locked
		card:Get("S_Amount").Instance.Text = if item ~= "" and not locked and cell > 1 then "x3" else ""
		card:Get("S_Plus").Instance.Visible = empty
		card:Get("S_Shiny").Instance.Visible = cell == 2 and preview.Values.S_Shiny
		card:Get("S_Lock").Instance.Visible = locked
		card:Get("S_Price").Instance.Text = if slot == 4 then COIN_PRICE else ROBUX_PRICE
		card:Get("S_Price").Instance:FindFirstChild("CurrencyIcon").Image = if slot == 4 then COIN_ICON else ROBUX_ICON
		root:FindFirstChild("Background"):FindFirstChild("Stroke2").Image = root:GetAttribute(if selected then "Look_SelectedStroke2" else "Look_Stroke2")
		stroke.Image = root:GetAttribute(if selected then "Look_SelectedStroke" else "Look_Stroke")
		stroke.ImageColor3 = root:GetAttribute(if selected then "Look_SelectedStrokeColor" elseif empty then "Look_EmptyStrokeColor" else "Look_StrokeColor")
	end

	--[[ Emotes ]]

	local slots: Frame = preview.View:Get("U_Slots").Instance
	local shownRows: number = math.ceil((1 + math.min(unlocked + 1, #ITEMS - 1)) / SLOTS_PER_ROW)
	local maxRows: number = math.ceil(#ITEMS / SLOTS_PER_ROW)
	local padding: number = slots:FindFirstChildOfClass("UIListLayout").Padding.Scale
	local rowStep: number = (preview.View:Get("U_Row1").Instance.Size.Y.Scale + padding) * slots.Size.Y.Scale
	preview.View:Get("U_EmoteSection").Instance.Position = UDim2.fromScale(0, EMOTES_TOP - (maxRows - shownRows) * rowStep)
end

return Module
