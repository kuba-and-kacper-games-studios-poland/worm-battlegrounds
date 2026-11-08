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

	--%%%%%%%%%%%%%%%%%%%% Shell

	-- A snail's shell breaks once its health drops below this, and shows again when healing brings it back up
	SHELL_BREAK_HEALTH = 50,

	-- The skin part that breaks
	SHELL_PART = "Shell",

	-- The break: this many chips in the shell's colours, sized and thrown within these ranges, fade after this long
	SHELL_CHIPS = 12,

	--- @type { number }
	SHELL_CHIP_SIZE = { 0.3, 0.6 },

	--- @type { number }
	SHELL_CHIP_SPEED = { 14, 26 },

	SHELL_CHIP_LIFETIME = 1.5,

	--- @type { Color3 }
	SHELL_CHIP_COLORS = { Color3.fromRGB(232, 210, 160), Color3.fromRGB(214, 180, 120), Color3.fromRGB(176, 108, 52) },

	--%%%%%%%%%%%%%%%%%%%% Ghosts

	-- A knocked-out snail's ghost floats GHOST_RISE studs up over GHOST_RISE_TIME seconds, this see-through
	GHOST_RISE = 4,
	GHOST_RISE_TIME = 1.5,
	GHOST_TRANSPARENCY = 0.6,

	--%%%%%%%%%%%%%%%%%%%% Tags

	-- How far above a snail's center its tag's bottom edge sits, in studs
	TAG_OFFSET = 2.4,

	-- The name colour of a VIP player's snail
	VIP_NAME_COLOR = Color3.fromRGB(255, 206, 46),

	-- A damage number rises POP_RISE studs while it fades
	POP_RISE = 3,
	POP_TWEENINFO = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

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

	-- Any snail lands (Snail_Land) when a fall faster than LAND_SOUND_SPEED stops (slower than LAND_SOUND_STOP)
	LAND_SOUND_SPEED = 30,
	LAND_SOUND_STOP = 5,

	--[[
		The active snail's jetpack hums (Snail_Jetpack, looped) while it wears one and climbs between JETPACK_SOUND_RISE
		studs a second and JUMP_SOUND_SPEED for JETPACK_SOUND_HOLD seconds (a jump passes through faster), and stops
		JETPACK_SOUND_HOLD after the climb ends
	]]
	JETPACK_SOUND_RISE = 8,
	JETPACK_SOUND_HOLD = 0.12,
}

return _settings
