--- @class MatchHud_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The exported match screen, and the results widget
	GUI_NAME = "MatchHud",
	RESULTS_GUI_NAME = "Results",

	-- The results' placing cards that fit across at the design's width; more players' cards share it
	RESULTS_FIT_PLACINGS = 4,

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
		The band's frame (U_Tension, its glow drawn outside it) as shares of the whole screen's width and height, so the
		glow runs along the very edges; on phones it reaches up past the top padding under Roblox's top bar too
	]]
	TENSION_SIZE = Vector2.new(0.99, 0.985),

	-- Once the shot is away the timer stays on the time that was left, dimmed to this colour, until the turn ends
	TIMER_SPENT_COLOR = Color3.fromRGB(140, 140, 150),

	--[[
		The turn panel (timer and wind) on phones and tablets: at the top of the HUD (already below Roblox's top bar there),
		its timer still in the middle at the gui's Utils_MobileSize (0.8 of its size), clear of the aim (2026-11-25)
	]]
	TURN_MOBILE_POSITION = UDim2.fromScale(0.5217, 0.012),

	--[[
		A turn's callout banner: its band opens (CALLOUT_BAND_TWEENINFO) while its content slides CALLOUT_SLIDE of the
		screen in and settles from CALLOUT_START_SCALE (CALLOUT_IN_TWEENINFO), stays CALLOUT_HOLD seconds, then slides on
		as the band closes (CALLOUT_OUT_TWEENINFO); anyone else's turn is shown at CALLOUT_OTHER_SCALE
	]]
	CALLOUT_START_SCALE = 1.12,
	CALLOUT_SLIDE = 0.03,
	CALLOUT_HOLD = 1,
	CALLOUT_OTHER_SCALE = 0.85,
	CALLOUT_BAND_TWEENINFO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	CALLOUT_IN_TWEENINFO = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	CALLOUT_OUT_TWEENINFO = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In),

	--[[
		The knocked-out screen (KnockedOut): it pops in from KO_POP_START_SCALE, and with no snail to name (the water,
		the lava, the arena's edge) the cause line takes the killer card's place, KO_CAUSE_ALONE_SCALE times as tall
	]]
	KO_POP_START_SCALE = 0.85,
	KO_POP_TWEENINFO = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	KO_CAUSE_ALONE_SCALE = 1.5,

	-- The callout's lines and avatar frame on the player's own turn (anyone else's take their colour)
	CALLOUT_ACCENT_COLOR = Color3.fromRGB(255, 140, 20),

	-- The callout title's gradient, top to bottom: gold on the player's own turn, white on anyone else's
	--- @type { Color3 }
	CALLOUT_MINE_GRADIENT = { Color3.fromRGB(255, 232, 110), Color3.fromRGB(255, 140, 20) },

	--- @type { Color3 }
	CALLOUT_OTHER_GRADIENT = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 215, 235) },

	--[[
		The round's intro (BattleIntro; the owner, 2026-11-24: "in 2 sequences - at the start and when we land… the gui
		should be different than the next round gui"). As the snails drop in: the screen's edges darken to
		INTRO_VIGNETTE_TRANSPARENCY, GET READY fades in from INTRO_READY_START_SCALE over its line, under Match_DropIn.
		Once they've landed: a white flash from INTRO_FLASH_TRANSPARENCY, THE BATTLE / BEGINS! slams in from
		INTRO_SLAM_START_SCALE and INTRO_SLAM_START_ROTATION to 1 and INTRO_SLAM_ROTATION, INTRO_SPARKS sparks, the deep
		hit (Match_BattleBegins), holds INTRO_SLAM_HOLD seconds, then zooms out to INTRO_SLAM_END_SCALE and fades
	]]
	INTRO_VIGNETTE_TRANSPARENCY = 0.35,

	--[[
		How far the intro's dark edges reach in, as shares of the screen's width (left and right) and height (top and
		bottom); they and the flash also run INTRO_COVER_BLEED of the screen's width past every edge, solid out there, so
		no phone shows a light strip at its sides (the owner, 2026-11-25: "still on phone has a gap on left and right")
	]]
	INTRO_VIGNETTE_DEPTH = Vector2.new(0.26, 0.34),
	INTRO_COVER_BLEED = 0.08,

	INTRO_READY_START_SCALE = 1.25,
	INTRO_FLASH_TRANSPARENCY = 0.25,
	INTRO_SLAM_START_SCALE = 2.8,
	INTRO_SLAM_START_ROTATION = -14,
	INTRO_SLAM_ROTATION = -4,
	INTRO_SLAM_END_SCALE = 1.18,
	INTRO_SLAM_HOLD = 1,
	INTRO_SPARKS = 70,

	-- BEGINS!'s height as a share of the screen's, and the shockwave ring's size and the light streak's width (shares of the slam's width)
	INTRO_MAIN_TEXT_SHARE = 0.15,
	INTRO_SHOCK_SIZE = 1.5,
	INTRO_STREAK_WIDTH = 1.6,

	-- The camera's jolt on the slam (CameraShake's Magnitude) and how long it takes to settle
	INTRO_SHAKE = 7,
	INTRO_SHAKE_SETTLE = 0.45,
	INTRO_SPARK_TEXTURE = "rbxassetid://97296507263981",
	INTRO_VIGNETTE_TWEENINFO = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	INTRO_READY_TWEENINFO = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	INTRO_LINE_TWEENINFO = TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	INTRO_FLASH_TWEENINFO = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	INTRO_SLAM_TWEENINFO = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
	INTRO_SHOCK_TWEENINFO = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	INTRO_OUT_TWEENINFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),

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
	STAMINA_FORMAT = "Stamina · %d%%",

	-- The health bar's text (at the bottom left, over the stamina bar), with the snail's health
	HEALTH_FORMAT = "Health · %d",

	-- The jetpack's fuel bar, over the stamina bar while the snail wears a jetpack: its share, or the turn it rests after flying
	FUEL_FORMAT = "Jetpack · %d%%",
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

	--[[
		A cooling box (the owner, 2026-11-25: "design a good cooldown gui"): its turns left, never more than the item's
		Cooldown (right after a shot Combat's count is one higher until the player's next turn starts), and its card
		filling from the bottom with the share of the cooldown already waited (S_Charge), COOLDOWN_CHARGE_BODY see-through
		in the fill and solid in a band COOLDOWN_CHARGE_EDGE of the card high along its top. As it ends the card flashes
		white (S_ReadyFlash) from READY_FLASH_TRANSPARENCY, fading over READY_FLASH_TWEENINFO
	]]
	COOLDOWN_CHARGE_BODY = 0.5,
	COOLDOWN_CHARGE_EDGE = 0.05,
	READY_FLASH_TRANSPARENCY = 0.35,
	READY_FLASH_TWEENINFO = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

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
		Another snail's angle marker and power show while its aim keeps arriving (none for AIM_SHOW_GRACE seconds hides
		them), eased toward each update at AIM_SMOOTHING (higher is snappier)
	]]
	AIM_SHOW_GRACE = 0.4,
	AIM_SMOOTHING = 15,

	--[[
		The aim, drawn on the HUD's aim layer (U_Aim) in units: a stud at MatchCamera's starting distance (DISTANCE),
		growing and shrinking with the zoom like the map, but never under or over AIM_ZOOM_SCALE times that size on screen
		(the owner's pick, 2026-11-24: "Zoom, within limits"). The crosshair (the gui's ring and X, in the power's colour
		since 2026-11-25), CROSSHAIR_SIZE units across and spinning CROSSHAIR_SPIN degrees a second, sits POWER_START units out from
		the snail's middle at no power (further when zoomed in, clear of its ball), plus POWER_GAP and half its size, and
		POWER_LENGTH further at full power, on the power ring (S_PowerRing, round the snail on its player's turn). The power
		shows as the power wedge on every screen, in POWER_COLORS from none to full
	]]
	--- @type { Color3 }
	POWER_COLORS = { Color3.fromRGB(255, 226, 92), Color3.fromRGB(255, 148, 38), Color3.fromRGB(240, 62, 46) },

	-- In units: where the power starts, its length at full power, the room before the crosshair, the crosshair's size; then its spin
	POWER_START = 2.3,
	POWER_LENGTH = 9.5,
	POWER_GAP = 0.3,
	CROSSHAIR_SIZE = 2.2,
	CROSSHAIR_SPIN = 60,

	--[[
		The power wedge, ShellShock Live's way (the owner, 2026-11-25: "make it similar to that", replacing the morning's
		circles on other snails' turns; "make it change color based on the power"): a soft triangle in the power's colour
		(POWER_COLORS) from POWER_START, a point at the snail's end, to the crosshair's ring, its far end POWER_WEDGE_SPREAD
		of its length across, on the player's own aim and everyone else's (0.26 since the owner's "too thin at the max
		power", 2026-11-25)
	]]
	POWER_WEDGE_SPREAD = 0.26,

	--[[
		A homing missile's target mark (the owner, 2026-11-25: "a bit different so player knows its a homing missile
		target - also a bit bigger"; "polish the icon a bit more"): TARGET_MARK_SIZE units across. Its lock-on brackets
		close in from TARGET_LOCK_SCALE times their size over TARGET_LOCK_SECONDS as the target is placed, then grow and
		shrink by TARGET_MARK_PULSE TARGET_MARK_PULSE_SPEED times a second, turning TARGET_BRACKET_SPIN degrees a second
	]]
	TARGET_MARK_SIZE = 3.6,
	TARGET_LOCK_SCALE = 1.7,
	TARGET_LOCK_SECONDS = 0.3,
	TARGET_MARK_PULSE = 0.06,
	TARGET_MARK_PULSE_SPEED = 1.2,
	TARGET_BRACKET_SPIN = 30,

	-- The aim's smallest and biggest size on screen against its size at the starting zoom, zoomed out and in
	--- @type { number }
	AIM_ZOOM_SCALE = { 0.75, 1.4 },

	--[[
		Aiming is Ring: point (the owner's pick, 2026-11-25, replacing 2026-11-24's trackpad drag): a press and a drag put
		the crosshair under the pointer or the finger, its way from the snail the angle and its distance the power, up to
		the ring; letting go locks the aim, and FIRE shoots it. A crosshair within AIM_DEADZONE of no power clears the aim
	]]
	AIM_DEADZONE = 0.05,

	-- Where a snail's first aim starts: this power, AIM_START_ANGLE degrees up, toward the side its nearest enemy is on
	AIM_START_POWER = 0.5,
	AIM_START_ANGLE = 45,

	-- The keys that fire the locked aim, beside the FIRE button and the pad's RT
	--- @type { Enum.KeyCode }
	FIRE_KEYS = { Enum.KeyCode.F, Enum.KeyCode.Return },

	--[[
		The share of the stamina, health and jetpack bars' picture that its fill covers (the rest clear), which code cuts
		the bar and its texture at; the studio's complete PowerSlider (2026-11-12) fills its whole width
	]]
	BAR_FILL = 1,

	--[[
		The readout over the snail with a homing missile in hand, before its target is picked: a click, a tap on touch,
		or on a pad the right stick and the Fire button (its name fills the %s)
	]]
	--- @type { [string]: string }
	TARGET_HINTS = { Pick = "Click on a target", TouchPick = "Tap on a target", PadPick = "Move to a target, %s to lock" },

	--%%%%%%%%%%%%%%%%%%%% Pad Aim

	--[[
		The right stick moves the crosshair like the drag does (2026-11-24): past STICK_DEADZONE of lean, up to
		STICK_AIM_SPEED of the power's full length a second at full lean, slower for a gentle one (the lean to the power of
		STICK_CURVE), so small leans aim finely. Pushing through the snail turns the aim to the other side
	]]
	STICK_DEADZONE = 0.2,
	STICK_AIM_SPEED = 1.1,
	STICK_CURVE = 2,

	--[[
		A push held past STICK_RAMP_DELAY seconds speeds up, to STICK_RAMP_MAX times STICK_AIM_SPEED over STICK_RAMP_TIME
		more, so a short nudge stays fine and a sweep from one side to the other is quick (the owner, 2026-11-26)
	]]
	STICK_RAMP_DELAY = 0.35,
	STICK_RAMP_TIME = 0.6,
	STICK_RAMP_MAX = 2.5,

	--[[
		A homing missile's target on a pad (the owner, 2026-11-26: "there's no crosshair for me to put"): the right stick
		moves its open mark from the nearest enemy, up to STICK_TARGET_SPEED screen heights a second at full lean (with
		the stick's curve and speed-up), kept STICK_TARGET_MARGIN of the screen's height inside its edges
	]]
	STICK_TARGET_SPEED = 0.55,
	STICK_TARGET_MARGIN = 0.05,

	--%%%%%%%%%%%%%%%%%%%% Prediction

	--[[
		For a player with the admin aimbot on, an arced weapon's path shows as a line of dots (the tutorial's until
		2026-11-25, the testers, 2026-11-15: "a line that predicts where the shot is gonna go… make the line move depending
		on power"): followed PREDICTION_STEP seconds
		at a time, up to PREDICTION_SECONDS, to the first thing it hits, a dot every PREDICTION_DOT_GAP studs (at most
		PREDICTION_DOTS) and a bigger one where it lands, at the power aimed; with no aim, faded to
		PREDICTION_IDLE_TRANSPARENCY, the power last fired (PREDICTION_IDLE_POWER at first). Everyone else, the tutorial too,
		sees only the start of the path (Preview, below)
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

	--%%%%%%%%%%%%%%%%%%%% Preview

	--[[
		Everywhere else, the tutorial too, an arced aim (a homing missile's launch too) shows the start of its path, as the testers had it on
		2026-11-24 (the owner, 2026-11-25: "it was perfect - so lets try to add those dots back", after the dots were halved,
		thinned, removed, then tried past the crosshair): PREVIEW_DOTS dots (the gui's PREFAB | AimDot) from the snail over
		PREVIEW_SHARE of a full-power shot's flight time, so they reach further with more power, no wind, stopped by the
		first thing in the way, shrinking over PREVIEW_DOT_SIZE (units) and fading to PREVIEW_FADE see-through, in the
		power's colour
	]]
	PREVIEW_DOTS = 9,
	PREVIEW_SHARE = 0.2,

	--- @type { number }
	PREVIEW_DOT_SIZE = { 0.75, 0.45 },

	PREVIEW_FADE = 0.75,

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
		"Tip: drag to aim. Farther from your snail is more power.",
		"Tip: let go to lock your aim, then press FIRE (or F).",
		"Tip: hold jump to fly with your jetpack.",
		"Tip: your aim stays where you left it for your next turn.",
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
