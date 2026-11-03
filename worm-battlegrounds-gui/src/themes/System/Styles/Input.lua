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
		Text = "Text",
		Placeholder = "TextDim",
		-- Glyph left of the text (Icon param)
		IconSize = "Symbol",
		Icon = "TextDim",
		IconGap = "S",
		Font = "Body",
		TextSize = "Body",
		-- Field label above the box
		LabelFont = "Body",
		LabelSize = "Body",
		LabelColor = "Text",
		States = {
			Selected = { Fill = "Surface" },
		},
	},

	--[[ Variants ]]

	Small = { Height = "ControlSmall" },
}

return _styles
