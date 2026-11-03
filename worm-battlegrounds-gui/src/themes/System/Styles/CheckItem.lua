--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- Row with a checkbox, a title and a chevron (tags in a list)
	Default = {
		-- The checkbox (Check) plus PaddingX above and below, so it sits equally far from every edge
		Height = "ControlSmall",
		Radius = "Control",
		PaddingX = "S",
		Gap = "S",
		Fill = "Background",
		-- 1 keeps the row clear until hovered, so it shows the fill of the item it sits in
		FillTransparency = 0,
		Font = "Body",
		TextSize = "Body",
		Text = "Text",
		MutedText = "TextMuted",

		--[[ Icon ]]

		IconSize = "Symbol",
		MutedIconTransparency = 0.5,

		--[[ Checkbox ]]

		BoxSize = "Check",
		BoxRadius = "Small",
		BoxFill = "Background",
		BoxStroke = "BorderStrong",
		StrokeThickness = "Thick",
		Mark = "Text",
		MarkSize = "Small",

		--[[ Chevron ]]

		ShowChevron = true,
		ChevronSize = "Symbol",
		Chevron = "TextDim",

		--[[ Details ]]

		DetailsGap = "None",
		DetailsPaddingBottom = "S",

		States = {
			Selected = { BoxFill = "Inverse", Mark = "InverseText" },
			Hover = { Fill = "SurfaceHover" },
			Pressed = { Fill = "SurfacePressed" },
			Disabled = { BoxFill = "Background", BoxStroke = "Border", Mark = "TextMuted" },
		},
	},

	--[[ Variants ]]

	-- A compact row, for sub-items listed inside another item's details
	Small = {
		Height = "RowSmall",
		Font = "Hint",
		TextSize = "Small",
		BoxSize = "CheckSmall",
		BoxRadius = 3,
		MarkSize = "Caption",
		FillTransparency = 1,
		States = {
			Hover = { FillTransparency = 0 },
			Pressed = { FillTransparency = 0 },
		},
	},
}

return _styles
