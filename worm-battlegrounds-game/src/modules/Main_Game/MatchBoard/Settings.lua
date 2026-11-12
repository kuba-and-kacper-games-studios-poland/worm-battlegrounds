--- @class MatchBoard_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Places

	--[[
		The match place (Arena), where matches run in reserved servers (the same id as MATCH_PLACE_ID in the place
		loader's config), and the teleport screen
	]]
	MATCH_PLACE_ID = 118265066788984,
	TELEPORT_GUI = "TeleportGui",

	-- The map that plays the lobby and its matches in one Studio server: matches start there instead of teleporting
	STUDIO_MAP = "Studio",

	--%%%%%%%%%%%%%%%%%%%% Public Rows

	--[[
		Every public row counts down this many seconds, always: at 0 it starts with whoever joined (or nobody) and a
		fresh row on another map takes its place; it also starts once VOTE_FRACTION of its players voted, or when full
	]]
	ROW_SECONDS = 30,
	VOTE_FRACTION = 2 / 3,

	-- The public rows, one per mode, always on the board: a row that starts is replaced by a fresh one of its mode
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

	-- How each mode reads on the board's cards and in the waiting room
	--- @type { [string]: string }
	MODE_NAMES = {
		Deathmatch = "Deathmatch",
		Duo = "Duo",
		Trio = "Trio",
		Quads = "Quads",
		Teams = "Teams",
	},

	-- The bots' difficulty in public matches
	PUBLIC_DIFFICULTY = "Medium",

	--%%%%%%%%%%%%%%%%%%%% Maps

	--[[
		Every arena: its name, the match sizes it's made for, and its picture (a landscape photo of the map, the game
		home's assets/ui/map_thumbnails; empty until the map is built)
	]]
	--- @type { [string]: MatchBoard_MapRow }
	MAPS = {
		RockslideRidge = { Name = "Rockslide Ridge", Sizes = { 2, 4, 6 }, Thumbnail = "rbxassetid://123838177297909" },
		PicnicPlains = { Name = "Picnic Plains", Sizes = { 2, 4, 6 }, Thumbnail = "rbxassetid://114380640476396" },
		FluffyFallout = { Name = "Fluffy Fallout", Sizes = { 2, 4, 6 }, Thumbnail = "" },
		LakesideShowdown = { Name = "Lakeside Showdown", Sizes = { 2, 4, 6 }, Thumbnail = "" },
		MoltenSpires = { Name = "Molten Spires", Sizes = { 2, 4, 6 }, Thumbnail = "" },
		TheBigMashup = { Name = "The Big Mashup", Sizes = { 8 }, Thumbnail = "" },
		Desert = { Name = "Desert", Sizes = { 2, 4, 6 }, Thumbnail = "rbxassetid://140014161821553" },
		VolcanoIsle = { Name = "Volcano Isle", Sizes = { 2, 4, 6 }, Thumbnail = "rbxassetid://110823072321769" },
	},

	--[[
		The maps rows and lobbies pick from: only those with a template in SAssets.Arenas. A size no map in the pool is
		made for plays on any map in it
	]]
	--- @type { string }
	MAP_POOL = { "PicnicPlains", "Desert", "RockslideRidge", "VolcanoIsle" },

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
	},

	-- The coins a solo win pays by the bots' difficulty, shown in the setup (MatchRewards' SOLO_COINS, which pays them)
	--- @type { [string]: number }
	SOLO_WIN_COINS = { Easy = 20, Medium = 35, Hard = 60 },

	-- A party match with bots adds this many bots per party member, up to PARTY_MAX_SIZE snails in all
	PARTY_BOTS_PER_PLAYER = 1,
	PARTY_MAX_SIZE = 8,

	--%%%%%%%%%%%%%%%%%%%% Custom

	-- The bots a custom lobby can fill its empty places with, in the order its Bots row shows them; Nightmare is only here
	--- @type { string }
	CUSTOM_DIFFICULTIES = { "None", "Easy", "Medium", "Hard", "Nightmare" },

	--%%%%%%%%%%%%%%%%%%%% Gui

	BOARD_GUI_NAME = "MatchBoard",
	CUSTOM_GUI_NAME = "CustomLobby",

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
