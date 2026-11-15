--- @class Tutorial_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Rewards

	-- The coins a player brings back from the tutorial match
	MATCH_COINS = "100",

	-- The weapons the tutorial match gives (no crate since 2026-11-15), which the player then equips
	--- @type { string }
	STARTER_WEAPONS = { "Grenade", "Shotgun" },

	--%%%%%%%%%%%%%%%%%%%% Steps

	-- The maps the match guide and the lobby guide run on (the Studio map runs both), and the tutorial match's kind
	MATCH_MAP = "Match",
	LOBBY_MAP = "Lobby",
	MATCH_KIND = "Tutorial",

	-- The weapon the player's second turn teaches (Match's TUTORIAL_LOADOUT gives it)
	GRENADE = "Grenade",

	--[[
		What each step's hint says: in the match the spot to land on, the first shot at the bot, picking the Grenade and
		throwing it on the second turn, the strong wind on the third, finishing the bot after, the bot's turns and going
		back; in the lobby a loadout slot and picking each weapon (%s is its name)
	]]
	--- @type { [string]: string }
	HINTS = {
		Drop = "Click the lit spot to land there",
		Aim = "Point at the bot, hold the left mouse button to charge, let go to fire. The line shows where your shot flies!",
		Grenade = "Now pick the Grenade on your bar",
		Throw = "Throw it at the bot: it bounces, then bursts when it stops",
		Wind = "Strong wind! It blows your shot back: watch the line bend, and charge way more power to fight it",
		Finish = "Finish the bot off!",
		BotTurn = "The bot's turn: watch out, it shoots back!",
		Lobby = "Good game! Head back to the lobby",
		Equip = "You got the Grenade and the Shotgun! Put them in your loadout: press a slot",
		Pick = "Pick the %s",
	},

	-- What the match's hints say on a touch screen instead, where they differ
	--- @type { [string]: string }
	TOUCH_HINTS = {
		Drop = "Tap the lit spot to land there",
		Aim = "Drag a finger to aim at the bot, then hold FIRE to charge, let go to shoot. The line shows where your shot flies!",
		Grenade = "Now tap the Grenade on your bar",
		Throw = "Aim at the bot and throw it with FIRE: it bounces, then bursts when it stops",
		Wind = "Strong wind! It blows your shot back: watch the line bend, and hold FIRE way longer to fight it",
	},

	--[[
		What the match's hints say on a pad instead, where they differ: each {Action} is the button of that action in
		the Console module's scheme, named for the player's pad ("RT" or "R2")
	]]
	--- @type { [string]: string }
	PAD_HINTS = {
		Drop = "Move the spot to the light with {Move}, press {PlaceDrop} to land",
		Aim = "Aim at the bot with {Aim}, hold {Fire} to charge, let go to fire. The line shows where your shot flies!",
		Grenade = "Now pick the Grenade with {WeaponNext}",
		Throw = "Aim at the bot with {Aim} and throw it with {Fire}: it bounces, then bursts when it stops",
		Wind = "Strong wind! It blows your shot back: watch the line bend, and hold {Fire} way longer to fight it",
	},

	--[[
		The tutorial's steps in the Roblox onboarding funnel (Creator Hub → Analytics → Funnels), in order: each is
		logged once a player first sees its hint (the server's AnalyticsService), "Equipped" when the tutorial is done.
		Hints that show only to some players (BotTurn, Finish) aren't funnel steps
	]]
	--- @type { string }
	FUNNEL_STEPS = { "Drop", "Aim", "Grenade", "Throw", "Wind", "Lobby", "Equip", "Pick", "Equipped" },

	--%%%%%%%%%%%%%%%%%%%% Guide

	--[[
		The ring around what to press: HOLE_PADDING pixels past a gui element on each side, WORLD_HOLE_RADIUS studs
		around a spot or a snail, never smaller than HOLE_MIN pixels; it pulses RING_PULSE_RATE radians a second
	]]
	HOLE_PADDING = 10,
	WORLD_HOLE_RADIUS = 4,
	HOLE_MIN = 72,
	RING_PULSE_RATE = 4,

	--[[
		The red arrow points at the ring from ARROW_GAP pixels above it (below it when the ring is in the screen's top
		ARROW_FLIP_SHARE), bobbing ARROW_BOB pixels toward it ARROW_BOB_RATE radians a second
	]]
	ARROW_GAP = 8,
	ARROW_FLIP_SHARE = 0.3,
	ARROW_BOB = 14,
	ARROW_BOB_RATE = 6,

	--[[
		The hint sits HINT_GAP pixels past the ring and its arrow, HINT_EDGE pixels in from the screen's edges, at
		HINT_TOP of the screen's height with no ring; its text is HINT_TEXT_SIZE at design size, HINT_BOTTOM_PADDING over
		the panel's bottom
	]]
	HINT_GAP = 24,
	HINT_EDGE = 16,
	HINT_TOP = 0.25,
	HINT_TEXT_SIZE = 32,
	HINT_BOTTOM_PADDING = 18,

	--%%%%%%%%%%%%%%%%%%%% Gui

	HINT_GUI_NAME = "TutorialHint",
	MATCH_HUD_GUI_NAME = "MatchHud",
	RESULTS_GUI_NAME = "Results",
	LOADOUT_GUI_NAME = "Loadout",
	PICKER_GUI_NAME = "LoadoutPicker",
}

return _settings
