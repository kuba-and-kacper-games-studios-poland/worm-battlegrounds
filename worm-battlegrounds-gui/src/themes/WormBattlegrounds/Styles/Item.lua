--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- A tile for one thing (a weapon, a slot, a crate result, a diamond pack): the outline shows its rarity
	Default = {
		Width = "Item",
		Height = "ItemTall",
		Padding = "XS",
		Gap = 4,
		Fill = "Tile",
		Stroke = "BorderStrong",
		BevelColor = "TileBevel",
		Slab = { Radius = "Card", StrokeThickness = "Thick", Bevel = 2, BevelInset = 3 },
		-- The name strip: its fill and height
		StripFill = "Strip",
		StripHeight = 28,
		-- The picture: a placeholder until the art exists, its well's fill, its share of the well
		Image = "wb-crate",
		Tint = "Text",
		IconFill = "Well",
		IconScale = 0.82,
		Text = "InverseText",
		TextStroke = "BorderStrong",
		TextStrokeThickness = "None",
		Upper = true,
		Font = "Title",
		TextSize = "Small",
		Subtext = "Text",
		SubtextFont = "Body",
		SubtextSize = "Caption",
		States = {
			Hover = { Fill = "TileHover" },
			Pressed = { Fill = "TilePressed" },
		},
		Tags = {
			Utils_ButtonScale = { Utils_HoverScale = 1.04, Utils_ClickScale = 0.96 },
			Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
		},
	},

	--[[ Sizes ]]

	-- A square slot (loadout bar, emote row)
	Square = { Height = "Item" },
	Small = {
		Width = "BarSlot",
		Height = "BarSlot",
		Padding = 4,
		StripHeight = 22,
		TextSize = "Caption",
		IconScale = 0.9,
		Slab = { BevelInset = 2 },
	},

	--[[ Rarities ]]

	Common = { Stroke = "Common" },
	Uncommon = { Stroke = "Uncommon" },
	Rare = { Stroke = "Rare" },
	Epic = { Stroke = "Epic" },
	Legendary = { Stroke = "Legendary" },
}

return _styles
