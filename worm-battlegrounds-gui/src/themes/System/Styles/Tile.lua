--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = {
		Radius = "Card",
		Padding = "S",
		ActionGap = "XS",
		Fill = "Surface",
		Stroke = "Border",
		StrokeThickness = "Thick",
		Divider = "Border",
		CaptionFill = "Background",
		CaptionPadding = "S",
		Font = "Body",
		TextSize = "Small",
		Text = "Text",
		SubFont = "Hint",
		SubSize = "Caption",
		Subtext = "TextDim",
		ActionStyle = { "Builder", "Ghost" },
		States = {
			Selected = { Stroke = "BorderStrong" },
			Hover = { Stroke = "TextDim" },
			SelectedHover = { Stroke = "BorderStrong" },
		},
	},
}

return _styles
