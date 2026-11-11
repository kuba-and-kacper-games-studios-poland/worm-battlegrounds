--- @type Crates_CrateData
local _data = {

	--[[ General ]]

	Name = "Tutorial crate",
	TabName = "Starter",
	LayoutOrder = 0,
	Hidden = true,

	--[[ Look ]]

	-- The showcase's theme: its glow and its second colour, the particles round it, and the premium dressing
	Glow = Color3.fromRGB(155, 225, 93),
	Accent = Color3.fromRGB(90, 190, 60),
	Ambient = "Sparkles",
	Premium = false,

	-- The 3D crate the opening drops in (ReplicatedStorage_Assets/Crates)
	Model = "PREFAB | Crate_Starter",

	--[[ Prices ]]

	-- Coins or diamonds for one crate, a 3-pack and a 10-pack
	Prices = {
		Coins = { One = "100", Three = "100", Ten = "100" },
	},

	--[[ Odds ]]

	-- Each item's chance in percent, by the currency paid; each table adds up to 100
	OddsByCurrency = {},

	-- Items always given, instead of a roll
	Fixed = { "Grenade", "Shotgun" },
}

return _data
