--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- Outlined button (Remove, Bake, Edit)
	Default = {
		Height = "Control",
		Radius = "Control",
		PaddingX = "L",
		Fill = "Background",
		Stroke = "BorderStrong",
		StrokeThickness = "Thick",
		Text = "Text",
		Font = "Body",
		TextSize = "Body",
		States = {
			Selected = { Fill = "Inverse", Text = "InverseText", Stroke = "BorderStrong" },
			Hover = { Fill = "SurfaceHover" },
			Pressed = { Fill = "SurfacePressed" },
			SelectedHover = { Fill = "InverseHover" },
			SelectedPressed = { Fill = "InversePressed" },
			Disabled = { Fill = "Background", Text = "TextMuted", Stroke = "Border" },
		},
		Tags = {
			Utils_ButtonScale = { Utils_HoverScale = 1, Utils_ClickScale = 0.97 },
		},
	},

	--[[ Variants ]]

	-- Filled call to action (Update)
	Primary = {
		Fill = "Inverse",
		Text = "InverseText",
		Stroke = "BorderStrong",
		States = {
			Hover = { Fill = "InverseHover" },
			Pressed = { Fill = "InversePressed" },
		},
	},
	Small = { Height = "ControlSmall", PaddingX = "M", TextSize = "Small" },
	Danger = { Text = "Danger", Stroke = "Danger" },
	-- No outline until hovered
	Ghost = { StrokeThickness = "None" },
}

return _styles
