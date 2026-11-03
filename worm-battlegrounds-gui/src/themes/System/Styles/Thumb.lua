--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- Name over the preview (gradient swatches)
	Default = {
		-- "Overlay", "Caption", "Row" or "Banner"
		Layout = "Overlay",
		Radius = "Control",
		PreviewRadius = "Control",
		Padding = "XS",
		CaptionPadding = "XS",
		Fill = "Surface",
		-- See-through card fill (1 shows only what is on the card); states can fade it in
		FillTransparency = 0,
		Stroke = "Border",
		StrokeThickness = "Thick",
		PreviewFill = "Surface",
		PreviewTransparency = 0,
		-- Share of the card's width the preview takes, centred (Overlay and Caption)
		PreviewScale = 1,
		-- A gradient multiplies this base, so it is white to show the gradient's own colors
		GradientBase = Color3.fromRGB(255, 255, 255),
		Font = "Body",
		TextSize = "Small",
		Text = "Text",
		SubFont = "Hint",
		SubSize = "Caption",
		Subtext = "TextDim",

		--[[ Glow ]]

		-- A round soft light behind the preview, so transparent images stay readable on any theme
		Glow = false,
		GlowColor = "Glow",
		GlowTransparency = 0.8,
		GlowBlur = 30,
		-- Size of the glow's circle against the preview
		GlowScale = 0.5,

		--[[ Overlay ]]

		-- An overlaid name sits centred along the top in white
		OverlayFont = "Title",
		OverlayTextSize = "Body",
		OverlayPadding = "S",
		-- Gap above the name: just enough for its outline, so it hugs the top edge
		OverlayTextTop = 2,
		OverlayText = Color3.fromRGB(255, 255, 255),
		-- The name's outline: this grey multiplied by the preview's gradient, so it follows the colors under it
		OverlayStroke = Color3.fromRGB(128, 128, 128),
		OverlayStrokeThickness = "Thick",
		OverlayStrokeTransparency = 0,

		--[[ Row ]]

		-- Preview side of a Row thumb
		RowSize = 44,

		--[[ Banner ]]

		-- Height of a Banner thumb, whose preview fills the card
		BannerHeight = 64,
		-- The scrim darkening the left of a banner's preview: its color, how see-through it starts and the share of the
		-- width where it has faded out
		Scrim = "Overlay",
		ScrimTransparency = 0.35,
		ScrimFade = 0.75,

		--[[ Heart ]]

		-- A round dark chip over the preview with a light heart, tinted when it is a favorite
		HeartSize = 18,
		-- Gap between an overlaid thumb's heart and its bottom right corner
		HeartInset = "XS",
		HeartFill = "Overlay",
		HeartFillTransparency = 0.55,
		HeartHoverTransparency = 0.3,
		-- Share of the chip the heart glyph fills
		HeartIconScale = 0.65,
		HeartIcon = Color3.fromRGB(255, 255, 255),
		HeartActive = "Favorite",
		-- Motion token for the heart fading in and out and its chip firming up
		HeartMotion = "Default",
		HeartTags = { Utils_ButtonScale = { Utils_HoverScale = 1.08, Utils_ClickScale = 0.9 } },

		-- Hovered and selected thumbs take the app's system outline (BorderStrong at the Thick 1.5 px)
		States = {
			Selected = { Stroke = "BorderStrong" },
			Hover = { Stroke = "BorderStrong", Fill = "SurfaceHover" },
			Pressed = { Fill = "SurfacePressed" },
			SelectedHover = { Stroke = "BorderStrong", Fill = "SurfaceHover" },
		},
	},

	--[[ Variants ]]

	-- Asset tiles: a smaller square image centred over a glow, the name and subtext centred under it. No outline; the
	-- card is clear until hovered
	Caption = {
		Layout = "Caption",
		PreviewRadius = "Small",
		PreviewTransparency = 1,
		PreviewScale = 0.62,
		StrokeThickness = "None",
		FillTransparency = 1,
		Glow = true,
		States = {
			Hover = { FillTransparency = 0 },
			Pressed = { FillTransparency = 0 },
		},
	},
	-- Asset list rows: a filled card with no outline, a small image over a glow on the left and the texts after it
	Row = {
		Layout = "Row",
		Padding = "S",
		PreviewRadius = "Small",
		PreviewTransparency = 1,
		StrokeThickness = "None",
		TextSize = "Body",
		Glow = true,
	},
	-- Scene rows: the preview fills the card behind white texts that sit on a dark scrim on the left
	Banner = {
		Layout = "Banner",
		Padding = "M",
		PreviewRadius = "Control",
		TextSize = "Body",
		Text = Color3.fromRGB(255, 255, 255),
		Subtext = Color3.fromRGB(225, 225, 225),
	},
}

return _styles
