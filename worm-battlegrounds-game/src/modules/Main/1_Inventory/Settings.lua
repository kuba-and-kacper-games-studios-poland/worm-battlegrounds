--- @class Inventory_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% General

	-- List of valid categories.
	CATEGORIES = {

		--[[ General ]]

		"General",

		-- Other used for all invalid categories
		"Other",
	},

	-- How much of any item can be used at one time.
	MAX_USE_QUANTITY = 100,

	--%%%%%%%%%%%%%%%%%%%% Unique

	-- Maximum amount of unique items.
	MAX_UNIQUE_ITEMS = 5000,

	--[[
		Inventory will re-count amount of unique items in the inventory
		upon adding or creating new unique item,\
		if the space left is less than this number.
	]]
	RECOUNT_MARGIN = 20,
}
return _settings
