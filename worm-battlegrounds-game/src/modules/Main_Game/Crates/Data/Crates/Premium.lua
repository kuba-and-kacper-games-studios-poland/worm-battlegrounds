--- @type Crates_CrateData
local _data = {

	--[[ General ]]

	Name = "Premium crate",
	TabName = "Premium",
	LayoutOrder = 2,

	-- Folded into the Weapon crate's diamonds (the testers, 2026-11-13); kept hidden so its id stays known
	Hidden = true,

	--[[ Look ]]

	-- The showcase's theme: its glow and its second colour, the particles round it, and the premium dressing
	Glow = Color3.fromRGB(92, 225, 255),
	Accent = Color3.fromRGB(255, 210, 74),
	Ambient = "Glints",
	Premium = true,

	-- The 3D crate the opening drops in (ReplicatedStorage_Assets/Crates)
	Model = "PREFAB | Crate_Premium",

	--[[ Prices ]]

	-- Diamonds for one crate, a 3-pack and a 10-pack
	Prices = {
		Diamonds = { One = "250", Three = "750", Ten = "2250" },
	},

	--[[ Odds ]]

	-- Each item's chance in percent; adds up to 100
	Odds = {
		ClusterBomb = 41.27,
		SpiderBomb = 41.27,
		HomingMissile = 15.87,
		VarietyGrenade = 1.59,
	},

	-- Items always given, instead of a roll
	Fixed = {},
}

return _data
