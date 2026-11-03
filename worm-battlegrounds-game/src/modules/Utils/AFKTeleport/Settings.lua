--- @class AFKTeleport_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Timer

	-- Seconds of no input before teleport request trigger.
	TELEPORT_REQUEST_TIME = 16 * 60,

	-- Interval between timer updates in seconds; also the step of the warning countdown.
	TIMER_INTERVAL = 1,

	-- Seconds after which teleport request is retried in case of failing.
	TELEPORT_RETRY_TIME = 30,

	--%%%%%%%%%%%%%%%%%%%% Warning

	-- Seconds before the teleport request that the warning gui counts down.
	WARNING_TIME = 30,
}
return _settings
