--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- A flat framed surface: the controls that draw on one pass their own Slab record over this
	Default = {
		Fill = "Surface",
		Stroke = "BorderStrong",
		StrokeThickness = "Thick",
		Radius = "Card",
		-- Thickness of the light line inside the face's edge (0 is none), and how far in it sits
		Bevel = 0,
		BevelColor = "Bevel",
		BevelInset = 4,
		-- An icon name tiled over the face ("" is none), its transparency and tile size in px
		Pattern = "",
		PatternTransparency = 0.9,
		PatternSize = 24,
	},
}

return _styles
