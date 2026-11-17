--- @class Lobby_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The guis the lobby turns on: its menu first, then its panels
	--- @type { string }
	LOBBY_GUIS = { "Lobby", "MatchBoard", "Party", "Loadout", "Currency", "LevelPlate" },

	-- The widgets that cover the whole screen: the lobby's guis hide while one is open
	--- @type { string }
	FULL_SCREEN_WIDGETS = { "Skins", "Crates", "Shop" },

	--[[
		The widgets that stand in some lobby guis' place, by widget: those guis hide while one is open. The weapon picker
		and the free crate dialog are tall windows in the middle, so the top row (the menu with FREE WEAPONS, the coins,
		the level) and the board at the bottom make way for them, and Party and the Loadout column stay (the owner,
		2026-11-17: "make sure they hide")
	]]
	--- @type { [string]: { string } }
	PANEL_WIDGETS = {
		EmoteShop = { "Loadout" },
		CustomLobby = { "Loadout" },
		MatchSetup = { "Loadout" },
		LoadoutPicker = { "Lobby", "MatchBoard", "Currency", "LevelPlate" },
		FreeCrateDialog = { "Lobby", "MatchBoard", "Currency", "LevelPlate" },
	},

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

	-- How much bigger the snails stand on the stage than in a match (the owner, 2026-11-15: "50% larger in lobby")
	STAGE_SNAIL_SCALE = 1.5,

	--[[
		In a custom lobby the stage stands its members on CUSTOM_PODS_PREFAB's eight pods instead (in Assets/Lobby, its
		pivot on the stage's pivot; authored 300 studs beside the stage): three in front, two raised behind them, three
		higher at the back, packed close (the owner, 2026-11-16). The camera then backs off along its look, and rises
		with it, just as far as every snail needs to fit STAGE_FIT_MARGIN of the screen, easing there
		(STAGE_CAMERA_EASE of the way each 1/60 s)
	]]
	CUSTOM_PODS_PREFAB = "PREFAB | CustomPods",
	STAGE_FIT_MARGIN = 0.82,
	STAGE_CAMERA_EASE = 0.08,

	--[[
		Every snail on the stage holds STAGE_WEAPON (scaled with it) and plays one of STAGE_POSES (Animations in
		Assets/Snails/Animations, the studio's bazooka poses), picked at random for each snail, never the one it had, and
		started at a random point: picked again when the stage's members change or the player comes back from a match
		(the owner, 2026-11-16: "make it feel organic and natural"). A pose with no AnimationId yet is skipped
	]]
	STAGE_WEAPON = "Bazooka",

	-- The stage weapon's size against its match model, as the studio's posed snail holds it (the match draws it bigger to read)
	STAGE_WEAPON_SCALE = 0.72,

	--- @type { string }
	STAGE_POSES = { "LobbyPose1", "LobbyPose2", "LobbyPose3", "LobbyPose4" },

	--%%%%%%%%%%%%%%%%%%%% Travel

	-- The teleport screen
	TELEPORT_GUI = "TeleportGui",

	-- The match a new player is sent to before they see the lobby
	TUTORIAL_MAP = "TutorialMeadow",
	TUTORIAL_DIFFICULTY = "Tutorial",

	-- Studio playtests skip the whole tutorial (nothing saves there) unless Workspace has this attribute set to true
	STUDIO_TUTORIAL_ATTRIBUTE = "StudioTutorial",
}

return _settings
