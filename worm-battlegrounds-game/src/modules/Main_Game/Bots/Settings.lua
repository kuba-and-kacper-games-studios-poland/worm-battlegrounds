--- @class Bots_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Bots

	-- Names bots play under, picked at random without repeats in a match
	--- @type { string }
	BOT_NAMES = {
		"Bax",
		"Ninja",
		"Pickles",
		"Bricky",
		"Wormzilla",
		"Noodle",
		"Sprocket",
		"Gizmo",
		"Turbo",
		"Biscuit",
		"Rascal",
		"Studs",
	},

	-- What each difficulty takes into a match
	--- @type { [string]: { string } }
	LOADOUTS = {
		Easy = { "Grenade", "Shotgun" },
		Medium = { "Grenade", "Shotgun", "Dynamite" },
		Hard = { "Dynamite", "ClusterBomb", "Uzi", "HomingMissile", "BaseballBat" },
	},

	--%%%%%%%%%%%%%%%%%%%% Turns

	-- A bot thinks for a random time between these before it takes aim, in seconds
	--- @type { number }
	THINK_TIME = { 2.5, 4 },

	--[[
		Then it holds its weapon and swings its aim from level to its shot over AIM_TIME seconds (sent every AIM_STEP,
		power starting at AIM_START_POWER), shown to every player, and fires
	]]
	AIM_TIME = 1.5,
	AIM_STEP = 0.1,
	AIM_START_POWER = 0.3,

	-- How often each difficulty's shot lands where it aimed (the rest miss on purpose)
	--- @type { [string]: number }
	HIT_RATE = { Easy = 0.3, Medium = 0.6, Hard = 0.85, Tutorial = 0 },

	-- How much of each hit a difficulty's bot takes: the tutorial bot falls to two Bazooka hits (35 x 3 = 105 of 200)
	--- @type { [string]: number }
	DAMAGE_TAKEN = { Tutorial = 3 },

	-- How far a missed shot is off, in radians of angle and share of power, at most
	MISS_ANGLE = 0.25,
	MISS_POWER = 0.25,

	--%%%%%%%%%%%%%%%%%%%% Aim Search

	--[[
		A bot tries every ANGLE_STEP degrees and every POWER_STEP of power, follows each arc for ARC_SECONDS, and keeps
		the one that lands nearest its target; it gives the server a frame every SEARCH_BATCH arcs
	]]
	ANGLE_STEP = 6,
	POWER_STEP = 0.1,
	ARC_SECONDS = 4,
	ARC_STEP = 1 / 20,
	SEARCH_BATCH = 20,

	-- Within this distance a bot swings its melee weapon or fires a gun straight, in studs
	MELEE_RANGE = 5,
	GUN_RANGE = 40,
}

return _settings
