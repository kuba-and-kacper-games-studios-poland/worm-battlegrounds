--- @class MatchCamera_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% View

	-- A narrow field of view from far away, looking along -Z, so the arena reads as flat
	FOV = 30,
	DISTANCE = 110,

	-- How quickly the camera catches up with what it follows: higher is snappier
	FOLLOW_SPEED = 6,

	--%%%%%%%%%%%%%%%%%%%% Blasts

	--[[
		Seconds the camera stays on a blast it followed the shot into before it moves on: BIG_BLAST_HOLD for blasts of
		BIG_BLAST_RADIUS studs or more, BLAST_HOLD for smaller ones
	]]
	BLAST_HOLD = 1.5,
	BIG_BLAST_HOLD = 2.5,
	BIG_BLAST_RADIUS = 6,

	--%%%%%%%%%%%%%%%%%%%% Zoom

	--[[
		The mouse wheel and a pinch move the camera between ZOOM_MIN and ZOOM_MAX studs from the plane (DISTANCE at
		start); each wheel notch changes the distance by ZOOM_STEP of itself, eased at ZOOM_SPEED (higher is snappier)
	]]
	ZOOM_MIN = 45,
	ZOOM_MAX = 200,
	ZOOM_STEP = 0.15,
	ZOOM_SPEED = 10,

	--%%%%%%%%%%%%%%%%%%%% Panning

	-- Panning with the right stick (while LT is held), in studs per second at full lean, and how far it must lean
	STICK_PAN_SPEED = 60,
	STICK_DEADZONE = 0.2,

	-- The mouse this close to the screen's left or right edge (a share of its height) pans at EDGE_PAN_SPEED studs per second
	EDGE_PAN_MARGIN = 0.015,
	EDGE_PAN_SPEED = 60,
}

return _settings
