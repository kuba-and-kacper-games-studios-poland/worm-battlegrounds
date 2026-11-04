--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- White brick cards with outlined titles
	Default = {
		TitleStrokeThickness = "Text",
		Slab = { Depth = 7, Shade = 1, Shine = 3 },
	},

	--[[ Variants ]]

	Panel = { Slab = { Depth = 12, Shade = 1, Shadow = 0 } },
}

return _styles
