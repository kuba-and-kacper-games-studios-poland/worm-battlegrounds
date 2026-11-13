--- @class Atmosphere_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Moods

	--[[
		Each place's mood: the lobby's (LOBBY_PROFILE) and each map's, by its MapId. Preset is a lighting preset in the
		place (the Lighting Manager's, Lighting.Presets). Ambient fills an area with an Ambient_ prefab's particles: the
		share of the area's height it takes, from Bottom to Top, and RateScale times the prefab's rate. Surface plays an
		effect on a random spot of a liquid's surface, every Every seconds (the fewest and the most), tinted by the
		liquid's colour when Tint is set. Ceiling trickles an effect from the underside of the rock over the map. Music
		is the SoundsList track that plays there (each carries the place's own ambience), SuddenDeathMusic the one that
		takes over while a match's sudden death runs. WindColor paints the wind's streaks on a map and WindSound is its
		wind's loop (the lobby has no wind)
	]]
	--- @type { [string]: Atmosphere_Profile }
	PROFILES = {
		Lobby = {
			Preset = "Lobby",
			Music = "BGM",
			Ambient = {
				{ Effect = "Ambient_Motes", Bottom = 0, Top = 1, RateScale = 1 },
			},
			Surface = {},
		},
		PicnicPlains = {
			Preset = "Plains",
			Music = "Music_PicnicPlains",
			SuddenDeathMusic = "Music_PicnicPlains_SuddenDeath",
			WindColor = Color3.fromRGB(255, 255, 255),
			WindSound = "Wind_OpenAir",
			Ambient = {
				{ Effect = "Ambient_Pollen", Bottom = 0.1, Top = 1, RateScale = 1 },
				{ Effect = "Ambient_Leaf", Bottom = 0.3, Top = 1, RateScale = 1 },
			},
			Surface = {
				{ Liquid = "Water", Effect = "Glint", Every = { 0.15, 0.4 }, Tint = false },
			},
		},

		-- The tutorial's map: Picnic Plains' meadow mood and music
		TutorialMeadow = {
			Preset = "Plains",
			Music = "Music_PicnicPlains",
			SuddenDeathMusic = "Music_PicnicPlains_SuddenDeath",
			WindColor = Color3.fromRGB(255, 255, 255),
			WindSound = "Wind_OpenAir",
			Ambient = {
				{ Effect = "Ambient_Pollen", Bottom = 0.1, Top = 1, RateScale = 1 },
				{ Effect = "Ambient_Leaf", Bottom = 0.3, Top = 1, RateScale = 1 },
			},
			Surface = {
				{ Liquid = "Water", Effect = "Glint", Every = { 0.15, 0.4 }, Tint = false },
			},
		},
		Desert = {
			Preset = "Desert",
			Music = "Music_Desert",
			SuddenDeathMusic = "Music_Desert_SuddenDeath",
			WindColor = Color3.fromRGB(255, 240, 214),
			WindSound = "Wind_Desert",
			Ambient = {
				{ Effect = "Ambient_Sand", Bottom = 0.05, Top = 0.6, RateScale = 1 },
			},
			Surface = {
				{ Liquid = "Lava", Effect = "Lava_Bubble", Every = { 0.6, 1.6 }, Tint = false },
				{ Liquid = "Lava", Effect = "Ember", Every = { 0.25, 0.7 }, Tint = false },
				{ Liquid = "Water", Effect = "Glint", Every = { 0.8, 2 }, Tint = false },
			},
		},
		RockslideRidge = {
			Preset = "Cave",
			Music = "Music_RockslideRidge",
			SuddenDeathMusic = "Music_RockslideRidge_SuddenDeath",
			WindColor = Color3.fromRGB(228, 222, 212),
			WindSound = "Wind_Howl",
			Ambient = {
				{ Effect = "Ambient_CaveDust", Bottom = 0, Top = 0.85, RateScale = 1 },
			},
			Surface = {
				{ Liquid = "Water", Effect = "Ripple", Every = { 1.5, 4 }, Tint = true },
			},
			Ceiling = { Effect = "Grit", Every = { 3, 7 } },
		},
		VolcanoIsle = {
			Preset = "Volcano",
			Music = "Music_VolcanoIsle",
			SuddenDeathMusic = "Music_VolcanoIsle_SuddenDeath",
			WindColor = Color3.fromRGB(235, 214, 200),
			WindSound = "Wind_OpenAir",
			Ambient = {
				{ Effect = "Ambient_CaveDust", Bottom = 0.2, Top = 1, RateScale = 0.6 },
			},
			Surface = {
				{ Liquid = "Lava", Effect = "Lava_Bubble", Every = { 0.4, 1.2 }, Tint = false },
				{ Liquid = "Lava", Effect = "Ember", Every = { 0.2, 0.6 }, Tint = false },
			},
		},
	},

	-- The profile outside matches
	LOBBY_PROFILE = "Lobby",

	--[[
		The place maps (ume's place loader MapId) with no matches and with nothing but a match; the Studio map has both,
		and the InMatch Player attribute says which half a player is in
	]]
	LOBBY_MAP = "Lobby",
	MATCH_MAP = "Match",

	-- How the lighting moves from one mood to the next (the first mood after joining is set at once)
	MOOD_TWEENINFO = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),

	-- Seconds one mood's music crossfades into the next's, and into its sudden-death version
	MUSIC_FADE = 2.5,

	--%%%%%%%%%%%%%%%%%%%% Sudden Death

	--[[
		While sudden death runs, the lighting deepens a touch on top of the map's mood: the brightness times
		SUDDEN_DEATH_BRIGHTNESS, the contrast and the atmosphere's density raised, the tint warmed (multiplied), as a
		lighting layer at SUDDEN_DEATH_WEIGHT
	]]
	SUDDEN_DEATH_BRIGHTNESS = 0.88,
	SUDDEN_DEATH_CONTRAST = 0.06,
	SUDDEN_DEATH_DENSITY = 0.05,
	SUDDEN_DEATH_TINT = Color3.fromRGB(255, 232, 214),
	SUDDEN_DEATH_WEIGHT = 5,
	SUDDEN_DEATH_ID = "SuddenDeath",
	SUDDEN_DEATH_TWEENINFO = TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),

	--%%%%%%%%%%%%%%%%%%%% Ambient

	-- How far in front of the map's front face its ambient particles reach, toward the camera
	AMBIENT_FRONT = 8,

	-- The lobby's ambient area: a box this far in front of the stage camera, this big
	LOBBY_AREA_DISTANCE = 30,
	LOBBY_AREA_SIZE = Vector3.new(70, 34, 40),

	-- The sideways pull on drifting particles per point of the match's wind, in studs per second squared
	WIND_PUSH = 0.35,

	-- The lobby stage's clouds drift sideways and back by up to CLOUD_DRIFT studs, each over a time in CLOUD_DRIFT_SECONDS
	CLOUD_DRIFT = 3,

	--- @type { number }
	CLOUD_DRIFT_SECONDS = { 9, 14 },

	--[[
		A cave's grit trickles from rock in the bounds' top CEILING_SHARE, found by sampling every CEILING_STEP studs
		down from the top
	]]
	CEILING_SHARE = 0.4,
	CEILING_STEP = 1,

	--%%%%%%%%%%%%%%%%%%%% Wind

	--[[
		The wind shows as WIND_EFFECT's streaks blowing across the camera's view, between WIND_DEPTH studs in front of
		the map's front face: WIND_RATE a second at the strongest wind (Match's WIND_MAX), fewer as it drops, none in
		still air. Each is WIND_SIZE_SCALE times the prefab's size, WIND_OPACITY times as opaque, and leaves within
		WIND_SPREAD degrees of level
	]]
	WIND_EFFECT = "Wind_Streak",

	--- @type { number }
	WIND_DEPTH = { 1, 12 },

	WIND_RATE = 18,
	WIND_SIZE_SCALE = 1,
	WIND_OPACITY = 0.6,
	WIND_SPREAD = 2,

	-- The streaks' speed, as a share of the prefab's, in the weakest wind and the strongest
	--- @type { number }
	WIND_SPEED_SHARE = { 0.45, 1 },

	-- The streaks' area reaches this share of the view's width further on the side the wind comes from, so they blow in
	WIND_UPWIND_SHARE = 0.5,

	-- The wind breathes in gusts: its streaks' rate swings by this share, over this many seconds
	WIND_GUST_SHARE = 0.35,
	WIND_GUST_SECONDS = 4,

	--[[
		A map's WindSound loops in the SFX group, from WIND_SOUND_VOLUME's first volume in the weakest wind to its second
		in the strongest (silent in still air), easing between them by WIND_SOUND_TWEENINFO
	]]
	--- @type { number }
	WIND_SOUND_VOLUME = { 0.1, 0.7 },

	WIND_SOUND_TWEENINFO = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),

	--[[
		At each gust's peak, in wind of WIND_GUST_SOUND_FROM of the strongest or more, WIND_GUST_SOUND whooshes (more
		likely the stronger the wind), between WIND_GUST_SOUND_VOLUME's volumes
	]]
	WIND_GUST_SOUND = "Wind_Gust",
	WIND_GUST_SOUND_FROM = 0.4,

	--[[
		When the wind changes (once every snail played on it), each streak emitter bursts WIND_CHANGE_BURST streaks at the
		strongest wind, fewer as it drops but at least WIND_CHANGE_BURST_MIN, and the gust whooshes at its loudest
	]]
	WIND_CHANGE_BURST = 40,
	WIND_CHANGE_BURST_MIN = 8,

	--- @type { number }
	WIND_GUST_SOUND_VOLUME = { 0.15, 0.5 },

	--%%%%%%%%%%%%%%%%%%%% Reactions

	-- The effect a blast plays from each kind of prop part, by the part's name
	--- @type { [string]: string }
	PROP_EFFECTS = {
		Leaves = "Leaves",
		Needles = "Leaves",
		Bush = "Leaves",
		Cactus = "Leaves",
		Twig = "Leaves",
		Rock = "Dust",
	},

	-- A blast reaching this many of a prop's parts plays its full burst; fewer, a smaller one (down to half)
	PROP_PARTS_FULL = 6,

	-- The share of the wind's pull that bends a prop's burst
	PROP_WIND_SHARE = 0.5,

	-- The effects a fall into each liquid plays where it goes in; the first, the splash, takes a liquid's own colour
	--- @type { [string]: { string } }
	SPLASH_EFFECTS = {
		Water = { "Splash_Water" },
		Lava = { "Splash_Lava", "Steam" },
	},

	-- How big a splash each falling thing makes (Splash_Water's own size is 1)
	--- @type { [string]: number }
	SPLASH_SCALES = {
		Chip = 0.35,
		Shot = 0.5,
		Snail = 0.7,
		Prop = 0.9,
	},

	-- A fallen chunk of ground splashes and kicks up dust by its width: width / LANDING_WIDTH, within LANDING_SCALES
	LANDING_WIDTH = 3,

	--- @type { number }
	LANDING_SCALES = { 0.6, 2 },

	-- A chunk falling less than this many studs lands without dust
	LANDING_MIN_DROP = 2,

	-- The dust a chunk lands with, in the chunk's colour lightened by this share
	LANDING_EFFECT = "Dust",
	LANDING_LIGHTEN = 0.55,

	-- One thing splashes at most once in this many seconds
	SPLASH_COOLDOWN = 0.6,

	--[[
		Water whose colour isn't Arena's own (a map's Arena_LiquidColor) tints its splashes and ripples with its colour,
		lightened by this share
	]]
	LIQUID_TINT_LIGHTEN = 0.25,

	--[[
		New obsidian lets off OBSIDIAN_EFFECT at most every OBSIDIAN_STEAM_GAP seconds, and its hiss at most every
		OBSIDIAN_SOUND_GAP, and not in the first OBSIDIAN_SETTLE seconds of a map
	]]
	OBSIDIAN_EFFECT = "Steam",
	OBSIDIAN_STEAM_GAP = 0.25,
	OBSIDIAN_SOUND_GAP = 1.2,
	OBSIDIAN_SETTLE = 2,

	-- Small things (chips) splash at most this often between them, so a blast over water doesn't flood it
	SMALL_SPLASH_GAP = 0.12,

	--%%%%%%%%%%%%%%%%%%%% Effects

	-- How long a played effect's copy stays after its last particle, in seconds
	CLEANUP_MARGIN = 0.5,

	-- How long the liquid's shape is reused before it's read again, in seconds (it steps at 8 fps)
	LIQUID_REFRESH = 0.1,
}

return _settings
