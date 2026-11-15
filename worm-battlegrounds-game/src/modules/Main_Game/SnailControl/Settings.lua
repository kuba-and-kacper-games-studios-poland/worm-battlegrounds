--- @class SnailControl_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Movement

	-- Walking speed along the plane, in studs per second
	WALK_SPEED = 8,

	-- A jump's upward speed, in studs per second: about 5 studs high at a snail's light gravity (Snails' GRAVITY_SCALE)
	JUMP_SPEED = 33,

	-- Ledges up to STEP_HEIGHT studs are climbed by walking into them, with an upward push of STEP_SPEED
	STEP_HEIGHT = 2,
	STEP_SPEED = 16,

	-- How far a snail may walk in one turn, in studs
	STAMINA_STUDS = 40,

	-- How far the left stick must lean before the snail walks, from 0 to 1
	STICK_DEADZONE = 0.3,

	--%%%%%%%%%%%%%%%%%%%% Effects

	-- A parachute caps the fall at this speed, in studs per second
	PARACHUTE_FALL_SPEED = 6,

	--[[
		Seconds of flight a jetpack holds for the whole match (the owner, 2026-11-15: one jetpack a game, its fuel kept from
		turn to turn until it's spent), and how fast it climbs while its player holds jump, in studs per second. Flying
		spends fuel, never stamina; the player's screen tells the server what's left every FUEL_REPORT_INTERVAL seconds
		while it flies
	]]
	JETPACK_FUEL = 6,
	JETPACK_SPEED = 16,
	FUEL_REPORT_INTERVAL = 0.2,

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
