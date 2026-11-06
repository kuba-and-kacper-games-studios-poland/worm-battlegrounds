--- @class ScreenScale_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Guis

	-- The game's guis whose S_ScreenScale UIScales follow the screen (ume's own guis scale themselves)
	--- @type { string }
	GUIS = {
		"MatchHud",
		"Results",
		"Lobby",
		"MatchBoard",
		"CustomLobby",
		"Party",
		"PartyInvite",
		"PartyInvited",
		"Loadout",
		"LoadoutPicker",
		"Crates",
		"CrateOdds",
		"CrateOpen",
		"Skins",
		"EmoteShop",
		"Shop",
		"Currency",
		"TutorialHint",
	},

	--%%%%%%%%%%%%%%%%%%%% Scale

	-- Screen height the guis are laid out for; S_ScreenScale is the screen's height over it
	DESIGN_HEIGHT = 1080,

	-- Screen width the lobby's side-by-side panels are laid out for; a narrower screen scales by its width instead
	DESIGN_WIDTH = 1920,

	-- Mobile screens shorter than this many pixels scale the guis up by MOBILE_BOOST
	SMALL_SCREEN = 500,
	MOBILE_BOOST = 1.3,

	--[[
		The smallest screen scale on every device but Mobile (whose phones have their own sizes): small 4:3 PC screens
		keep their text at 14 px or more instead of shrinking to 0.53
	]]
	MIN_SCALE = 0.6,

	--[[
		The UIScale attribute Utils_PlatformScale keeps a panel's device scale in (a panel tagged with it is sized per
		device); the screen's scale is multiplied by it. Without the tag, a panel keeps the screen's scale
	]]
	BASE_SCALE_ATTRIBUTE = "Utils_BaseScale",
}

return _settings
