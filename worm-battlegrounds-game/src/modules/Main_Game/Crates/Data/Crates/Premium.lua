--- @type Crates_CrateData
local _data = {

	--[[ General ]]

	Name = "Premium crate",
	TabName = "Premium",
	LayoutOrder = 2,
	Hidden = false,

	--[[ Look ]]

	-- The showcase's theme: its glow and its second colour, the particles round it, and the premium dressing
	Glow = Color3.fromRGB(92, 225, 255),
	Accent = Color3.fromRGB(255, 210, 74),
	Ambient = "Glints",
	Premium = true,

	-- The 3D crate the opening drops in (ReplicatedStorage_Assets/Crates)
	Model = "PREFAB | Crate_Premium",

	--[[ Prices ]]

	-- Coins or diamonds for one crate, a 3-pack and a 10-pack
	Prices = {
		Diamonds = { One = "250", Three = "750", Ten = "2250" },
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
