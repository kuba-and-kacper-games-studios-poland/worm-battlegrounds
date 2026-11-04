--[[
	Created By: 	Nari
]]

--- @type UmeGui_Tokens
local _tokens = {

	--[[ Palette ]]

	-- The GUI kit's colours (draft 4); the base theme's game colours (teams, bars) carry over
	Palette = {
		Night = {
			-- The ink every outline, text outline and drop is drawn in
			Ink = Color3.fromRGB(11, 16, 32),
			Border = Color3.fromRGB(11, 16, 32),
			BorderStrong = Color3.fromRGB(11, 16, 32),

			-- The sea window's middle colour, for anything that shows a window's colour without its gradient
			Background = Color3.fromRGB(23, 105, 122),
			-- A slot: black, see-through
			Slot = Color3.fromRGB(0, 0, 0),
			-- A picture's light well (portraits)
			Well = Color3.fromRGB(143, 211, 255),

			Text = Color3.fromRGB(255, 255, 255),
			TextDim = Color3.fromRGB(196, 232, 238),
			TextMuted = Color3.fromRGB(150, 186, 196),
			InverseText = Color3.fromRGB(11, 16, 32),

			-- What a skin is tinted while pressed
			Pressed = Color3.fromRGB(214, 214, 214),

			-- Cyan box titles, green prices and map names, cream hero titles, gold winners
			Accent = Color3.fromRGB(110, 237, 254),
			Price = Color3.fromRGB(156, 240, 90),
			Map = Color3.fromRGB(156, 240, 90),
			Cream = Color3.fromRGB(255, 254, 195),
			Gold = Color3.fromRGB(255, 212, 58),
			Success = Color3.fromRGB(156, 240, 90),
			Danger = Color3.fromRGB(255, 110, 96),
			Warning = Color3.fromRGB(255, 176, 32),

			Track = Color3.fromRGB(11, 16, 32),

			--[[ Game ]]

			Coin = Color3.fromRGB(255, 212, 58),
			Diamond = Color3.fromRGB(110, 237, 254),
			Vip = Color3.fromRGB(255, 212, 58),

			-- The glow behind a reward, per rarity
			GlowCommon = Color3.fromRGB(214, 224, 242),
			GlowUncommon = Color3.fromRGB(190, 255, 150),
			GlowRare = Color3.fromRGB(150, 215, 255),
			GlowEpic = Color3.fromRGB(230, 185, 255),
			GlowLegendary = Color3.fromRGB(255, 236, 150),
		},
	},

	--[[ Text ]]

	-- Londrina Solid Black for every text (a Creator Store font; it has the one weight)
	Font = {
		Hint = { Family = "rbxassetid://113086061264643", Weight = "Heavy" },
		Body = { Family = "rbxassetid://113086061264643", Weight = "Heavy" },
		Title = { Family = "rbxassetid://113086061264643", Weight = "Heavy" },
	},

	-- Px on a 1080 px tall screen; nothing is smaller than 32 (about 15 pt on a phone)
	TextSize = {
		Caption = 32,
		Small = 32,
		Body = 36,
		Button = 40,
		Heading = 48,
		Title = 64,
		Icon = 48,
		Symbol = 40,
		SymbolSmall = 32,
		Display = 80,
		Hero = 112,
	},

	-- The kit's pictures and skins, as local previews until they're uploaded (written by the kit's build script)
	Icons = require(script.Parent:FindFirstChild("Icons")),

	--[[ Shape ]]

	Radius = {
		Small = 12,
		Control = 18,
		Card = 18,
		Window = 24,
	},
	Size = {
		-- Buttons: medium, large and hero (a slanted skin exists for each), and the small square ones
		Control = 96,
		ControlLarge = 112,
		Hero = 144,
		ControlSmall = 96,
		IconButton = 96,
		-- A pill (currencies, timers)
		Pill = 72,
		-- A list row on a slot
		Row = 160,
		-- Things on slots: items, perks, rewards
		Item = 152,
		ItemTall = 200,
		BarSlot = 112,
		-- Skin tiles and game pass cards
		Tile = 280,
		TileTall = 380,
		-- People and places on cards
		PlayerCard = 200,
		PlayerCardTall = 300,
		Avatar = 96,
		AvatarLarge = 128,
		ThumbnailWidth = 192,
		ThumbnailHeight = 108,
		-- Small pictures beside text, and a picture on its own
		Glyph = 48,
		IconLarge = 96,
		-- The ink drop under raised pieces
		Drop = 8,
	},
	Spacing = {
		XS = 8,
		S = 16,
		M = 24,
		L = 32,
		XL = 48,
		Buttons = 24,
	},
	Stroke = {
		Thin = 3,
		Thick = 4,
		Heavy = 6,
		-- Outlines around titles and button text
		Text = 4,
	},
}

return _tokens
