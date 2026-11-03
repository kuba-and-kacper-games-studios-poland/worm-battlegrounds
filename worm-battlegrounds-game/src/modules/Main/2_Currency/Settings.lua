--- @class Currency_Settings
local _settings = {

	--- @type { [string]: Currency_CurrencySettings }
	CURRENCIES = {

		--%%%%%%%%%%%%%%%%%%%% Default

		["Cash"] = {
			--[[ General ]]

			DefaultValue = "0",
			IconId = "rbxassetid://92339054232049",

			--[[ Range ]]

			MinValue = "0",
			RespectMinValue = true,

			MaxValue = "0",
			RespectMaxValue = false,

			--[[ Updating ]]

			ServerUpdate = false,
			ServerUpdateIndividual = false,
			ClientUpdate = true,
			ClientUpdateIndividual = true,
		},
	},
}
return _settings
