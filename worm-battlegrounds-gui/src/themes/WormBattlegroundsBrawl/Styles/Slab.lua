--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- The kit's surface: these keys come on top of the base theme's (fill, radius, pattern)
	Default = {
		-- A kit skin (a wb-skin- icon name, "" is none), its slice scale (the PNGs are 2x) and its tint
		Skin = "",
		SkinScale = 0.5,
		SkinTint = "Text",
		-- The ink drop under a raised skin (px, 0 is none) and how see-through it is
		Drop = 0,
		DropTransparency = 0.65,
		-- The body: none by default; how far inside the piece it sits, how see-through it is
		Fill = "",
		FillTransparency = 0,
		Inset = 0,
		-- A ColorSequence from the gradient library, top to bottom (false is a plain fill)
		Gradient = false,
		-- How much clearer the body's bottom is than its top (a slot fades from 30 % to 18 % black)
		Fade = 0,
		PatternTransparency = 0.96,
		PatternSize = 96,
	},
}

return _styles
