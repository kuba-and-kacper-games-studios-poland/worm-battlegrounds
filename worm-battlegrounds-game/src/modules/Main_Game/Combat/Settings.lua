--- @class Combat_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Shots

	--[[
		Each point of wind pushes wind-affected shots WIND_ACCEL studs per second squared along X, plus WIND_ACCEL_GROWTH
		for every point of the wind's strength, so strong wind sweeps a steep shot back the other way (at 6, any shot
		steeper than about 64°; at 10, steeper than about 42°) while light wind stays gentle
	]]
	WIND_ACCEL = 7,
	WIND_ACCEL_GROWTH = 1.5,

	-- How far in front of the snail's ball a shot starts, in studs
	MUZZLE_GAP = 0.8,

	--[[
		Seconds a held press (the mouse button, FIRE on touch, RT) takes to fill the power from none to full, at one even
		rate, as in Worms Armageddon; a full charge fires by itself. Bots charge as fast
	]]
	CHARGE_SECONDS = 1.3,

	-- For this long after leaving, a shot can't hit the snail that fired it, in seconds
	SHOOTER_GRACE = 0.25,

	-- The most a projectile may fly before it bursts where it is, in seconds
	MAX_PROJECTILE_TIME = 20,

	--[[
		Shots fly in slow motion, so players can follow them with their eyes: the same paths at this share of real speed
		(0.5 is half speed). Gravity, wind, speeds and drag all scale with it, and a thrown bomb's Fuse counts its own
		flight time, so it bursts at the same point of its path; a placed one's (Dynamite) stays in real seconds
	]]
	PROJECTILE_TIME_SCALE = 0.5,

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
		A thrown bomb (its Tumble option) leaves the hand turning AIR_SPIN radians a second (of its flight) for each stud a
		second it flies across, at most AIR_SPIN_MAX, and keeps turning through the air until the ground rolls it
	]]
	AIR_SPIN = 0.35,
	AIR_SPIN_MAX = 30,

	--[[
		A rolling shot slows by ROLL_DRAG studs per second squared, and stops below STOP_SPEED on ground flatter than
		REST_NORMAL_Y (the Y of its normal; 1 is flat): on a slope gravity keeps it rolling down
	]]
	ROLL_DRAG = 12,
	STOP_SPEED = 1.5,
	REST_NORMAL_Y = 0.9,

	--[[
		A shot flies on through water or lava, slowed: it keeps SINK_ENTRY_KEEP of its speed as it splashes in, then
		gravity pulls it at SINK_GRAVITY of its strength and it keeps SINK_KEEP of its speed each second of its flight
		while under; it bursts on what it touches there, and it's gone after SINK_SECONDS (real seconds) under without one
	]]
	SINK_ENTRY_KEEP = 0.5,
	SINK_GRAVITY = 0.3,
	SINK_KEEP = 0.12,
	SINK_SECONDS = 4,

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

	--[[
		A full-strength blow jolts the camera (SHAKE_KICK, CameraShake's Magnitude, gone in SHAKE_KICK_SETTLE seconds),
		then rumbles it (SHAKE_MAGNITUDE, settling over SHAKE_SETTLE seconds)
	]]
	SHAKE_KICK = 10,
	SHAKE_KICK_SETTLE = 0.18,
	SHAKE_MAGNITUDE = 6.5,
	SHAKE_SETTLE = 0.7,

	--[[
		A hit on a snail adds its own shake, at full strength for HIT_SHAKE_DAMAGE damage, plus KNOCKOUT_SHAKE when it
		knocks the snail out; each gun shot kicks the camera at GUN_SHAKE strength
	]]
	HIT_SHAKE_DAMAGE = 60,
	KNOCKOUT_SHAKE = 0.8,
	GUN_SHAKE = 0.15,

	--[[
		A blast at least this strong vibrates a phone or pad (the Combat_BlastBig and Combat_BlastSmall haptic presets);
		a weaker one only shakes
	]]
	HAPTIC_BIG = 0.6,
	HAPTIC_SMALL = 0.15,

	--[[
		A hit of HITSTOP_DAMAGE or more stops the blast's effects and the camera for HITSTOP_SECONDS on every screen; a
		knockout blow stops them for HITSTOP_KNOCKOUT and the camera punches in on the snail (MatchCamera's PunchIn)
	]]
	HITSTOP_DAMAGE = 30,
	HITSTOP_SECONDS = 0.07,
	HITSTOP_KNOCKOUT = 0.16,

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

	--%%%%%%%%%%%%%%%%%%%% Effects

	--[[
		The studio's blast effects (I.Vfx prefabs) by size: a blast plays the last one whose radius it reaches, scaled
		by its radius over BLAST_VFX_RADIUS (the radius they were made for)
	]]
	--- @type { { any } }
	BLAST_VFX = { { 0, "Explosion" }, { 6, "Explosion_Fire" }, { 9, "Explosion_Big" } },

	BLAST_VFX_RADIUS = 6.5,

	-- The flash at a gun's muzzle as it fires, by weapon (I.Vfx prefabs)
	--- @type { [string]: string }
	MUZZLE_VFX = { Uzi = "Flash_SMG", Minigun = "Flash_SMG", Shotgun = "Flash_Sniper" },

	--[[
		The blast out of a launcher as its shot leaves, by weapon (I.Vfx prefabs played where the shot starts, pointing
		along it), at LAUNCH_VFX_SCALE
	]]
	--- @type { [string]: { string } }
	LAUNCH_VFX = {
		Bazooka = { "Flash_Sniper", "Explosion_Gun" },
		HomingMissile = { "Flash_Sniper", "Explosion_Gun" },
	},
	LAUNCH_VFX_SCALE = 1.5,

	-- One Punch's blast plays along the swing at this scale (the prefab is made for a 20-stud part)
	PUNCH_VFX_SCALE = 0.5,

	--%%%%%%%%%%%%%%%%%%%% Sounds

	--[[
		Match sounds play where they happen, at full volume within SOUND_ROLLOFF_MIN studs of the camera (it sits 45 to
		200 studs from the plane) and fading out to SOUND_ROLLOFF_MAX; Snails' sounds use the same range
	]]
	SOUND_ROLLOFF_MIN = 150,
	SOUND_ROLLOFF_MAX = 600,

	-- A blast at least this big (its radius, in studs) plays Explosion_Big, a smaller one Explosion_Small
	BIG_BLAST_SOUND_RADIUS = 6,

	--[[
		A bouncing shot plays Shot_Bounce when a bounce changes its speed by at least BOUNCE_SOUND_SPEED studs a second
		(rolling and gravity never do), at most once every BOUNCE_SOUND_GAP seconds
	]]
	BOUNCE_SOUND_SPEED = 15,
	BOUNCE_SOUND_GAP = 0.12,

	--[[
		A lobbed shot of these kinds whistles (Shot_Whistle) once as it starts coming down faster than WHISTLE_FALL_SPEED
		(studs per second of its flight), and hushes as it lands
	]]
	--- @type { [string]: boolean }
	WHISTLE_KINDS = { Bouncer = true, Rocket = true, Crawler = true },

	WHISTLE_FALL_SPEED = 25,

	--%%%%%%%%%%%%%%%%%%%% Behaviors

	-- Bomblets fly out of a cluster bomb at a random speed between these, in studs per second
	--- @type { number }
	BOMBLET_SPEED = { 20, 40 },

	-- For this long a bomblet flies through everything, so it leaves its cluster bomb's crater, in seconds
	BOMBLET_GHOST = 0.1,

	-- A variety grenade's worms dig at SNAIL_SPEED, take a bite of terrain every SNAIL_BITE seconds, and stop after SNAIL_LIFETIME
	SNAIL_SPEED = 6,
	SNAIL_BITE = 0.3,
	SNAIL_LIFETIME = 6,

	-- A crawling spider bomb or a homing missile bursts once this close to a snail, in studs
	CONTACT_DISTANCE = 2.5,

	--[[
		A crawling spider bomb walks up a ledge up to CRAWL_STEP_UP studs high (taller is a wall it climbs), steps down
		one up to CRAWL_STEP_DOWN (deeper and it falls), and waits when its target is within CRAWL_STOP studs across
	]]
	CRAWL_STEP_UP = 1.25,
	CRAWL_STEP_DOWN = 3,
	CRAWL_STOP = 0.25,

	--[[
		An open black hole draws the snails in its PullRadius toward it at BLACK_HOLE_DRAG_SPEED studs per second (sliding
		along the ground, drifting through the air), and holds each one stuck within BLACK_HOLE_STICK studs of its middle
		until it bursts
	]]
	BLACK_HOLE_DRAG_SPEED = 10,
	BLACK_HOLE_STICK = 2.5,

	-- The box a melee swing checks in front of the snail, in studs on each side
	MELEE_BOX = 4,

	--%%%%%%%%%%%%%%%%%%%% Held Weapon

	-- How fast the active snail's weapon turns to another player's new aim (higher is snappier)
	HELD_TURN_SPEED = 14,

	--%%%%%%%%%%%%%%%%%%%% Aimbot

	-- The aim guide (the admin `aimbot` command) draws a path that lands on its target in the hit colour, the best miss in the other
	AIMBOT_HIT_COLOR = Color3.fromRGB(80, 255, 120),
	AIMBOT_MISS_COLOR = Color3.fromRGB(255, 170, 40),

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

	--[[
		Flying shots are drawn this many times their size, models and plain balls (placed ones like the Dynamite
		aside); hits still use PROJECTILE_SIZE
	]]
	PROJECTILE_DRAW_SCALE = 2,

	-- Shots drawn at a scale of their own instead, by weapon (the homing missile's model is thin: the testers, 2026-11-13)
	--- @type { [string]: number }
	PROJECTILE_DRAW_SCALES = { HomingMissile = 3.5 },

	--[[
		The trail (a Vfx effect, with its exhaust's emitters when it has one) a weapon's shot draws behind it while it
		flies, by item id; it fades out where the shot ends. TRAIL_SCALE widens every one, and a rocket's starts
		TRAIL_TAIL studs behind its middle, at its drawn tail
	]]
	--- @type { [string]: string }
	PROJECTILE_TRAILS = {
		Bazooka = "Trail_Smoke",
		HomingMissile = "Trail_Smoke",
		BlackHoleGrenade = "Trail_BlackHole",
		VarietyGrenade = "Trail_Variety",
		ClusterBomb = "Trail_Smoke",
	},
	TRAIL_SCALE = 1,
	TRAIL_TAIL = 2,

	-- A worm's model sways from side to side as it digs: how far, in radians, and how fast, in swings a second
	WORM_SWAY = 0.35,
	WORM_SWAY_SPEED = 2,

	-- How quickly a model the server moves (a crawling spider bomb, a worm) glides after its part; higher follows closer
	CRAWL_GLIDE = 18,
}

return _settings
