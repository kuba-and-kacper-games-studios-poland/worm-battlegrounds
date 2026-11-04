--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- A slanted yellow banner behind a big title
	Default = {
		-- Its share of the column's width, and its height
		Width = 0.62,
		Height = 116,
		Image = "wb-ribbon",
		-- The banner image's height and its 9-slice centre, in px of the PNG
		ImageHeight = 192,
		SliceCenter = Rect.new(72, 92, 440, 100),
		Tint = "Primary",
		-- Room for the slanted ends
		PaddingX = 64,
		Gap = 0,
		-- Sunburst rays behind it: shown, size, where along its width, colour, how see-through, degrees a second
		Rays = false,
		RaysSize = 560,
		RaysX = 0.3,
		RaysColor = "Text",
		RaysTransparency = 0.8,
		RaysSpeed = 8,
	},

	--[[ Variants ]]

	Blue = { Tint = "Secondary" },
	Red = { Tint = "Danger" },
	-- Rays turning behind the banner
	Sunburst = { Rays = true },
}

return _styles
