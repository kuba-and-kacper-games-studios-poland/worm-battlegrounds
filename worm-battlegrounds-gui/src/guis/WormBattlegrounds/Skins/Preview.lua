--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

local _localName: string = "SkinsPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

-- The open category's pieces: name, rarity colour, owned
--- @type { { any } }
local PIECES = {
	{ "No hat", Color3.fromRGB(205, 213, 223), true },
	{ "Ten-Gallon", Color3.fromRGB(140, 235, 46), true },
	{ "Red Hachimaki", Color3.fromRGB(38, 198, 255), true },
	{ "Plumed Helm", Color3.fromRGB(38, 198, 255), true },
	{ "Captain's Tricorn", Color3.fromRGB(140, 235, 46), false },
	{ "Ringmaster Topper", Color3.fromRGB(38, 198, 255), false },
	{ "Lich Crown", Color3.fromRGB(255, 181, 31), false },
	{ "Field Helmet", Color3.fromRGB(140, 235, 46), false },
}

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

--- @class UmeGui_Guis_WormBattlegrounds_Skins_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Pieces", Label = "Pieces", Value = 8, Min = 1, Max = 8, Step = 1 },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Shows the screen as the Cosmetics module draws it: HATS open and fanned out, its pieces in the grid with the second
	one worn (the tile's selected look) and the unowned ones locked.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Decks ]]

	for _index: number, slot: string in ipairs({ "Hat", "Neck", "Body", "Shell" }) do
		local deck: ImageButton = preview.View:Get("U_Deck" .. slot).Instance
		local background: Frame = deck:FindFirstChild("Background")
		local open: boolean = slot == "Hat"
		background:FindFirstChild("Stroke2").Image = deck:GetAttribute(if open then "Look_OpenStroke2" else "Look_Stroke2")
		background:FindFirstChild("Stroke").Image = deck:GetAttribute(if open then "Look_OpenStroke" else "Look_Stroke")
		background:FindFirstChild("Stroke").ImageColor3 = deck:GetAttribute(if open then "Look_OpenStrokeColor" else "Look_StrokeColor")
		deck:FindFirstChild("S_Name").TextColor3 = deck:GetAttribute(if open then "Look_OpenTextColor" else "Look_TextColor")
		for _cardIndex: number, card: Instance in ipairs(deck:FindFirstChild("S_Fan"):GetChildren()) do
			card.Position = card:GetAttribute(if open then "Look_OpenPosition" else "Look_ClosedPosition")
		end
	end

	--[[ Tiles ]]

	local tiles = preview.Fill("PREFAB | PieceTile", preview.Values.S_Pieces) --- @type { UmeGui_Subview }

	--- @param tile UmeGui_Subview
	for index: number, tile in ipairs(tiles) do
		local root: GuiObject = tile.Root.Instance
		local background: Frame = root:FindFirstChild("Background")
		local worn: boolean = index == 2
		tile:Get("S_Name").Instance.Text = PIECES[index][1]
		tile:Get("S_Rarity").Instance.ImageColor3 = PIECES[index][2]
		tile:Get("S_Locked").Instance.Visible = not PIECES[index][3]
		tile:Get("S_Worn").Instance.Visible = worn
		background:FindFirstChild("Stroke2").Image = root:GetAttribute(if worn then "Look_SelectedStroke2" else "Look_Stroke2")
		background:FindFirstChild("Stroke").Image = root:GetAttribute(if worn then "Look_SelectedStroke" else "Look_Stroke")
		background:FindFirstChild("Stroke").ImageColor3 = root:GetAttribute(if worn then "Look_SelectedStrokeColor" else "Look_StrokeColor")
	end
end

return Module
