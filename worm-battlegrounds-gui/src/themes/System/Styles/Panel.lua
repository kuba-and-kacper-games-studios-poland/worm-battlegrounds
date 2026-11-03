--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = { Fill = "Background", Padding = "None", Gap = "None" },

	--[[ Variants ]]

	-- Pads its content, for panels without Scroll/Footer sections
	Padded = { Padding = "L", Gap = "M" },
}

return _styles
