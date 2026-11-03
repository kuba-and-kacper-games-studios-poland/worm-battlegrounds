--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- A row of a pick list in a ListBox: its box's fill until hovered, filled while selected
	Default = {
		Height = "Row",
		Radius = "Small",
		PaddingX = "S",
		Fill = "Surface",
		Text = "Text",
		Font = "Body",
		TextSize = "Body",
		States = {
			Selected = { Fill = "Inverse", Text = "InverseText" },
			Hover = { Fill = "SurfaceHover" },
			Pressed = { Fill = "SurfacePressed" },
			SelectedHover = { Fill = "InverseHover" },
			SelectedPressed = { Fill = "InversePressed" },
			Disabled = { Text = "TextMuted" },
		},
	},
}

return _styles
