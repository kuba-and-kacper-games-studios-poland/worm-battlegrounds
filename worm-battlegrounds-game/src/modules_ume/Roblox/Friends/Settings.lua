--- @class Friends_Settings
local _settings = {

	--[[ Periodic Check ]]

	-- Seconds between checks of every pair of players, up to COUNT_CHECK_PLAYERS players.
	COUNT_CHECK_DELAY = 30,

	-- Player count the delay is tuned for (2 or more); above it, the delay grows with the number of pairs.
	COUNT_CHECK_PLAYERS = 10,
}
return _settings
