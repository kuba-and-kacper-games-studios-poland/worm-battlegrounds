--- @class Loadout_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Slots

	-- Slots every player has, and the most a player can open
	BASE_SLOTS = 3,
	MAX_SLOTS = 5,

	-- What slots 4 and 5 cost in coins, and the game passes that open them instead
	--- @type { [number]: string }
	SLOT_PRICES = {
		[4] = "2500",
		[5] = "6000",
	},

	--- @type { [number]: string }
	SLOT_PASSES = {
		[4] = "Slot4",
		[5] = "Slot5",
	},

	--%%%%%%%%%%%%%%%%%%%% Items

	-- The inventory categories a slot takes
	--- @type { string }
	SLOT_CATEGORIES = { "Weapon", "Utility" },

	-- Copies of an item that make it shiny
	SHINY_COPIES = 10,

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The lobby panel and the picker widget
	PANEL_GUI_NAME = "Loadout",
	PICKER_GUI_NAME = "LoadoutPicker",

	-- An empty slot's name colour; a filled one takes its item's rarity colour (the gui kit's Text)
	EMPTY_NAME_COLOR = Color3.fromRGB(255, 255, 255),

	-- An empty slot's picture: the gui kit's plus
	EMPTY_ICON = "rbxassetid://134817447648270",
}

return _settings
