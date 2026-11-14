--- @class Snails_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Health

	-- Every snail starts with this much health, which healing never goes above
	MAX_HEALTH = 200,

	-- A fall costs 1 health per stud above SAFE_FALL_HEIGHT, MAX_FALL_DAMAGE at most
	SAFE_FALL_HEIGHT = 10,
	MAX_FALL_DAMAGE = 40,

	--%%%%%%%%%%%%%%%%%%%% Body

	-- The invisible ball a snail stands on, in studs across, and its grip: a snail holds still on slopes up to about 45°
	ROOT_SIZE = 2.6,
	ROOT_FRICTION = 1,

	-- The skin every snail wears until Cosmetics picks the equipped one: a model in Assets.Skins, facing its pivot's front
	DEFAULT_SKIN = "Classic",

	-- How far below its ball the ground may be for a snail to count as standing on it, in studs
	GROUND_GAP = 0.4,

	-- A snail slower than this, in studs per second, is at rest
	SETTLE_SPEED = 0.5,

	--%%%%%%%%%%%%%%%%%%%% Animations

	-- A snail plays its walk while it moves along faster than this, in studs per second (and climbs or falls slower than STEP_SOUND_MAX_RISE)
	WALK_ANIMATION_SPEED = 1.5,

	--[[
		A snail hides in its shell the moment it's hit, or when thrown (faster than HIDE_SPEED, and not the active snail
		jumping or falling on its own), and comes out HIDE_SECONDS after the hit or after it last flew that fast, once
		slower than SHOW_SPEED or, when it's the active snail, the moment it walks
	]]
	HIDE_SPEED = 25,
	SHOW_SPEED = 2,
	HIDE_SECONDS = 1,

	--%%%%%%%%%%%%%%%%%%%% Ghosts

	--[[
		A knocked-out snail turns into its ghost on every screen: lit up in GHOST_COLOR, it floats GHOST_RISE studs up over
		GHOST_TIME seconds, bobbing GHOST_BOB studs side to side GHOST_BOB_RATE times a second and swaying GHOST_SWAY degrees,
		fading out from GHOST_FADE_FROM of the way up, and then it's gone from sight
	]]
	GHOST_RISE = 9,
	GHOST_TIME = 1.8,
	GHOST_BOB = 0.5,
	GHOST_BOB_RATE = 1.2,
	GHOST_SWAY = 10,
	GHOST_FADE_FROM = 0.3,
	GHOST_COLOR = Color3.fromRGB(205, 235, 255),

	--%%%%%%%%%%%%%%%%%%%% Tags

	-- How far above a snail's center its tag's bottom edge sits, in studs
	TAG_OFFSET = 2.4,

	-- The name colour of a VIP player's snail
	VIP_NAME_COLOR = Color3.fromRGB(255, 206, 46),

	--[[
		As a turn starts, the red turn arrow drops onto the active snail's tag from ARROW_DROP_FROM design px above
		(off the top of the screen), bouncing in over ARROW_DROP_SECONDS, then bobs ARROW_BOB_HEIGHT px up and down
		ARROW_BOB_SPEED radians a second
	]]
	ARROW_DROP_FROM = 700,
	ARROW_DROP_SECONDS = 0.7,
	ARROW_BOB_HEIGHT = 7,
	ARROW_BOB_SPEED = 6,

	--[[
		Worms Armageddon's way: once the active snail moves (TAG_HIDE_MOVE studs from where its turn started), aims
		(TAG_HIDE_AIM radians, or charges a shot) or shoots, its tag and arrow hide until the turn ends. The aim follows
		the pointer, so it counts only while this screen's camera is still (moving less than TAG_HIDE_CAMERA_STILL studs a
		frame): the camera flying to the snail as the turn starts drifts it
	]]
	TAG_HIDE_MOVE = 0.75,
	TAG_HIDE_AIM = math.rad(4),
	TAG_HIDE_CAMERA_STILL = 0.02,

	-- A damage number rises POP_RISE studs while it fades
	POP_RISE = 3,
	POP_TWEENINFO = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

	--[[
		Bigger hits pop bigger and warmer: each row is the damage it starts at, the number's size (times its design size)
		and its colour; the last row an amount reaches is used. Numbers above the first row punch in (POP_PUNCH_TWEENINFO)
		from POP_PUNCH times their size
	]]
	--- @type { { any } }
	POP_TIERS = {
		{ 0, 1, Color3.fromRGB(255, 255, 255) },
		{ 25, 1.3, Color3.fromRGB(255, 220, 60) },
		{ 45, 1.65, Color3.fromRGB(255, 120, 40) },
	},

	POP_PUNCH = 1.5,
	POP_PUNCH_TWEENINFO = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

	--%%%%%%%%%%%%%%%%%%%% Gear

	--[[
		Utilities a snail wears while they work, drawn by every client from their Arsenal models: the snail attribute
		that shows each one, and where its RootPart sits in the ball's space (−Z ahead of the snail, +Y up)
	]]
	--- @type { [string]: Snails_Gear }
	GEAR = {
		Parachute = { Attribute = "Parachute", Offset = Vector3.new(0, 4.9, 0) },
		Jetpack = { Attribute = "JetpackFuel", Offset = Vector3.new(0, 0.4, 2.4) },
	},

	--%%%%%%%%%%%%%%%%%%%% Sounds

	--[[
		Every client hears a snail from how its ball moves: the active snail squishes a step (Snail_Step) every
		STEP_SOUND_DISTANCE studs it walks while its upward speed stays under STEP_SOUND_MAX_RISE
	]]
	STEP_SOUND_DISTANCE = 1.6,
	STEP_SOUND_MAX_RISE = 4,

	-- The active snail jumps (Snail_Jump) when it shoots up past JUMP_SOUND_SPEED from below JUMP_SOUND_FROM, in studs a second
	JUMP_SOUND_SPEED = 25,
	JUMP_SOUND_FROM = 5,

	-- Any snail lands (Snail_Land, and the Fall effect's dust) when a fall faster than LAND_SOUND_SPEED stops (slower than LAND_SOUND_STOP)
	LAND_SOUND_SPEED = 30,
	LAND_SOUND_STOP = 5,

	--[[
		The active snail's jetpack hums (Snail_Jetpack, looped) while it wears one and climbs between JETPACK_SOUND_RISE
		studs a second and JUMP_SOUND_SPEED for JETPACK_SOUND_HOLD seconds (a jump passes through faster), and stops
		JETPACK_SOUND_HOLD after the climb ends
	]]
	JETPACK_SOUND_RISE = 8,
	JETPACK_SOUND_HOLD = 0.12,

	--%%%%%%%%%%%%%%%%%%%% Effects

	-- A snail shows its trail (the Trail_Snail effect) while it flies faster than this, in studs a second: knocked back, not walking
	TRAIL_SPEED = 45,

	-- Where the jetpack's jet (the Trail_Jet effect) comes out, from the snail's ball: under the worn jetpack (GEAR)
	JET_TRAIL_OFFSET = Vector3.new(0, -0.6, 2.4),

	--[[
		The jet also streams JET_EXHAUST_VFX's Exhaust emitters (the rocket's thruster and smoke) down from there, so it
		shows while the jetpack hovers still; it's on while the snail wearing it is in the air (nothing within
		JET_GROUND_GAP studs under its ball) and not dropping faster than JET_FALL_SPEED studs a second
	]]
	JET_EXHAUST_VFX = "Trail_Smoke",
	JET_GROUND_GAP = 0.6,
	JET_FALL_SPEED = 6,

	-- The healing crosses are drawn this many times their made size, so they read from the match camera's distance
	HEAL_VFX_SCALE = 2,

	--%%%%%%%%%%%%%%%%%%%% Flight

	--[[
		The share of the Workspace's gravity snails feel, so they're light, as in Worms: the ball's Lift holds up the
		rest while it walks, and a thrown snail flies the game's own simulation (Combat's Ballistics) with it
	]]
	GRAVITY_SCALE = 0.55,

	--[[
		A thrown snail bounces off what it hits harder than Combat's REST_SPEED with this share of its speed into it,
		and lands once it rests on the ground: it's handed back to Roblox physics there, keeping FLIGHT_LAND_KEEP of
		its speed to slide on
	]]
	FLIGHT_BOUNCE = 0.2,
	FLIGHT_LAND_KEEP = 0.4,

	-- The most a throw lasts before the snail is handed back to Roblox physics wherever it is, in seconds
	FLIGHT_MAX_SECONDS = 8,

	--%%%%%%%%%%%%%%%%%%%% Burning

	--[[
		Touching lava that doesn't knock a snail out (a pool on the map, or the lava sea seeping into a small hole) sets
		it Burning: BURN_DELAY seconds later it loses BURN_DAMAGE health, so its turn ends then as any hurt does, and again
		every BURN_INTERVAL seconds, BURN_TICKS times in all. It burns once a dip: staying in the lava, or touching it again
		while it burns, adds nothing, so a snail left in a pool can walk out on its turn
	]]
	BURN_DELAY = 2,
	BURN_DAMAGE = 8,
	BURN_INTERVAL = 1,
	BURN_TICKS = 3,

	--%%%%%%%%%%%%%%%%%%%% Auras

	-- The Vfx prefab whose particles stream around a snail while an attribute is set on it: the potions', and burning
	--- @type { [string]: string }
	AURAS = { SpeedMultiplier = "Aura_Speed", LowGravity = "Aura_LowGravity", Burning = "Aura_Burning" },

	--%%%%%%%%%%%%%%%%%%%% Potions

	--[[
		The vignette's colour on the player's own turn while their snail is under the Speed potion, the Low gravity
		potion, or both
	]]
	POTION_VIGNETTE_SPEED = Color3.fromRGB(70, 200, 255),
	POTION_VIGNETTE_LOW_GRAVITY = Color3.fromRGB(165, 95, 255),
	POTION_VIGNETTE_BOTH = Color3.fromRGB(255, 95, 205),

	-- How the vignette fades in, changes colour and fades out
	POTION_VIGNETTE_TWEENINFO = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
}

return _settings
