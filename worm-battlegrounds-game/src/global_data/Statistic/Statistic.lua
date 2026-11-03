--- @class Statistic_Statistics
--- @type { [string]: Statistic_Statistic }
local data = {
	--[[
		["Example"] = {
			DefaultValue = "0",

			MinValue = "0",
			RespectMinValue = true,
			MaxValue = "0",
			RespectMaxValue = false,

			ServerUpdate = true,
			ServerUpdateIndividual = true,
			ClientUpdate = true,
			
		},
	]]

	--[[ General ]]

	["Playtime"] = {
		DefaultValue = "0",

		MinValue = "0",
		RespectMinValue = true,
		MaxValue = "0",
		RespectMaxValue = false,

		ServerUpdate = false,
		ServerUpdateIndividual = false,
		ClientUpdate = true,
	},
}
return data
