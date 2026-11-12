--- @class Match_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Phases

	-- How long the match waits for every player in its roster before it starts without them, in seconds
	WAIT_FOR_PLAYERS = 20,

	-- How long players have to pick where their snail lands, and the most the landing may take, in seconds
	DROP_SECONDS = 10,
	MAX_LANDING = 12,

	-- How fast the left stick moves the drop spot at full lean, in studs per second
	DROP_STICK_SPEED = 40,

	-- How high over its land a snail that wasn't placed (a bot, a player who didn't place) starts its parachute, in studs
	DROP_HEIGHT = 20,

	--%%%%%%%%%%%%%%%%%%%% Turns

	-- How long a turn lasts, in seconds
	TURN_SECONDS = 25,

	-- The most a shot may stay in flight before the turn moves on anyway, in seconds
	MAX_FLIGHT = 20,

	--[[
		After a turn, the match waits until every snail is at rest on the ground (or in a liquid), with no debris falling,
		no projectile and no health changing, for SETTLE_HOLD seconds, or HIT_HOLD after a shot or anyone getting hurt.
		Nothing moving or getting hurt for STALL_SECONDS moves on anyway (a snail stuck off the ground), and so does
		MAX_SETTLE seconds of settling
	]]
	SETTLE_HOLD = 0.3,
	HIT_HOLD = 3,
	STALL_SECONDS = 5,
	MAX_SETTLE = 20,

	--[[
		At the end of every turn, each snail whose head is under a liquid that doesn't knock it out (a pond) loses
		UNDERWATER_DAMAGE health, never going below 1, as Worms Armageddon's poison. Its head's top is
		UNDERWATER_HEAD_HEIGHT studs over its ball's centre (where Classic's eyestalks start)
	]]
	UNDERWATER_DAMAGE = 5,
	UNDERWATER_HEAD_HEIGHT = 1.6,

	-- The wind each turn is a whole number from -WIND_MAX to WIND_MAX
	WIND_MAX = 10,

	-- Sudden death starts at SUDDEN_DEATH_ROUND (after 10 rounds): the liquid rises SUDDEN_DEATH_RISE half-stud rows every turn
	SUDDEN_DEATH_ROUND = 11,
	SUDDEN_DEATH_RISE = 4,

	--%%%%%%%%%%%%%%%%%%%% End

	--[[
		How long the lobby offers a dropped player to go back to their match, in seconds; meanwhile a bot plays their
		snail's turns, and a player dropping mid-turn leaves the bot at least TAKEOVER_SECONDS of it
	]]
	REJOIN_SECONDS = 900,
	TAKEOVER_SECONDS = 12,

	-- How long the rematch vote stays open after the results, in seconds
	REMATCH_SECONDS = 20,

	--[[
		A player sent to the lobby isn't sent again for LOBBY_RESEND_SECONDS while the teleport runs; one that can't start
		shows LOBBY_FAILED_MESSAGE, and Lobby works again at once
	]]
	LOBBY_RESEND_SECONDS = 15,
	LOBBY_FAILED_MESSAGE = "Couldn't get you to the lobby. Try again!",

	--%%%%%%%%%%%%%%%%%%%% Teams

	-- How many snails each team has in each mode; Deathmatch is everyone for themselves
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

	-- Each snail's own colour in a free-for-all, in order
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
		The map that plays the lobby and its matches in one Studio server: the lobby hands its matches to I.Match.Host
		instead of teleporting, and players go back to the lobby screens afterwards
	]]
	STUDIO_MAP = "Studio",

	--[[
		The match a Studio test of the Match map alone plays (it has no lobby to send metadata): every test player joins
		its roster, and bots fill the rest. STUDIO_WAIT is how long the server waits for test players to join first.
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
}

return _settings
