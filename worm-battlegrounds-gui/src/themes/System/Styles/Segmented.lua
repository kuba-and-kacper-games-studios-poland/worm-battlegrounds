--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = {
		Height = "Control",
		Radius = "Control",
		Gap = "S",
		Fill = "Background",
		Stroke = "BorderStrong",
		StrokeThickness = "Thick",
		Divider = "BorderStrong",
		Text = "Text",
		Font = "Body",
		TextSize = "Small",
		LabelStyle = "Field",
		States = {
			-- The selected fill matches the outline so the box reads as one piece
			Selected = { Fill = "BorderStrong", Text = "InverseText" },
			Hover = { Fill = "SurfaceHover" },
			Pressed = { Fill = "SurfacePressed" },
			SelectedHover = { Fill = "InverseHover" },
			SelectedPressed = { Fill = "InversePressed" },
		},
	},

	--[[ Variants ]]

	Small = { Height = "ControlSmall" },
}

return _styles
