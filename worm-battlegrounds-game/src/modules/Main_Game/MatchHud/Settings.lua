--- @class MatchHud_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The exported match screen, and the results widget
	GUI_NAME = "MatchHud",
	RESULTS_GUI_NAME = "Results",

	-- A loadout box's face while it's selected, and otherwise (the theme's Inverse and Tile colours)
	SELECTED_COLOR = Color3.fromRGB(210, 240, 244),
	TILE_COLOR = Color3.fromRGB(52, 140, 156),

	--%%%%%%%%%%%%%%%%%%%% Top Bar

	-- The match's top bar buttons (text until their icons exist), and the question Leave game asks first
	LEAVE_TEXT = "Leave",
	MUSIC_TEXT = "Music",
	LEAVE_QUESTION = "Leave the match? Your worm will be knocked out.",

	--%%%%%%%%%%%%%%%%%%%% Loadout Bar

	-- The keys that pick the loadout boxes, in order: the Bazooka's box first, then the slots
	--- @type { Enum.KeyCode }
	SLOT_KEYS = {
		Enum.KeyCode.One,
		Enum.KeyCode.Two,
		Enum.KeyCode.Three,
		Enum.KeyCode.Four,
		Enum.KeyCode.Five,
		Enum.KeyCode.Six,
	},

	--%%%%%%%%%%%%%%%%%%%% Kill Feed

	-- How many lines the kill feed shows at once, and how long each one stays, in seconds
	FEED_LINES = 4,
	FEED_SECONDS = 6,

	--%%%%%%%%%%%%%%%%%%%% Aiming

	-- A drag shorter than MIN_DRAG pixels cancels the shot; at MAX_DRAG pixels the power is full
	MIN_DRAG = 24,
	MAX_DRAG = 260,

	-- How often the player's aim is sent to the other players while they aim, in seconds
	AIM_SEND_INTERVAL = 0.1,

	-- The aim line: how many seconds of the path it shows, as how many placeholder dots
	AIM_LINE_SECONDS = 0.6,
	AIM_LINE_DOTS = 10,
	AIM_DOT_SIZE = 0.35,
	AIM_DOT_COLOR = Color3.fromRGB(255, 255, 255),

	-- The marker on a homing missile's target
	TARGET_COLOR = Color3.fromRGB(255, 70, 70),

	-- On a pad: how far the right stick must lean to aim, and how many full sweeps of the power bar holding RT makes per second
	STICK_DEADZONE = 0.3,
	PAD_POWER_SPEED = 0.8,
}

return _settings
