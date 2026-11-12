--- @class Lobby_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The guis the lobby turns on: its menu first, then its panels
	--- @type { string }
	LOBBY_GUIS = { "Lobby", "MatchBoard", "Party", "Loadout", "Currency" },

	-- The widgets that cover the whole screen: the lobby's guis hide while one is open
	--- @type { string }
	FULL_SCREEN_WIDGETS = { "Skins", "Crates", "Shop" },

	-- The widgets that stand in one lobby panel's place, by widget: those panels hide while one is open
	--- @type { [string]: { string } }
	PANEL_WIDGETS = { EmoteShop = { "Loadout" } },

	--%%%%%%%%%%%%%%%%%%%% Stage

	--[[
		The lobby's stage, a prefab in Assets/Lobby (authored in Workspace.Ume.ReplicatedStorage_Assets/Lobby) each client
		clones into Workspace.Ume.Lobby: the camera sits on its CAMERA_MARKER, looking along its front, and each pod in its
		PODS_FOLDER (POD_PREFIX and a number, from 1) has a SNAIL_MARKER where a party member's snail stands, the player
		on the first
	]]
	STAGE_PREFAB = "PREFAB | Stage",
	PODS_FOLDER = "Pods",
	POD_PREFIX = "Pod_",
	CAMERA_MARKER = "Camera",
	SNAIL_MARKER = "Snail",

	-- The stage camera's field of view
	STAGE_FOV = 50,

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
