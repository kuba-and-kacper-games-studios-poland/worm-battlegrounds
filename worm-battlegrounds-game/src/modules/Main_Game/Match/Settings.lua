--- @class Match_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Phases

	-- How long the match waits for every player in its roster before it starts without them, in seconds
	WAIT_FOR_PLAYERS = 20,

	-- How long players have to pick where their worm lands, and the most the landing may take, in seconds
	DROP_SECONDS = 15,
	MAX_LANDING = 12,

	-- How fast the left stick moves the drop spot at full lean, in studs per second
	DROP_STICK_SPEED = 40,

	--%%%%%%%%%%%%%%%%%%%% Turns

	-- How long a turn lasts, in seconds
	TURN_SECONDS = 15,

	-- The most a shot may stay in flight before the turn moves on anyway, in seconds
	MAX_FLIGHT = 20,

	--[[
		After a shot, the match waits until worms, debris and projectiles have been at rest for SETTLE_HOLD seconds,
		or MAX_SETTLE seconds have passed
	]]
	SETTLE_HOLD = 0.5,
	MAX_SETTLE = 8,

	-- The wind each turn is a whole number from -WIND_MAX to WIND_MAX
	WIND_MAX = 10,

	--[[
		Sudden death starts at this round: the liquid rises SUDDEN_DEATH_RISE half-stud rows at the start of every turn
		(the start is still asked on the wiki's Match modes & maps page)
	]]
	SUDDEN_DEATH_ROUND = 10,
	SUDDEN_DEATH_RISE = 4,

	--%%%%%%%%%%%%%%%%%%%% End

	-- How long a dropped player has to come back before their worm is knocked out as a leaver, in seconds
	REJOIN_SECONDS = 60,

	-- How long the rematch vote stays open after the results, in seconds
	REMATCH_SECONDS = 20,

	--%%%%%%%%%%%%%%%%%%%% Teams

	-- How many worms each team has in each mode; Deathmatch is everyone for themselves
	--- @type { [string]: number }
	TEAM_SIZES = { Deathmatch = 1, Duo = 2, Trio = 3, Quads = 4 },

	-- Team names and colours in team modes, in order; Roblox teams of these names are made so chat and the list follow
	--- @type { Match_TeamStyle }
	TEAMS = {
		{ Name = "Red", Color = Color3.fromRGB(255, 84, 84) },
		{ Name = "Blue", Color = Color3.fromRGB(64, 156, 255) },
		{ Name = "Green", Color = Color3.fromRGB(96, 214, 96) },
		{ Name = "Yellow", Color = Color3.fromRGB(255, 206, 64) },
	},

	-- Each worm's own colour in a free-for-all, in order
	--- @type { Color3 }
	FFA_COLORS = {
		Color3.fromRGB(255, 84, 84),
		Color3.fromRGB(64, 156, 255),
		Color3.fromRGB(96, 214, 96),
		Color3.fromRGB(255, 206, 64),
		Color3.fromRGB(190, 110, 255),
		Color3.fromRGB(255, 150, 60),
		Color3.fromRGB(60, 220, 220),
		Color3.fromRGB(255, 120, 200),
	},

	--%%%%%%%%%%%%%%%%%%%% Studio

	--[[
		The match a Studio test plays (Studio has no lobby to send metadata): every test player joins its roster, and
		bots fill the rest. STUDIO_WAIT is how long the server waits for test players to join before it starts.
	]]
	--- @type Match_Metadata
	STUDIO_METADATA = {
		MatchId = "Studio",
		Kind = "Public",
		Mode = "Deathmatch",
		Size = 4,
		MapId = "PicnicPlains",
		Difficulty = "Medium",
		Roster = {},
	},
	STUDIO_WAIT = 3,

	-- What a Studio test player with an empty loadout takes into the match, to try the weapons
	--- @type { string }
	STUDIO_LOADOUT = { "Grenade", "ClusterBomb", "HomingMissile", "BlackHoleGrenade", "Jetpack" },
}

return _settings
