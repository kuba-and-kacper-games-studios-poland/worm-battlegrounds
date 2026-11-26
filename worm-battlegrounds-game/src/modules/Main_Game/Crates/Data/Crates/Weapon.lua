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

	-- Diamonds for one crate, a 3-pack and a 10-pack
	Prices = {
		Diamonds = { One = "100", Three = "300", Ten = "1000" },
	},

	--[[ Odds ]]

	-- Each item's chance in percent; adds up to 100
	Odds = {
		Uzi = 26.82,
		BaseballBat = 26.82,
		ClusterBomb = 18.18,
		SpiderBomb = 18.18,
		HomingMissile = 9.09,
		VarietyGrenade = 0.91,
	},

	-- Items always given, instead of a roll
	Fixed = {},
}

return _data
