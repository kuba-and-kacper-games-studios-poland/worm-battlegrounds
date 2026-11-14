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

	--[[
		Each item's chance in percent, by the currency paid; each table adds up to 100. A set's pieces share what its
		whole skin had (2026-11-14)
	]]
	OddsByCurrency = {
		Coins = {

			--[[ Wild West ]]

			Shell_Saddlebag = 6.67,
			Hat_TenGallon = 6.67,
			Neck_DustyBandana = 6.66,

			--[[ High Seas ]]

			Hat_CaptainsTricorn = 6.67,
			Neck_SeaScarf = 6.67,
			Shell_TreasureHold = 6.66,

			--[[ Frontline ]]

			Hat_FieldHelmet = 6.67,
			Neck_CamoScarf = 6.67,
			Shell_Bunker = 6.66,

			--[[ Shadow Clan ]]

			Hat_RedHachimaki = 3.34,
			Body_Midnight = 3.33,
			Shell_ShadowCoil = 3.33,

			--[[ Round Table ]]

			Hat_PlumedHelm = 3.34,
			Neck_CrestShield = 3.33,
			Shell_Rampart = 3.33,

			--[[ Big Top ]]

			Hat_RingmasterTopper = 2.5,
			Neck_FrillyRuff = 2.5,
			Body_Greasepaint = 2.5,
			Shell_ConfettiCoil = 2.5,

			--[[ Inferno ]]

			Neck_SpikedCollar = 2.34,
			Body_Brimstone = 2.33,
			Shell_HellfireSpiral = 2.33,

			--[[ Circuit ]]

			Body_ChromePlating = 1,
			Shell_ReactorCore = 1,

			--[[ Crypt ]]

			Hat_LichCrown = 0.34,
			Body_BareBones = 0.33,
			Shell_Ossuary = 0.33,
		},
		Diamonds = {

			--[[ Wild West ]]

			Shell_Saddlebag = 6.67,
			Hat_TenGallon = 6.67,
			Neck_DustyBandana = 6.66,

			--[[ High Seas ]]

			Hat_CaptainsTricorn = 6.67,
			Neck_SeaScarf = 6.67,
			Shell_TreasureHold = 6.66,

			--[[ Frontline ]]

			Hat_FieldHelmet = 6.67,
			Neck_CamoScarf = 6.67,
			Shell_Bunker = 6.66,

			--[[ Shadow Clan ]]

			Hat_RedHachimaki = 3.34,
			Body_Midnight = 3.33,
			Shell_ShadowCoil = 3.33,

			--[[ Round Table ]]

			Hat_PlumedHelm = 3.34,
			Neck_CrestShield = 3.33,
			Shell_Rampart = 3.33,

			--[[ Big Top ]]

			Hat_RingmasterTopper = 2.5,
			Neck_FrillyRuff = 2.5,
			Body_Greasepaint = 2.5,
			Shell_ConfettiCoil = 2.5,

			--[[ Inferno ]]

			Neck_SpikedCollar = 2.34,
			Body_Brimstone = 2.33,
			Shell_HellfireSpiral = 2.33,

			--[[ Circuit ]]

			Body_ChromePlating = 1,
			Shell_ReactorCore = 1,

			--[[ Crypt ]]

			Hat_LichCrown = 0.34,
			Body_BareBones = 0.33,
			Shell_Ossuary = 0.33,
		},
	},

	-- Items always given, instead of a roll
	Fixed = {},
}

return _data
