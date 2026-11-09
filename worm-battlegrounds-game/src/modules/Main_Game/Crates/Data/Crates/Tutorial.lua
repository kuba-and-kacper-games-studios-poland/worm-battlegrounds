--- @type Crates_CrateData
local _data = {

	--[[ General ]]

	Name = "Tutorial crate",
	TabName = "Starter",
	Picture = "rbxassetid://121731184312632",
	LayoutOrder = 0,
	Hidden = true,

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
