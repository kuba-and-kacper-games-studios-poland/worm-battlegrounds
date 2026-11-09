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

	--%%%%%%%%%%%%%%%%%%%% Turn

	-- On the player's own turn, the timer ticks (Turn_Tick) each second from this many seconds left
	TICK_SOUND_FROM = 5,

	-- The stamina bar's text, with its share in percent
	STAMINA_FORMAT = "Stamina %d%%",

	-- How many snails the turn list on the left shows: the one playing, then the next ones
	TURN_LIST_ENTRIES = 6,

	--%%%%%%%%%%%%%%%%%%%% Teams

	--[[
		A player's share of a team panel's width (the design's two teams of two fill it); a side with more players
		than fit shrinks them all to fit
	]]
	TEAM_PLAYER_WIDTH = 0.235,

	-- A knocked-out snail's avatar tint in the team panels
	OUT_AVATAR_COLOR = Color3.fromRGB(70, 70, 70),

	-- A bot's avatar in the team panels and the turn list (the theme's wb-smiley; the design's own picture draws blank)
	BOT_AVATAR = "rbxassetid://75798902746408",

	--%%%%%%%%%%%%%%%%%%%% Top Bar

	-- The match's top bar buttons (text until their icons exist), and the question Leave game asks first
	LEAVE_TEXT = "Leave game",
	MUSIC_TEXT = "Mute music",
	LEAVE_QUESTION = "Leave the match? Your snail will be knocked out.",

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

	-- How often the player's aim is sent to the other players during their turn, in seconds
	AIM_SEND_INTERVAL = 0.1,

	--[[
		The mouse or a held finger aims: the weapon points from the snail toward it, and while it's held the power is how
		far it is from the snail on the screen, in shares of the screen's height: none at MIN_PULL (let go closer, it
		cancels), full at MAX_PULL
	]]
	MIN_PULL = 0.02,
	MAX_PULL = 0.3,

	--[[
		Another snail's angle marker and power show while its aim keeps arriving (none for AIM_SHOW_GRACE seconds hides
		them), eased toward each update at AIM_SMOOTHING (higher is snappier)
	]]
	AIM_SHOW_GRACE = 0.4,
	AIM_SMOOTHING = 15,

	-- The angle marker, the studio's crosshair picture: how far from the snail's middle it sits and its size (studs)
	CROSSHAIR_DISTANCE = 9,
	CROSSHAIR_SIZE = 3,
	CROSSHAIR_IMAGE = "rbxassetid://91912077604159",

	--[[
		The power bar, a row of POWER_DOTS circles from the muzzle to the crosshair that light up as it fills: their colours
		and sizes (studs) from the first circle to the last, which sits on the crosshair and fills its ring (0.7 of
		CROSSHAIR_SIZE)
	]]
	POWER_DOTS = 32,

	--- @type { Color3 }
	POWER_COLORS = { Color3.fromRGB(255, 220, 60), Color3.fromRGB(240, 60, 30) },

	--- @type { number }
	POWER_DOT_SIZE = { 0.5, 2.1 },

	--[[
		The power slider's and stamina bar's picture is filled across only this share of its width (the rest is clear),
		so the gui draws it wider by as much and code cuts its fill at the share times this
	]]
	BAR_FILL = 0.744,

	-- The marker on a homing missile's target
	TARGET_COLOR = Color3.fromRGB(255, 70, 70),

	-- The power slider's text with a homing missile in hand: before its target is picked, then until the player aims
	--- @type { [string]: string }
	TARGET_HINTS = { Pick = "Click on a target", Shoot = "Shoot!" },

	-- On a pad: how far the right stick must lean to aim
	STICK_DEADZONE = 0.3,

	-- With an admin's aim guide on, a right click eases the aim onto the guide nearest the mouse over this many seconds
	AIMBOT_EASE = 0.4,
}

return _settings
