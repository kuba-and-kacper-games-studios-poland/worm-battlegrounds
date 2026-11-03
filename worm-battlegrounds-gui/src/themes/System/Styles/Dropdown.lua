--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = {
		Height = "Control",
		Radius = "Control",
		PaddingX = "S",
		Gap = "S",
		Fill = "Background",
		Stroke = "BorderStrong",
		StrokeThickness = "Thick",
		ArrowThickness = 1.5,
		Text = "Text",
		Placeholder = "TextDim",
		Arrow = "TextDim",
		Font = "Body",
		SelectedFont = "Title",
		TextSize = "Body",
		-- Field label above the box
		LabelFont = "Body",
		LabelSize = "Body",
		LabelColor = "Text",
		States = {
			Hover = { Fill = "SurfaceHover" },
		},

		--[[ Menu ]]

		ItemHeight = "Row",
		MenuPadding = "XS",
		-- Space between the box and the open menu
		MenuGap = "S",
		-- Space the open menu keeps from the gui's top and bottom edges
		MenuMargin = "M",
		-- The open menu has the same fill as the box
		MenuFill = "Background",
		MenuStroke = "BorderStrong",
		ItemText = "TextDim",
		ItemHover = "SurfaceHover",
	},

	--[[ Variants ]]

	Small = { Height = "ControlSmall" },
}

return _styles
