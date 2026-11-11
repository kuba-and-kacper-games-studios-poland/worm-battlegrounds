--- @class Arena_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Terrain

	-- How much longer than the terrain is deep the cutter is, so it always cuts all the way through
	CARVE_DEPTH_MARGIN = 2,

	--[[
		The grid blasts cut on, in studs, lined up with the maps' 1-stud grid: a blast takes every square whose center is
		within its radius, so craters are stepped like voxels
	]]
	CARVE_CELL = 1,

	-- How far apart two pieces may sit, in studs, and still hold each other up; also how far above the floor bedrock may end
	CONTACT_MARGIN = 0.15,

	-- The most pieces one support search walks before it treats the group as held up, so a carve stays cheap
	SUPPORT_SEARCH_LIMIT = 400,

	-- How long a hole a client cut on its own waits for the server's pieces, in seconds, before it's undone
	PREDICT_TIMEOUT = 3,

	--%%%%%%%%%%%%%%%%%%%% Land Spots

	--[[
		Where snails stand when they don't pick a spot (bots, players who don't place theirs): the ground is looked for
		every LAND_SPOT_STEP studs along the arena, and spots are kept at least LAND_SPOT_GAP studs apart while there's room
	]]
	LAND_SPOT_STEP = 2,
	LAND_SPOT_GAP = 16,

	-- How steep ground a snail may stand on: the lowest Y of the ground's normal (1 is flat)
	LAND_SPOT_MIN_NORMAL = 0.7,

	--[[
		Nothing starts in the top START_TOP_GAP studs of the bounds: land that high has no room to parachute onto (Match's
		DROP_HEIGHT), and is a map's roof, like Rockslide Ridge's rock ceiling
	]]
	START_TOP_GAP = 20,

	--%%%%%%%%%%%%%%%%%%%% Collision

	--[[
		The collision groups registered at start, each with the groups it never collides with: snails stand on terrain
		but pass through each other and the place's own parts, ghosts touch nothing, and the chips blasts throw
		(Combat's client effects) bounce on terrain only
	]]
	--- @type { [string]: { string } }
	COLLISION_GROUPS = {
		Terrain = {},
		Snail = { "Snail", "Default" },
		Projectile = { "Projectile", "Default" },
		Ghost = { "Default", "Terrain", "Snail", "Projectile", "Ghost" },
		Chip = { "Chip", "Default", "Snail", "Projectile", "Ghost" },
	},

	--%%%%%%%%%%%%%%%%%%%% Debris

	-- A falling group with no terrain under it falls this many studs below the arena's bounds, then is removed
	DEBRIS_KILL_DEPTH = 20,

	--%%%%%%%%%%%%%%%%%%%% Props

	-- How far under a prop's base (a tree, a bush, a rock) the ground may be before the prop falls, in studs
	PROP_SUPPORT_DEPTH = 1.5,

	--[[
		A blast cuts through the props it reaches; the pieces that still reach the prop's base through each other stand
		(a part that starts at most PROP_BASE_HEIGHT studs above the base is on the ground)
	]]
	PROP_BASE_HEIGHT = 0.6,

	--[[
		How fast a blast throws what it cuts off a prop (and a one-part prop it reaches), in studs per second, and the
		most it spins it, in radians per second
	]]
	PROP_KNOCK_SPEED = 35,
	PROP_KNOCK_SPIN = 6,

	-- How long a fallen or thrown prop lies before it fades out, in seconds, and the fade
	PROP_FADE_DELAY = 3,
	PROP_FADE_TWEENINFO = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),

	--%%%%%%%%%%%%%%%%%%%% Liquid

	-- One liquid block's width and height, in studs, and how many times a second the liquid moves
	LIQUID_CELL = 0.5,
	LIQUID_FPS = 8,

	-- MaterialService's half-stud variant on SmoothPlastic: one stud on every 0.5-stud liquid block
	LIQUID_VARIANT = "2022 Small Stud",

	-- How many cells a falling block drops in one step
	LIQUID_FALL = 6,

	-- A cell counts as solid when terrain reaches into a box this share of the cell's size around its center
	LIQUID_PROBE_SCALE = 0.5,

	-- How many grid rows a map's load probes before it gives the server a frame
	LIQUID_BUILD_ROWS_PER_FRAME = 8,

	--[[
		Only the sea knocks snails out (the liquid at the map's floor, which sudden death raises), up to this many studs
		above its level as its surface ripples; ponds higher up are safe to fall in
	]]
	SEA_SLACK = 1,

	-- The liquid kinds, in the order of their ids in the grid (a map's liquid marker names one)
	--- @type { string }
	LIQUID_KINDS = { "Water", "Lava" },

	-- How far a liquid block moves sideways per step, in cells, toward the nearest way down: water is faster than lava
	--- @type { [string]: number }
	LIQUID_SPREAD = { Water = 12, Lava = 3 },

	--[[
		How many of its highest blocks one connected body of liquid moves each step into lower free cells beside it, so
		it levels through gaps and under debris like liquid under pressure
	]]
	--- @type { [string]: number }
	LIQUID_PRESSURE = { Water = 8, Lava = 2 },

	--- @type { [string]: Color3 }
	LIQUID_COLORS = { Water = Color3.fromRGB(40, 140, 230), Lava = Color3.fromRGB(255, 96, 20) },

	--- @type { [string]: number }
	LIQUID_TRANSPARENCY = { Water = 0.2, Lava = 0 },

	--[[
		Lava turns the water it touches into obsidian: terrain blocks in OBSIDIAN_COLOR, in MaterialService's
		OBSIDIAN_VARIANT, that blasts cut like any ground
	]]
	OBSIDIAN_COLOR = Color3.fromRGB(38, 28, 52),
	OBSIDIAN_VARIANT = "2022 Stud",

	--[[
		Every SEA_MARK_STEPS liquid steps (and after sudden death raises it), the liquid joined to the sea counts as the
		sea, so a pond the rising sea reaches knocks snails out too
	]]
	SEA_MARK_STEPS = 8,
}

return _settings
