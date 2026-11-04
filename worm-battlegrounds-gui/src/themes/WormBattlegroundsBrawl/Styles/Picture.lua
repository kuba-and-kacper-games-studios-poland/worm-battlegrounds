--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ Variants ]]

	-- A square portrait with round corners in a light-blue well, the kit's 6 px ink outline
	Avatar = { Fill = "Well", Tint = "Text", Radius = "Card", Stroke = "Ink", StrokeThickness = "Heavy" },
	AvatarLarge = {
		Width = "AvatarLarge",
		Height = "AvatarLarge",
		Image = "person",
		Fill = "Well",
		Tint = "Text",
		Radius = "Card",
		Stroke = "Ink",
		StrokeThickness = "Heavy",
	},
	-- A map or mode picture: rounded, ink outline
	Thumbnail = { Radius = "Control", Stroke = "Ink", StrokeThickness = "Heavy" },
	-- A bare picture standing on its own on a card, bigger than a glyph
	Icon = { Width = "IconLarge", Height = "IconLarge", FillTransparency = 1, StrokeThickness = "None" },
}

return _styles
