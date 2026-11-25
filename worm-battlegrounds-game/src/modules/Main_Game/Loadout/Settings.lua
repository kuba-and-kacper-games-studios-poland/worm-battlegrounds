--- @class Loadout_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Slots

	--[[
		Slots every player has besides the Bazooka, and the most a player can open (the owner, 2026-11-25: "keep only 2
		slots for weapons (bazooka always there)"; 3 before)
	]]
	BASE_SLOTS = 1,
	MAX_SLOTS = 6,

	--[[
		Each slot past the base opens in order, each dearer than the last, with its diamonds here (an average match pays
		about 25; halved from the coin prices on 2026-11-25, when coins went), or slots 3 to 6 with Robux (SLOT_PRODUCTS)
	]]
	--- @type { [number]: string }
	DIAMOND_SLOT_PRICES = { [2] = "375", [3] = "1000", [4] = "2500", [5] = "6000", [6] = "12500" },

	-- Players from before 2026-11-25 (their tutorial match played, or a slot filled) keep this many slots past the new base
	KEPT_SLOTS = 2,

	--[[
		The developer products that open each slot for Robux (Marketplace's Products: R$39, 69, 99, 149, the owner,
		2026-11-25), offered on the slot's question when the diamonds aren't there; slot 2 opens with diamonds alone
	]]
	--- @type { [number]: string }
	SLOT_PRODUCTS = { [3] = "LoadoutSlot3", [4] = "LoadoutSlot4", [5] = "LoadoutSlot5", [6] = "LoadoutSlot6" },

	-- The game passes that opened one more slot each before the slot products (2026-11-25): still counted for players who own them, no longer sold
	--- @type { string }
	SLOT_PASSES = { "Slot5", "Slot6" },

	--%%%%%%%%%%%%%%%%%%%% Items

	-- The inventory categories a slot takes
	--- @type { string }
	SLOT_CATEGORIES = { "Weapon", "Utility" },

	-- Copies of an item that make it shiny, and golden (a look only: golden items deal and boost as shiny ones)
	SHINY_COPIES = 10,
	GOLDEN_COPIES = 100,

	--[[
		The looks a weapon can wear, plainest first: a player picks any look up to the best they have (the panel's
		look tab); the damage always follows the best one owned
	]]
	--- @type { string }
	LOOKS = { "Normal", "Shiny", "Golden" },

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The lobby panel and the picker widget
	PANEL_GUI_NAME = "Loadout",
	PICKER_GUI_NAME = "LoadoutPicker",

	--[[
		The panel's DisplayOrder while the picker is open: over WidgetManager's dim (DIM_ORDER -1) and under the picker
		(1), so the loadout and its look tab stay bright beside it (the owner, 2026-11-25)
	]]
	PICKING_DISPLAY_ORDER = 0,

	--[[
		The basic weapon every loadout has, first on the panel and in the picker (where nothing replaces it), and the
		rarity the picker draws it in (it's Arsenal's alone, with no inventory row)
	]]
	BASIC_WEAPON = "Bazooka",
	BASIC_WEAPON_RARITY = "Common",

	-- Cards in each of the panel's rows (U_Row1 to U_Row4, the last card of an odd count on the right), and in each of the picker's rows
	SLOTS_PER_ROW = 2,
	ITEMS_PER_ROW = 3,

	-- The picture beside a locked slot's price (its diamonds)
	DIAMOND_ICON = "rbxassetid://98200575516825",
}

return _settings
