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
		ROOM_REFRESH_SECONDS, and sends a player who arrived with no seat back after STRANGER_SECONDS. 30 so more real
		players find it before bots fill it (the owner, 2026-11-24); MatchBoard keeps a copy: change both together
	]]
	WAITING_SECONDS = 30,
	ROOM_REFRESH_SECONDS = 2,
	STRANGER_SECONDS = 6,

	-- Seconds between the landing and the first turn, while every screen slams THE BATTLE BEGINS (MatchHud's BattleIntro)
	BATTLE_INTRO_SECONDS = 1.8,

	-- Seconds a full waiting room waits before its match starts (its last players may still be on their way)
	FULL_START_SECONDS = 4,

	--[[
		The vote to start (RoWorld's, the owner, 2026-11-24): it passes when every seated player here voted, up to
		VOTE_ALL_UP_TO of them, or VOTE_SHARE of them above; the match then starts VOTE_START_SECONDS later
	]]
	VOTE_ALL_UP_TO = 3,
	VOTE_SHARE = 2 / 3,
	VOTE_START_SECONDS = 3,

	-- The waiting room's gui, at the bottom middle
	WAITING_GUI_NAME = "MatchWaiting",

	--[[
		How long players have to pick where their snail lands, always the whole time so they can move their spot (the
		owner, 2026-11-15; the tutorial ends once its player placed), and the most the landing may take, in seconds
	]]
	DROP_SECONDS = 15,
	MAX_LANDING = 12,

	-- A solo match's drop, shorter: only bots play with the player, so no one needs the time (the owner, 2026-11-25: "more dynamic")
	SOLO_DROP_SECONDS = 7,

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

	--%%%%%%%%%%%%%%%%%%%% Drop Marker

	--[[
		Every participant's spot shows the DropMarker pin, its tip on the spot: the player's own follows the pointer until
		they place it, faded DROP_PIN_FADE where a snail doesn't fit, and others' are faded until they place theirs (the
		owner, 2026-11-17: the old picking "was good", only its look changed). A placed pin drops in from DROP_PIN_FALL of
		its height above its spot
	]]
	DROP_PIN_FADE = 0.6,
	DROP_PIN_FALL = 0.35,
	DROP_PIN_TWEENINFO = TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),

	-- The small target under the pin's tip (the aim crosshair's ring and a dot) pops in from this many times its size when placed
	DROP_TARGET_POP = 1.6,
	DROP_TARGET_TWEENINFO = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

	--%%%%%%%%%%%%%%%%%%%% Local Play

	--[[
		Local play (the owner, 2026-11-17): before each local player's turn MatchHud's turn callout names them on the
		host's screen and the turn waits for a press, at most LOCAL_HANDOFF_SECONDS
	]]
	LOCAL_HANDOFF_SECONDS = 30,

	--%%%%%%%%%%%%%%%%%%%% Tutorial

	--[[
		The tutorial's drop: the player and the bot start on land about TUTORIAL_GAP studs apart near the map's middle
		(chosen from TUTORIAL_SPOT_COUNT land spots), lit TUTORIAL_DROP_HEIGHT studs over it, the player has
		TUTORIAL_DROP_SECONDS to place theirs, and any press within TUTORIAL_PICK_RADIUS studs of the lit spot counts
		(the guide's ring is at least HOLE_MIN pixels, wider than a few studs when the camera is far out). The tutorial
		has no timers (the owner, 2026-11-24): the drop and the player's turns last TUTORIAL_DROP_SECONDS and
		TUTORIAL_TURN_SECONDS, long enough never to run out, and the HUD hides their clocks
	]]
	TUTORIAL_GAP = 30,
	TUTORIAL_SPOT_COUNT = 16,
	TUTORIAL_DROP_HEIGHT = 8,
	TUTORIAL_DROP_SECONDS = 900,
	TUTORIAL_TURN_SECONDS = 900,
	TUTORIAL_PICK_RADIUS = 10,

	-- What the player takes into the tutorial match beside the Bazooka, whatever their loadout: nothing, the Bazooka alone (2026-11-24)
	--- @type { string }
	TUTORIAL_LOADOUT = {},

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

	-- How long a knocked-out player's Play again waits for them in the lobby, in seconds (the trip there takes a few)
	PLAY_AGAIN_SECONDS = 90,
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
		MapId = "RollingPlains",
		Difficulty = "Medium",
		Roster = {},
	},
	STUDIO_WAIT = 3,
}

return _settings
