--- @type Crates_CrateData
local _data = {

	--[[ General ]]

	Name = "Weapon crate",
	TabName = "Weapons",
	LayoutOrder = 1,
	Hidden = false,

	--[[ Look ]]

	-- The showcase's theme: its glow and its second colour, the particles round it, and the premium dressing
	Glow = Color3.fromRGB(255, 179, 71),
	Accent = Color3.fromRGB(255, 122, 26),
	Ambient = "Embers",
	Premium = false,

	-- The 3D crate the opening drops in (ReplicatedStorage_Assets/Crates)
	Model = "PREFAB | Crate_Weapon",

	--[[ Prices ]]

	-- Coins or diamonds for one crate, a 3-pack and a 10-pack
	Prices = {
		Coins = { One = "100", Three = "300", Ten = "900" },
		Diamonds = { One = "250", Three = "750", Ten = "2250" },
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
