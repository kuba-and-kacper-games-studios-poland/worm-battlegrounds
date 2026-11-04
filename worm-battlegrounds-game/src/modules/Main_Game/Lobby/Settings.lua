--- @class Lobby_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The guis the lobby turns on: its background first, then its panels
	--- @type { string }
	LOBBY_GUIS = { "Lobby", "MatchBoard", "Party", "Loadout", "Crates", "Currency" },

	--%%%%%%%%%%%%%%%%%%%% Travel

	-- The teleport screen
	TELEPORT_GUI = "TeleportGui",

	-- The match a new player is sent to before they see the lobby
	TUTORIAL_MAP = "PicnicPlains",
	TUTORIAL_DIFFICULTY = "Tutorial",
}

return _settings
