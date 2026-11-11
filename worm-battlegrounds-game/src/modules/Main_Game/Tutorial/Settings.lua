--- @class Tutorial_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Rewards

	-- The coins a player brings back from the tutorial match, the price of the tutorial crate
	MATCH_COINS = "100",

	-- The crate the lobby offers once, and the weapons it gives, which the player then equips
	CRATE_ID = "Tutorial",

	--- @type { string }
	STARTER_WEAPONS = { "Grenade", "Shotgun" },

	--%%%%%%%%%%%%%%%%%%%% Match Hints

	-- The maps the match hints and the lobby hints run on (the Studio map runs both), and the tutorial match's kind
	MATCH_MAP = "Match",
	LOBBY_MAP = "Lobby",
	MATCH_KIND = "Tutorial",

	-- What each hint says, in order: walk, jump, aim and fire, the bot's turn, then finishing it
	--- @type { [string]: string }
	HINTS = {
		Walk = "Walk with A and D, or the arrow keys",
		Jump = "Jump with Space",
		Fire = "Point at the bot to aim, hold the mouse button to charge, let go to fire. On a touch screen, tap to aim and hold FIRE",
		BotTurn = "The bot's turn. Watch out!",
		Finish = "Two hits knock it out. Finish it!",
		Equip = "Put the Grenade and the Shotgun in your loadout",
	},

	--[[
		What the match hints say on a pad instead, where they differ: each {Action} is the button of that action in
		the Console module's scheme, named for the player's pad ("RT" or "R2")
	]]
	--- @type { [string]: string }
	PAD_HINTS = {
		Walk = "Walk with {Move} or the D-pad",
		Jump = "Jump with {Jump}, hold it to fly",
		Fire = "Aim at the bot with {Aim}, hold {Fire} to charge, let go to fire",
	},

	-- How fast a snail must rise, in studs per second, to count as a jump
	JUMP_SPEED = 6,

	--%%%%%%%%%%%%%%%%%%%% Gui

	HINT_GUI_NAME = "TutorialHint",
	LOBBY_GUI_NAME = "Lobby",
	LOADOUT_GUI_NAME = "Loadout",
}

return _settings
