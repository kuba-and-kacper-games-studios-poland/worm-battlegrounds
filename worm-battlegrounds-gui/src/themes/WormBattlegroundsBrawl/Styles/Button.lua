--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type { [string]: UmeGui_Style }
local _styles = {

	--[[ General ]]

	--[[
		A kit button: one skin image (outline, light and lip drawn in), white outlined capitals. Each colour is a job:
		blue for other actions, back, info and Join in a list
	]]
	Default = {
		Height = "Control",
		-- A Screen button's scale per device (Utils_PlatformScale): the kit is drawn for phones, so smaller on a PC
		PlatformScale = { Utils_DesktopScale = 0.75, Utils_MobileScale = 1, Utils_ConsoleScale = 1, Utils_VRScale = 1 },
		Skin = "wb-skin-btn_blue",
		SelectedSkin = "wb-skin-btn_blue",
		DisabledSkin = "wb-skin-btn_grey",
		SkinScale = 0.5,
		SkinTint = "Text",
		Drop = "Drop",
		-- How far above the middle the text sits, clear of the skin's lip
		TextLift = 6,
		Font = "Title",
		TextSize = "Button",
		Text = "Text",
		TextStroke = "Ink",
		TextStrokeThickness = "Text",
		Upper = true,
		PaddingX = "L",
		IconSize = "Glyph",
		IconGap = "S",
		-- The pad shortcut's badge on the button's top left corner (the node's Hint), shown only on Console
		HintSize = "Glyph",
		-- The base theme's flat states are replaced: white text on every skin
		States = {
			Selected = { Text = "Text", TextStroke = "Ink" },
			Pressed = { SkinTint = "Pressed" },
			Disabled = { Text = "TextDim", TextStroke = "Ink" },
		},
		-- Squashes while held, bounces back on release
		Tags = {
			Utils_ButtonScale = { Utils_HoverScale = 1.04, Utils_ClickScale = 0.92, Utils_ScaleAnimation = "Bouncy" },
			Utils_ButtonSound = { ClickSound_Name = "Button_Click", HoverSound_Name = "Button_Hover" },
		},
	},

	--[[ Jobs ]]

	-- The next thing to press, one per window: yellow and slanted, moving the player on
	Primary = {
		Skin = "wb-skin-slant_yellow_{height}",
		SelectedSkin = "wb-skin-slant_yellow_{height}",
		DisabledSkin = "wb-skin-slant_grey_{height}",
		PaddingX = "XL",
		Text = "Text",
		TextStrokeThickness = "Text",
	},
	-- Other actions, going back, info (the default's blue, named)
	Secondary = {},
	-- Every price: a buy is green, never yellow
	Price = { Skin = "wb-skin-btn_green", SelectedSkin = "wb-skin-btn_green" },
	-- A confirm that isn't the window's next step (Ready in a lobby list)
	Confirm = { Skin = "wb-skin-btn_green", SelectedSkin = "wb-skin-btn_green" },
	-- Leaving, closing, removing
	Danger = { Skin = "wb-skin-btn_red", SelectedSkin = "wb-skin-btn_red" },
	-- Game modes and events
	Event = { Skin = "wb-skin-btn_purple", SelectedSkin = "wb-skin-btn_purple" },
	-- Side buttons and tabs at rest; the picked tab turns blue
	Tab = { Skin = "wb-skin-btn_slate", SelectedSkin = "wb-skin-btn_blue" },
	-- Owned, locked, not ready yet: grey even when it can be pressed
	Muted = { Skin = "wb-skin-btn_grey", SelectedSkin = "wb-skin-btn_grey", Text = "TextDim" },

	--[[ Sizes ]]

	-- Smaller text on a medium button (never shorter than 96: a thumb wide)
	Small = { TextSize = "Small", TextStrokeThickness = "Text", PaddingX = "M" },
	Large = { Height = "ControlLarge", TextSize = "Heading", TextLift = 6 },
	-- The screen's one hero (Play): 144 tall, text 64, a heavier outline
	Hero = { Height = "Hero", TextSize = "Title", TextLift = 8, TextStrokeThickness = "Heavy", IconSize = 64 },
	-- A square icon button, 96 × 96 (back, info, add): a node gives Text = "" and an Icon
	Square = { PaddingX = "None" },

	--[[ Widgets ]]

	-- A widget's close: the Hazard plate's slanted red plate with its X drawn in
	Close = {
		Skin = "wb-skin-close_slant",
		SelectedSkin = "wb-skin-close_slant",
		DisabledSkin = "wb-skin-close_slant",
		TextSize = "Button",
		PaddingX = "None",
	},
}

return _styles
