--- @class Combat_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Shots

	-- Each point of wind pushes wind-affected shots this hard along X, in studs per second squared
	WIND_ACCEL = 3,

	-- How far in front of the worm's ball a shot starts, in studs
	MUZZLE_GAP = 0.8,

	-- For this long after leaving, a shot can't hit the worm that fired it, in seconds
	SHOOTER_GRACE = 0.25,

	-- The most a projectile may fly before it bursts where it is, in seconds
	MAX_PROJECTILE_TIME = 12,

	--%%%%%%%%%%%%%%%%%%%% Blasts

	--[[
		A blast throws worms away from its center tilted up by UPWARD_BIAS (0 is straight away, 1 is 45° up), and at
		its edge with KNOCKBACK_EDGE of the speed it throws at its center
	]]
	UPWARD_BIAS = 0.5,
	KNOCKBACK_EDGE = 0.5,

	-- How big a hole a bullet leaves in the terrain, in studs, and the share of its knockback class one bullet pushes
	BULLET_CARVE = 0.75,
	BULLET_KNOCK_SHARE = 0.25,

	--%%%%%%%%%%%%%%%%%%%% Behaviors

	-- Bomblets fly out of a cluster bomb at a random speed between these, in studs per second
	--- @type { number }
	BOMBLET_SPEED = { 20, 40 },

	-- Snails crawl at SNAIL_SPEED, take a bite of terrain every SNAIL_BITE seconds, and stop after SNAIL_LIFETIME
	SNAIL_SPEED = 6,
	SNAIL_BITE = 0.3,
	SNAIL_LIFETIME = 6,

	-- A crawling spider bomb or a homing missile bursts once this close to a worm, in studs
	CONTACT_DISTANCE = 2.5,

	-- A rolling black hole grenade hops over bumps with this upward speed
	ROLL_HOP_SPEED = 22,

	-- The box a melee swing checks in front of the worm, in studs on each side
	MELEE_BOX = 4,

	--%%%%%%%%%%%%%%%%%%%% Placeholders

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
}

return _settings
