--- @class Tutorial_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Rewards

	-- The coins a player brings back from the tutorial match, the price of the tutorial crate
	MATCH_COINS = "100",

	-- The crate the lobby offers once, and the weapons it gives, which the player then equips
	CRATE_ID = "Tutorial",

	--- @type { string }
	STARTER_WEAPONS = { "Grenade", "Shotgun" },

	--%%%%%%%%%%%%%%%%%%%% Steps

	-- The maps the match guide and the lobby guide run on (the Studio map runs both), and the tutorial match's kind
	MATCH_MAP = "Match",
	LOBBY_MAP = "Lobby",
	MATCH_KIND = "Tutorial",

	--[[
		What each step's hint says: in the match the spot to land on, shooting the bot (on touch, tapping it then FIRE),
		the bot's turn, a retry after a miss and going back; in the lobby the free crate, tapping it open, its reels,
		Continue, closing the crates, a loadout slot and picking each weapon (%s is its name)
	]]
	--- @type { [string]: string }
	HINTS = {
		Drop = "Click the lit spot to land there",
		Aim = "Point at the bot, hold the left mouse button to charge, let go to fire",
		BotTurn = "The bot doesn't know how to shoot yet!",
		Retry = "So close! Point at the bot and fire again",
		Lobby = "You won! Head back to the lobby",
		Crate = "You've got a free crate! Open your crates",
		OpenCrate = "Open your free crate",
		Tap = "Tap the crate to open it!",
		Opening = "Let's see what you got!",
		Continue = "Your new weapons! Press Continue",
		CloseCrates = "Now close the crates",
		Equip = "Put the Grenade and the Shotgun in your loadout: press a slot",
		Pick = "Pick the %s",
	},

	-- What the match's hints say on a touch screen instead, where they differ
	--- @type { [string]: string }
	TOUCH_HINTS = {
		Drop = "Tap the lit spot to land there",
		Aim = "Tap the bot to aim at it",
		Fire = "Hold FIRE to charge, let go to shoot",
		Retry = "So close! Tap the bot to aim again",
	},

	--[[
		What the match's hints say on a pad instead, where they differ: each {Action} is the button of that action in
		the Console module's scheme, named for the player's pad ("RT" or "R2")
	]]
	--- @type { [string]: string }
	PAD_HINTS = {
		Drop = "Move the spot to the light with {Move}, press {PlaceDrop} to land",
		Aim = "Aim at the bot with {Aim}, hold {Fire} to charge, let go to fire",
		Retry = "So close! Aim at the bot with {Aim} and fire with {Fire}",
	},

	--%%%%%%%%%%%%%%%%%%%% Spotlight

	--[[
		The hole around what to press: HOLE_PADDING pixels past a gui element on each side, WORLD_HOLE_RADIUS studs
		around a spot or a snail, never smaller than HOLE_MIN pixels; its ring pulses RING_PULSE_RATE radians a second
	]]
	HOLE_PADDING = 10,
	WORLD_HOLE_RADIUS = 4,
	HOLE_MIN = 72,
	RING_PULSE_RATE = 4,

	--[[
		The hint sits HINT_GAP pixels from the hole, HINT_EDGE pixels in from the screen's edges, at HINT_TOP of the
		screen's height with no hole; its text is HINT_TEXT_SIZE at design size, HINT_BOTTOM_PADDING over the panel's bottom
	]]
	HINT_GAP = 24,
	HINT_EDGE = 16,
	HINT_TOP = 0.18,
	HINT_TEXT_SIZE = 32,
	HINT_BOTTOM_PADDING = 18,

	--%%%%%%%%%%%%%%%%%%%% Gui

	HINT_GUI_NAME = "TutorialHint",
	MATCH_HUD_GUI_NAME = "MatchHud",
	RESULTS_GUI_NAME = "Results",
	LOBBY_GUI_NAME = "Lobby",
	CRATES_GUI_NAME = "Crates",
	LOADOUT_GUI_NAME = "Loadout",
	PICKER_GUI_NAME = "LoadoutPicker",
}

return _settings
