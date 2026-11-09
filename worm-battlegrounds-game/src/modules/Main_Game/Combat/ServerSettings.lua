--- @class Combat_ServerSettings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Aimbot

	-- How often the server solves the aim guide (the admin `aimbot` command) again while its snail or a target moves, in seconds
	AIMBOT_REFRESH = 0.2,

	-- The shares of power the guide tries for arc weapons, a low and a high arc each: finer than the bots' POWER_STEPS
	--- @type { number }
	AIMBOT_POWERS = { 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1 },

	-- How long a guided arc is followed looking for what it hits, and its step, in seconds
	AIMBOT_ARC_SECONDS = 5,
	AIMBOT_ARC_STEP = 1 / 30,

	-- An arc that lands this close to its target, in studs, counts as a hit
	AIMBOT_HIT_MARGIN = 2.5,
}

return _settings
