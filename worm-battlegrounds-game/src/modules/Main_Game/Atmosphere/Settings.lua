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
		wind's loop (the lobby has no wind). Sky gives a map a sky of its own over its preset's (Sky properties: the six
		faces from art/map_skies, celestial bodies off); a map without one shows its preset's
	]]
	--- @type { [string]: Atmosphere_Profile }
	PROFILES = {

		--[[
			The lobby's Parallax rows are drawn only on the loading card (Transition's lobby scene): the lobby itself is a
			3D stage with no backdrop layers
		]]
		Lobby = {
			Preset = "Lobby",
			Parallax = {

				--[[ Far snowy brick peaks over green foothills ]]

				{ Image = "rbxassetid://138969257928643", Depth = 1100, X = -750, Bottom = -8, Width = 500, Height = 218 },
				{ Image = "rbxassetid://111750536991328", Depth = 1100, X = -250, Bottom = -8, Width = 500, Height = 218 },
				{ Image = "rbxassetid://82666766422926", Depth = 1100, X = 250, Bottom = -8, Width = 500, Height = 218 },
				{ Image = "rbxassetid://82800576469011", Depth = 1100, X = 750, Bottom = -8, Width = 500, Height = 218 },
				{ Color = Color3.fromRGB(144, 189, 168), Depth = 1100.5, X = 0, Bottom = -345, Width = 2000, Height = 346 },

				--[[ Clouds (Rolling Plains' pictures) ]]

				{ Image = "rbxassetid://129166667994953", Depth = 700, X = -520, Bottom = 116, Width = 257.6, Height = 128.8 },
				{ Image = "rbxassetid://86974442104926", Depth = 700, X = 120, Bottom = 166, Width = 179.2, Height = 89.6 },
				{ Image = "rbxassetid://85010433092572", Depth = 700, X = 560, Bottom = 124, Width = 235.2, Height = 117.6 },
				{ Image = "rbxassetid://120459724898873", Depth = 700, X = -60, Bottom = 221, Width = 134.4, Height = 67.2 },

				--[[ Near brick meadow with oaks and pines ]]

				{ Image = "rbxassetid://103337111307035", Depth = 350, X = -262.5, Bottom = -5, Width = 525, Height = 81 },
				{ Image = "rbxassetid://117186475164441", Depth = 350, X = 262.5, Bottom = -5, Width = 525, Height = 81 },
				{ Color = Color3.fromRGB(92, 156, 113), Depth = 350.5, X = 0, Bottom = -145, Width = 1050, Height = 147 },
			},
			Music = "BGM",
			Ambient = {
				{ Effect = "Ambient_Motes", Bottom = 0, Top = 1, RateScale = 1 },
			},
			Surface = {},
		},
		PicnicPlains = {
			Preset = "Plains",
			Sky = {
				SkyboxFt = "rbxassetid://126464635735668",
				SkyboxBk = "rbxassetid://121337561639918",
				SkyboxLf = "rbxassetid://117572288895021",
				SkyboxRt = "rbxassetid://105602696805183",
				SkyboxUp = "rbxassetid://137807361860350",
				SkyboxDn = "rbxassetid://74008396460569",
				CelestialBodiesShown = false,
			},
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

		-- shortcut: Picnic Plains' mood until the lake gets its own (its own music since 2026-11-16)
		LakesideShowdown = {
			Preset = "Plains",
			Music = "Music_LakesideShowdown",
			SuddenDeathMusic = "Music_LakesideShowdown_SuddenDeath",
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

		--[[
			shortcut: Picnic Plains' mood until Rolling Plains gets its own (its own music since 2026-11-16); its own
			parallax layers over Picnic Plains' gradient sky since 2026-11-25
		]]
		RollingPlains = {
			Preset = "Plains",
			Sky = {
				SkyboxFt = "rbxassetid://99363908139132",
				SkyboxBk = "rbxassetid://137313082002092",
				SkyboxLf = "rbxassetid://94095323195070",
				SkyboxRt = "rbxassetid://130006245012592",
				SkyboxUp = "rbxassetid://103458071719063",
				SkyboxDn = "rbxassetid://77273756312382",
				CelestialBodiesShown = false,
			},
			Parallax = {

				--[[ Far hazy islands; both fills are one sea blue ]]

				{ Image = "rbxassetid://90492886631693", Depth = 1100, X = -750, Bottom = -8, Width = 500, Height = 198 },
				{ Image = "rbxassetid://97779160747848", Depth = 1100, X = -250, Bottom = -8, Width = 500, Height = 198 },
				{ Image = "rbxassetid://126654422829519", Depth = 1100, X = 250, Bottom = -8, Width = 500, Height = 198 },
				{ Image = "rbxassetid://118309025375247", Depth = 1100, X = 750, Bottom = -8, Width = 500, Height = 198 },
				{ Color = Color3.fromRGB(123, 180, 233), Depth = 1100.5, X = 0, Bottom = -345, Width = 2000, Height = 369 },

				--[[ Clouds ]]

				{ Image = "rbxassetid://129166667994953", Depth = 700, X = -520, Bottom = 116, Width = 257.6, Height = 128.8 },
				{ Image = "rbxassetid://86974442104926", Depth = 700, X = 120, Bottom = 166, Width = 179.2, Height = 89.6 },
				{ Image = "rbxassetid://85010433092572", Depth = 700, X = 560, Bottom = 124, Width = 235.2, Height = 117.6 },
				{ Image = "rbxassetid://120459724898873", Depth = 700, X = -60, Bottom = 221, Width = 134.4, Height = 67.2 },

				--[[ Near grassy islands and trees ]]

				{ Image = "rbxassetid://85231310851686", Depth = 350, X = -262.5, Bottom = -5, Width = 525, Height = 81 },
				{ Image = "rbxassetid://106383223101696", Depth = 350, X = 262.5, Bottom = -5, Width = 525, Height = 81 },
				{ Color = Color3.fromRGB(123, 180, 233), Depth = 350.5, X = 0, Bottom = -145, Width = 1050, Height = 147 },
			},
			Music = "Music_RollingPlains",
			SuddenDeathMusic = "Music_RollingPlains_SuddenDeath",
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
			Sky = {
				SkyboxFt = "rbxassetid://71270015180658",
				SkyboxBk = "rbxassetid://98208496302416",
				SkyboxLf = "rbxassetid://98114376317689",
				SkyboxRt = "rbxassetid://126438811843569",
				SkyboxUp = "rbxassetid://76137748327422",
				SkyboxDn = "rbxassetid://135538962182732",
				CelestialBodiesShown = false,
			},
			Parallax = {

				--[[ Far mesas ]]

				{ Image = "rbxassetid://130661378778864", Depth = 1100, X = -750, Bottom = 0, Width = 500, Height = 148 },
				{ Image = "rbxassetid://93069687422859", Depth = 1100, X = -250, Bottom = 0, Width = 500, Height = 148 },
				{ Image = "rbxassetid://98922529645627", Depth = 1100, X = 250, Bottom = 0, Width = 500, Height = 148 },
				{ Image = "rbxassetid://110765217904489", Depth = 1100, X = 750, Bottom = 0, Width = 500, Height = 148 },
				{ Color = Color3.fromRGB(250, 209, 162), Depth = 1100.5, X = 0, Bottom = -345, Width = 2000, Height = 354 },

				--[[ Clouds ]]

				{ Image = "rbxassetid://117350518482573", Depth = 700, X = -460, Bottom = 124, Width = 257.6, Height = 128.8 },
				{ Image = "rbxassetid://108381771125782", Depth = 700, X = 40, Bottom = 174, Width = 179.2, Height = 89.6 },
				{ Image = "rbxassetid://139012446744357", Depth = 700, X = 500, Bottom = 136, Width = 235.2, Height = 117.6 },
				{ Image = "rbxassetid://95169402656903", Depth = 700, X = -120, Bottom = 232, Width = 134.4, Height = 67.2 },

				--[[ Near dunes ]]

				{ Image = "rbxassetid://92808363681888", Depth = 350, X = -262.5, Bottom = 3, Width = 525, Height = 66 },
				{ Image = "rbxassetid://138039729329328", Depth = 350, X = 262.5, Bottom = 3, Width = 525, Height = 66 },
				{ Color = Color3.fromRGB(252, 194, 132), Depth = 350.5, X = 0, Bottom = -145, Width = 1050, Height = 155 },
			},
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

		-- The Desert until 2026-11-15, renamed when a new map took its name: the Desert's mood and music
		MirageMesa = {
			Preset = "Desert",
			Music = "Music_MirageMesa",
			SuddenDeathMusic = "Music_MirageMesa_SuddenDeath",
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

		-- shortcut: Picnic Plains' sky mood until Fluffy Fallout gets its own (its own music since 2026-11-16)
		FluffyFallout = {
			Preset = "Plains",
			Music = "Music_FluffyFallout",
			SuddenDeathMusic = "Music_FluffyFallout_SuddenDeath",
			WindColor = Color3.fromRGB(255, 255, 255),
			WindSound = "Wind_OpenAir",
			Ambient = {
				{ Effect = "Ambient_Pollen", Bottom = 0.1, Top = 1, RateScale = 1 },
			},
			Surface = {
				{ Liquid = "Water", Effect = "Glint", Every = { 0.15, 0.4 }, Tint = false },
			},
		},
		RockslideRidge = {
			Preset = "Cave",
			Sky = {
				SkyboxFt = "rbxassetid://133999400453106",
				SkyboxBk = "rbxassetid://103320266335414",
				SkyboxLf = "rbxassetid://136322873666391",
				SkyboxRt = "rbxassetid://140357849493459",
				SkyboxUp = "rbxassetid://110602513746126",
				SkyboxDn = "rbxassetid://80043436557296",
				CelestialBodiesShown = false,
			},
			Music = "Music_RockslideRidge",
			SuddenDeathMusic = "Music_RockslideRidge_SuddenDeath",
			WindColor = Color3.fromRGB(228, 222, 212),
			WindSound = "Wind_Howl",
			Ambient = {
				{ Effect = "Ambient_CaveDust", Bottom = 0, Top = 0.85, RateScale = 1 },
			},
			Surface = {
				{ Liquid = "Lava", Effect = "Lava_Bubble", Every = { 0.4, 1.2 }, Tint = false },
				{ Liquid = "Lava", Effect = "Ember", Every = { 0.2, 0.6 }, Tint = false },
			},
			Ceiling = { Effect = "Grit", Every = { 3, 7 } },
		},

		--[[
			An open snowy mountain since 2026-11-25 (was a cave): its own Mountains sky; shortcut: the meadow's light until it
			gets a preset of its own (its own music since 2026-11-16, Rockslide Ridge's howling wind, its water's ripples)
		]]
		EchoCaverns = {
			Preset = "Plains",
			Sky = {
				SkyboxFt = "rbxassetid://139125511340152",
				SkyboxBk = "rbxassetid://79523563555922",
				SkyboxLf = "rbxassetid://131048416551722",
				SkyboxRt = "rbxassetid://77989498895287",
				SkyboxUp = "rbxassetid://126242536248773",
				SkyboxDn = "rbxassetid://137571441310944",
				CelestialBodiesShown = false,
			},
			Parallax = {

				--[[ Far snowy range ]]

				{ Image = "rbxassetid://74510315412100", Depth = 1100, X = -750, Bottom = -6, Width = 500, Height = 218 },
				{ Image = "rbxassetid://79426272421825", Depth = 1100, X = -250, Bottom = -6, Width = 500, Height = 218 },
				{ Image = "rbxassetid://114325352282610", Depth = 1100, X = 250, Bottom = -6, Width = 500, Height = 218 },
				{ Image = "rbxassetid://119966560497602", Depth = 1100, X = 750, Bottom = -6, Width = 500, Height = 218 },
				{ Color = Color3.fromRGB(188, 203, 221), Depth = 1100.5, X = 0, Bottom = -345, Width = 2000, Height = 348 },

				--[[ Clouds ]]

				-- Higher and a little fainter since 2026-11-25 (the owner: "too low… a bit more subtle", then "a bit higher"; 110 studs lower and solid before)
				{ Image = "rbxassetid://98672992888178", Depth = 700, X = -430, Bottom = 256, Width = 257.6, Height = 128.8, Transparency = 0.2 },
				{ Image = "rbxassetid://90974304724232", Depth = 700, X = 260, Bottom = 306, Width = 179.2, Height = 89.6, Transparency = 0.2 },
				{ Image = "rbxassetid://130289146969975", Depth = 700, X = 600, Bottom = 246, Width = 235.2, Height = 117.6, Transparency = 0.2 },
				{ Image = "rbxassetid://121409989482134", Depth = 700, X = -720, Bottom = 336, Width = 134.4, Height = 67.2, Transparency = 0.2 },

				--[[ Near snowy hills and pines ]]

				{ Image = "rbxassetid://81484878649333", Depth = 350, X = -262.5, Bottom = -3, Width = 525, Height = 81 },
				{ Image = "rbxassetid://70830604089110", Depth = 350, X = 262.5, Bottom = -3, Width = 525, Height = 81 },
				{ Color = Color3.fromRGB(149, 160, 182), Depth = 350.5, X = 0, Bottom = -145, Width = 1050, Height = 149 },
			},
			Music = "Music_EchoCaverns",
			SuddenDeathMusic = "Music_EchoCaverns_SuddenDeath",
			WindColor = Color3.fromRGB(255, 255, 255),
			WindSound = "Wind_Howl",
			Ambient = {
				{ Effect = "Ambient_Motes", Bottom = 0.1, Top = 1, RateScale = 0.6 },
			},
			Surface = {
				{ Liquid = "Water", Effect = "Ripple", Every = { 1.5, 4 }, Tint = true },
			},
		},
		VolcanoIsle = {
			Preset = "Volcano",
			Sky = {
				SkyboxFt = "rbxassetid://133568701967211",
				SkyboxBk = "rbxassetid://90205576169723",
				SkyboxLf = "rbxassetid://73282958212064",
				SkyboxRt = "rbxassetid://76596542266781",
				SkyboxUp = "rbxassetid://102639367163151",
				SkyboxDn = "rbxassetid://128089118867016",
				CelestialBodiesShown = false,
			},
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

	-- The lighting layer a map's own Sky goes on, over its preset's (a sky's textures change at once)
	MAP_SKY_WEIGHT = 2,
	MAP_SKY_ID = "MapSky",

	--[[
		The atmosphere a map with its own Sky gets on that layer: an Atmosphere with any density covers everything under
		the horizon with its own colour, and the match camera looks level, so half its view was fog (the owner,
		2026-11-25: "the bottom half is too long… the top part where actual skybox is is barely visible"), and its haze
		and glare tint the sky even with no density. None of them and full offset show the whole painted sky
	]]
	--- @type { [string]: number }
	MAP_SKY_ATMOSPHERE = { Density = 0, Offset = 1, Haze = 0, Glare = 0 },

	--[[
		A mood's Parallax rows are flat pictures standing far behind the map (a skybox never moves or grows as the camera
		pans and zooms, so shapes painted in it looked stuck to the screen: the owner, 2026-11-25): each Depth studs
		behind the play plane, centred X studs along the map from its middle, its bottom edge Bottom studs up from the
		map's Bounds bottom, Width by Height studs, showing an Image (Transparency see-through, 0 when left out) or a solid
		Color (the ground under a layer), drawn unlit. Each picture's SurfaceGui canvas is PARALLAX_CANVAS pixels wide
	]]
	PARALLAX_CANVAS = 1024,

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

	-- The sideways pull on drifting particles per point of the match's wind (±20), in studs per second squared
	WIND_PUSH = 0.175,

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
		When the wind changes (every second round), each streak emitter bursts WIND_CHANGE_BURST streaks at the
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
