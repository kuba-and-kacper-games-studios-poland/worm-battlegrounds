--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- A slot: black at 30 % fading to 18 %, round corners, no outline; holds things and rows on any window
	Default = {
		Padding = "M",
		Gap = "S",
		-- A Screen panel's scale per device (Utils_PlatformScale): the kit is drawn for phones, so smaller on a PC
		PlatformScale = { Utils_DesktopScale = 0.75, Utils_MobileScale = 1, Utils_ConsoleScale = 1, Utils_VRScale = 1 },
		Slab = { Fill = "Slot", FillTransparency = 0.7, Fade = 0.4, Radius = "Card", Pattern = "" },
		-- A slot's title: cyan, on no band of its own
		Band = { Fill = "", Pattern = "" },
		BandHeight = 48,
		BandInset = 8,
		BandPadding = "XS",
		Title = "Accent",
		TitleSize = "Body",
		TitleStroke = "Ink",
		TitleAlign = "Left",
	},

	--[[ Variants ]]

	-- A framed panel placed on the screen (lobby panels, hud blocks): a window without the plate, its title on a header
	Panel = {
		Padding = "L",
		Gap = "M",
		Slab = {
			Skin = "wb-skin-frame_window",
			Drop = 10,
			Fill = "Text",
			FillTransparency = 0,
			Fade = 0,
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 74, 90)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(23, 105, 122)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(42, 138, 150)),
			}),
			Inset = 6,
			Radius = 18,
			Pattern = "wb-skin-lattice",
		},
		Band = { Skin = "wb-skin-header_sea", SkinScale = 0.5 },
		BandHeight = 80,
		BandInset = 6,
		BandPadding = "M",
		Title = "Text",
		TitleSize = "Heading",
		TitleAlign = "Center",
	},
	-- A block of the match's hud: a darker slot straight on the game, no frame, so the arena stays in view
	Hud = {
		Padding = "S",
		Gap = "XS",
		Slab = { FillTransparency = 0.45, Fade = 0.25 },
	},
	-- A dark pill on the screen (the currencies): fully round ends, ink outline, no title
	Pill = {
		Padding = "XS",
		Slab = { Skin = "wb-skin-pill_dark", Drop = "Drop", Fill = "", Pattern = "" },
	},
	-- People and places (a player, a game mode, an open match): a raised slate card
	Card = {
		Padding = "M",
		Gap = "XS",
		Slab = { Skin = "wb-skin-card_slate", Drop = "Drop", Fill = "", Pattern = "" },
		Title = "Text",
	},
	-- With Card: the winner
	Winner = { Slab = { Skin = "wb-skin-card_gold" } },
	-- With Card: a game mode or an open match
	Event = { Slab = { Skin = "wb-skin-card_purple" } },
	-- With Card: a highlighted person or place (you, in a list of players)
	Highlight = { Slab = { Skin = "wb-skin-card_blue" } },
}

return _styles
