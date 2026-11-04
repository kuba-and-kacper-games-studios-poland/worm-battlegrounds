--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- White brick cards; the picture's placeholder in the outline's dark
	Default = {
		TextStrokeThickness = "Text",
		Tint = "BorderStrong",
		Slab = { Depth = 7, Shade = 1, Shine = 3 },
	},

	--[[ Sizes ]]

	Small = { Slab = { Depth = 5 } },
}

return _styles
