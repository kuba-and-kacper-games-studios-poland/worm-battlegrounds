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
		Fire = "Drag toward the bot to aim: the longer the drag, the stronger the shot. Let go to fire, or press FIRE on a touch screen",
		BotTurn = "The bot's turn. Watch out!",
		Finish = "Two hits knock it out. Finish it!",
		Equip = "Put the Grenade and the Shotgun in your loadout",
	},

	-- How fast a snail must rise, in studs per second, to count as a jump
	JUMP_SPEED = 6,

	--%%%%%%%%%%%%%%%%%%%% Gui

	HINT_GUI_NAME = "TutorialHint",
	LOBBY_GUI_NAME = "Lobby",
	LOADOUT_GUI_NAME = "Loadout",
}

return _settings
