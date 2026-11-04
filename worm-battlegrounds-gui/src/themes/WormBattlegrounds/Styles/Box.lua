--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- A recessed row inside a panel or widget (a match, a crate, a stats block)
	Default = {
		AutoHeight = true,
		Flex = false,
		Padding = "M",
		Gap = "S",
		Slab = { Fill = "Surface", Radius = "Card", StrokeThickness = "Thin" },
		-- The title's header band: its slab, height, inset from the box's edge and side padding
		Band = { Fill = "Header", Radius = "Small", StrokeThickness = "None", Pattern = "wb-stripes" },
		BandHeight = "BandSmall",
		BandInset = 4,
		BandPadding = "S",
		Title = "Text",
		TitleFont = "Title",
		TitleSize = "Body",
		TitleStroke = "BorderStrong",
		TitleStrokeThickness = "Text",
		TitleUpper = true,
		TitleAlign = "Left",
	},

	--[[ Variants ]]

	-- A framed panel placed on the screen (lobby panels, hud blocks)
	Panel = {
		Padding = "L",
		Gap = "M",
		Slab = {
			Fill = "Background",
			Radius = "Window",
			StrokeThickness = "Thick",
			Bevel = 2,
			BevelInset = 6,
		},
		Band = { Radius = "Control" },
		BandHeight = "Band",
		BandInset = 8,
		BandPadding = "M",
		TitleSize = "Heading",
	},
	-- Doesn't grow with its content: takes its column's free height, or its node's size (a box a Scroll fills)
	Fixed = { AutoHeight = false, Flex = true },
}

return _styles
