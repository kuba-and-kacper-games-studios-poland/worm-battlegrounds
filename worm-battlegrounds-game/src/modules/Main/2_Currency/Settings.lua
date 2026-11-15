--- @class Currency_Settings
local _settings = {

	--- @type { [string]: Currency_CurrencySettings }
	CURRENCIES = {

		--%%%%%%%%%%%%%%%%%%%% Coins

		["Coins"] = {
			--[[ General ]]

			DefaultValue = "0",
			IconId = "rbxassetid://123804836570291",

			--[[ Range ]]

			MinValue = "0",
			RespectMinValue = true,

			MaxValue = "0",
			RespectMaxValue = false,

			--[[ Updating ]]

			ServerUpdate = true,
			ServerUpdateIndividual = false,
			ClientUpdate = true,
			ClientUpdateIndividual = true,
		},

		--%%%%%%%%%%%%%%%%%%%% Diamonds

		["Diamonds"] = {
			--[[ General ]]

			DefaultValue = "0",
			IconId = "rbxassetid://98200575516825",

			--[[ Range ]]

			MinValue = "0",
			RespectMinValue = true,

			MaxValue = "0",
			RespectMaxValue = false,

			--[[ Updating ]]

			ServerUpdate = true,
			ServerUpdateIndividual = false,
			ClientUpdate = true,
			ClientUpdateIndividual = true,
		},
	},
}
return _settings
