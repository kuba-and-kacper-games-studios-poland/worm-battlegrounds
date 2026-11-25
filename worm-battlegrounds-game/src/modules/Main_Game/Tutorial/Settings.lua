--- @class Tutorial_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Rewards

	--[[
		The diamonds finishing the tutorial gives, or ending it early (the owner, 2026-11-24: paid in the lobby once a weapon
		is equipped); diamonds since 2026-11-25, half the old 100 coins
	]]
	MATCH_DIAMONDS = "50",

	-- The weapons the tutorial match gives (no crate since 2026-11-15); the player then equips one of them
	--- @type { string }
	STARTER_WEAPONS = { "Grenade", "Shotgun" },

	--%%%%%%%%%%%%%%%%%%%% Steps

	-- The maps the match guide and the lobby guide run on (the Studio map runs both), and the tutorial match's kind
	MATCH_MAP = "Match",
	LOBBY_MAP = "Lobby",
	MATCH_KIND = "Tutorial",

	--[[
		What each step's hint says, two or three words (the owner, 2026-11-24: "VERY VERY SIMPLE"): in the match the spot
		to land on, the first drag, then FIRE; in the lobby picking a weapon, in the picker or on a free slot. Capitals
		come from the gui (TextCase_Upper)
	]]
	--- @type { [string]: string }
	HINTS = {
		Drop = "Click to land",
		Move = "Move here",
		Aim = "Drag to aim",
		Fire = "Press FIRE",
		Pick = "Pick a weapon",
	},

	-- What the hints say on a touch screen instead, where they differ
	--- @type { [string]: string }
	TOUCH_HINTS = {
		Drop = "Tap to land",
		Fire = "Tap FIRE",
	},

	--[[
		What the hints say on a pad instead, where they differ: each {Action} is the button of that action in the Console
		module's scheme, named for the player's pad ("RT" or "R2")
	]]
	--- @type { [string]: string }
	PAD_HINTS = {
		Drop = "{Move} to the light, {PlaceDrop} to land",
		Aim = "Aim with {Aim}",
		Fire = "Press {Fire}",
	},

	--[[
		The tutorial's steps in the Roblox onboarding funnel (Creator Hub → Analytics → Funnels), in order: each is
		logged once a player first sees its hint (the server's AnalyticsService), "Won" with the win card, "Equipped" when
		the tutorial is done. Changed 2026-11-24 with the shorter tutorial, so the numbers before and after don't compare
	]]
	--- @type { string }
	FUNNEL_STEPS = { "Drop", "Move", "Aim", "Fire", "Won", "Pick", "Equipped" },

	--[[
		The first step of the player's first turn (the owner, 2026-11-25: "MOVE HERE - and a arrow and like a tip showing
		that we can move around"): a ring on the ground MOVE_DISTANCE studs from the snail (toward the bot, else away,
		else MOVE_SHORT_DISTANCE; only flat ground, at most MOVE_STEP studs up or down from the snail's feet), done once
		the snail is MOVE_REACH studs from it or has walked MOVE_DONE_DISTANCE; with no such ground it's skipped
	]]
	MOVE_DISTANCE = 8,
	MOVE_SHORT_DISTANCE = 5,
	MOVE_STEP = 3,
	MOVE_REACH = 2,
	MOVE_DONE_DISTANCE = 6,

	-- The tip under "Move here", by the player's device ({Move} names the pad's stick, as in PAD_HINTS)
	--- @type { [string]: string }
	MOVE_TIPS = {
		Desktop = "Walk with A and D, or the arrow keys",
		Mobile = "Walk with the arrow buttons",
		Console = "Walk with {Move}",
	},

	--%%%%%%%%%%%%%%%%%%%% Public Matches Hint

	--[[
		Once the tutorial is done, the lobby shows where to play with others (the owner, 2026-11-25: "a hint that tells
		player that he can join the public matches... shouldnt be annoying and should disable after a while", then "maybe
		the JOIN buttons glowing... players might try to click the PUBLIC MATCHES text"): every JOIN on the board glows,
		its S_Glow pulsing between PUBLIC_GLOW_TRANSPARENCY's two values PUBLIC_GLOW_RATE radians a second, with one small
		line beside the board's title (the tip's size, no arrow), PUBLIC_HINT_DELAY seconds after each arrival in the lobby
		(after the diamonds fly in), for PUBLIC_HINT_SECONDS, hidden under any window, and never again once the player has
		played PUBLIC_HINT_MATCHES matches (their MatchesPlayed: the tutorial's counts)
	]]
	PUBLIC_HINT = "Hit JOIN to play with other players!",

	--- @type { number }
	PUBLIC_GLOW_TRANSPARENCY = { 0, 0.55 },
	PUBLIC_GLOW_RATE = 4,
	PUBLIC_HINT_DELAY = 3,
	PUBLIC_HINT_SECONDS = 12,
	PUBLIC_HINT_MATCHES = 2,

	--%%%%%%%%%%%%%%%%%%%% End Tutorial

	--[[
		END TUTORIAL, on the top bar through the tutorial match (in Leave game's place, with its icon): it asks first, then
		ends the whole tutorial, paying MATCH_DIAMONDS and giving the starter weapons, and goes back to the lobby
	]]
	END_TEXT = "End tutorial",
	END_ICON = "rbxassetid://107990939394341",
	END_QUESTION = "End the tutorial? You still get 50 diamonds.",

	--%%%%%%%%%%%%%%%%%%%% Win Card

	-- The win card's title when the player won the tutorial match, and when they didn't (fell in the sea)
	WIN_TITLE = "You won!",
	LOST_TITLE = "Nice try!",

	--%%%%%%%%%%%%%%%%%%%% Guide

	--[[
		The ring round a spot in the world (the drop's lit spot): WORLD_HOLE_RADIUS studs around it, never smaller than
		HOLE_MIN pixels, pulsing RING_PULSE_RATE radians a second. A gui element gets the arrow alone, pointing at it from
		HOLE_PADDING pixels past its edge
	]]
	HOLE_PADDING = 6,
	WORLD_HOLE_RADIUS = 3,
	HOLE_MIN = 56,
	RING_PULSE_RATE = 4,

	--[[
		The red arrow (the snail tag's turn arrow) points at the target from ARROW_GAP pixels above it (below it when the
		target is in the screen's top ARROW_FLIP_SHARE), bobbing ARROW_BOB pixels toward it ARROW_BOB_RATE radians a second
	]]
	ARROW_GAP = 6,
	ARROW_FLIP_SHARE = 0.3,
	ARROW_BOB = 12,
	ARROW_BOB_RATE = 6,

	--[[
		The hint, the HUD's own outlined text with no panel, sits HINT_GAP pixels past the arrow (or past the target when
		it has none), HINT_EDGE pixels in from the screen's edges
	]]
	HINT_GAP = 4,
	HINT_EDGE = 16,

	--[[
		Under "Drag to aim" a touch point slides SWIPE_DISTANCE design pixels right and SWIPE_RISE up, SWIPE_GAP under the
		hint, fading in and out, every SWIPE_SECONDS
	]]
	SWIPE_DISTANCE = 150,
	SWIPE_RISE = 34,
	SWIPE_GAP = 56,
	SWIPE_SECONDS = 1.6,

	--%%%%%%%%%%%%%%%%%%%% Gui

	HINT_GUI_NAME = "TutorialHint",
	WIN_GUI_NAME = "TutorialWin",
	MATCH_HUD_GUI_NAME = "MatchHud",
	LOADOUT_GUI_NAME = "Loadout",
	PICKER_GUI_NAME = "LoadoutPicker",
	BOARD_GUI_NAME = "MatchBoard",
}

return _settings
