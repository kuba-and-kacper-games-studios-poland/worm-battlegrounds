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
		"SoloSetup",
		"Party",
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

	-- Mobile screens shorter than this many pixels scale the guis up by MOBILE_BOOST
	SMALL_SCREEN = 500,
	MOBILE_BOOST = 1.3,
}

return _settings
