--- @class MatchBoard_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Places

	-- The teleport screen; the match place is the place loader config's MatchPlaceId, this experience's Arena
	TELEPORT_GUI = "TeleportGui",

	-- The map that plays the lobby and its matches in one Studio server: matches start there instead of teleporting
	STUDIO_MAP = "Studio",

	--%%%%%%%%%%%%%%%%%%%% Public Rows

	--[[
		The public rows, one card per mode, always on the board. Join seats the player (and their party) in the fullest
		open match of that mode on any server that has room for them all, on one team where it can (Matchmaking), or
		opens a new one on the card's map; the match's server holds its waiting room
	]]
	--- @type { MatchBoard_RowOption }
	PUBLIC_ROWS = {
		{ Mode = "Deathmatch", Size = 4 },
		{ Mode = "Duo", Size = 4 },
		{ Mode = "Trio", Size = 6 },
		{ Mode = "Quads", Size = 8 },
	},

	-- Snails in a team, by mode (custom Teams lobbies play in two teams)
	--- @type { [string]: number }
	TEAM_SIZES = { Deathmatch = 1, Duo = 2, Trio = 3, Quads = 4 },

	-- How each mode reads on the board's cards
	--- @type { [string]: string }
	MODE_NAMES = {
		Deathmatch = "Deathmatch",
		Duo = "Duo",
		Trio = "Trio",
		Quads = "Quads",
		Teams = "Teams",
	},

	--[[
		The mode icons (art/modes, drawn in the weapon icons' look) that change with the board: each public card's by its
		mode, and SOLO VS BOTS's and the setup's title's by the match it sets up (Bots, Party, Local). LOCAL, CUSTOM, the
		custom lobby's title and the Random map card carry theirs in the gui
	]]
	--- @type { [string]: string }
	MODE_ICONS = {
		Deathmatch = "rbxassetid://101410705091276",
		Duo = "rbxassetid://130275829062405",
		Trio = "rbxassetid://130310099327594",
		Quads = "rbxassetid://137708705569595",
		Bots = "rbxassetid://70468282427332",
		Party = "rbxassetid://120087464798832",
		Local = "rbxassetid://126362872028871",
	},

	-- The bots' difficulty in public matches
	PUBLIC_DIFFICULTY = "Medium",

	-- How long each public card keeps its map, the same on every server (the rotation), in seconds
	MAP_SECONDS = 30,

	-- A Join this many seconds after the cards moved on still plays the map the player's card showed, in seconds
	JOIN_GRACE = 2,

	-- How often the board checks whether its cards' timers reached another second, in seconds
	TIMER_TICK = 0.2,

	-- What a Join that couldn't reach the matches says
	JOIN_FAILED_MESSAGE = "Couldn't find a match. Try again!",

	--%%%%%%%%%%%%%%%%%%%% Maps

	--[[
		Every arena: its name, the match sizes it's made for, and its pictures, landscape photos of the map (the game
		home's assets/ui/map_thumbnails; empty until the map is built): Thumbnail cut to the lobby card's shape,
		TileThumbnail to the custom lobby's map tile
	]]
	--- @type { [string]: MatchBoard_MapRow }
	MAPS = {
		RockslideRidge = { Name = "Rockslide Ridge", Sizes = { 2, 4, 6 }, Thumbnail = "rbxassetid://101364558522354", TileThumbnail = "rbxassetid://76070824844534" },
		PicnicPlains = { Name = "Picnic Plains", Sizes = { 6, 8 }, Thumbnail = "rbxassetid://114380640476396", TileThumbnail = "rbxassetid://70528973496836" },
		FluffyFallout = { Name = "Fluffy Fallout", Sizes = { 2, 4, 6 }, Thumbnail = "rbxassetid://70830416217312", TileThumbnail = "rbxassetid://103570575490285" },
		LakesideShowdown = { Name = "Lakeside Showdown", Sizes = { 2, 4, 6 }, Thumbnail = "rbxassetid://73998072466850", TileThumbnail = "rbxassetid://106543031741291" },
		MoltenSpires = { Name = "Molten Spires", Sizes = { 2, 4, 6 }, Thumbnail = "", TileThumbnail = "" },
		TheBigMashup = { Name = "The Big Mashup", Sizes = { 8 }, Thumbnail = "", TileThumbnail = "" },
		Desert = { Name = "Desert", Sizes = { 2, 4, 6 }, Thumbnail = "rbxassetid://83756913609980", TileThumbnail = "rbxassetid://95484779686713" },
		MirageMesa = { Name = "Mirage Mesa", Sizes = { 2, 4, 6 }, Thumbnail = "rbxassetid://140014161821553", TileThumbnail = "rbxassetid://85483220004379" },
		VolcanoIsle = { Name = "Volcano Isle", Sizes = { 2, 4, 6 }, Thumbnail = "rbxassetid://110823072321769", TileThumbnail = "rbxassetid://72281204382629" },
		RollingPlains = { Name = "Rolling Plains", Sizes = { 2, 4 }, Thumbnail = "rbxassetid://118659936926806", TileThumbnail = "rbxassetid://119350227368156" },
		EchoCaverns = { Name = "Echo Caverns", Sizes = { 2, 4, 6, 8 }, Thumbnail = "rbxassetid://97183016065357", TileThumbnail = "rbxassetid://113242205351682" },

		-- The tutorial's own map, never in MAP_POOL. shortcut: Picnic Plains' picture until Training Meadow has its own uploaded
		TutorialMeadow = { Name = "Training Meadow", Sizes = { 2 }, Thumbnail = "rbxassetid://114380640476396", TileThumbnail = "" },
	},

	--[[
		The rotation: the maps the public rows and Solo vs bots pick from, each for the sizes its row says (only maps
		with a template in SAssets.Arenas). A size no map in the pool is made for plays on any map in it
	]]
	--- @type { string }
	MAP_POOL = { "PicnicPlains", "Desert", "FluffyFallout", "RollingPlains", "EchoCaverns", "VolcanoIsle" },

	-- The maps a custom lobby can pick, in the order the custom window lists them: the rotation, then the custom-only maps
	--- @type { string }
	CUSTOM_MAP_POOL = {
		"PicnicPlains",
		"Desert",
		"FluffyFallout",
		"RollingPlains",
		"EchoCaverns",
		"VolcanoIsle",
		"MirageMesa",
		"LakesideShowdown",
		"RockslideRidge",
	},

	--%%%%%%%%%%%%%%%%%%%% Solo And Party

	-- The bots' difficulties, in the order the setup panel shows them; a party can also play with "None" (no bots)
	--- @type { string }
	SOLO_DIFFICULTIES = { "Easy", "Medium", "Hard" },

	-- What the setup panel says a match pays: solo (beside the coins a win pays), a party with bots, a party alone
	--- @type { [string]: string }
	REWARD_TEXT = {
		Solo = "Win reward",
		Party = "Pays coins like a public match",
		PartyNoBots = "Pays half the coins of a public match",
		Local = "No rewards",
	},

	-- The coins a solo win pays by the bots' difficulty, shown in the setup (MatchRewards' SOLO_COINS, which pays them)
	--- @type { [string]: number }
	SOLO_WIN_COINS = { Easy = 20, Medium = 35, Hard = 60 },

	-- A party match with bots adds this many bots per party member, up to PARTY_MAX_SIZE snails in all
	PARTY_BOTS_PER_PLAYER = 1,
	PARTY_MAX_SIZE = 8,

	--%%%%%%%%%%%%%%%%%%%% Local

	--[[
		Local play (the owner, 2026-11-17): friends on one screen taking turns with one controller passed round, the
		host's screen playing every local snail; how many players it starts with and takes at most, and what each
		guest's snail is called ("Player 2")
	]]
	LOCAL_PLAYERS = 2,
	LOCAL_MAX_PLAYERS = 8,
	LOCAL_GUEST_NAME = "Player %d",

	--%%%%%%%%%%%%%%%%%%%% Custom

	-- The bots a custom lobby can fill its empty places with, in the order its Bots row shows them; Nightmare is only here
	--- @type { string }
	CUSTOM_DIFFICULTIES = { "None", "Easy", "Medium", "Hard", "Nightmare" },

	-- What Start says in a custom lobby with only its owner in it and no bots
	CUSTOM_ALONE_MESSAGE = "You can't start a custom lobby by yourself. Invite a player or turn bots on!",

	-- A custom lobby's free place in its member list (one per place up to its size): the name line, faded this much
	CUSTOM_OPEN_SLOT_TEXT = "Open slot",
	CUSTOM_OPEN_SLOT_TRANSPARENCY = 0.5,

	--%%%%%%%%%%%%%%%%%%%% Gui

	BOARD_GUI_NAME = "MatchBoard",
	CUSTOM_GUI_NAME = "CustomLobby",

	-- The solo, party and local setup: a WidgetManager widget like the custom lobby's window, for its blur and dim
	SETUP_GUI_NAME = "MatchSetup",

	-- A party member's Join, Play and Custom buttons while their leader picks the match: the face, its outline, the text
	LOCKED_MAIN_COLOR = Color3.fromRGB(70, 70, 80),
	LOCKED_STROKE_COLOR = Color3.fromRGB(130, 130, 130),
	LOCKED_TEXT_COLOR = Color3.fromRGB(153, 153, 153),

	--%%%%%%%%%%%%%%%%%%%% Motion

	--[[
		When the setup panel or the waiting room takes the board's place, its lobby rows and buttons slide down off the
		screen (this far past the bottom edge, as a share of the screen's height), and back up after
	]]
	PLAY_SLIDE_MARGIN = 0.05,
	PLAY_OUT_TWEENINFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	PLAY_IN_TWEENINFO = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

return _settings
