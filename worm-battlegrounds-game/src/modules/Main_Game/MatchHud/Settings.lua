--- @class MatchHud_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The exported match screen, and the results widget
	GUI_NAME = "MatchHud",
	RESULTS_GUI_NAME = "Results",

	--[[
		Guis the framework keeps on (`UserInterface_PreventHiding`) that the match screen hides while the player is in
		a match: the currency bar sits where the turn banner and timer go
	]]
	--- @type { string }
	HIDDEN_IN_MATCH = { "Currency" },

	-- A loadout slot's fill while it's selected, and otherwise (the gui kit's selected blue and its Slot)
	SELECTED_COLOR = Color3.fromRGB(40, 140, 255),
	SELECTED_TRANSPARENCY = 0.2,
	TILE_COLOR = Color3.fromRGB(0, 0, 0),
	TILE_TRANSPARENCY = 0.7,

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

	--[[
		A box whose item has no icon shows the weapon's model instead: seen through a camera with this field of view,
		from this direction (the muzzle points right), with this much room around it (1 is a tight fit)
	]]
	MODEL_FOV = 30,
	MODEL_VIEW_DIRECTION = Vector3.new(0.3, 0.25, 1),
	MODEL_PADDING = 1.15,

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

	--[[
		Another worm's aim line shows while its aim keeps arriving (none for AIM_SHOW_GRACE seconds hides it), eased
		toward each update at AIM_SMOOTHING (higher is snappier)
	]]
	AIM_SHOW_GRACE = 0.4,
	AIM_SMOOTHING = 15,

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
