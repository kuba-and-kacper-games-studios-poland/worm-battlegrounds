--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- A filled box of ListItem rows
	Default = {
		Fill = "Surface",
		Stroke = "Border",
		StrokeThickness = "Thick",
		Radius = "Card",
		Padding = "XS",
		Gap = "None",
		-- Rows shown before it scrolls, and the height of one (a ListItem's)
		Rows = 6,
		RowHeight = "Row",
		ScrollBar = "Border",
		ScrollBarThickness = 4,
	},
}

return _styles
