--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- Boxed glyph (window −/×, section −)
	Default = {
		Size = "IconButton",
		Radius = "Control",
		Fill = "Background",
		Stroke = "BorderStrong",
		StrokeThickness = "Thick",
		Text = "Text",
		Font = "Body",
		TextSize = "Icon",
		-- The glyph is an icon name drawn as an image (Tokens.Icons) this big, instead of text
		Image = false,
		IconSize = "Symbol",
		-- Label that slides out right of the icon while hovered or selected (buttons with Text)
		LabelFont = "Body",
		LabelSize = "Body",
		LabelPadding = "XS",
		-- The label shows inside the button on hover instead of widening it (Wide)
		LabelInside = false,
		States = {
			Selected = { Fill = "Inverse", Text = "InverseText", Stroke = "BorderStrong" },
			Hover = { Fill = "SurfaceHover" },
			Pressed = { Fill = "SurfacePressed" },
			SelectedHover = { Fill = "InverseHover" },
			SelectedPressed = { Fill = "InversePressed" },
			Disabled = { Text = "TextMuted", Stroke = "Border" },
		},
		Tags = {
			Utils_ButtonScale = { Utils_HoverScale = 1, Utils_ClickScale = 0.94 },
		},
	},

	--[[ Variants ]]

	Ghost = { StrokeThickness = "None" },
	-- Icon is an icon name ("trash-can", "floppy-disk"), drawn as the theme's image for it
	Builder = { Image = true },
	-- Compact, for actions inline with a title; list it after Builder
	Small = { Size = "IconButtonSmall", TextSize = "Small", IconSize = "SymbolSmall" },
	-- Stretched by a Fill row at control height: the label fades in beside the glyph on hover, inside the button
	Wide = { Size = "ControlSmall", LabelInside = true, LabelFont = "Hint", LabelSize = "Small" },
}

return _styles
