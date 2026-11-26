--- @type Crates_CrateData
local _data = {

	--[[ General ]]

	Name = "Utility crate",
	TabName = "Utility",
	LayoutOrder = 3,
	Hidden = false,

	--[[ Look ]]

	-- The showcase's theme: its glow and its second colour, the particles round it, and the premium dressing
	Glow = Color3.fromRGB(63, 240, 192),
	Accent = Color3.fromRGB(24, 180, 154),
	Ambient = "Bubbles",
	Premium = false,

	-- The 3D crate the opening drops in (ReplicatedStorage_Assets/Crates)
	Model = "PREFAB | Crate_Utility",

	--[[ Prices ]]

	-- Diamonds for one crate, a 3-pack and a 10-pack
	Prices = {
		Diamonds = { One = "100", Three = "300", Ten = "1000" },
	},

	--[[ Odds ]]

	-- Each item's chance in percent; adds up to 100
	Odds = {
		Bandage = 52.38,
		Jetpack = 28.57,
		Medkit = 19.05,
	},

	-- Items always given, instead of a roll
	Fixed = {},
}

return _data
