--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	Default = {
		-- Backdrop dimming the gui behind
		Backdrop = "Overlay",
		BackdropTransparency = 0.6,
		ZIndex = 900,

		-- Card
		Margin = "L",
		MaxWidth = 300,
		Fill = "Background",
		Radius = "Card",
		Stroke = "Border",
		StrokeThickness = "Thick",
		Shadow = "Overlay",
		ShadowTransparency = 0.5,
		ShadowBlur = 16,
		ShadowOffset = 4,
		Padding = "L",
		Gap = "M",

		-- Texts and buttons
		TitleStyle = "Heading",
		TextStyle = { "Small", "Dim" },
		ErrorStyle = { "Small", "Danger" },
		CancelStyle = "Small",
		ConfirmStyle = { "Small", "Primary" },
		DangerStyle = { "Small", "Danger" },
	},
}

return _styles
