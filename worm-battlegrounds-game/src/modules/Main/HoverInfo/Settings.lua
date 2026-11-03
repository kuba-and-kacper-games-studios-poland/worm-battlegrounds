--- @class HoverInfo_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The gui the box is drawn in (an export of ume-gui's System/HoverInfo, or the game's own copy).
	GUI_NAME = "HoverInfo",

	-- Screen height the gui is laid out for; S_ScreenScale is the screen's height over it.
	DESIGN_HEIGHT = 1080,

	-- Mobile screens shorter than this many pixels scale the gui up by MOBILE_BOOST, as every window does.
	SMALL_SCREEN = 500,
	MOBILE_BOOST = 1.3,

	--%%%%%%%%%%%%%%%%%%%% Placing

	-- Pixels between the pointer and the box: right of and under the mouse, above a finger or a gamepad's pick.
	POINTER_GAP = 18,

	-- Pixels the box keeps from the screen's edges.
	EDGE_MARGIN = 8,

	--%%%%%%%%%%%%%%%%%%%% Look

	-- The line along the box's top for an item with no rarity: the gui's common grey.
	ACCENT_COLOR = Color3.fromRGB(154, 163, 173),

	--[[
		The name's width at 1080 (the box's 340 less its sides' padding), its text size and its height for one line: a
		longer name wraps, and the label grows a line at a time.
	]]
	NAME_WIDTH = 308,
	NAME_TEXT_SIZE = 30,
	NAME_HEIGHT = 36,

	-- How enchantment levels are written; a level past the list is written as a number.
	--- @type { string }
	NUMERALS = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X" },
}
return _settings
