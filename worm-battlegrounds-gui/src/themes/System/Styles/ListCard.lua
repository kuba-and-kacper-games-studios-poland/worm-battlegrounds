--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = {
		Radius = "Card",
		Padding = "M",
		Gap = "M",
		ActionGap = "Buttons",
		Fill = "Background",
		Stroke = "BorderStrong",
		StrokeThickness = "Thick",
		Font = "Title",
		TextSize = "Body",
		Text = "Text",
		SubFont = "Hint",
		SubSize = "Small",
		Subtext = "TextDim",
		ActionStyle = "Small",
	},

	--[[ Variants ]]

	Subtle = { Stroke = "Border" },
}

return _styles
