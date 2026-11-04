--- @type Crates_CrateData
local _data = {

	--[[ General ]]

	Name = "Tutorial crate",
	Picture = "rbxasset://textures/wb_guipreview/crate_17762c23.png",
	LayoutOrder = 0,
	Hidden = true,

	--[[ Prices ]]

	-- Coins or diamonds for one crate, and for a 10-pack
	Prices = {
		Coins = { One = "100", Ten = "100" },
	},

	--[[ Odds ]]

	-- Each item's chance in percent, by the currency paid; each table adds up to 100
	OddsByCurrency = {},

	-- Items always given, instead of a roll
	Fixed = { "Grenade", "Shotgun" },
}

return _data
