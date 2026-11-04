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
	--[[ Matches ]]

	["XP"] = {
		DefaultValue = "0",

		MinValue = "0",
		RespectMinValue = true,
		MaxValue = "0",
		RespectMaxValue = false,

		ServerUpdate = false,
		ServerUpdateIndividual = false,
		ClientUpdate = true,
	},

	["MatchesPlayed"] = {
		DefaultValue = "0",

		MinValue = "0",
		RespectMinValue = true,
		MaxValue = "0",
		RespectMaxValue = false,

		ServerUpdate = false,
		ServerUpdateIndividual = false,
		ClientUpdate = true,
	},

	["Wins"] = {
		DefaultValue = "0",

		MinValue = "0",
		RespectMinValue = true,
		MaxValue = "0",
		RespectMaxValue = false,

		ServerUpdate = false,
		ServerUpdateIndividual = false,
		ClientUpdate = true,
	},

	["Knockouts"] = {
		DefaultValue = "0",

		MinValue = "0",
		RespectMinValue = true,
		MaxValue = "0",
		RespectMaxValue = false,

		ServerUpdate = false,
		ServerUpdateIndividual = false,
		ClientUpdate = true,
	},

	["DamageDealt"] = {
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
