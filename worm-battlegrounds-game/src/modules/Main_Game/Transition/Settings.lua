--- @class Transition_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The teleport card ume's teleports clone into PlayerGui, by the gui name they're passed
	GUI_NAME = "TeleportGui",

	-- What the card says when no destination came with it
	--- @type Transition_Destination
	DEFAULT_DESTINATION = { Kicker = "Loading", Title = "Snail Battlegrounds" },

	-- The found map's name punches in when the search ends
	TITLE_PUNCH = 1.22,
	TITLE_PUNCH_TWEENINFO = TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

	--%%%%%%%%%%%%%%%%%%%% Scenes

	--[[
		Each map's scene is its own Atmosphere row: its sky (SkyboxFt) and its Parallax rows, drawn through the match
		camera. A map only adds its look here: where the horizon sits on its sky picture (a share from the top), its
		accent colour and its weather. A map with no row takes DEFAULT_LOOK; the lobby's scene is LOBBY_LOOK, the
		gradient sky Atmosphere's Lobby Parallax rows are drawn for (the lobby itself never builds those rows)
	]]
	--- @type { [string]: Transition_Look }
	LOOKS = {
		Desert = { Horizon = 0.555, Accent = Color3.fromRGB(255, 181, 71), Weather = "Sand" },
		EchoCaverns = { Horizon = 0.565, Accent = Color3.fromRGB(143, 211, 255), Weather = "Snow" },
		RollingPlains = { Horizon = 0.565, Accent = Color3.fromRGB(155, 225, 93), Weather = "Pollen" },
	},

	--- @type Transition_Look
	DEFAULT_LOOK = { Horizon = 0.555, Accent = Color3.fromRGB(255, 212, 59), Weather = "Motes" },

	--- @type Transition_Look
	LOBBY_LOOK = { Sky = "rbxassetid://99363908139132", Horizon = 0.565, Accent = Color3.fromRGB(255, 212, 59), Weather = "Motes" },

	-- The scene name the lobby's look builds under
	LOBBY_SCENE = "Lobby",

	-- A Parallax image row this high (studs over the map's bottom) is a cloud, which drifts and wraps round the screen
	CLOUD_MIN_BOTTOM = 40,

	--[[
		Each weather's little squares, at their own depths so they move with the camera: how many, their colours and
		transparency, their size (and a streak's thickness), how fast they drift (studs a second), their wobble, bob and
		spin. Low keeps them over the ground
	]]
	--- @type { [string]: { Transition_WeatherRow } }
	WEATHER = {
		Sand = {
			{
				Count = 46,
				Low = true,
				Colors = { Color3.fromRGB(255, 236, 204) },
				Transparency = NumberRange.new(0.3, 0.65),
				Size = NumberRange.new(5, 9),
				Thick = 0.45,
				Depth = NumberRange.new(140, 520),
				SpeedX = NumberRange.new(34, 60),
				SpeedY = NumberRange.new(-2, 1),
				Wobble = 0,
				Bob = 0,
				Spin = 0,
			},
		},
		Snow = {
			{
				Count = 60,
				Colors = { Color3.fromRGB(255, 255, 255) },
				Transparency = NumberRange.new(0.05, 0.4),
				Size = NumberRange.new(0.9, 1.7),
				Depth = NumberRange.new(120, 640),
				SpeedX = NumberRange.new(2, 6),
				SpeedY = NumberRange.new(-9, -5),
				Wobble = 2.2,
				Bob = 0,
				Spin = 30,
			},
		},
		Pollen = {
			{
				Count = 40,
				Colors = { Color3.fromRGB(255, 247, 196) },
				Transparency = NumberRange.new(0.15, 0.5),
				Size = NumberRange.new(0.6, 1.1),
				Depth = NumberRange.new(120, 560),
				SpeedX = NumberRange.new(3, 8),
				SpeedY = NumberRange.new(-1.5, 1.5),
				Wobble = 2.2,
				Bob = 3,
				Spin = 0,
			},
			{
				Count = 9,
				Colors = { Color3.fromRGB(111, 191, 74), Color3.fromRGB(143, 212, 94) },
				Transparency = NumberRange.new(0, 0),
				Size = NumberRange.new(1.6, 1.6),
				Depth = NumberRange.new(120, 560),
				SpeedX = NumberRange.new(3, 8),
				SpeedY = NumberRange.new(-1.5, 1.5),
				Wobble = 2.2,
				Bob = 3,
				Spin = 110,
			},
		},
		Motes = {
			{
				Count = 34,
				Colors = { Color3.fromRGB(255, 255, 255) },
				Transparency = NumberRange.new(0.3, 0.65),
				Size = NumberRange.new(0.5, 0.9),
				Depth = NumberRange.new(140, 600),
				SpeedX = NumberRange.new(-1, 2),
				SpeedY = NumberRange.new(1, 3),
				Wobble = 2.2,
				Bob = 0,
				Spin = 0,
			},
		},
	},

	--%%%%%%%%%%%%%%%%%%%% Timing

	-- While a match is being found the scene whips to the next map in the pool this often, in seconds
	SEARCH_WHIP_SECONDS = 1.6,

	-- How often Roblox gets a fresh copy of the card to hold through the teleport, so the held frame is never stale
	HANDOVER_SECONDS = 0.5,

	-- How long each tip stays, in seconds
	TIP_SECONDS = 5,

	--%%%%%%%%%%%%%%%%%%%% Tips

	-- The tips the card shows, one at a time
	--- @type { string }
	TIPS = {
		"A grenade bursts as soon as it stops rolling",
		"Ponds only hurt. The open sea knocks you out",
		"Your aim carries over into your next turn",
		"Teammates can't hurt each other",
		"Strong weapons wait a few turns before their first use",
	},

	--%%%%%%%%%%%%%%%%%%%% Teleports

	-- How many times a teleport that fails on the way is tried again, and the seconds between tries
	TELEPORT_RETRIES = 2,
	TELEPORT_RETRY_DELAY = 2,

	-- The failures worth trying again; any other drops the card at once
	--- @type { Enum.TeleportResult }
	TELEPORT_RETRY_RESULTS = { Enum.TeleportResult.Failure, Enum.TeleportResult.Flooded },

	-- What a player is told when their teleport failed for good
	TELEPORT_FAILED_MESSAGE = "Couldn't get you there. Try again!",
}

return _settings
