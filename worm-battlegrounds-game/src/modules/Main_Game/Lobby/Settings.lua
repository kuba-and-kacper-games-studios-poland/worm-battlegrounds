--- @class Lobby_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The guis the lobby turns on: its menu first, then its panels
	--- @type { string }
	LOBBY_GUIS = { "Lobby", "MatchBoard", "Party", "Loadout", "Currency", "LevelPlate" },

	-- The guis that stay while a takeover holds the screen (the XP replay, Progression's): the diamonds it fills, and its own
	--- @type { string }
	TAKEOVER_GUIS = { "Currency", "LevelPlate" },

	--[[
		The widgets that cover the whole screen: the lobby's guis hide while one is open. The match setups too (PLAY WITH
		FRIENDS, the custom lobby, the solo, party and local setup), in the middle over a darker dim (the owner,
		2026-11-25: "hide other uis, center it and make the background darker")
	]]
	--- @type { string }
	FULL_SCREEN_WIDGETS = { "Skins", "Crates", "Shop", "FriendsMatch", "CustomLobby", "MatchSetup" },

	--[[
		The widgets that stand in some lobby guis' place, by widget: those guis hide while one is open. The weapon picker
		and the free crate dialog are tall windows in the middle, so the top row (the menu with FREE WEAPONS, the diamonds,
		the level) and the board at the bottom make way for them, and Party and the Loadout column stay (the owner,
		2026-11-17: "make sure they hide"); the party invite too (the owner, 2026-11-24: FREE WEAPONS overlapped it)
	]]
	--- @type { [string]: { string } }
	PANEL_WIDGETS = {
		EmoteShop = { "Loadout" },
		LoadoutPicker = { "Lobby", "MatchBoard", "Currency", "LevelPlate" },
		FreeCrateDialog = { "Lobby", "MatchBoard", "Currency", "LevelPlate" },
		PartyInvite = { "Lobby", "MatchBoard", "Currency", "LevelPlate" },
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

	--[[
		How much bigger the snails stand on the stage than in a match (the owner, 2026-11-15: "50% larger in lobby"; bigger
		again on the small Fortnite-style pads, 2026-11-24: "the snails are a bit bigger, near each other")
	]]
	STAGE_SNAIL_SCALE = 1.9,

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

	--[[
		A member's stage weapon wears the look their level opened for it (Progression's WEAPON_REWARDS: the Bazooka is
		Shiny at 30, Golden at 90), as Combat dresses a held one (its VARIANT_LOOKS; Combat doesn't run in the lobby): Golden
		turns gold (Gild: dark and bright, GildCover see-through), then both wear a ForceField sheen in Sheen and an outline
		(Outline, OutlineTransparency); the copies grow by STAGE_COVER_GROW and STAGE_SHEEN_GROW
	]]
	--- @type { [string]: Lobby_WeaponLook }
	STAGE_WEAPON_LOOKS = {
		Shiny = {
			Sheen = Color3.fromRGB(170, 235, 255),
			Outline = Color3.fromRGB(225, 240, 255),
			OutlineTransparency = 0.35,
		},
		Golden = {
			Gild = { Color3.fromRGB(70, 42, 10), Color3.fromRGB(255, 200, 70) },
			GildCover = 0.3,
			Sheen = Color3.fromRGB(255, 215, 110),
			Outline = Color3.fromRGB(255, 205, 80),
			OutlineTransparency = 0.2,
		},
	},

	STAGE_COVER_GROW = 1.015,
	STAGE_SHEEN_GROW = 1.04,

	--- @type { string }
	STAGE_POSES = { "LobbyPose1", "LobbyPose2", "LobbyPose3", "LobbyPose4" },

	--%%%%%%%%%%%%%%%%%%%% Labels

	--[[
		Over each snail on the stage stands the studio's nameplate (the U_Nameplate BillboardGui in Assets/Lobby's
		PREFAB | Nameplate): its level, display name and @username, NAMEPLATE_SCALE times its design size in studs,
		NAMEPLATE_GAP studs over the snail's top without its weapon (the owner, 2026-11-24: names over the snails, not
		on the party cards)
	]]
	NAMEPLATE_NAME = "U_Nameplate",
	NAMEPLATE_SCALE = 2.75,
	NAMEPLATE_GAP = -0.9,

	--[[
		The party's other snails wear theirs this much smaller than the player's own: two sizes, the player's much bigger
		(the owner, 2026-11-24)
	]]
	NAMEPLATE_OTHER_SCALE = 0.55,

	--[[
		Over each free pod floats a "+" bubble (the U_InviteBubble BillboardGui in Assets/Lobby's PREFAB | InviteBubble),
		INVITE_HEIGHT studs over the pod's snail marker, that opens the party invite
	]]
	INVITE_NAME = "U_InviteBubble",
	INVITE_HEIGHT = 5,

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
