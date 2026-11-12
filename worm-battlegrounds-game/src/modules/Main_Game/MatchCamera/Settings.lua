--- @class MatchCamera_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% View

	-- A narrow field of view from far away, looking along -Z, so the arena reads as flat
	FOV = 30,
	DISTANCE = 110,

	-- How quickly the camera catches up with what it follows (SHOT_FOLLOW_SPEED for a shot in flight): higher is snappier
	FOLLOW_SPEED = 3.5,
	SHOT_FOLLOW_SPEED = 5,

	-- The fastest the view moves, in studs per second at DISTANCE (faster zoomed out, slower zoomed in); a hand move and a shot in flight are never held back
	MAX_SPEED = 140,

	--[[
		A shot in flight, or a snail a blow sent flying, moves the view only once it leaves the middle DEAD_ZONE of the
		view's half size, so bounces and wobbles don't shake it
	]]
	DEAD_ZONE = 0.25,

	--[[
		Moving on to the next snail, or to where a gun's bullets landed, the camera glides at TRAVEL_SPEED (slower than
		FOLLOW_SPEED, so the move reads) for at most TRAVEL_MAX seconds, or until it's within TRAVEL_DONE studs
	]]
	TRAVEL_SPEED = 1.6,
	TRAVEL_MAX = 2.5,
	TRAVEL_DONE = 1.5,

	-- How far over the map's top (its Bounds) the view may rise, in studs, so a snail high up sits mid-screen
	CEILING_EXTRA = 60,

	--[[
		On the player's own turn the pan eases back to their snail at RECENTER_SPEED (higher is snappier) while the snail
		moves faster than RECENTER_MOVE_SPEED studs a second
	]]
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
	LEAD_SMOOTH = 3,

	-- A knockout blow pushes the camera in on the snail, to PUNCH_ZOOM of the player's zoom, for PUNCH_SECONDS
	PUNCH_ZOOM = 0.65,
	PUNCH_SECONDS = 0.9,

	--[[
		A shot rides up to SHOT_TOP of the view's half height over its middle (near the screen's top) before the view
		rises with it, from the height the view had when the shot took off, so the map stays in view under a high one;
		the view zooms out to fit both, up to SHOT_ZOOM_OUT times the player's zoom
	]]
	SHOT_TOP = 0.7,
	SHOT_ZOOM_OUT = 1.5,

	--[[
		Gliding to the next snail, the view zooms out by up to TRAVEL_ZOOM_OUT of the player's zoom (from
		TRAVEL_ZOOM_DISTANCE studs away), and back in as it arrives
	]]
	TRAVEL_ZOOM_OUT = 0.2,
	TRAVEL_ZOOM_DISTANCE = 80,

	--[[
		A blast the camera follows pushes the view in by BLAST_KICK of the zoom (BIG_BLAST_KICK for a big one), easing
		back over BLAST_KICK_SECONDS
	]]
	BLAST_KICK = 0.06,
	BIG_BLAST_KICK = 0.12,
	BLAST_KICK_SECONDS = 0.6,

	--%%%%%%%%%%%%%%%%%%%% Zoom

	--[[
		The mouse wheel and a pinch move the camera between ZOOM_MIN and ZOOM_MAX studs from the plane (DISTANCE at
		start); each wheel notch changes the distance by ZOOM_STEP of itself, eased at ZOOM_SPEED (higher is snappier)
	]]
	ZOOM_MIN = 45,
	ZOOM_MAX = 200,
	ZOOM_STEP = 0.15,
	ZOOM_SPEED = 6,

	-- Holding D-pad up or down on a pad zooms in or out by this share of the distance each second
	PAD_ZOOM_RATE = 0.9,

	--%%%%%%%%%%%%%%%%%%%% Panning

	--[[
		Outside the player's own turn before the shot, moving the view by hand (a drag, a finger, the stick, the screen's
		edge) leaves what the camera follows: it stays where the player puts it, catching up at MANUAL_SPEED, while they
		hold the pan and until MANUAL_HOLD seconds after their last move, then glides back; a new turn always takes it to
		the snail whose turn it is, ignoring the hand until it gets there
	]]
	MANUAL_HOLD = 5,
	MANUAL_SPEED = 15,

	-- Panning with the right stick (while LT is held), in studs per second at full lean, and how far it must lean
	STICK_PAN_SPEED = 60,
	STICK_DEADZONE = 0.2,

	-- The mouse this close to the screen's left or right edge (a share of its height) pans at EDGE_PAN_SPEED studs per second
	EDGE_PAN_MARGIN = 0.015,
	EDGE_PAN_SPEED = 60,
}

return _settings
