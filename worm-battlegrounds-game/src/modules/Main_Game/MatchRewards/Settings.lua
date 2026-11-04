--- @class MatchRewards_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Coins

	-- A public deathmatch's coins by its number of players, then by place
	--- @type { [number]: { number } }
	DEATHMATCH_COINS = {
		[2] = { 50, 15 },
		[4] = { 100, 50, 25, 15 },
		[6] = { 125, 75, 50, 30, 20, 15 },
		[8] = { 150, 100, 70, 50, 35, 25, 20, 15 },
	},

	-- A public team match's coins by its number of teams, then by place; winning a 2v2 pays TEAM_2V2_WIN instead
	--- @type { [number]: { number } }
	TEAM_COINS = {
		[2] = { 100, 15 },
		[3] = { 100, 50, 15 },
		[4] = { 100, 60, 30, 15 },
	},
	TEAM_2V2_WIN = 75,

	-- A solo match pays only a win, by the bot's difficulty
	--- @type { [string]: number }
	SOLO_COINS = { Easy = 20, Medium = 35, Hard = 60 },

	-- The last 2 places are paid only after this many rounds, or when another worm knocked the player out
	ANTI_FARM_ROUNDS = 2,

	-- The game pass that doubles every coin reward
	DOUBLE_COINS_PASS = "DoubleCoins",

	--%%%%%%%%%%%%%%%%%%%% XP

	-- XP for finishing a match, and the kinds of match that give it (the wiki still asks which do)
	XP_PER_MATCH = 100,

	--- @type { [string]: boolean }
	XP_KINDS = { Public = true, Solo = true, Custom = true },
}

return _settings
