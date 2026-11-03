--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = {
		Radius = "Card",
		Fill = "Surface",
		Stroke = "Border",
		StrokeThickness = "Thick",
		Divider = "Border",
		Padding = "M",
		CaptionPadding = "S",
		Font = "Title",
		TextSize = "Heading",
		Text = "Text",
		SubFont = "Hint",
		SubSize = "Small",
		Subtext = "TextDim",

		--[[ Status ]]

		-- Message centred over the preview, as a share of its width
		StatusFont = "Hint",
		StatusSize = "Small",
		Status = "TextDim",
		StatusWidth = 0.8,
		-- How see-through the preview turns while a status shows over it
		StatusFade = 0.8,

		--[[ Lighting ]]

		-- The 3D preview's own light, the same in both modes
		Ambient = Color3.fromRGB(190, 190, 190),
		LightColor = Color3.fromRGB(180, 180, 180),
		LightDirection = Vector3.new(-0.6, -1, -0.8),
	},
}

return _styles
