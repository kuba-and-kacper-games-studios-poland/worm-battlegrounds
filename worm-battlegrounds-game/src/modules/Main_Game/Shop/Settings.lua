--- @class Shop_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Diamond Packs

	-- The developer products the shop sells, in order: the Marketplace entry, its name, its picture and what it gives
	--- @type { Shop_Pack }
	PACKS = {
		{ Product = "Diamonds_Handful", Name = "Handful", Icon = "rbxassetid://108852031784319", Diamonds = "250" },
		{ Product = "Diamonds_Pouch", Name = "Pouch", Icon = "rbxassetid://72342194438233", Diamonds = "500" },
		{ Product = "Diamonds_Bag", Name = "Bag", Icon = "rbxassetid://85100866314854", Diamonds = "1000" },
		{ Product = "Diamonds_Chest", Name = "Chest", Icon = "rbxassetid://81930520222703", Diamonds = "1500" },
		{ Product = "Diamonds_Vault", Name = "Vault", Icon = "rbxassetid://108392197531787", Diamonds = "2500" },
	},

	--%%%%%%%%%%%%%%%%%%%% Game Passes

	--[[
		The game passes the shop sells, in order: the Marketplace entry, its name, its picture and what it gives. The
		loadout slot passes left on 2026-11-25: slots are sold on the loadout's locked slot (Loadout's SLOT_PRODUCTS)
	]]
	--- @type { Shop_Pass }
	PASSES = {
		{
			GamePass = "VIP",
			Name = "VIP",
			Icon = "rbxassetid://84847875031526",
			Benefits = "A free skin crate every day, a gold name, a chat tag and the VIP skin",
		},
		{ GamePass = "DoubleCoins", Name = "Double Diamonds", Icon = "rbxassetid://122604385822529", Benefits = "Twice the diamonds from every match" },
	},

	--%%%%%%%%%%%%%%%%%%%% VIP

	VIP_PASS = "VIP",

	-- The tag in front of a VIP player's chat messages
	VIP_CHAT_TAG = '<font color="#FFCE2E">[VIP]</font> ',

	-- Seconds between checks for a new day's free crate
	VIP_CHECK_SECONDS = 60,

	--%%%%%%%%%%%%%%%%%%%% Gui

	GUI_NAME = "Shop",
}

return _settings
