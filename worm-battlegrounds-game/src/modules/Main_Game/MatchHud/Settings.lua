--- @class MatchHud_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The exported match screen, and the results widget
	GUI_NAME = "MatchHud",
	RESULTS_GUI_NAME = "Results",

	-- The results' placing cards that fit across at the design's width; more players' cards share it
	RESULTS_FIT_PLACINGS = 4,

	-- The tutorial's Rematch button, grey and dead: its face, its outline and its text (the tutorial always goes back)
	--- @type { [string]: Color3 }
	LOCKED_REMATCH_COLORS = {
		Main = Color3.fromRGB(120, 120, 130),
		Stroke = Color3.fromRGB(170, 170, 178),
		Text = Color3.fromRGB(200, 200, 205),
	},

	--[[
		Guis the framework keeps on (`UserInterface_PreventHiding`) that the match screen hides while the player is in
		a match: the currency bar sits where the turn banner and timer go
	]]
	--- @type { string }
	HIDDEN_IN_MATCH = { "Currency" },

	--%%%%%%%%%%%%%%%%%%%% Turn

	--[[
		On the player's own turn the timer turns TIMER_WARN_COLOR from TIMER_WARN_FROM seconds left, then TIMER_DANGER_COLOR
		from TICK_SOUND_FROM, when it ticks aloud (Turn_Tick) each second, twice a second from TICK_FAST_FROM, and a band
		pulses along the screen's sides, TENSION_PULSE_RATE times a second at first and twice as fast at the end
	]]
	TIMER_WARN_FROM = 8,
	TICK_SOUND_FROM = 5,
	TICK_FAST_FROM = 3,
	TIMER_WARN_COLOR = Color3.fromRGB(255, 170, 40),
	TIMER_DANGER_COLOR = Color3.fromRGB(255, 70, 50),
	TENSION_PULSE_RATE = 1.5,

	--[[
		A turn's callout banner: its band opens (CALLOUT_BAND_TWEENINFO) while its content slides CALLOUT_SLIDE of the
		screen in and settles from CALLOUT_START_SCALE (CALLOUT_IN_TWEENINFO), stays CALLOUT_HOLD seconds, then slides on
		as the band closes (CALLOUT_OUT_TWEENINFO); anyone else's turn is shown at CALLOUT_OTHER_SCALE
	]]
	CALLOUT_START_SCALE = 1.3,
	CALLOUT_SLIDE = 0.06,
	CALLOUT_HOLD = 1,
	CALLOUT_OTHER_SCALE = 0.8,
	CALLOUT_BAND_TWEENINFO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	CALLOUT_IN_TWEENINFO = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	CALLOUT_OUT_TWEENINFO = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In),

	-- The callout's lines and avatar frame on the player's own turn (anyone else's take their colour)
	CALLOUT_ACCENT_COLOR = Color3.fromRGB(255, 140, 20),

	-- The callout title's gradient, top to bottom: gold on the player's own turn, white on anyone else's
	--- @type { Color3 }
	CALLOUT_MINE_GRADIENT = { Color3.fromRGB(255, 232, 110), Color3.fromRGB(255, 140, 20) },

	--- @type { Color3 }
	CALLOUT_OTHER_GRADIENT = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 215, 235) },

	-- When the player is next, their "You're next!" line flashes this colour (with Turn_Next) and fades back
	NEXT_FLASH_COLOR = Color3.fromRGB(255, 220, 60),
	NEXT_FLASH_TWEENINFO = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

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

	--[[
		A bot's avatar in the team panels, the turn list, the turn callout and the results: the default snail's voxel
		headshot (art/bots), uploaded to The Snail Studio group
	]]
	BOT_AVATAR = "rbxassetid://75705415395334",

	--%%%%%%%%%%%%%%%%%%%% Top Bar

	-- The match's Leave game button in the top bar (art/topbar's TopBar_Leave), and the question it asks first
	LEAVE_ICON = "rbxassetid://107990939394341",
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
		Enum.KeyCode.Seven,
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
		After a shot is sent, the aim stays hidden and the weapon on the shot's angle until the server moves the match on;
		if it hasn't after this many seconds (it refused the shot), the player may aim again
	]]
	FIRE_ANSWER_SECONDS = 2,

	--[[
		A homing missile fired with no target picked homes on the mouse's point on the arena, or (a pad) this many studs
		along its aim
	]]
	HOMING_AIM_REACH = 60,

	--[[
		Another snail's angle marker and power show while its aim keeps arriving (none for AIM_SHOW_GRACE seconds hides
		them), eased toward each update at AIM_SMOOTHING (higher is snappier)
	]]
	AIM_SHOW_GRACE = 0.4,
	AIM_SMOOTHING = 15,

	--[[
		The aim, Worms Armageddon's, drawn on the HUD's aim layer (U_Aim) in units: a stud at MatchCamera's starting
		distance (DISTANCE), so it looks the same at any zoom. The power's cone: POWER_DOTS circles from POWER_START
		units out from the snail's middle (further when zoomed in, clear of its ball), POWER_LENGTH units from the first
		circle's middle to the last's, growing from the first size to the last and through POWER_COLORS (each circle's
		gradient runs them along the aim, so the circles blend into one), each growing in as the power passes it. Then POWER_GAP units of room, then the crosshair (the gui's ring and X, in the
		aiming snail's colour), CROSSHAIR_SIZE units across, spinning CROSSHAIR_SPIN degrees a second
	]]
	POWER_DOTS = 14,

	--- @type { Color3 }
	POWER_COLORS = { Color3.fromRGB(255, 226, 92), Color3.fromRGB(255, 148, 38), Color3.fromRGB(240, 62, 46) },

	--- @type { number }
	POWER_DOT_SIZE = { 0.9, 2.3 },

	-- In units: where the cone starts, its length, the room before the crosshair, the crosshair's size; then its spin
	POWER_START = 2.3,
	POWER_LENGTH = 7,
	POWER_GAP = 0.3,
	CROSSHAIR_SIZE = 3.4,
	CROSSHAIR_SPIN = 60,

	--[[
		The share of the power slider's and stamina bar's picture that its fill covers (the rest clear), which code cuts
		the bar and its texture at; the studio's complete PowerSlider (2026-11-12) fills its whole width
	]]
	BAR_FILL = 1,

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
