--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = {
		HeaderHeight = "IconButton",
		PaddingX = "L",
		PaddingY = "XS",
		PaddingTop = "L",
		PaddingBottom = "L",
		Gap = "XS",
		ContentGap = "M",
		Font = "Title",
		TextSize = "Heading",
		Text = "Text",
		Count = "TextDim",
		Divider = "Border",

		-- Title bar: filled, fading towards the bottom (transparency at the bottom edge)
		HeaderFill = "Surface",
		HeaderFade = 0.6,
		HeaderRadius = "None",
		-- Separator line under the title bar
		Line = true,
		ChevronLeft = false,
		ChevronSize = "Symbol",
		Chevron = "TextDim",
		States = {
			Hover = { HeaderFill = "SurfaceHover" },
			Pressed = { HeaderFill = "SurfacePressed" },
		},
	},

	--[[ Variants ]]

	-- A quiet list group: no fill until hovered, no line, the chevron before the title
	Plain = {
		HeaderFill = "Background",
		HeaderFade = 0,
		HeaderRadius = "Control",
		Line = false,
		ChevronLeft = true,
		Font = "Body",
		TextSize = "Body",
		PaddingX = "S",
		Gap = "S",
	},
}

return _styles
