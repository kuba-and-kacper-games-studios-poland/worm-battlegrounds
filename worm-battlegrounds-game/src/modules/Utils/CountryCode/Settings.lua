--- @class CountryCode_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Cache

	-- Max entries kept in the in-memory country-code cache before FIFO eviction.
	CACHE_MAX_ENTRIES = 5000,

	-- Seconds before a user id with no saved country is read from the DataStore again.
	MISS_RETRY_SEC = 600,
}
return _settings
