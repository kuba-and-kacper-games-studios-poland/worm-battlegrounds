--- @class Utils_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Scalers

	-- Screen size the scalers treat as 100%.
	DEFAULT_VIEWPORT_SIZE = Vector2.new(1920, 1080),

	--%%%%%%%%%%%%%%%%%%%% Price Tag

	-- Texts a price tag shows instead of a price.
	--- @type { [string]: string }
	PRICETAG_MESSAGES = {
		["Error"] = "ERROR",
		["Owned"] = "OWNED",
		["Group"] = "JOIN GROUP",
		["RobloxPlus"] = "ROBLOX PLUS",
	},
}
return _settings
