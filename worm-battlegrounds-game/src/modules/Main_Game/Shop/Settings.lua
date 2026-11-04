--- @class Shop_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Diamond Packs

	-- The developer products the shop sells, in order: the Marketplace entry, its name and what it gives
	--- @type { Shop_Pack }
	PACKS = {
		{ Product = "Diamonds_Handful", Name = "Handful", Diamonds = "250" },
		{ Product = "Diamonds_Pouch", Name = "Pouch", Diamonds = "500" },
		{ Product = "Diamonds_Bag", Name = "Bag", Diamonds = "1000" },
		{ Product = "Diamonds_Chest", Name = "Chest", Diamonds = "1500" },
		{ Product = "Diamonds_Vault", Name = "Vault", Diamonds = "2500" },
	},

	PACK_ICON = "rbxasset://textures/wb_guipreview/diamond_48620100.png",

	--%%%%%%%%%%%%%%%%%%%% Game Passes

	-- The game passes the shop sells, in order: the Marketplace entry, its name and what it gives
	--- @type { Shop_Pass }
	PASSES = {
		{ GamePass = "VIP", Name = "VIP", Benefits = "A free skin crate every day, a gold name, a chat tag and the VIP skin" },
		{ GamePass = "DoubleCoins", Name = "Double Coins", Benefits = "Twice the coins from every match" },
		{ GamePass = "Slot4", Name = "Loadout slot 4", Benefits = "A fourth weapon slot, without paying coins" },
		{ GamePass = "Slot5", Name = "Loadout slot 5", Benefits = "A fifth weapon slot, without paying coins" },
	},

	--%%%%%%%%%%%%%%%%%%%% VIP

	VIP_PASS = "VIP",

	-- The tag in front of a VIP player's chat messages
	VIP_CHAT_TAG = '<font color="#FFCE2E">[VIP]</font> ',

	-- Seconds between checks for a new day's free crate
	VIP_CHECK_SECONDS = 60,

	--%%%%%%%%%%%%%%%%%%%% Gui

	GUI_NAME = "Shop",

	-- The top bar button that opens the shop, on these maps only
	TOP_BAR_TEXT = "SHOP",

	--- @type { string }
	TOP_BAR_MAPS = { "Lobby" },
}

return _settings
