--[[
	Created By: 	Nari
]]

local _localName: string = "LoadoutPickerPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- Cards: name, rarity colour, copies (0: not owned, locked), look ("" normal, "Equipped", "Selected")
--- @type { { any } }
local ITEMS = {
	{ "Grenade", Color3.fromRGB(68, 141, 224), 7, "Selected" },
	{ "Shotgun", Color3.fromRGB(167, 79, 224), 3, "Equipped" },
	{ "Uzi", Color3.fromRGB(79, 194, 97), 2, "Equipped" },
	{ "Dynamite", Color3.fromRGB(224, 176, 35), 1, "" },
	{ "Baseball bat", Color3.fromRGB(176, 176, 185), 5, "" },
	{ "Minigun", Color3.fromRGB(224, 176, 35), 0, "" },
	{ "Spider bomb", Color3.fromRGB(167, 79, 224), 0, "" },
}

-- Cards in each row, as Loadout's ITEMS_PER_ROW
local ITEMS_PER_ROW: number = 3

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

--- @class UmeGui_Guis_WormBattlegrounds_LoadoutPicker_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Items", Label = "Cards", Value = 7, Min = 0, Max = 7, Step = 1 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills the grid as Loadout's Picker does: a row per three cards, each card cloned from the row's nested
	ItemCard, the one in the slot selected, those in other slots equipped, the ones not owned locked.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local count: number = preview.Values.S_Items

	--[[ Rows ]]

	local rows = preview.Fill("PREFAB | ItemRow", math.ceil(count / ITEMS_PER_ROW)) --- @type { UmeGui_Subview }

	--[[ Cards ]]

	--- @param row UmeGui_Subview
	for rowIndex: number, row in ipairs(rows) do
		local template: ImageButton = row.Root.Instance:FindFirstChild("PREFAB | ItemCard", true)
		row.Root.Instance.LayoutOrder = rowIndex
		for column: number = 1, ITEMS_PER_ROW do
			local index: number = (rowIndex - 1) * ITEMS_PER_ROW + column
			local item = ITEMS[index] --- @type { any }?
			if not item then
				break
			end
			local card: ImageButton = template:Clone()
			local background: Frame = card:FindFirstChild("Background")
			card.Name = item[1]
			card.LayoutOrder = column
			card.Visible = true
			card:FindFirstChild("S_Name").Text = item[1]
			card:FindFirstChild("S_Rarity").ImageColor3 = item[2]
			card:FindFirstChild("S_Amount").Text = if item[3] > 0 then `x{item[3]}` else ""
			card:FindFirstChild("S_Locked").Visible = item[3] == 0
			background:FindFirstChild("Stroke2").Image = card:GetAttribute(`Look_{item[4]}Stroke2`)
			background:FindFirstChild("Stroke").Image = card:GetAttribute(`Look_{item[4]}Stroke`)
			background:FindFirstChild("Stroke").ImageColor3 = card:GetAttribute(`Look_{item[4]}StrokeColor`)
			card.Parent = template.Parent
		end
		template:Destroy()
	end
end

return Module
