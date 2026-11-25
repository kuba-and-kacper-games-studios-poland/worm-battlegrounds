--- @class Currency_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Currencies

	--- @type { [string]: Currency_CurrencySettings }
	CURRENCIES = {

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

	--%%%%%%%%%%%%%%%%%%%% Conversions

	--[[
		Retired currencies a player's saved balance turns into, once, as their data loads: Per of the old for one of
		the new, rounded up, and the old entry is taken off the save. Coins became diamonds on 2026-11-25 (the owner: one
		currency), at the crates' rate (100 coins or 50 diamonds)
	]]
	--- @type { Currency_Conversion }
	CONVERSIONS = {
		{ From = "Coins", To = "Diamonds", Per = "2" },
	},
}
return _settings
