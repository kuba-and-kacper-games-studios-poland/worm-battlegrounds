--- @class MatchCamera_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% View

	-- A narrow field of view from far away, looking along -Z, so the arena reads as flat
	FOV = 30,
	DISTANCE = 110,

	-- How quickly the camera catches up with what it follows: higher is snappier
	FOLLOW_SPEED = 6,

	--[[
		Moving on to the next snail, or to where a gun's bullets landed, the camera glides at TRAVEL_SPEED (slower than
		FOLLOW_SPEED, so the move reads) for at most TRAVEL_MAX seconds, or until it's within TRAVEL_DONE studs
	]]
	TRAVEL_SPEED = 2.5,
	TRAVEL_MAX = 1.5,
	TRAVEL_DONE = 1.5,

	-- How far over the map's top (its Bounds) the view may rise, in studs, so a snail high up sits mid-screen
	CEILING_EXTRA = 60,

	--[[
		On the player's own turn the pan keeps their snail inside LEASH of the view's half size from its middle, and eases
		back to it at RECENTER_SPEED (higher is snappier) while the snail moves faster than RECENTER_MOVE_SPEED studs a second
	]]
	LEASH = 0.7,
	RECENTER_SPEED = 2.5,
	RECENTER_MOVE_SPEED = 3,

	--%%%%%%%%%%%%%%%%%%%% Blasts

	--[[
		Seconds the camera stays on a blast it followed the shot into before it moves on: BIG_BLAST_HOLD for blasts of
		BIG_BLAST_RADIUS studs or more, BLAST_HOLD for smaller ones
	]]
	BLAST_HOLD = 1,
	BIG_BLAST_HOLD = 1.6,
	BIG_BLAST_RADIUS = 6,

	--[[
		While it holds after a shot, a snail moving faster than CHASE_SPEED studs a second (a blow sent it flying, or it
		fell) is followed, and the hold lasts CHASE_HOLD seconds after it slows
	]]
	CHASE_SPEED = 25,
	CHASE_HOLD = 0.6,

	--%%%%%%%%%%%%%%%%%%%% Feel

	-- A flying shot is led LEAD_SECONDS along its flight (at most LEAD_MAX studs), its speed smoothed at LEAD_SMOOTH
	LEAD_SECONDS = 0.35,
	LEAD_MAX = 18,
	LEAD_SMOOTH = 8,

	-- A knockout blow pushes the camera in on the snail, to PUNCH_ZOOM of the player's zoom, for PUNCH_SECONDS
	PUNCH_ZOOM = 0.65,
	PUNCH_SECONDS = 0.9,

	--%%%%%%%%%%%%%%%%%%%% Zoom

	--[[
		The mouse wheel and a pinch move the camera between ZOOM_MIN and ZOOM_MAX studs from the plane (DISTANCE at
		start); each wheel notch changes the distance by ZOOM_STEP of itself, eased at ZOOM_SPEED (higher is snappier)
	]]
	ZOOM_MIN = 45,
	ZOOM_MAX = 200,
	ZOOM_STEP = 0.15,
	ZOOM_SPEED = 10,

	-- Holding D-pad up or down on a pad zooms in or out by this share of the distance each second
	PAD_ZOOM_RATE = 0.9,

	--%%%%%%%%%%%%%%%%%%%% Panning

	-- Panning with the right stick (while LT is held), in studs per second at full lean, and how far it must lean
	STICK_PAN_SPEED = 60,
	STICK_DEADZONE = 0.2,

	-- The mouse this close to the screen's left or right edge (a share of its height) pans at EDGE_PAN_SPEED studs per second
	EDGE_PAN_MARGIN = 0.015,
	EDGE_PAN_SPEED = 60,
}

return _settings
