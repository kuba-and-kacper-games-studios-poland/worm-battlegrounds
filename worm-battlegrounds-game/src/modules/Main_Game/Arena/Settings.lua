--- @class Arena_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Terrain

	-- How much longer than the terrain is deep the carving cylinder is, so it always cuts all the way through
	CARVE_DEPTH_MARGIN = 2,

	-- How far apart two pieces may sit, in studs, and still hold each other up
	CONTACT_MARGIN = 0.15,

	-- The most pieces one support search walks before it treats the group as grounded, so a carve stays cheap
	SUPPORT_SEARCH_LIMIT = 400,

	--%%%%%%%%%%%%%%%%%%%% Collision

	--[[
		The collision groups registered at start, each with the groups it never collides with: worms stand on terrain
		but pass through each other and the place's own parts, and ghosts touch nothing
	]]
	--- @type { [string]: { string } }
	COLLISION_GROUPS = {
		Terrain = {},
		Worm = { "Worm", "Default" },
		Projectile = { "Projectile", "Default" },
		Ghost = { "Default", "Terrain", "Worm", "Projectile", "Ghost" },
	},

	--%%%%%%%%%%%%%%%%%%%% Debris

	--[[
		A falling group has landed once it moves slower than SETTLE_SPEED (studs per second) for SETTLE_HOLD
		seconds, or after DEBRIS_SETTLE_TIME seconds at most; it is removed once it falls DEBRIS_KILL_DEPTH
		studs below the arena's bounds
	]]
	SETTLE_SPEED = 0.5,
	SETTLE_HOLD = 0.5,
	DEBRIS_SETTLE_TIME = 4,
	DEBRIS_KILL_DEPTH = 20,

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
}

return _settings
