--- @class MatchBoard_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Places

	-- The teleport screen; the match place is the place loader config's MatchPlaceId, this experience's Arena
	TELEPORT_GUI = "TeleportGui",

	-- The map that plays the lobby and its matches in one Studio server: matches start there instead of teleporting
	STUDIO_MAP = "Studio",

	--%%%%%%%%%%%%%%%%%%%% Public Rows

	--[[
		The public rows, one card per mode, always on the board. Join seats the player (and their party) in the mode's
		filling match on every server (Matchmaking's frontier), or opens the next one on the card's map; the match's
		server holds its waiting room. Three cards, no Quads (the owner, 2026-11-24: "we want only 3 segments")
	]]
	--- @type { MatchBoard_RowOption }
	PUBLIC_ROWS = {
		{ Mode = "Deathmatch", Size = 4 },
		{ Mode = "Duo", Size = 4 },
		{ Mode = "Trio", Size = 6 },
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
		The mode icons that change with the board (art/ui_glyphs, white glyphs in the LobbyRework look, 2026-11-24; Quads
		keeps its art/modes one): each public card's by its mode, and PLAY SOLO's and the setup's title's by the match it
		sets up (Bots, Party, Local). LOCAL, CUSTOM, the custom lobby's title and the Random map card carry theirs in the
		gui
	]]
	--- @type { [string]: string }
	MODE_ICONS = {
		Deathmatch = "rbxassetid://88744460498201",
		Duo = "rbxassetid://76759738385570",
		Trio = "rbxassetid://126355291658126",
		Quads = "rbxassetid://137708705569595",
		Bots = "rbxassetid://119204758692964",
		Party = "rbxassetid://119204758692964",
		Local = "rbxassetid://86467359142321",
	},

	-- The bots' difficulty in public matches
	PUBLIC_DIFFICULTY = "Medium",

	--[[
		Every public card shows its mode's filling match on every server (Matchmaking's frontier), read this often, in
		seconds (the owner, 2026-11-24: "it updates every 3 seconds or so, 40/60, 20/50")
	]]
	CARD_REFRESH_SECONDS = 3,

	--[[
		A Join seats the group in the filling match, or opens the next one, at most JOIN_TRIES rounds (another lobby may
		fill or open one between the steps). A match a lobby opens starts SERVER_BOOT_SECONDS plus WAITING_SECONDS
		after, and stays in the store PENDING_SECONDS while its server boots. WAITING_SECONDS is Match's own, copied
		here since the lobby place doesn't load Match: change both together
	]]
	JOIN_TRIES = 3,
	SERVER_BOOT_SECONDS = 12,
	WAITING_SECONDS = 30,
	PENDING_SECONDS = 45,

	--[[
		A Join puts the teleport card up at once, JOIN_SEARCH_KICKER over JOIN_SEARCH_MESSAGE, whipping through the
		rotation's maps (the owner, 2026-11-24: nothing showed for a few seconds, so players pressed JOIN again). A group
		seated in a match another lobby just opened waits for its server: at most SERVER_WAIT_SECONDS, looking every
		SERVER_WAIT_POLL seconds, the card showing the match's map under JOIN_WAIT_MESSAGE
	]]
	JOIN_SEARCH_KICKER = "Public match",
	JOIN_SEARCH_MESSAGE = "Finding a match",
	SERVER_WAIT_SECONDS = 25,
	SERVER_WAIT_POLL = 0.5,
	JOIN_WAIT_MESSAGE = "Match found",

	-- The teleport card's line over a match's map, and how it says how many snails play
	DESTINATION_KICKER = "Heading to",
	DESTINATION_DETAIL = "%d snails",

	-- How long each public card keeps its map, the same on every server (the rotation), in seconds
	MAP_SECONDS = 30,

	-- A Join this many seconds after the cards moved on still plays the map the player's card showed, in seconds
	JOIN_GRACE = 2,

	-- How often the board checks whether its cards' timers reached another second, in seconds
	TIMER_TICK = 0.2,

	-- What a Join that couldn't reach the matches says
	JOIN_FAILED_MESSAGE = "Couldn't find a match. Try again!",

	--[[
		A JOIN pressed again within this many seconds sends nothing (the server takes 2 a second and warns past that: the
		owner, 2026-11-24, spamming JOIN)
	]]
	JOIN_PRESS_GAP = 1,

	--[[
		PLAY SOLO's icon and text are centred on the button as one group (the owner, 2026-11-24: "center the whole play
		icon and text"), the text this share of the icon's width after it
	]]
	SOLO_ICON_GAP = 0.25,

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
		Desert = { Name = "Desert", Sizes = { 2, 4, 6 }, Thumbnail = "rbxassetid://81138287783963", TileThumbnail = "rbxassetid://113826869502887" },
		MirageMesa = { Name = "Mirage Mesa", Sizes = { 2, 4, 6 }, Thumbnail = "rbxassetid://140014161821553", TileThumbnail = "rbxassetid://85483220004379" },
		VolcanoIsle = { Name = "Volcano Isle", Sizes = { 2, 4, 6 }, Thumbnail = "rbxassetid://110823072321769", TileThumbnail = "rbxassetid://72281204382629" },
		RollingPlains = { Name = "Rolling Plains", Sizes = { 2, 4 }, Thumbnail = "rbxassetid://92320287823767", TileThumbnail = "rbxassetid://80399475408535" },
		EchoCaverns = { Name = "Echo Caverns", Sizes = { 2, 4, 6, 8 }, Thumbnail = "rbxassetid://128031100933800", TileThumbnail = "rbxassetid://93769256053322" },

		-- The tutorial's own map, never in MAP_POOL. shortcut: Picnic Plains' picture until Training Meadow has its own uploaded
		TutorialMeadow = { Name = "Training Meadow", Sizes = { 2 }, Thumbnail = "rbxassetid://114380640476396", TileThumbnail = "" },
	},

	--[[
		The rotation: the maps the public rows and Solo vs bots pick from, each for the sizes its row says (only maps
		with a template in SAssets.Arenas). A size no map in the pool is made for plays on any map in it. Three maps
		only while the maps are tested (the owner, 2026-11-25: "we are keeping only 3 maps in game for now")
	]]
	--- @type { string }
	MAP_POOL = { "EchoCaverns", "Desert", "RollingPlains" },

	-- The maps a custom lobby can pick, in the order the custom window lists them: the rotation, then the custom-only maps
	--- @type { string }
	CUSTOM_MAP_POOL = {
		"EchoCaverns",
		"Desert",
		"RollingPlains",
	},

	--%%%%%%%%%%%%%%%%%%%% Solo And Party

	-- The bots' difficulties, in the order the setup panel shows them; a party can also play with "None" (no bots)
	--- @type { string }
	SOLO_DIFFICULTIES = { "Easy", "Medium", "Hard" },

	--[[
		PLAY SOLO's setup picks only the bots' difficulty (the owner, 2026-11-25: "select random map and also we only have
		difficulty choice... icons for easy medium and hard"): a card per difficulty with its glyph (art/ui_glyphs: a
		smile, a frown, a skull), the win reward and PLAY; the map is always Random. A party and local play keep the map list
	]]
	--- @type { [string]: string }
	DIFFICULTY_ICONS = {
		Easy = "rbxassetid://88105304367362",
		Medium = "rbxassetid://94010149349376",
		Hard = "rbxassetid://103240032909077",
	},

	--[[
		Each difficulty's colour, played subtly on its card (the owner, 2026-11-25: "play with colors for difficulties
		subtly"): a faint wash rising from the card's bottom, its glyph tinted DIFFICULTY_GLYPH_TINT of the way from
		white, and the picked card's outline and name in it
	]]
	--- @type { [string]: Color3 }
	DIFFICULTY_COLORS = {
		Easy = Color3.fromRGB(110, 220, 110),
		Medium = Color3.fromRGB(255, 190, 70),
		Hard = Color3.fromRGB(255, 85, 80),
	},
	DIFFICULTY_GLYPH_TINT = 0.45,

	-- What the setup panel says a match pays: solo (beside the diamonds a win pays), a party with bots, a party alone
	--- @type { [string]: string }
	REWARD_TEXT = {
		Solo = "Win reward",
		Party = "Pays diamonds like a public match",
		PartyNoBots = "Pays half the diamonds of a public match",
		Local = "No rewards",
	},

	-- The diamonds a solo win pays by the bots' difficulty, shown in the setup (MatchRewards' SOLO_DIAMONDS, which pays them)
	--- @type { [string]: number }
	SOLO_WIN_DIAMONDS = { Easy = 20, Medium = 30, Hard = 40 },

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

	-- PLAY WITH FRIENDS, which the board's gear tile opens: LOCAL and CUSTOM (2026-11-25)
	FRIENDS_GUI_NAME = "FriendsMatch",

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
