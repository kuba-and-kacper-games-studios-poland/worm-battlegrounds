--- @class SnailControl_ServerSettings
local _settings = {

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

	-- How far a snail may stray off the arena's plane (in Z) before the server snaps it back, in studs
	PLANE_SLACK = 0.5,
}

return _settings
