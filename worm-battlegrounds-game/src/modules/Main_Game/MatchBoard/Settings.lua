--- @class MatchBoard_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Places

	-- The place matches run in (this one, until matches get a place of their own), and the teleport screen
	MATCH_PLACE_ID = game.PlaceId,
	TELEPORT_GUI = "TeleportGui",

	-- The map that plays the lobby and its matches in one Studio server: matches start there instead of teleporting
	STUDIO_MAP = "Studio",

	--%%%%%%%%%%%%%%%%%%%% Public Rows

	-- A row starts this many seconds after its first player joins, or once VOTE_FRACTION of its players voted
	ROW_SECONDS = 30,
	VOTE_FRACTION = 2 / 3,

	-- The board's rows: one deathmatch at one of DEATHMATCH_SIZES, and TEAM_ROWS team matches from TEAM_OPTIONS
	--- @type { number }
	DEATHMATCH_SIZES = { 2, 4, 6, 8 },
	TEAM_ROWS = 2,

	--- @type { MatchBoard_RowOption }
	TEAM_OPTIONS = {
		{ Mode = "Duo", Size = 4 },
		{ Mode = "Duo", Size = 6 },
		{ Mode = "Duo", Size = 8 },
		{ Mode = "Trio", Size = 6 },
		{ Mode = "Quads", Size = 8 },
	},

	-- Worms in a team, by mode (custom Teams lobbies play in two teams)
	--- @type { [string]: number }
	TEAM_SIZES = { Deathmatch = 1, Duo = 2, Trio = 3, Quads = 4 },

	-- How each mode reads on the board
	--- @type { [string]: string }
	MODE_NAMES = {
		Deathmatch = "Deathmatch",
		Duo = "Duo team deathmatch",
		Trio = "Trio team deathmatch",
		Quads = "Quads team deathmatch",
		Teams = "Team deathmatch",
	},

	-- The bots' difficulty in public matches
	PUBLIC_DIFFICULTY = "Medium",

	--%%%%%%%%%%%%%%%%%%%% Maps

	-- Every arena: its name, the match sizes it's made for, and its picture (placeholder until it's drawn)
	--- @type { [string]: MatchBoard_MapRow }
	MAPS = {
		RockslideRidge = { Name = "Rockslide Ridge", Sizes = { 2, 4, 6 }, Thumbnail = "" },
		PicnicPlains = { Name = "Picnic Plains", Sizes = { 2, 4, 6 }, Thumbnail = "" },
		FluffyFallout = { Name = "Fluffy Fallout", Sizes = { 2, 4, 6 }, Thumbnail = "" },
		LakesideShowdown = { Name = "Lakeside Showdown", Sizes = { 2, 4, 6 }, Thumbnail = "" },
		MoltenSpires = { Name = "Molten Spires", Sizes = { 2, 4, 6 }, Thumbnail = "" },
		TheBigMashup = { Name = "The Big Mashup", Sizes = { 8 }, Thumbnail = "" },
		Desert = { Name = "Desert", Sizes = { 2, 4, 6 }, Thumbnail = "" },
	},

	--[[
		The maps rows and lobbies pick from: only those with a template in SAssets.Arenas. A size no map in the pool is
		made for plays on any map in it
	]]
	--- @type { string }
	MAP_POOL = { "PicnicPlains", "Desert" },

	--%%%%%%%%%%%%%%%%%%%% Solo

	-- The solo difficulties, in the order SoloSetup shows them
	--- @type { string }
	SOLO_DIFFICULTIES = { "Easy", "Medium", "Hard" },

	--%%%%%%%%%%%%%%%%%%%% Gui

	BOARD_GUI_NAME = "MatchBoard",
	MODES_GUI_NAME = "PlayModes",
	SOLO_GUI_NAME = "SoloSetup",
	CUSTOM_GUI_NAME = "CustomLobby",

	-- A picked difficulty's or map's slot fill, and an unpicked one's (the gui kit's selected blue and its Slot)
	SELECTED_COLOR = Color3.fromRGB(40, 140, 255),
	SELECTED_TRANSPARENCY = 0.2,
	TILE_COLOR = Color3.fromRGB(0, 0, 0),
	TILE_TRANSPARENCY = 0.7,
}

return _settings
