--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- A toy brick: flat face, deep edge, a light strip along the top, white text with a dark outline
	Default = {
		TextStrokeThickness = "Text",
		Slab = { Depth = 8, Shade = 1, Shine = 4 },
		States = {
			Selected = { Text = "Text" },
		},
	},
}

return _styles
