--- @class Match_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Phases

	--[[
		How long a solo, party, custom or tutorial match waits for every player in its roster before it starts, in
		seconds; a bot plays for anyone who isn't there yet until they arrive
	]]
	WAIT_FOR_PLAYERS = 20,

	--[[
		A public match's waiting room: it takes joins from every lobby server for WAITING_SECONDS, or until every
		player in it pressed Ready, then starts with bots in the empty seats. It reads the seats lobbies claimed every
		ROOM_REFRESH_SECONDS, and sends a player who arrived with no seat back after STRANGER_SECONDS
	]]
	WAITING_SECONDS = 15,
	ROOM_REFRESH_SECONDS = 2,
	STRANGER_SECONDS = 6,

	-- The waiting room's gui, at the bottom middle
	WAITING_GUI_NAME = "MatchWaiting",

	--[[
		How long players have to pick where their snail lands, always the whole time so they can move their spot (the
		owner, 2026-11-15; the tutorial ends once its player placed), and the most the landing may take, in seconds
	]]
	DROP_SECONDS = 15,
	MAX_LANDING = 12,

	-- How fast the left stick moves the drop spot at full lean, in studs per second
	DROP_STICK_SPEED = 40,

	-- How high over its land a snail that wasn't placed (a bot, a player who didn't place) starts its parachute, in studs
	DROP_HEIGHT = 20,

	--[[
		The drop draws DROP_SPOT_CHOICES random land spots for each snail: bots pick theirs from them (Bots' GetStart:
		never near a spot taken already), and a player who doesn't place starts on the first one at least Arena's
		LAND_SPOT_GAP from everyone's
	]]
	DROP_SPOT_CHOICES = 6,

	--%%%%%%%%%%%%%%%%%%%% Tutorial

	--[[
		The tutorial's drop: the player and the bot start on land about TUTORIAL_GAP studs apart near the map's middle
		(chosen from TUTORIAL_SPOT_COUNT land spots), lit TUTORIAL_DROP_HEIGHT studs over it, the player has
		TUTORIAL_DROP_SECONDS to place theirs, and any press within TUTORIAL_PICK_RADIUS studs of the lit spot counts
		(the guide's ring is at least HOLE_MIN pixels, wider than a few studs when the camera is far out)
	]]
	TUTORIAL_GAP = 30,
	TUTORIAL_SPOT_COUNT = 16,
	TUTORIAL_DROP_HEIGHT = 8,
	TUTORIAL_DROP_SECONDS = 40,
	TUTORIAL_PICK_RADIUS = 10,

	--[[
		The tutorial's wind, one for each WIND_ROUNDS rounds, before the usual rolls (the testers, 2026-11-15: "after 2
		rounds change the wind and showcase how extreme wind can sway shot"): calm while the player learns to shoot and
		throw, then a strong wind against them (they start left of the bot)
	]]
	--- @type { number }
	TUTORIAL_WINDS = { 0, -16 },

	-- What the player takes into the tutorial match beside the Bazooka, whatever their loadout: the Grenade it teaches
	--- @type { string }
	TUTORIAL_LOADOUT = { "Grenade" },

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

	--[[
		The wind is a whole number from -WIND_MAX to WIND_MAX, rolled again at the start of every WIND_ROUNDS-th round
		(so every snail plays that many turns on it), never the same twice in a row
	]]
	WIND_MAX = 20,
	WIND_ROUNDS = 2,

	--[[
		How often each strength of wind is rolled (the owner, 2026-11-15: mostly -5 to 5, about 65% of rolls; -20 or
		+20 about 0.3%): the weight of 0, 1, 2… up to WIND_MAX, out of their sum (100); a strength above 0 blows either
		way at even odds
	]]
	--- @type { number }
	WIND_WEIGHTS = { 12, 12, 11, 11, 10, 9, 6, 5, 4.5, 4, 3.5, 2.5, 2, 1.7, 1.4, 1.2, 1, 0.8, 0.6, 0.5, 0.3 },

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

	--%%%%%%%%%%%%%%%%%%%% Drawing

	--[[
		The clock clients draw moving things on (I.Match.GetDrawTime): it eases toward the server's clock over
		DRAW_CLOCK_EASE seconds instead of following its corrections, and jumps to it when DRAW_CLOCK_SNAP seconds off
	]]
	DRAW_CLOCK_EASE = 1,
	DRAW_CLOCK_SNAP = 0.5,

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
