--- @class Loadout_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Slots

	-- Slots every player has, and the most a player can open
	BASE_SLOTS = 3,
	MAX_SLOTS = 6,

	-- Coins for the one slot coins open (slot 4)
	COIN_SLOT_PRICE = "2500",

	-- The game passes that each open one more slot, in any order; the panel offers them in this order
	--- @type { string }
	SLOT_PASSES = { "Slot5", "Slot6" },

	--%%%%%%%%%%%%%%%%%%%% Items

	-- The inventory categories a slot takes
	--- @type { string }
	SLOT_CATEGORIES = { "Weapon", "Utility" },

	-- Copies of an item that make it shiny, and golden (a look only: golden items deal and boost as shiny ones)
	SHINY_COPIES = 10,
	GOLDEN_COPIES = 100,

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The lobby panel and the picker widget
	PANEL_GUI_NAME = "Loadout",
	PICKER_GUI_NAME = "LoadoutPicker",

	-- The basic weapon every loadout has, first on the panel and never in the picker
	BASIC_WEAPON = "Bazooka",

	-- Cards in each of the panel's rows (U_Row1 to U_Row4, the last card of an odd count on the right), and in each of the picker's rows
	SLOTS_PER_ROW = 2,
	ITEMS_PER_ROW = 3,

	-- The picture beside a locked slot's price: coins for the coin slot, Robux for a pass
	COIN_ICON = "rbxassetid://123804836570291",
	ROBUX_ICON = "rbxasset://textures/ui/common/robux@3x.png",
}

return _settings
