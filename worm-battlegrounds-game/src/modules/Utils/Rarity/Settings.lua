--- @class Rarity_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% General

	-- All Rarity names in ascending order.
	--- @type { string }
	RARITY_NAMES = {
		"Common",
		"Uncommon",
		"Rare",
		"Epic",
		"Legendary",
		"Mythic",
		"Exotic",
		"Ancient",
		"Divine",
		"Celestial",
		"Cosmic",
		"Eternal",
		"Transcendent",
		"Secret",
	},

	-- Rarity weight ranges indexed by name (Min = luck 0, Max = luck 1000).
	--- @type { [string]: Rarity_WeightRange }
	RARITY_WEIGHTS = {
		["Common"] = { Min = 25, Max = 10 },
		["Uncommon"] = { Min = 30, Max = 16 },
		["Rare"] = { Min = 20, Max = 22 },
		["Epic"] = { Min = 12, Max = 18 },
		["Legendary"] = { Min = 7, Max = 14 },
		["Mythic"] = { Min = 4, Max = 12 },
		["Exotic"] = { Min = 1, Max = 8 },
		["Ancient"] = { Min = 0.2, Max = 3 },
		["Divine"] = { Min = 0.03, Max = 1.5 },
		["Celestial"] = { Min = 0.005, Max = 0.8 },
		["Cosmic"] = { Min = 0.0005, Max = 0.2 },
		["Eternal"] = { Min = 0.000004, Max = 0.05 },
		["Transcendent"] = { Min = 0.000002, Max = 0.02 },
		["Secret"] = { Min = 0.000001, Max = 0.01 },
	},

	-- Rarities icons indexed by their names.
	--- @type { [string]: string }
	RARITY_ICONS = {
		["Common"] = "rbxassetid://82036068730437",
		["Uncommon"] = "rbxassetid://82036068730437",
		["Rare"] = "rbxassetid://82036068730437",
		["Epic"] = "rbxassetid://82036068730437",
		["Legendary"] = "rbxassetid://82036068730437",
		["Mythic"] = "rbxassetid://82036068730437",
		["Exotic"] = "rbxassetid://82036068730437",
		["Ancient"] = "rbxassetid://82036068730437",
		["Divine"] = "rbxassetid://82036068730437",
		["Celestial"] = "rbxassetid://82036068730437",
		["Cosmic"] = "rbxassetid://82036068730437",
		["Eternal"] = "rbxassetid://82036068730437",
		["Transcendent"] = "rbxassetid://82036068730437",
		["Secret"] = "rbxassetid://82036068730437",
	},

	--%%%%%%%%%%%%%%%%%%%% Gradients

	-- Rotation and whether Utils_UIGradientMove is added, indexed by rarity name.
	--- @type { [string]: Rarity_GradientStyle }
	RARITY_GRADIENTS = {
		["Common"] = { Rotation = -85, AddGradientMove = false },
		["Uncommon"] = { Rotation = -85, AddGradientMove = false },
		["Rare"] = { Rotation = -85, AddGradientMove = false },
		["Epic"] = { Rotation = -85, AddGradientMove = false },
		["Legendary"] = { Rotation = -85, AddGradientMove = false },
		["Mythic"] = { Rotation = -85, AddGradientMove = false },
		["Exotic"] = { Rotation = -85, AddGradientMove = false },
		["Ancient"] = { Rotation = 0, AddGradientMove = true },
		["Divine"] = { Rotation = 0, AddGradientMove = true },
		["Celestial"] = { Rotation = -85, AddGradientMove = false },
		["Cosmic"] = { Rotation = 0, AddGradientMove = true },
		["Eternal"] = { Rotation = 0, AddGradientMove = true },
		["Transcendent"] = { Rotation = 0, AddGradientMove = true },
		["Secret"] = { Rotation = 0, AddGradientMove = true },
	},

	--%%%%%%%%%%%%%%%%%%%% Looks

	--[[
		How a rarity is written on a label (`ApplyLook`): its text, font,
		base colour, gradient colours (top to bottom), outline, and whether a glow copy sits behind it.
	]]
	--- @type { [string]: Rarity_Look }
	RARITY_LOOKS = {
		["Common"] = {
			Text = "Common",
			Font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Heavy),
			Base = Color3.fromHex("CDD5DF"),
			Colors = { Color3.fromHex("F0F4F8"), Color3.fromHex("C2CCD8") },
			Stroke = Color3.fromHex("14171B"),
			Glow = false,
		},
		["Uncommon"] = {
			Text = "Uncommon",
			Font = Font.fromEnum(Enum.Font.FredokaOne),
			Base = Color3.fromHex("8CEB2E"),
			Colors = { Color3.fromHex("D4FF8A"), Color3.fromHex("8CEB2E"), Color3.fromHex("4CA615") },
			Stroke = Color3.fromHex("0C2410"),
			Glow = false,
		},
		["Rare"] = {
			Text = "Rare",
			Font = Font.fromEnum(Enum.Font.FredokaOne),
			Base = Color3.fromHex("26C6FF"),
			Colors = { Color3.fromHex("A6F0FF"), Color3.fromHex("26C6FF"), Color3.fromHex("0F8FE8") },
			Stroke = Color3.fromHex("0A1C38"),
			Glow = false,
		},
		["Epic"] = {
			Text = "Epic",
			Font = Font.new("rbxasset://fonts/families/Merriweather.json", Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
			Base = Color3.fromHex("A64DFF"),
			Colors = { Color3.fromHex("E0A8FF"), Color3.fromHex("B061FF"), Color3.fromHex("7424E0") },
			Stroke = Color3.fromHex("220A3B"),
			Glow = true,
		},
		["Legendary"] = {
			Text = "LEGENDARY",
			Font = Font.new("rbxasset://fonts/families/Sarpanch.json", Enum.FontWeight.Heavy),
			Base = Color3.fromHex("FFB51F"),
			Colors = { Color3.fromHex("FFE066"), Color3.fromHex("FFB51F"), Color3.fromHex("D9700A") },
			Stroke = Color3.fromHex("3A2200"),
			Glow = true,
		},
		["Mythic"] = {
			Text = "Mythic",
			Font = Font.new("rbxasset://fonts/families/GrenzeGotisch.json", Enum.FontWeight.Heavy),
			Base = Color3.fromHex("FF3344"),
			Colors = { Color3.fromHex("FF8A93"), Color3.fromHex("FF3344"), Color3.fromHex("A80F1E") },
			Stroke = Color3.fromHex("2A0406"),
			Glow = true,
		},
		["Exotic"] = {
			Text = "Exotic",
			Font = Font.fromEnum(Enum.Font.Bangers),
			Base = Color3.fromHex("1FD1A5"),
			Colors = { Color3.fromHex("7CFFD4"), Color3.fromHex("1FD1A5"), Color3.fromHex("0E8F6E") },
			Stroke = Color3.fromHex("042A20"),
			Glow = true,
		},
		["Ancient"] = {
			Text = "Ancient",
			Font = Font.fromEnum(Enum.Font.Antique),
			Base = Color3.fromHex("C49A55"),
			Colors = { Color3.fromHex("E8D3A2"), Color3.fromHex("C49A55"), Color3.fromHex("7A5426") },
			Stroke = Color3.fromHex("2B1A08"),
			Glow = true,
		},
		["Divine"] = {
			Text = "Divine",
			Font = Font.new("rbxasset://fonts/families/Fondamento.json", Enum.FontWeight.Bold),
			Base = Color3.fromHex("FFD940"),
			Colors = { Color3.fromHex("FFF29A"), Color3.fromHex("FFD940"), Color3.fromHex("E89B10") },
			Stroke = Color3.fromHex("3A2A00"),
			Glow = true,
		},
		["Celestial"] = {
			Text = "C E L E S T I A L",
			Font = Font.new("rbxasset://fonts/families/Michroma.json", Enum.FontWeight.Bold),
			Base = Color3.fromHex("3DE8FF"),
			Colors = { Color3.fromHex("A8F6FF"), Color3.fromHex("3DE8FF"), Color3.fromHex("9C7BFF") },
			Stroke = Color3.fromHex("06222A"),
			Glow = true,
		},
		["Cosmic"] = {
			Text = "Cosmic",
			Font = Font.new("rbxasset://fonts/families/Jura.json", Enum.FontWeight.Bold),
			Base = Color3.fromHex("7A4DFF"),
			Colors = { Color3.fromHex("C2A8FF"), Color3.fromHex("8C5CFF"), Color3.fromHex("3F1FC2") },
			Stroke = Color3.fromHex("120A33"),
			Glow = true,
		},
		["Eternal"] = {
			Text = "Eternal",
			Font = Font.new("rbxasset://fonts/families/AccanthisADFStd.json", Enum.FontWeight.Bold),
			Base = Color3.fromHex("FF3DB4"),
			Colors = { Color3.fromHex("FFA3DB"), Color3.fromHex("FF3DB4"), Color3.fromHex("B00F78") },
			Stroke = Color3.fromHex("2E0620"),
			Glow = true,
		},
		["Transcendent"] = {
			Text = "Transcendent",
			Font = Font.new("rbxasset://fonts/families/TitilliumWeb.json", Enum.FontWeight.Heavy),
			Base = Color3.fromHex("4DFFC3"),
			Colors = { Color3.fromHex("B8FFE8"), Color3.fromHex("4DFFC3"), Color3.fromHex("FF6BDA") },
			Stroke = Color3.fromHex("0A2A22"),
			Glow = true,
		},
		["Secret"] = {
			Text = "SECRET",
			Font = Font.new("rbxasset://fonts/families/SpecialElite.json", Enum.FontWeight.Bold),
			Base = Color3.fromHex("FFFFFF"),
			Colors = {
				Color3.fromHex("FF4D4D"),
				Color3.fromHex("FFA94D"),
				Color3.fromHex("FFF04D"),
				Color3.fromHex("5CFF6B"),
				Color3.fromHex("4DD2FF"),
				Color3.fromHex("8C6BFF"),
				Color3.fromHex("FF6BE0"),
			},
			Stroke = Color3.fromHex("000000"),
			Glow = true,
		},
	},
}
return _settings
