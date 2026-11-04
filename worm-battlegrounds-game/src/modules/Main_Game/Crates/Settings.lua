--- @class Crates_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Opening

	-- How many crates a pack opens
	--- @type { number }
	COUNTS = { 1, 10 },

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
	ODDS_GUI_NAME = "CrateOdds",
	OPEN_GUI_NAME = "CrateOpen",
}

return _settings
