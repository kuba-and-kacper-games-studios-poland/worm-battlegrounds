--[[
	Created By: 	Nari
]]

--- @type UmeGui_Tokens
local _tokens = {

	--[[ Palette ]]

	Palette = {
		Night = {
			-- Cream panels and white cards, like the toy bricks in the art
			Background = Color3.fromRGB(255, 241, 208),
			Surface = Color3.fromRGB(255, 255, 255),
			SurfaceHover = Color3.fromRGB(250, 246, 236),
			SurfacePressed = Color3.fromRGB(236, 230, 216),
			SurfaceEdge = Color3.fromRGB(204, 192, 170),
			PanelEdge = Color3.fromRGB(222, 190, 128),

			Border = Color3.fromRGB(90, 76, 70),
			BorderStrong = Color3.fromRGB(26, 20, 30),

			-- White text with a dark outline; dim text is a warm brown on its own
			Text = Color3.fromRGB(255, 255, 255),
			TextDim = Color3.fromRGB(118, 96, 78),
			TextMuted = Color3.fromRGB(170, 154, 138),
			InverseText = Color3.fromRGB(255, 255, 255),

			Track = Color3.fromRGB(70, 58, 64),
			Accent = Color3.fromRGB(255, 200, 40),
			AccentEdge = Color3.fromRGB(204, 138, 8),
			Success = Color3.fromRGB(70, 190, 50),
			Danger = Color3.fromRGB(238, 62, 50),
			DangerEdge = Color3.fromRGB(166, 32, 24),
			Warning = Color3.fromRGB(255, 160, 20),

			--[[ Game ]]

			Primary = Color3.fromRGB(98, 206, 48),
			PrimaryHover = Color3.fromRGB(116, 222, 64),
			PrimaryPressed = Color3.fromRGB(80, 182, 36),
			PrimaryEdge = Color3.fromRGB(46, 138, 22),
			Banner = Color3.fromRGB(255, 146, 26),
			BannerEdge = Color3.fromRGB(202, 92, 8),
		},
	},

	--[[ Text ]]

	-- A chunky display font for titles, a round one for the rest (both have one weight)
	Font = {
		Hint = { Family = "rbxasset://fonts/families/FredokaOne.json", Weight = "Regular" },
		Body = { Family = "rbxasset://fonts/families/FredokaOne.json", Weight = "Regular" },
		Title = { Family = "rbxasset://fonts/families/LuckiestGuy.json", Weight = "Regular" },
	},

	--[[ Shape ]]

	-- Boxier than the dark look, with thicker outlines
	Radius = {
		Small = 6,
		Control = 10,
		Card = 12,
		Window = 16,
	},
	Stroke = {
		Thick = 4,
		Text = 2.5,
	},
}

return _tokens
