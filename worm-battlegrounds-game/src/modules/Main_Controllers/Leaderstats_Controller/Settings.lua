--- @class Leaderstats_Controller_Settings
local _settings = {

	--[[
		Values shown in the player list, in this order of `Priority` (higher first).
		`Source` is `"Statistic"` or `"Currency"`, `Key` the statistic or currency name,
		`Format` is `"Time"` or `"Number"`.
	]]
	--- @type { Leaderstats_Controller_Stat }
	STATS = {
		{

			--[[ General ]]

			Name = "Wins",
			Priority = 1,

			--[[ Value ]]

			Source = "Statistic",
			Key = "Wins",
			Format = "Number",
		},
	},
}
return _settings
