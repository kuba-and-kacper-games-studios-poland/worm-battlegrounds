--- @class MatchCamera_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% View

	-- A narrow field of view from far away, looking along -Z, so the arena reads as flat
	FOV = 30,
	DISTANCE = 110,

	-- How quickly the camera catches up with what it follows: higher is snappier
	FOLLOW_SPEED = 6,

	--%%%%%%%%%%%%%%%%%%%% Panning

	-- Panning with the right stick (while LT is held), in studs per second at full lean, and how far it must lean
	STICK_PAN_SPEED = 60,
	STICK_DEADZONE = 0.2,
}

return _settings
