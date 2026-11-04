--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- A flat framed button: teal face, navy outline, a light bevel line, outlined upper-case text
	Default = {
		Fill = "Tile",
		BevelColor = "TileBevel",
		Font = "Title",
		Text = "Text",
		TextStroke = "BorderStrong",
		TextStrokeThickness = "Text",
		Upper = true,
		Slab = { Radius = "Control", StrokeThickness = "Thick", Bevel = 2, BevelInset = 3 },
		States = {
			Selected = { Fill = "Inverse", BevelColor = "Strip", Text = "InverseText", TextStroke = "Inverse" },
			Hover = { Fill = "TileHover" },
			Pressed = { Fill = "TilePressed" },
			SelectedHover = { Fill = "InverseHover" },
			SelectedPressed = { Fill = "InversePressed" },
			Disabled = {
				Fill = "Surface",
				BevelColor = "SurfaceHover",
				Text = "TextMuted",
				Stroke = "Border",
			},
		},
		Tags = {
			Utils_ButtonScale = { Utils_HoverScale = 1.04, Utils_ClickScale = 0.95 },
			Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
		},
	},

	--[[ Variants ]]

	-- Smaller text with no outline, so short words stay crisp
	Small = { TextSize = "Caption", TextStrokeThickness = "None", PaddingX = "S" },
	-- Yellow call to action (Play, Join, Open, Buy), navy text
	Primary = {
		Fill = "Primary",
		BevelColor = "PrimaryBevel",
		Text = "InverseText",
		TextStrokeThickness = "None",
		States = {
			Hover = { Fill = "PrimaryHover" },
			Pressed = { Fill = "PrimaryPressed" },
		},
	},
	-- Red (Leave, Kick)
	Danger = {
		Fill = "Danger",
		BevelColor = "DangerBevel",
		Text = "Text",
		States = {
			Hover = { Fill = "Danger" },
			Pressed = { Fill = "Danger" },
		},
	},
	-- A widget's close button: a red square with its X
	Close = {
		Fill = "Danger",
		BevelColor = "DangerBevel",
		Text = "Text",
		TextSize = "Heading",
		PaddingX = "None",
		States = {
			Hover = { Fill = "Danger" },
			Pressed = { Fill = "Danger" },
		},
	},
}

return _styles
