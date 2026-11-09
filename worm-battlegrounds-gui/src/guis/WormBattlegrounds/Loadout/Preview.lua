--[[
	Created By: 	Nari
]]

local _localName: string = "LoadoutPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- The basic weapon, then the items in slots 1 to 5 ("" is empty), as Loadout's Panel draws them
--- @type { string }
local ITEMS = { "Bazooka", "Grenade", "Shotgun", "", "Uzi", "Dynamite" }

-- Cells in each row and the slots' prices, as Loadout's SLOTS_PER_ROW and SLOT_PRICES
local SLOTS_PER_ROW: number = 3

--- @type { [number]: string }
local SLOT_PRICES = { [4] = "2500", [5] = "6000" }

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
		{ Control = "Slider", Id = "S_Unlocked", Label = "Open slots", Value = 3, Min = 3, Max = 5, Step = 1 },
		{ Control = "Slider", Id = "S_Selected", Label = "Picking slot (0: none)", Value = 1, Min = 0, Max = 5, Step = 1 },
		{ Control = "Slider", Id = "S_Emotes", Label = "Emotes", Value = 4, Min = 1, Max = 9, Step = 1 },
		{ Control = "Toggle", Id = "S_Shiny", Label = "First item shiny", Value = false },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the panel as Loadout's Panel does: the basic weapon, filled, empty, picked and locked slots over two rows,
	then the emote row.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local unlocked: number = preview.Values.S_Unlocked
	local bottomRow: Instance = preview.View:Get("U_BottomRow").Instance

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
		if cell > SLOTS_PER_ROW then
			root.Parent = bottomRow
		end
		card:Get("S_Number").Instance.Text = tostring(cell)
		card:Get("S_Number").Instance.Visible = item ~= "" and not locked
		card:Get("S_Name").Instance.Text = if locked then "" else item
		card:Get("S_Icon").Instance.Visible = item ~= "" and not locked
		card:Get("S_Amount").Instance.Text = if item ~= "" and not locked and cell > 1 then "x3" else ""
		card:Get("S_Plus").Instance.Visible = empty
		card:Get("S_Shiny").Instance.Visible = cell == 2 and preview.Values.S_Shiny
		card:Get("S_Lock").Instance.Visible = locked
		card:Get("S_Price").Instance.Text = `{SLOT_PRICES[slot] or ""} coins`
		root:FindFirstChild("Background"):FindFirstChild("Stroke2").Image = root:GetAttribute(if selected then "Look_SelectedStroke2" else "Look_Stroke2")
		stroke.Image = root:GetAttribute(if selected then "Look_SelectedStroke" else "Look_Stroke")
		stroke.ImageColor3 = root:GetAttribute(if selected then "Look_SelectedStrokeColor" elseif empty then "Look_EmptyStrokeColor" else "Look_StrokeColor")
	end

	--[[ Emotes ]]

	local emotes = preview.Fill("PREFAB | Emote", preview.Values.S_Emotes) --- @type { UmeGui_Subview }

	--- @param emote UmeGui_Subview
	for index: number, emote in ipairs(emotes) do
		emote.Root.Instance.LayoutOrder = index
		emote:Get("S_Name").Instance.Text = `Emote {index}`
	end
end

return Module
