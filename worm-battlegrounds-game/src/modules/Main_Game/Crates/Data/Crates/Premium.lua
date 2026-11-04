--- @type Crates_CrateData
local _data = {

	--[[ General ]]

	Name = "Premium crate",
	Picture = "rbxasset://textures/wb_guipreview/crate_17762c23.png",
	LayoutOrder = 2,
	Hidden = false,

	--[[ Prices ]]

	-- Coins or diamonds for one crate, and for a 10-pack
	Prices = {
		Diamonds = { One = "250", Ten = "2250" },
	},

	--[[ Odds ]]

	-- Each item's chance in percent, by the currency paid; each table adds up to 100
	OddsByCurrency = {
		Diamonds = {
			ClusterBomb = 26,
			SpiderBomb = 26,
			Minigun = 26,
			HomingMissile = 10,
			OnePunch = 10,
			VarietyGrenade = 1,
			BlackHoleGrenade = 1,
		},
	},

	-- Items always given, instead of a roll
	Fixed = {},
}

return _data
