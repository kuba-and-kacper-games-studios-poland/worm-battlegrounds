--- @class Combat_ServerSettings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Aimbot

	-- How often the server finds again which snails the aimbot (the admin `aimbot` command) can hit while its snail or a target moves, in seconds
	AIMBOT_REFRESH = 0.2,

	-- The shares of power the aimbot tries for arc weapons, a low and a high arc each: finer than the bots' POWER_STEPS
	--- @type { number }
	AIMBOT_POWERS = { 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1 },

	-- How long an arc is followed looking for what it first touches, and its step, in seconds
	AIMBOT_ARC_SECONDS = 5,
	AIMBOT_ARC_STEP = 1 / 30,

	-- How many of the arcs that first touch nearest a target fly the bots' full prediction (bounces, fuses, blasts)
	AIMBOT_SIMULATED = 4,
}

return _settings
