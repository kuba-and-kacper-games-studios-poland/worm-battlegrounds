--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = {
		Radius = "Control",
		Fill = "Surface",
		Stroke = "BorderStrong",
		StrokeThickness = "Thick",
		Padding = "XS",
		-- Space the menu keeps from the gui's edges
		Margin = "M",
		MinWidth = 132,

		--[[ Items ]]

		ItemHeight = "Row",
		ItemRadius = "Small",
		ItemHover = "SurfaceHover",
		PaddingX = "S",
		Font = "Body",
		TextSize = "Body",
		Text = "Text",
		DangerText = "Danger",
		IconSize = "Symbol",
		IconGap = "S",
	},
}

return _styles
