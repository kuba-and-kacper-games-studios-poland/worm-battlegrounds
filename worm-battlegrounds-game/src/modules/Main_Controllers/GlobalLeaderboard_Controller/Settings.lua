--- @class GlobalLeaderboard_Controller_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Statistics

	--[[
		Statistics written to the global leaderboard store of the same name. Boards and statues on
		one of these stores read its page with this `PageSize` (at most 100) and `IsAscending`.
	]]
	--- @type { [string]: GlobalLeaderboard_Controller_TrackedStatistic }
	TRACKED_STATISTICS = {
		["Playtime"] = {

			--[[ Updating ]]

			UpdateGroup = "Statistic",

			--[[ Page ]]

			PageSize = 100,
			IsAscending = false,
		},
	},

	--%%%%%%%%%%%%%%%%%%%% Cache

	-- Max cached player names / country entries before oldest are evicted.
	CACHE_MAX_ENTRIES = 5000,
}
return _settings
