--- @class Combat_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Shots

	-- Each point of wind pushes wind-affected shots this hard along X, in studs per second squared
	WIND_ACCEL = 3,

	-- How far in front of the snail's ball a shot starts, in studs
	MUZZLE_GAP = 0.8,

	-- Seconds a held RT takes to fill a pad player's power bar from no power to full, then back down; bots charge as fast
	CHARGE_SECONDS = 1.6,

	-- For this long after leaving, a shot can't hit the snail that fired it, in seconds
	SHOOTER_GRACE = 0.25,

	-- The most a projectile may fly before it bursts where it is, in seconds
	MAX_PROJECTILE_TIME = 12,

	--%%%%%%%%%%%%%%%%%%%% Projectile Physics

	--[[
		Flying shots move by the game's own simulation (Ballistics), the same on the server and on every client, in fixed
		steps of PROJECTILE_STEP seconds; a step resolves at most PROJECTILE_MAX_CONTACTS touches, and a shot is set
		PROJECTILE_SKIN studs off what it touched
	]]
	PROJECTILE_STEP = 1 / 60,
	PROJECTILE_MAX_CONTACTS = 4,
	PROJECTILE_SKIN = 0.02,

	--[[
		A bouncing shot keeps BOUNCE_FRICTION of its speed along the surface at each bounce (its row's Elasticity of its
		speed into it); one that hits softer than REST_SPEED (studs per second, into the surface) stays on it and rolls
	]]
	BOUNCE_FRICTION = 0.8,
	REST_SPEED = 8,

	--[[
		A rolling shot slows by ROLL_DRAG studs per second squared, and stops below STOP_SPEED on ground flatter than
		REST_NORMAL_Y (the Y of its normal; 1 is flat): on a slope gravity keeps it rolling down
	]]
	ROLL_DRAG = 12,
	STOP_SPEED = 1.5,
	REST_NORMAL_Y = 0.9,

	--[[
		A shot in water or lava sinks, as in Worms: gravity pulls it at SINK_GRAVITY of its strength, it keeps SINK_KEEP of
		its speed each second, and it's gone after SINK_SECONDS without a blast
	]]
	SINK_GRAVITY = 0.15,
	SINK_KEEP = 0.05,
	SINK_SECONDS = 1.5,

	--[[
		The server sends each shot's state every STATE_INTERVAL seconds; a client whose copy was more than
		CORRECTION_TOLERANCE studs off at that step goes back to it (it keeps HISTORY_SECONDS of steps to rewind) and steps
		again, easing the jump out over about CORRECTION_SMOOTH seconds, and steps at most MAX_CATCH_UP in one frame
	]]
	STATE_INTERVAL = 0.1,
	CORRECTION_TOLERANCE = 0.15,
	HISTORY_SECONDS = 2,
	CORRECTION_SMOOTH = 0.1,
	MAX_CATCH_UP = 240,

	--%%%%%%%%%%%%%%%%%%%% Blasts

	--[[
		A blast throws snails away from its center tilted up by UPWARD_BIAS (0 is straight away, 1 is 45° up), and at
		its edge with KNOCKBACK_EDGE of the speed it throws at its center
	]]
	UPWARD_BIAS = 0.5,
	KNOCKBACK_EDGE = 0.5,

	-- How big a hole a bullet leaves in the terrain, in studs, and the share of its knockback class one bullet pushes
	BULLET_CARVE = 0.75,
	BULLET_KNOCK_SHARE = 0.25,

	--%%%%%%%%%%%%%%%%%%%% Blast Feel

	-- A blast this big (its radius, in studs) shakes the camera and vibrates at full strength; bigger ones go past it
	FEEL_FULL_RADIUS = 10,

	-- Blasts shake and vibrate less the farther they are from the middle of the view, and not at all past this, in studs
	FEEL_RANGE = 90,

	-- How hard a full-strength blast shakes the camera (CameraShake's Magnitude), and how long it takes to settle, in seconds
	SHAKE_MAGNITUDE = 4,
	SHAKE_SETTLE = 0.45,

	--[[
		A blast at least this strong vibrates a phone or pad (the Combat_BlastBig and Combat_BlastSmall haptic presets);
		a weaker one only shakes
	]]
	HAPTIC_BIG = 0.6,
	HAPTIC_SMALL = 0.15,

	--[[
		The most chunks of ground a blast throws, how fast they fly (studs per second), the smallest and biggest side
		of a chunk (studs), and how long one lies on the ground before it fades (seconds)
	]]
	DEBRIS_MAX = 16,

	--- @type { number }
	DEBRIS_SPEED = { 25, 50 },

	--- @type { number }
	DEBRIS_SIZE = { 0.3, 1 },

	DEBRIS_LIFETIME = 2.5,

	--%%%%%%%%%%%%%%%%%%%% Behaviors

	-- Bomblets fly out of a cluster bomb at a random speed between these, in studs per second
	--- @type { number }
	BOMBLET_SPEED = { 20, 40 },

	-- For this long a bomblet flies through everything, so it leaves its cluster bomb's crater, in seconds
	BOMBLET_GHOST = 0.1,

	-- Snails crawl at SNAIL_SPEED, take a bite of terrain every SNAIL_BITE seconds, and stop after SNAIL_LIFETIME
	SNAIL_SPEED = 6,
	SNAIL_BITE = 0.3,
	SNAIL_LIFETIME = 6,

	-- A crawling spider bomb or a homing missile bursts once this close to a snail, in studs
	CONTACT_DISTANCE = 2.5,

	-- A rolling black hole grenade hops over bumps with this upward speed
	ROLL_HOP_SPEED = 22,

	-- The box a melee swing checks in front of the snail, in studs on each side
	MELEE_BOX = 4,

	--%%%%%%%%%%%%%%%%%%%% Held Weapon

	--[[
		Where the active snail holds its weapon, from its ball's center: HELD_FORWARD studs along its aim, HELD_HEIGHT up
		and HELD_DEPTH toward the camera (+Z), so the weapon is always on the side players see; it turns to a new aim at
		HELD_TURN_SPEED (higher is snappier)
	]]
	HELD_FORWARD = 0.8,
	HELD_HEIGHT = -0.3,
	HELD_DEPTH = 1.5,
	HELD_TURN_SPEED = 14,

	--%%%%%%%%%%%%%%%%%%%% Placeholders

	--[[
		shortcut: weapons whose shot flies as another weapon's projectile model until the studio makes their own (the
		Bazooka's rocket as the homing missile's missile)
	]]
	--- @type { [string]: string }
	PROJECTILE_STAND_INS = { Bazooka = "HomingMissile" },

	-- shortcut: projectiles are plain neon parts in these colours until the real models exist
	--- @type { [string]: Color3 }
	PROJECTILE_COLORS = {
		Rocket = Color3.fromRGB(255, 170, 40),
		Bouncer = Color3.fromRGB(80, 200, 80),
		Crawler = Color3.fromRGB(40, 40, 40),
		Homing = Color3.fromRGB(255, 70, 70),
		Roller = Color3.fromRGB(120, 40, 200),
		Snail = Color3.fromRGB(255, 220, 60),
		Bomblet = Color3.fromRGB(200, 120, 40),
	},
	PROJECTILE_SIZE = 1,

	-- shortcut: blasts draw with the particle pictures every Roblox client ships until the studio makes its own
	--- @type { [string]: string }
	BLAST_TEXTURES = {
		Smoke = "rbxasset://textures/particles/smoke_main.dds",
		Fire = "rbxasset://textures/particles/fire_main.dds",
		Sparks = "rbxasset://textures/particles/sparkles_main.dds",
	},
}

return _settings
