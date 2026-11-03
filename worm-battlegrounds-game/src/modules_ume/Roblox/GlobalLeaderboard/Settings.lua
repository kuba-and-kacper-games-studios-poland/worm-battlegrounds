--- @class GlobalLeaderboard_Settings
local _settings = {

	--[[
		Prefix for the GlobalLeaderboard:

		{LEADERBOARD_PREFIX}_{storeName}_{I.Config.Map.LeaderboardStoreName}

		Examples:

		GL_Playtime_Testing
		GL_Playtime_Production
	]]
	LEADERBOARDS_PREFIX = "GL",

	-- How often the GlobalLeaderboard are updated.
	UPDATE_DELAY = 30,

	-- Minimum value for an entry to show.
	MIN_PAGE_VALUE = 1,

	-- Maximum value for an entry to be shown.
	MAX_PAGE_VALUE = 10e15,
}
return _settings
