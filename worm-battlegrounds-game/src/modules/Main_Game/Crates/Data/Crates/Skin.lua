--- @type Crates_CrateData
local _data = {

	--[[ General ]]

	Name = "Skin crate",
	TabName = "Skins",
	LayoutOrder = 4,
	Hidden = false,

	--[[ Look ]]

	-- The showcase's theme: its glow and its second colour, the particles round it, and the premium dressing
	Glow = Color3.fromRGB(255, 106, 213),
	Accent = Color3.fromRGB(176, 77, 255),
	Ambient = "Sparkles",
	Premium = false,

	-- The 3D crate the opening drops in (ReplicatedStorage_Assets/Crates)
	Model = "PREFAB | Crate_Skin",

	--[[ Prices ]]

	-- Coins or diamonds for one crate, a 3-pack and a 10-pack
	Prices = {
		Coins = { One = "100", Three = "300", Ten = "900" },
		Diamonds = { One = "50", Three = "150", Ten = "450" },
	},

	--[[ Odds ]]

	-- Each item's chance in percent, by the currency paid; each table adds up to 100
	OddsByCurrency = {
		Coins = {
			Skin_Soldier = 20,
			Skin_Pirate = 20,
			Skin_Cowboy = 20,
			Skin_Ninja = 10,
			Skin_Knight = 10,
			Skin_Clown = 10,
			Skin_Robot = 2,
			Skin_Devil = 7,
			Skin_Skeleton = 1,
		},
		Diamonds = {
			Skin_Soldier = 20,
			Skin_Pirate = 20,
			Skin_Cowboy = 20,
			Skin_Ninja = 10,
			Skin_Knight = 10,
			Skin_Clown = 10,
			Skin_Robot = 2,
			Skin_Devil = 7,
			Skin_Skeleton = 1,
		},
	},

	-- Items always given, instead of a roll
	Fixed = {},
}

return _data
