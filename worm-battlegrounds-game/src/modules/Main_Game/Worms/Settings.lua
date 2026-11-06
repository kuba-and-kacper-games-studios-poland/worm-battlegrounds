--- @class Worms_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Health

	-- Every worm starts with this much health, which healing never goes above
	MAX_HEALTH = 200,

	-- A fall costs 1 health per stud above SAFE_FALL_HEIGHT, MAX_FALL_DAMAGE at most
	SAFE_FALL_HEIGHT = 10,
	MAX_FALL_DAMAGE = 40,

	--%%%%%%%%%%%%%%%%%%%% Body

	-- The invisible ball a worm stands on, in studs across, and its grip: a worm holds still on slopes up to about 45°
	ROOT_SIZE = 2.6,
	ROOT_FRICTION = 1,

	-- The skin every worm wears until Cosmetics picks the equipped one: a model in Assets.Skins, facing its pivot's front
	DEFAULT_SKIN = "Classic",

	-- How far below its ball the ground may be for a worm to count as standing on it, in studs
	GROUND_GAP = 0.4,

	-- A worm slower than this, in studs per second, is at rest
	SETTLE_SPEED = 0.5,

	--%%%%%%%%%%%%%%%%%%%% Ghosts

	-- A knocked-out worm's ghost floats GHOST_RISE studs up over GHOST_RISE_TIME seconds, this see-through
	GHOST_RISE = 4,
	GHOST_RISE_TIME = 1.5,
	GHOST_TRANSPARENCY = 0.6,

	--%%%%%%%%%%%%%%%%%%%% Tags

	-- How far above a worm's center its tag's bottom edge sits, in studs
	TAG_OFFSET = 1.8,

	-- The name colour of a VIP player's worm
	VIP_NAME_COLOR = Color3.fromRGB(255, 206, 46),

	--[[
		The health bar's colour at full, half and no health, blended in between (the GUI kit's Success, Warning and
		Danger)
	]]
	HEALTH_FULL_COLOR = Color3.fromRGB(156, 240, 90),
	HEALTH_HALF_COLOR = Color3.fromRGB(255, 176, 32),
	HEALTH_EMPTY_COLOR = Color3.fromRGB(255, 110, 96),

	-- A damage number rises POP_RISE studs while it fades
	POP_RISE = 3,
	POP_TWEENINFO = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

	--%%%%%%%%%%%%%%%%%%%% Gear

	--[[
		Utilities a worm wears while they work, drawn by every client from their Arsenal models: the worm attribute
		that shows each one, and where its RootPart sits in the ball's space (−Z ahead of the worm, +Y up)
	]]
	--- @type { [string]: Worms_Gear }
	GEAR = {
		Parachute = { Attribute = "Parachute", Offset = Vector3.new(0, 4.3, 0) },
		Jetpack = { Attribute = "JetpackFuel", Offset = Vector3.new(0, 0.8, 1.3) },
	},
}

return _settings
