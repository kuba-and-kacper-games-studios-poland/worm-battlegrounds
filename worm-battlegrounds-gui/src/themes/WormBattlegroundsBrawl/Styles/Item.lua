--[[
	Created By: 	Nari
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	-- A thing the player owns or picks, on a plain slot: the picture, its name and one line under it
	Default = {
		Width = "Item",
		Height = "ItemTall",
		-- A Screen item's scale per device (Utils_PlatformScale): the kit is drawn for phones, so smaller on a PC
		PlatformScale = { Utils_DesktopScale = 0.75, Utils_MobileScale = 1, Utils_ConsoleScale = 1, Utils_VRScale = 1 },
		Padding = "S",
		Gap = "XS",
		Slab = { Fill = "Slot", FillTransparency = 0.7, Fade = 0.4, Radius = "Card", Pattern = "" },
		Image = "wb-crate",
		Tint = "Text",
		IconScale = 0.9,
		Text = "Text",
		TextStroke = "Ink",
		TextStrokeThickness = "Text",
		Upper = false,
		Font = "Title",
		TextSize = "Small",
		Subtext = "TextDim",
		SubtextFont = "Body",
		SubtextSize = "Small",
		-- A reward tile's stage (a wb-skin-tile_ icon name, "" is none), how far inside the frame it sits, its corners
		Stage = "",
		StageInset = 4,
		StageRadius = 16,
		-- The light behind an epic or legendary reward: shown, its colour, how see-through the rays are
		Glow = false,
		GlowColor = "GlowCommon",
		RaysTransparency = 0.9,
		Tags = {
			Utils_ButtonScale = { Utils_HoverScale = 1.04, Utils_ClickScale = 0.92, Utils_ScaleAnimation = "Bouncy" },
			Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
		},
	},

	--[[ Sizes ]]

	-- A square slot (a loadout slot, an emote)
	Square = { Height = "Item" },
	-- A small square slot with a picture only (the match's bar, the emote wheel)
	Small = { Width = "BarSlot", Height = "BarSlot", Padding = "XS", IconScale = 0.8 },

	-- A choice on a slot with its pay under it (a solo match's difficulty): wider, the pay in the coins' colour
	Difficulty = { Width = 200, Height = 220, Subtext = "Coin" },

	--[[ Rewards: a framed tile, silver for the rest and gold for epic, legendary and premium ]]

	Common = {
		Slab = { Skin = "wb-skin-frame_silver", Drop = "Drop", Fill = "" },
		Stage = "wb-skin-tile_common",
		Padding = 26,
		GlowColor = "GlowCommon",
	},
	Uncommon = {
		Slab = { Skin = "wb-skin-frame_silver", Drop = "Drop", Fill = "" },
		Stage = "wb-skin-tile_uncommon",
		Padding = 26,
		GlowColor = "GlowUncommon",
	},
	Rare = {
		Slab = { Skin = "wb-skin-frame_silver", Drop = "Drop", Fill = "" },
		Stage = "wb-skin-tile_rare",
		Padding = 26,
		GlowColor = "GlowRare",
	},
	Epic = {
		Slab = { Skin = "wb-skin-frame_gold", Drop = "Drop", Fill = "" },
		Stage = "wb-skin-tile_epic",
		Padding = 26,
		Glow = true,
		GlowColor = "GlowEpic",
	},
	Legendary = {
		Slab = { Skin = "wb-skin-frame_gold", Drop = "Drop", Fill = "" },
		Stage = "wb-skin-tile_legendary",
		Padding = 26,
		Glow = true,
		GlowColor = "GlowLegendary",
	},
}

return _styles
