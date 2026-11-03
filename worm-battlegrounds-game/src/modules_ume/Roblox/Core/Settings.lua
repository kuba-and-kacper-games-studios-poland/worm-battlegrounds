--- @class Core_Settings
local _settings = {

	--[[ Retries ]]

	-- Seconds a failing call retries every frame before it backs off.
	FAST_RETRY_SECONDS = 5,

	-- Seconds between retries after the first FAST_RETRY_SECONDS.
	SLOW_RETRY_INTERVAL = 0.5,

	-- Seconds after which a call that never succeeded gives up.
	MAX_RETRY_SECONDS = 60,

	--[[ Debug ]]

	-- Print the first failure of each call to the console (only in Studio).
	FAILED_CALL_LOG = true,
}
return _settings
