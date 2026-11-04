--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- A framed picture in a sky-blue well; until the art exists it shows the kit's crate
	Default = {
		Width = "Item",
		Height = "Item",
		Image = "wb-crate",
		Tint = "Text",
		Fill = "Well",
		FillTransparency = 0,
		Radius = "Card",
		Stroke = "BorderStrong",
		StrokeThickness = "Thick",
	},

	--[[ Variants ]]

	Avatar = {
		Width = "Avatar",
		Height = "Avatar",
		Image = "person",
		Fill = "Inverse",
		Tint = "InverseText",
		Radius = 999,
	},
	Thumbnail = { Width = "ThumbnailWidth", Height = "ThumbnailHeight", Radius = "Control" },
	-- A bare icon beside text, no frame
	Glyph = { Width = "Glyph", Height = "Glyph", FillTransparency = 1, StrokeThickness = "None" },
}

return _styles
