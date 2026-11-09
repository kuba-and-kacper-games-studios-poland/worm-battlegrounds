--- @class Crates_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Opening

	-- How many crates a pack opens: one buy button each (U_BuyX<count>), priced by the crate's One, Three and Ten
	--- @type { number }
	COUNTS = { 1, 3, 10 },

	-- Copies of an item that make it shiny
	SHINY_COPIES = 10,

	-- Currencies bought with Robux: rolling crates with them is a paid random item, hidden where the policy restricts it
	--- @type { string }
	PAID_CURRENCIES = { "Diamonds" },

	--%%%%%%%%%%%%%%%%%%%% Special Crates

	-- The crate VIP players open free once a day, and the odds it rolls with
	VIP_CRATE = "Skin",
	VIP_ODDS = "Coins",

	-- The crate the tutorial gives, once
	TUTORIAL_CRATE = "Tutorial",

	--%%%%%%%%%%%%%%%%%%%% Reveal

	-- Seconds the crate shakes before it opens, and how far it tilts
	SHAKE_SECONDS = 1.2,
	SHAKE_DEGREES = 12,

	--%%%%%%%%%%%%%%%%%%%% Gui

	GUI_NAME = "Crates",
	OPEN_GUI_NAME = "CrateOpen",

	-- The currencies crates are paid in, one balance chip each (U_Pay<currency>), in the order a crate picks first
	--- @type { string }
	PAY_CURRENCIES = { "Coins", "Diamonds" },

	-- The x1 button's price while the crate is free (VIP's daily crate)
	PRICE_FREE = "FREE",

	--[[
		The lobby gui with the corner menu (U_Menu: S_Weapons and S_Skins open a crate's tab), and the badge on its
		Weapons button: this text while a free crate waits, else how many crates the player's coins open, shown as
		BADGE_MAX+ past BADGE_MAX
	]]
	LOBBY_GUI_NAME = "Lobby",
	BADGE_FREE = "FREE",
	BADGE_MAX = 9,
}

return _settings
