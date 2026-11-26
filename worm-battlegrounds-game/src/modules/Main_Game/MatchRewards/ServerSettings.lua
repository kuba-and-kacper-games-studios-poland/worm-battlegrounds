--- @class MatchRewards_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Diamonds

	--[[
		A public deathmatch's diamonds by its number of players, then by place. Matches pay diamonds since 2026-11-25 (the
		owner: one currency): every coin reward halved at the crates' rate (100 coins or 50 diamonds), halves rounded up
	]]
	--- @type { [number]: { number } }
	DEATHMATCH_DIAMONDS = {
		[2] = { 25, 8 },
		[4] = { 50, 25, 13, 8 },
		[6] = { 63, 38, 25, 15, 10, 8 },
		[8] = { 75, 50, 35, 25, 18, 13, 10, 8 },
	},

	-- A public team match's diamonds by its number of teams, then by place; winning a 2v2 pays TEAM_2V2_WIN instead
	--- @type { [number]: { number } }
	TEAM_DIAMONDS = {
		[2] = { 50, 8 },
		[3] = { 50, 25, 8 },
		[4] = { 50, 30, 15, 8 },
	},
	TEAM_2V2_WIN = 38,

	-- A solo match pays only a win, by the bot's difficulty
	--- @type { [string]: number }
	SOLO_DIAMONDS = { Easy = 20, Medium = 30, Hard = 40 },

	-- A party match (friends only) pays like a public deathmatch of its size, times this share when it has no bots
	PARTY_NO_BOTS_SHARE = 0.5,

	-- The last 2 places are paid only after this many rounds, or when another snail knocked the player out
	ANTI_FARM_ROUNDS = 2,

	-- The game pass that doubles every diamond reward (its Marketplace id keeps the old name: gifted passes are saved by it)
	DOUBLE_DIAMONDS_PASS = "DoubleCoins",

	--%%%%%%%%%%%%%%%%%%%% XP

	-- XP for finishing a match, and the kinds of match that give it (custom lobbies give none: the testers, 2026-11-13; local play neither)
	XP_PER_MATCH = 100,

	--- @type { [string]: boolean }
	XP_KINDS = { Public = true, Solo = true, Party = true, Custom = false, Local = false },

	-- On top of XP_PER_MATCH: a win (first place, or the winning team), and each snail the player knocked out
	XP_WIN = 50,
	XP_PER_KNOCKOUT = 10,

	-- The lines the lobby's XP replay shows, for one and for several (several matches before the player's lobby saw them)
	--- @type { [string]: { string } }
	XP_LABELS = {
		Played = { "Match played", "%d matches played" },
		Win = { "Victory", "%d victories" },
		Knockouts = { "1 knockout", "%d knockouts" },
	},
}

return _settings
