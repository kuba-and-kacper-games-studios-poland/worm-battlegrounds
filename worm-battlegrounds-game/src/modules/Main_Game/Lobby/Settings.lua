--- @class Lobby_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The guis the lobby turns on: its background first, then its panels
	--- @type { string }
	LOBBY_GUIS = { "Lobby", "MatchBoard", "Party", "Loadout", "Currency" },

	--%%%%%%%%%%%%%%%%%%%% Stage

	--[[
		The lobby's 3D stage behind the guis, a persistent Model the place loads into Workspace.Ume, and its markers:
		where the camera sits (looking along its front) and where the player's worm stands
	]]
	STAGE_NAME = "LobbyStage",
	CAMERA_MARKER = "Camera",
	WORM_MARKER = "Worm",

	-- The stage camera's field of view
	STAGE_FOV = 40,

	--%%%%%%%%%%%%%%%%%%%% Travel

	-- The teleport screen
	TELEPORT_GUI = "TeleportGui",

	-- The match a new player is sent to before they see the lobby
	TUTORIAL_MAP = "PicnicPlains",
	TUTORIAL_DIFFICULTY = "Tutorial",

	-- Studio playtests skip the tutorial match (nothing saves there) unless Workspace has this attribute set to true
	STUDIO_TUTORIAL_ATTRIBUTE = "StudioTutorial",
}

return _settings
