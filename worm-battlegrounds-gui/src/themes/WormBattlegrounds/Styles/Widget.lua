--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- A menu WidgetManager opens: a teal frame with a dark header bar inside its top, the title left, the close right
	Default = {
		Width = 900,
		Height = 620,
		Padding = "L",
		Gap = "M",
		Panel = {
			Fill = "Background",
			Radius = "Window",
			StrokeThickness = "Thick",
			Bevel = 2,
			BevelInset = 6,
		},

		-- The header bar: how far inside the frame it sits, its height, its width as a share of the bar's space
		HeaderInset = 8,
		BannerHeight = "Banner",
		BannerWidth = 1,
		Banner = {
			Fill = "Header",
			Radius = "Control",
			StrokeThickness = "None",
			Pattern = "wb-stripes",
		},
		Title = "Text",
		TitleFont = "Title",
		TitleSize = "Title",
		TitleStroke = "BorderStrong",
		TitleStrokeThickness = "Text",
		TitleUpper = true,
		TitleAlign = "Left",

		CloseSize = 44,
		CloseStyle = "Close",
		CloseTags = {
			Interact_Button = { Interact_ModuleName = "WidgetManager", Interact_Function = "CloseCurrent" },
			Utils_ButtonKey = { Utils_GamepadKey = "ButtonB" },
			Utils_ButtonScale = { Utils_HoverScale = 1.06, Utils_ClickScale = 0.94 },
		},
	},

	--[[ Sizes ]]

	Small = { Width = 640, Height = 460 },
	Large = { Width = 1240, Height = 820 },
}

return _styles
