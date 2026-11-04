--[[
	Created By: 	Nari
]]

--- @type UmeGui_Tokens
local _tokens = {

	--[[ Palette ]]

	Palette = {
		Night = {
			-- Teal frames with a light bevel line inside their edge
			Background = Color3.fromRGB(38, 120, 136),
			Bevel = Color3.fromRGB(112, 192, 205),
			-- The dark bars titles sit on (widget headers, box bands)
			Header = Color3.fromRGB(20, 66, 80),

			-- Recessed rows inside a frame
			Surface = Color3.fromRGB(28, 96, 111),
			SurfaceHover = Color3.fromRGB(34, 108, 124),
			SurfacePressed = Color3.fromRGB(24, 84, 98),

			-- Buttons and item tiles
			Tile = Color3.fromRGB(52, 140, 156),
			TileHover = Color3.fromRGB(64, 156, 172),
			TilePressed = Color3.fromRGB(44, 124, 140),
			TileBevel = Color3.fromRGB(128, 204, 216),
			-- The white name strip on a tile, and the sky-blue well its picture sits in
			Strip = Color3.fromRGB(246, 248, 242),
			Well = Color3.fromRGB(150, 206, 222),

			-- Thick navy outlines
			Border = Color3.fromRGB(16, 52, 64),
			BorderStrong = Color3.fromRGB(10, 30, 40),

			Text = Color3.fromRGB(255, 255, 255),
			TextDim = Color3.fromRGB(180, 222, 230),
			TextMuted = Color3.fromRGB(118, 168, 180),

			-- The selected tab or option: light aqua with navy text
			Inverse = Color3.fromRGB(210, 240, 244),
			InverseHover = Color3.fromRGB(228, 248, 250),
			InversePressed = Color3.fromRGB(190, 228, 234),
			InverseText = Color3.fromRGB(14, 38, 50),

			Track = Color3.fromRGB(12, 40, 52),
			Accent = Color3.fromRGB(255, 200, 36),
			Success = Color3.fromRGB(100, 200, 60),
			Danger = Color3.fromRGB(224, 62, 50),
			Warning = Color3.fromRGB(255, 160, 30),

			--[[ Game ]]

			-- Call-to-action buttons (Play, Join, Open, Buy): yellow with navy text
			Primary = Color3.fromRGB(255, 196, 36),
			PrimaryHover = Color3.fromRGB(255, 212, 80),
			PrimaryPressed = Color3.fromRGB(232, 174, 20),
			PrimaryBevel = Color3.fromRGB(255, 234, 150),
			DangerBevel = Color3.fromRGB(255, 140, 128),
			Coin = Color3.fromRGB(255, 208, 50),
			Diamond = Color3.fromRGB(120, 222, 255),
			Vip = Color3.fromRGB(255, 214, 60),
			Health = Color3.fromRGB(110, 210, 70),
			Stamina = Color3.fromRGB(90, 180, 255),
			Power = Color3.fromRGB(255, 128, 40),

			TeamRed = Color3.fromRGB(235, 64, 52),
			TeamBlue = Color3.fromRGB(52, 130, 235),
			TeamGreen = Color3.fromRGB(76, 200, 76),
			TeamYellow = Color3.fromRGB(245, 205, 40),

			Common = Color3.fromRGB(190, 196, 200),
			Uncommon = Color3.fromRGB(90, 210, 80),
			Rare = Color3.fromRGB(60, 140, 240),
			Epic = Color3.fromRGB(170, 80, 240),
			Legendary = Color3.fromRGB(255, 190, 30),
		},
	},

	--[[ Text ]]

	-- Gotham: Heavy for titles, buttons and names, Bold for text, Medium for small print
	Font = {
		Hint = { Family = "rbxasset://fonts/families/GothamSSm.json", Weight = "Medium" },
		Body = { Family = "rbxasset://fonts/families/GothamSSm.json", Weight = "Bold" },
		Title = { Family = "rbxasset://fonts/families/GothamSSm.json", Weight = "Heavy" },
	},
	TextSize = {
		Caption = 16,
		Small = 18,
		Body = 22,
		Heading = 26,
		Title = 32,
		Icon = 30,
		Symbol = 24,
		SymbolSmall = 20,
		-- Big numbers: turn timer, countdowns, damage pops
		Display = 48,
	},

	-- The kit's pictures, as local previews until they're uploaded (written by the kit's build script)
	Icons = require(script.Parent:FindFirstChild("Icons")),

	--[[ Shape ]]

	Radius = {
		Small = 4,
		Control = 6,
		Card = 6,
		Window = 10,
	},
	Size = {
		Row = 48,
		RowSmall = 40,
		Control = 56,
		ControlSmall = 44,
		IconButton = 48,
		IconButtonSmall = 40,
		Header = 64,
		Title = 72,
		Logo = 40,
		Grip = 24,

		Track = 6,
		Bar = 22,
		Knob = 30,
		ToggleWidth = 72,
		ToggleHeight = 38,
		Swatch = 48,
		Check = 28,
		CheckSmall = 22,
		Chip = 56,
		Menu = 320,

		--[[ Game ]]

		-- Widget header bar, and the title bands on boxes
		Banner = 60,
		Band = 48,
		BandSmall = 38,
		-- Item cards: loadout slots, picker tiles, crate results
		Item = 150,
		ItemTall = 190,
		-- Loadout bar slots in a match
		BarSlot = 96,
		-- Skin tiles and game pass cards
		Tile = 260,
		TileTall = 300,
		-- Avatars in party and waiting-room rows
		Avatar = 56,
		-- Map pictures in match rows
		ThumbnailWidth = 128,
		ThumbnailHeight = 72,
		-- Small pictures beside text (coin, diamond, crown)
		Glyph = 36,
	},
	Spacing = {
		XS = 6,
		S = 10,
		M = 16,
		L = 22,
		XL = 30,
		Buttons = 14,
	},
	Stroke = {
		Thin = 2,
		Thick = 3,
		-- Outlines around titles and button text
		Text = 2,
	},
}

return _tokens
