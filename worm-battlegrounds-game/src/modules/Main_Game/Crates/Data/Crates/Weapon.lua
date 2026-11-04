--- @type Crates_CrateData
local _data = {

	--[[ General ]]

	Name = "Weapon crate",
	Picture = "rbxasset://textures/wb_guipreview/crate_17762c23.png",
	LayoutOrder = 1,
	Hidden = false,

	--[[ Prices ]]

	-- Coins or diamonds for one crate, and for a 10-pack
	Prices = {
		Coins = { One = "100", Ten = "900" },
	},

	--[[ Odds ]]

	-- Each item's chance in percent, by the currency paid; each table adds up to 100
	OddsByCurrency = {
		Coins = {
			Uzi = 14.75,
			BaseballBat = 14.75,
			Dynamite = 14.75,
			SpartanSpear = 14.75,
			ClusterBomb = 10,
			SpiderBomb = 10,
			Minigun = 10,
			HomingMissile = 5,
			OnePunch = 5,
			VarietyGrenade = 0.5,
			BlackHoleGrenade = 0.5,
		},
	},

	-- Items always given, instead of a roll
	Fixed = {},
}

return _data
