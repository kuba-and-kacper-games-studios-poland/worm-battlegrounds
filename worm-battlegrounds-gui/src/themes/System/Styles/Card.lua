--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = {
		Radius = "Card",
		Padding = "M",
		Gap = "XS",
		Fill = "Background",
		Stroke = "BorderStrong",
		StrokeThickness = "Thick",
		CaptionFont = "Hint",
		CaptionSize = "Caption",
		Caption = "TextDim",
		Font = "Body",
		TextSize = "Heading",
		Text = "Text",
		StatusFont = "Hint",
		StatusSize = "Small",
		Status = "Success",
	},

	--[[ Variants ]]

	Subtle = { Stroke = "Border" },
	Filled = { Fill = "Surface", Stroke = "Border" },
}

return _styles
