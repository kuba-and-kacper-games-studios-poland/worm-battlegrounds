--- @class Currency_Settings
local _settings = {

	--- @type { [string]: Currency_CurrencySettings }
	CURRENCIES = {

		--%%%%%%%%%%%%%%%%%%%% Coins

		["Coins"] = {
			--[[ General ]]

			DefaultValue = "0",
			IconId = "rbxasset://textures/wb_guipreview/coin_b3e36086.png",

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
			IconId = "rbxasset://textures/wb_guipreview/diamond_48620100.png",

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
