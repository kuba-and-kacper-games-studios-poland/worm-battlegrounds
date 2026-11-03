--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = { Gap = "M", PaddingX = "None", PaddingY = "None" },

	--[[ Spacing ]]

	None = { Gap = "None" },
	Tight = { Gap = "XS" },
	Snug = { Gap = "S" },
	-- Rows of buttons
	Buttons = { Gap = "Buttons" },
	Loose = { Gap = "L" },

	--[[ Padding ]]

	-- A toolbar row along a panel edge, inset like a tab bar
	Bar = { PaddingX = "L", PaddingY = "M" },
}

return _styles
