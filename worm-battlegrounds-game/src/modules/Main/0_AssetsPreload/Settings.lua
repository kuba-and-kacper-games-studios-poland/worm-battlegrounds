--- @class AssetsPreload_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Content

	--[[
		Strings in the game's data and settings matching this are pictures code sets later (item, weapon and crate
		icons, map pictures, pad glyphs), loaded with the rest
	]]
	ID_PATTERN = "^rbxassetid://%d+$",

	-- How many levels of nested tables the data and settings scan follows
	SCAN_DEPTH = 8,

	-- Modules whose settings the scan leaves out: Rarity's icons are the template's placeholders, which don't load
	--- @type { string }
	SKIP_SETTINGS = { "Rarity" },
}
return _settings
