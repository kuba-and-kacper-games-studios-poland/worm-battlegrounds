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

	-- Once the shot is away the timer stays on the time that was left, dimmed to this colour, until the turn ends
	TIMER_SPENT_COLOR = Color3.fromRGB(140, 140, 150),

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

	--[[
		Local play: while a local player's turn waits for the controller (Match's HandOff), the callout holds with their
		snail's name, its lines in the snail's colour, and this line under it for the device in use (Utils' platforms)
	]]
	--- @type { [string]: string }
	HANDOFF_TEXTS = {
		Desktop = "Pass the controller, then click when ready",
		Mobile = "Pass the device, then tap when ready",
		Console = "Pass the controller, then press A",
	},

	--[[
		When sudden death starts, the callout announces the rising liquid (the map's sea, the match's SeaKind) once the
		turn's own callout is gone: SUDDEN_DEATH_TITLE with the liquid's name, no avatar, the lines in its colour, held
		SUDDEN_DEATH_HOLD seconds while the title fills with it from the bottom (its gradient's offset tweened from
		SUDDEN_DEATH_FILL_FROM to SUDDEN_DEATH_FILL_TO by SUDDEN_DEATH_FILL_TWEENINFO). Later sudden-death turns add
		SUDDEN_DEATH_REMINDER to the turn's line
	]]
	SUDDEN_DEATH_TITLE = "%s is rising...",
	SUDDEN_DEATH_SUB = "Sudden death!",
	SUDDEN_DEATH_REMINDER = "The %s rises",
	SUDDEN_DEATH_HOLD = 2.4,
	SUDDEN_DEATH_FILL_FROM = Vector2.new(0, 0.55),
	SUDDEN_DEATH_FILL_TO = Vector2.new(0, -0.1),
	SUDDEN_DEATH_FILL_TWEENINFO = TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),

	-- Each liquid's name in the callout and its colour (the lines, and the title's fill under white)
	--- @type { [string]: MatchHud_SuddenDeathLiquid }
	SUDDEN_DEATH_LIQUIDS = {
		Water = { Name = "Water", Color = Color3.fromRGB(63, 166, 255) },
		Lava = { Name = "Lava", Color = Color3.fromRGB(255, 140, 20) },
	},

	-- When the player is next, their "You're next!" line flashes this colour (with Turn_Next) and fades back
	NEXT_FLASH_COLOR = Color3.fromRGB(255, 220, 60),
	NEXT_FLASH_TWEENINFO = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

	-- The stamina bar's text, with its share in percent
	STAMINA_FORMAT = "Stamina %d%%",

	-- The jetpack's fuel bar, over the stamina bar while the snail wears a jetpack: its share, or the turn it rests after flying
	FUEL_FORMAT = "Jetpack %d%%",
	FUEL_REST_TEXT = "Jetpack next turn",

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

	-- Utilities used the moment their box is picked, with no press on the screen (the owner, 2026-11-16: the Jetpack)
	--- @type { [string]: boolean }
	USE_ON_SELECT = { Jetpack = true },

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

	-- The power slider's text with a homing missile in hand: before its target is picked (by a click, or a tap on touch), then until the player aims
	--- @type { [string]: string }
	TARGET_HINTS = { Pick = "Click on a target", TouchPick = "Tap on a target", Shoot = "Shoot!" },

	--%%%%%%%%%%%%%%%%%%%% Pad Aim

	--[[
		The right stick points the aim (the owner's pick, 2026-11-17: it was twitchy). It does nothing under STICK_DEADZONE of
		lean; a gentle lean, up to STICK_FIRM_LEAN, only nudges the aim toward the stick's way, from the first to the
		second of STICK_NUDGE_SPEED degrees a second as it leans further, for fine aiming
	]]
	--- @type { number }
	STICK_NUDGE_SPEED = { 5, 30 },
	STICK_DEADZONE = 0.3,
	STICK_FIRM_LEAN = 0.55,

	--[[
		A firm lean turns the aim to the stick's way in a quick ease, from the first to the second of STICK_TURN_SPEED
		(higher is snappier: at 18 it's 95% there in a sixth of a second) up to full lean
	]]
	--- @type { number }
	STICK_TURN_SPEED = { 8, 18 },

	--[[
		While the lean drops faster than this (lean per second), the stick is springing back as it's let go: the aim
		holds still, so letting go before RT never moves it
	]]
	STICK_DROP_RATE = 1.5,

	--%%%%%%%%%%%%%%%%%%%% Prediction

	--[[
		In the tutorial match, and for a player with the admin aimbot on, an arced weapon's path shows as a line of
		dots (the testers, 2026-11-15: "a line that predicts where the shot is gonna go… make the line move depending
		on power"): followed PREDICTION_STEP seconds
		at a time, up to PREDICTION_SECONDS, to the first thing it hits, a dot every PREDICTION_DOT_GAP studs (at most
		PREDICTION_DOTS) and a bigger one where it lands. While charging it shows the power held; before, faded to
		PREDICTION_IDLE_TRANSPARENCY, the power last fired (PREDICTION_IDLE_POWER at first)
	]]
	PREDICTION_STEP = 1 / 30,
	PREDICTION_SECONDS = 4,
	PREDICTION_DOT_GAP = 1.5,
	PREDICTION_DOTS = 80,
	PREDICTION_DOT_SIZE = 0.6,
	PREDICTION_END_SIZE = 1.4,
	PREDICTION_COLOR = Color3.fromRGB(255, 215, 110),
	PREDICTION_END_COLOR = Color3.fromRGB(235, 64, 52),
	PREDICTION_IDLE_POWER = 0.6,
	PREDICTION_IDLE_TRANSPARENCY = 0.4,

	--%%%%%%%%%%%%%%%%%%%% Drop

	-- The drop's timer (the turn timer's plate) turns TIMER_DANGER_COLOR from DROP_WARN_FROM seconds left, when Turn_Tick plays each second
	DROP_WARN_FROM = 3,

	--%%%%%%%%%%%%%%%%%%%% Control Hints

	-- The controls listed at the bottom left of the screen while the player waits for the match and picks where to land
	HINTS_GUI_NAME = "ControlHints",

	--[[
		The strip shows in a player's first HINTS_MATCHES matches only: once their MatchesPlayed statistic reaches it
		(from their tenth match on) it stays hidden for good. Never in the tutorial match, which teaches the same
	]]
	HINTS_MATCHES = 9,

	-- Seconds each tip stays over the strip, and the fade between two
	HINT_TIP_SECONDS = 4,
	HINT_TIP_TWEENINFO = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

	-- The tips the line over the strip turns through, in order
	--- @type { string }
	HINT_TIPS = {
		"Tip: hold to charge a shot, let go to fire.",
		"Tip: hold jump to fly with your jetpack.",
		"Tip: the wind pushes every thrown shot. Check the arrow before you fire.",
		"Tip: a full charge fires by itself.",
		"Tip: after a throw you can keep moving. Run from your own blast!",
		"Tip: falling into the open sea knocks you out at once.",
		"Tip: grenades burst when they stop rolling.",
	},

	--%%%%%%%%%%%%%%%%%%%% Results XP

	--[[
		The Results screen's level bar, from the level before the match to after it: RESULTS_XP_DELAY seconds after the
		screen opens, each of the match's XP lines (MatchRewards' XpLines) adds to the XP total with Xp_Line, then fills
		the bar for RESULTS_XP_FILL_SECONDS (its share of that, for a stretch that reaches a level first), with
		RESULTS_XP_TICKS Xp_Tick ticks climbing through RESULTS_XP_TICK_PITCH as it fills, RESULTS_XP_LINE_GAP seconds
		apart; a level reached plays Level_Up and pops the level's diamond (RESULTS_LEVEL_TWEENINFO)
	]]
	RESULTS_XP_DELAY = 0.6,
	RESULTS_XP_LINE_GAP = 0.25,
	RESULTS_XP_FILL_SECONDS = 0.8,
	RESULTS_XP_TICKS = 10,
	RESULTS_XP_TICK_PITCH = NumberRange.new(0.9, 1.5),
	RESULTS_LEVEL_TWEENINFO = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

return _settings
