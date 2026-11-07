--- @class SnailControl_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Movement

	-- Walking speed along the plane, in studs per second
	WALK_SPEED = 8,

	-- A jump's upward speed, in studs per second: about 5 studs high at Roblox's default gravity
	JUMP_SPEED = 44,

	-- Ledges up to STEP_HEIGHT studs are climbed by walking into them, with an upward push of STEP_SPEED
	STEP_HEIGHT = 2,
	STEP_SPEED = 16,

	-- How far a snail may walk in one turn, in studs
	STAMINA_STUDS = 20,

	-- How far the left stick must lean before the snail walks, from 0 to 1
	STICK_DEADZONE = 0.3,

	--%%%%%%%%%%%%%%%%%%%% Checks

	--[[
		While a player moves their snail, the server compares it with where it last was every CHECK_INTERVAL seconds: it
		may not cover more than SPEED_TOLERANCE times walking speed sideways (or jumping speed upwards), plus
		MOVE_SLACK studs for network lag, or it snaps back
	]]
	CHECK_INTERVAL = 0.25,
	SPEED_TOLERANCE = 1.5,
	MOVE_SLACK = 2,

	--[[
		How far a snail may still move sideways after its stamina runs out (its client learning of it, momentum through
		the air, slides) before the server counts it as walking on and snaps it back, in studs
	]]
	STAMINA_GRACE = 8,

	--[[
		How far a snail may climb past what its jump (from the ground it last stood on, plus MOVE_SLACK) and its jetpack
		fuel (JETPACK_SPEED studs a second) reach before the server snaps it back, in studs
	]]
	LIFT_GRACE = 3,

	--%%%%%%%%%%%%%%%%%%%% Effects

	-- A parachute caps the fall at this speed, in studs per second
	PARACHUTE_FALL_SPEED = 6,

	-- Seconds of flight a jetpack holds, and how fast it climbs while its player holds jump, in studs per second
	JETPACK_FUEL = 3,
	JETPACK_SPEED = 16,

	-- The Speed potion's walking speed and stamina multiplier
	SPEED_MULTIPLIER = 1.5,

	-- The share of gravity left under the Low gravity potion
	LOW_GRAVITY_SCALE = 0.4,

	--[[
		What a shiny copy multiplies each effect's number by: 20% more jetpack fuel, 10% faster, 10% stronger low
		gravity, a 20% slower parachute
	]]
	--- @type { [string]: number }
	SHINY_BOOST = { Jetpack = 1.2, Speed = 1.1, LowGravity = 0.9, Parachute = 0.8 },
}

return _settings
