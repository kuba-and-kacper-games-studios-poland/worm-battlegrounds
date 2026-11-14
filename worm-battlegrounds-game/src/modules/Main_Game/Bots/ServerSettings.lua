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
		"Snailzilla",
		"Noodle",
		"Sprocket",
		"Gizmo",
		"Turbo",
		"Biscuit",
		"Rascal",
		"Studs",
		"Fleaper",
		"Shide",
		"MB",
		"gaspro",
		"RedBicycle12",
		"Tommy",
		"Travis",
		"REKTWASAKI",
		"Lats",
		"George",
		"ozyboii",
		"GloriousMorning",
	},

	-- The difficulty a bot plays a dropped player's snail at, with that player's own loadout
	TAKEOVER_DIFFICULTY = "Medium",

	-- What each difficulty takes into a match: weapons, and the jetpack and heals it moves and heals with
	--- @type { [string]: { string } }
	LOADOUTS = {
		Easy = { "Grenade", "Shotgun", "Jetpack" },
		Medium = { "Grenade", "Shotgun", "Dynamite", "SpiderBomb", "Jetpack", "Bandage" },
		Hard = { "Dynamite", "ClusterBomb", "Uzi", "HomingMissile", "BaseballBat", "SpiderBomb", "Jetpack", "Medkit" },
		Nightmare = { "Grenade", "Dynamite", "ClusterBomb", "Uzi", "HomingMissile", "BaseballBat", "SpiderBomb", "BlackHoleGrenade", "Jetpack", "Medkit" },
	},

	--[[
		Every bot (the tutorial's aside) also rolls one of these, at even odds, onto its loadout: none (""), or a potion
		it drinks only when the spot it wants is past its walk (Speed) or up a ledge its jump can't reach (Low gravity)
	]]
	--- @type { string }
	POTIONS = { "", "SpeedPotion", "LowGravityPotion" },

	-- No bot parachutes in within START_GAP studs of a spot taken already, a player's or a bot's (GetStart)
	START_GAP = 20,

	--[[
		Taunts: TAUNT_DELAY seconds after a bot's shot knocks out an enemy it plays one of TAUNT_KILL, and after one that
		hurts a player for TAUNT_DAMAGE or more, one of TAUNT_HIT at TAUNT_CHANCE (Cosmetics' PlaySnailEmote)
	]]
	--- @type { string }
	TAUNT_KILL = { "Emote_Taunt", "Emote_Laugh", "Emote_Flex", "Emote_Dance", "Emote_Backflip", "Emote_VictoryTrumpet" },

	--- @type { string }
	TAUNT_HIT = { "Emote_Laugh", "Emote_ThumbsUp", "Emote_Flex", "Emote_Taunt" },

	TAUNT_DAMAGE = 20,
	TAUNT_CHANCE = 0.6,
	TAUNT_DELAY = 1.2,

	--%%%%%%%%%%%%%%%%%%%% Skill

	--[[
		How well each difficulty plays, the human side its trained brain (ServerData/Brains) plays through:
		- AimNoise, PowerNoise: the spread of its hand, in degrees of angle and share of power (one standard deviation)
		- WindRead: how much of the wind it counts in its aim (1 reads it exactly)
		- Ranging: what each earlier shot at the same target from about the same spot multiplies its spread by, as
		  players walk their shots in, never under RangingMin
		- Spots, Targets, Finalists: how many places to shoot from, enemies to aim at and best shots to simulate in full
		  it weighs each turn
		- AimPoints: where on each target it tries to land a shot: 1 the snail, 2 also its feet, 3 also the ground under
		  it on its side nearer a deadly drop (to blast it out from under it), 4 also the other side
		- MapSense: how much it minds the map where it stands (a deadly edge, ground a blast would drop it through, low
		  ground near the sea), from 0 to 1
		- Choice: how loosely it picks among its plans (0 always takes the best; higher takes good-enough ones more often)
		- AirShots: how many spots in the air, hovering on its jetpack, it also weighs shooting from (0: none)
		- Banks: how many bank shots it tries with a bouncing weapon (the Grenade, the Cluster bomb) when its direct
		  arc at a target misses by more than BANK_MISS: landing beside or past it, to bounce and roll in
		- Hunt: how much nearer players (not bots) count when it picks its targets, from 0 to 1
		- StartNoise: how loosely it picks where it parachutes in (GetStart), on top of what its genome likes there
		Nightmare is secret: it isn't on the board.
	]]
	--- @type { [string]: Bots_Skill }
	SKILLS = {
		Easy = {
			AimNoise = 9,
			PowerNoise = 0.1,
			WindRead = 0.4,
			Ranging = 0.8,
			RangingMin = 0.5,
			Spots = 2,
			Targets = 1,
			Finalists = 3,
			AimPoints = 1,
			MapSense = 0.5,
			Choice = 0.5,
			AirShots = 0,
			Banks = 0,
			Hunt = 0,
			StartNoise = 1,
		},
		Medium = {
			AimNoise = 4.5,
			PowerNoise = 0.06,
			WindRead = 0.8,
			Ranging = 0.75,
			RangingMin = 0.35,
			Spots = 4,
			Targets = 2,
			Finalists = 5,
			AimPoints = 2,
			MapSense = 0.75,
			Choice = 0.2,
			AirShots = 0,
			Banks = 0,
			Hunt = 0,
			StartNoise = 0.5,
		},
		Hard = {
			AimNoise = 1.8,
			PowerNoise = 0.025,
			WindRead = 1,
			Ranging = 0.7,
			RangingMin = 0.25,
			Spots = 7,
			Targets = 3,
			Finalists = 10,
			AimPoints = 3,
			MapSense = 1,
			Choice = 0,
			AirShots = 2,
			Banks = 2,
			Hunt = 0,
			StartNoise = 0.25,
		},
		Nightmare = {
			AimNoise = 0.5,
			PowerNoise = 0.008,
			WindRead = 1,
			Ranging = 0.6,
			RangingMin = 0.15,
			Spots = 14,
			Targets = 4,
			Finalists = 24,
			AimPoints = 4,
			MapSense = 1,
			Choice = 0,
			AirShots = 6,
			Banks = 6,
			Hunt = 0.5,
			StartNoise = 0.15,
		},
	},

	--%%%%%%%%%%%%%%%%%%%% Turns

	-- A bot thinks for a random time between these before it moves and takes aim, in seconds (its plan is made meanwhile)
	--- @type { number }
	THINK_TIME = { 0.8, 1.5 },

	-- A short pause after a heal or a walk, so it reads like a player's, in seconds
	ACTION_PAUSE = 0.4,

	--[[
		Then it holds its weapon, swings its crosshair from level to its shot over AIM_TIME seconds, charges its power
		as a player would (Combat's CHARGE_SECONDS for full power), all sent every AIM_STEP and shown to every player,
		and fires
	]]
	AIM_TIME = 1.2,
	AIM_STEP = 0.1,

	-- The health a difficulty's bot starts with, where it isn't Snails' MAX_HEALTH: any hit knocks the tutorial bot out
	--- @type { [string]: number }
	HEALTH = { Tutorial = 10 },

	-- How far the tutorial bot charges its Bazooka before it gives up without firing
	TUTORIAL_FUMBLE_POWER = 0.3,

	--%%%%%%%%%%%%%%%%%%%% Planning

	--[[
		Arc shots are solved exactly for each share of power in POWER_STEPS (a low and a high arc each), then checked
		against the terrain along their path for ARC_SECONDS, a point every ARC_STEP seconds
	]]
	--- @type { number }
	POWER_STEPS = { 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1 },

	ARC_SECONDS = 4,
	ARC_STEP = 1 / 20,

	-- A finalist's full simulation stops after this many seconds of the shot's own (slowed) flight time
	PREDICT_SECONDS = 6.4,

	-- A spider bomb's crawl is foreseen a step of this many seconds at a time
	CRAWL_PREDICT_STEP = 1 / 20,

	-- A plan gives the server a frame after this many seconds of thinking in a row, so a turn never stalls it
	THINK_SLICE = 0.008,

	--[[
		Spots to shoot from are the ground every MOVE_STEP studs within its stamina, up to CLIMB_MAX studs higher with a
		jetpack; it swings a melee weapon from MELEE_GAP studs and places Dynamite DYNAMITE_GAP studs from a target on
		about its level (CLOSE_HEIGHT studs)
	]]
	MOVE_STEP = 4,
	CLIMB_MAX = 14,
	MELEE_GAP = 3,
	DYNAMITE_GAP = 2,
	CLOSE_HEIGHT = 3,

	--[[
		What it knows about a spot: how near a deadly drop is within EDGE_LOOK studs, its height over the enemies (a full
		point per HEIGHT_SCALE studs), which enemies see it within SIGHT_RANGE studs, and who stands within CROWD_RANGE
	]]
	EDGE_LOOK = 10,
	HEIGHT_SCALE = 20,
	SIGHT_RANGE = 60,
	CROWD_RANGE = 8,

	--[[
		How a spot's footing is judged: a blast of UNDERMINE_RADIUS at its feet, and whether the snail would then drop
		into the sea or how far; ground less than LOW_RANGE studs over the sea counts as low, more so from URGENCY_ROUNDS
		rounds before sudden death (Match's SUDDEN_DEATH_ROUND)
	]]
	UNDERMINE_RADIUS = 6,
	LOW_RANGE = 15,
	URGENCY_ROUNDS = 3,

	-- The ground under a target its harder bots try to blast away: this far to its side and below its feet, in studs
	UNDER_SIDE = 4,
	UNDER_DEPTH = 2,

	-- A snail thrown by a blast is followed for KNOCK_SECONDS, a step every KNOCK_STEP seconds, to see where it lands
	KNOCK_SECONDS = 3,
	KNOCK_STEP = 1 / 30,

	--[[
		A thrown snail that lands slides on along the ground, as Snails' FLIGHT_LAND_KEEP hands it to Roblox physics: for
		this many seconds at that share of its speed, off any edge on the way
	]]
	KNOCK_SLIDE_SECONDS = 0.25,

	-- A spot with terrain less than COVER_HEIGHT studs over it is under cover: shots from above can't drop on it
	COVER_HEIGHT = 12,

	-- Standing with its head in a pond costs Match's UNDERWATER_DAMAGE every turn: a spot counts it this many times
	POND_TURNS = 3,

	--[[
		A shot that hurts no enemy is still worth its genome's Pressure the nearer it lands to one, full at the snail and
		nothing from PRESSURE_RANGE studs: it shoots toward enemies it can't reach, and digs its way to them
	]]
	PRESSURE_RANGE = 30,

	--[[
		With no arc reaching any target, it aims at the terrain toward each one instead: points every DIG_STEP studs along
		the way, from DIG_MIN studs off (never right over its head)
	]]
	DIG_MIN = 10,
	DIG_STEP = 8,

	-- A shot that knocks out the last enemy is worth this much more: it pays for hurting its own side to win
	WIN_VALUE = 6,

	--[[
		A skill's Banks: when its direct arc at a target lands more than BANK_MISS studs off, a bouncing weapon also
		tries points BANK_STEP studs apart on the ground either side of the target, and BANK_HEIGHT studs over them on
		its far side (a wall it bounces back off), judged by where the full flight bursts
	]]
	BANK_MISS = 3,
	BANK_STEP = 5,
	BANK_HEIGHT = 6,

	--%%%%%%%%%%%%%%%%%%%% Moving

	--[[
		Bots walk, jump and fly their jetpack with SnailControl's speeds and stamina. A walk ends within ARRIVE_DISTANCE
		studs of its spot, after MOVE_SECONDS, or when it moved less than STUCK_DISTANCE in STUCK_SECONDS; it waits up to
		LAND_SECONDS to stand on the ground before it aims
	]]
	MOVE_SECONDS = 4,
	ARRIVE_DISTANCE = 0.75,
	STUCK_DISTANCE = 0.3,
	STUCK_SECONDS = 0.8,
	LAND_SECONDS = 2,

	--[[
		A bot checks the ground WALK_LOOK studs past its ball before each step, down to FALL_LOOK studs: no ground, the
		sea or a drop that hurts (Snails' SAFE_FALL_HEIGHT) stops it, unless its jetpack carries it over
	]]
	WALK_LOOK = 1,
	FALL_LOOK = 60,

	-- A walk that ends more than CLOSE_SLACK studs further from its target than planned doesn't swing or place
	CLOSE_SLACK = 1.5,

	-- Running from its Dynamite with a jetpack on, a bot flies up to this many studs over where it placed it
	ESCAPE_HEIGHT = 8,

	--[[
		Flying, it keeps HEADROOM studs between its ball and a ceiling, and gives up on a wall after jumping at it
		WALL_JUMPS times without getting past
	]]
	HEADROOM = 1.5,
	WALL_JUMPS = 2,

	--[[
		A spot in the air (a skill's AirShots) hovers at least AIR_MIN studs over the ground: as high as a safe fall, and
		also as high as its flight goes, where the fall after its shot costs health (the spot's Fall), worth it only
		when the shot pays for it
	]]
	AIR_MIN = 5,

	--%%%%%%%%%%%%%%%%%%%% Training

	--[[
		The gym (Studio only) starts when the Workspace attribute TRAIN_ATTRIBUTE is set to its options (JSON), shows
		its progress in TRAIN_STATUS_ATTRIBUTE and writes its report to ServerStorage's TRAIN_RESULT StringValue
	]]
	TRAIN_ATTRIBUTE = "Bots_Train",
	TRAIN_STATUS_ATTRIBUTE = "Bots_TrainStatus",
	TRAIN_RESULT = "Bots_TrainResult",

	-- A training run's defaults, which its options override
	--- @type Bots_TrainOptions
	TRAIN_DEFAULTS = {
		Difficulty = "Hard",
		Generations = 6,
		Population = 8,
		MatchesPerGeneration = 6,
		ExamMatches = 6,
		Elites = 2,
		MutationRate = 0.35,
		MutationSize = 0.35,
		MaxRounds = 14,
		Seed = 0,
		Log = false,
	},

	-- How each seat counts in a match's result: a free-for-all's first to last place, and a team match's win
	--- @type { number }
	PLACE_POINTS = { 1, 0.45, 0.15, 0 },

	-- A seat's fitness also counts every point of damage dealt to enemies, and takes away every one to allies
	DAMAGE_POINTS = 0.002,

	-- The longest a gym turn waits for the ground a blast cut loose to land, in seconds
	SETTLE_LIMIT = 1.5,

	-- The gym's bots think this long before giving its server a frame (live bots: THINK_SLICE), in seconds
	GYM_THINK_SLICE = 0.1,

	--[[
		The parity probe (Studio only, Scripts/Server/Parity) runs when the Workspace attribute PARITY_ATTRIBUTE is set
		to its maps as JSON (`{"Maps": [...]}`, `{}` for every map) and writes its report to ServerStorage's
		PARITY_RESULT folder, in StringValues of under PARITY_CHUNK characters, for the PC gym's report to be compared
		with
	]]
	PARITY_ATTRIBUTE = "Bots_Parity",
	PARITY_RESULT = "Bots_ParityResult",
	PARITY_CHUNK = 150000,
}

return _settings
