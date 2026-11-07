--- @type Crates_CrateData
local _data = {

	--[[ General ]]

	Name = "Utility crate",
	Picture = "rbxassetid://121731184312632",
	LayoutOrder = 3,
	Hidden = false,

	--[[ Prices ]]

	-- Coins or diamonds for one crate, and for a 10-pack
	Prices = {
		Coins = { One = "100", Ten = "900" },
		Diamonds = { One = "200", Ten = "1800" },
	},

	--[[ Odds ]]

	-- Each item's chance in percent, by the currency paid; each table adds up to 100
	OddsByCurrency = {
		Coins = {
			Parachute = 27.5,
			Bandage = 27.5,
			Jetpack = 15,
			SpeedPotion = 15,
			Medkit = 10,
			LowGravityPotion = 5,
		},
		Diamonds = {
			Parachute = 15,
			Bandage = 15,
			Jetpack = 20,
			SpeedPotion = 20,
			Medkit = 20,
			LowGravityPotion = 10,
		},
	},

	-- Items always given, instead of a roll
	Fixed = {},
}

return _data
