--- @class Lobby_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Gui

	-- The guis the lobby turns on: its background first, then its panels
	--- @type { string }
	LOBBY_GUIS = { "Lobby", "MatchBoard", "Party", "Loadout", "Currency" },

	--%%%%%%%%%%%%%%%%%%%% Backdrop Map

	--[[
		Behind the lobby's guis, bots play a match on BACKDROP_MAP, copied by the server into Workspace.Ume.Lobby as
		BACKDROP_NAME, this far from the arena's own place
	]]
	BACKDROP_MAP = "PicnicPlains",
	BACKDROP_NAME = "Backdrop",
	BACKDROP_ORIGIN = Vector3.new(0, 400, -1500),

	-- The liquid filling each of the map's liquid markers (a still box: the backdrop has no liquid simulation)
	--- @type { [string]: Color3 }
	BACKDROP_LIQUID_COLORS = { Water = Color3.fromRGB(40, 140, 230), Lava = Color3.fromRGB(255, 96, 20) },

	--- @type { [string]: number }
	BACKDROP_LIQUID_TRANSPARENCY = { Water = 0.2, Lava = 0 },

	--%%%%%%%%%%%%%%%%%%%% Backdrop Camera

	-- The camera looks along -Z at the action from this far, with this field of view, catching up at FOLLOW_SPEED
	BACKDROP_DISTANCE = 90,
	BACKDROP_FOV = 30,
	BACKDROP_FOLLOW_SPEED = 1.5,

	--[[
		How strongly the match is blurred behind the guis, and the Lighting layer's weight: over an open window's
		(WidgetManager's 999), whose lighter blur would otherwise sharpen the match
	]]
	BACKDROP_BLUR = 30,
	BACKDROP_BLUR_WEIGHT = 1000,
	BACKDROP_BLUR_TWEENINFO = TweenInfo.new(0.4),

	--%%%%%%%%%%%%%%%%%%%% Backdrop Bots

	-- How many snails play (the first in the player's equipped skin), and the least room between their start spots, in studs
	BACKDROP_SNAILS = 4,
	BACKDROP_SPACING = 18,

	-- A snail's size, the radius of the ball a match's snail stands on (Snails' ROOT_SIZE / 2), and its health (MAX_HEALTH)
	BACKDROP_SNAIL_RADIUS = 1.3,
	BACKDROP_HEALTH = 200,

	--[[
		The weapons bots fire, each with what its shot flies as (the Bazooka's rocket has no model of its own yet); blast
		size, damage and knockback come from each weapon's Arsenal row
	]]
	--- @type { [string]: string }
	BACKDROP_WEAPONS = { Bazooka = "HomingMissile", Grenade = "Grenade" },

	--[[
		A turn: thinking, then walking up to WALK studs at WALK_SPEED, or now and then (JETPACK_CHANCE) flying with the
		jetpack, then turning the weapon to the shot over AIM seconds, and resting REST seconds once everything landed
	]]
	--- @type { number }
	BACKDROP_THINK = { 2, 3.5 },

	--- @type { number }
	BACKDROP_WALK = { 0, 8 },

	BACKDROP_WALK_SPEED = 5,
	BACKDROP_AIM = 1.6,
	BACKDROP_REST = 1.5,

	--[[
		The jetpack: worn on the back of the shell (up and behind, Snails' GEAR), it lifts the snail JETPACK_HEIGHT studs
		over a flight of JETPACK_TIME seconds to land JETPACK_REACH studs away, toward its rival, on ground no more than
		JETPACK_HEIGHT above or below where it took off
	]]
	BACKDROP_JETPACK_CHANCE = 0.35,
	BACKDROP_JETPACK_UP = 0.4,
	BACKDROP_JETPACK_BEHIND = 2.4,
	BACKDROP_JETPACK_HEIGHT = 4,
	BACKDROP_JETPACK_TIME = 2.2,

	--- @type { number }
	BACKDROP_JETPACK_REACH = { 8, 16 },

	--[[
		Shots and thrown snails fall at BACKDROP_GRAVITY (studs per second squared, gentler than a match's), so they fly slow
		arcs; a shot flies for a time in FLIGHT, aimed at a snail and off by up to MISS studs either way
	]]
	BACKDROP_GRAVITY = 50,

	--- @type { number }
	BACKDROP_FLIGHT = { 1.4, 3.2 },

	BACKDROP_MISS = 7,

	-- A bot tries up to this many shots (a rival and a flight time) for one that no ground overhead or in the way catches
	BACKDROP_AIM_TRIES = 16,

	-- A blast throws snails at its weapon's knockback times this, and a snail knocked out reappears after the round
	BACKDROP_KNOCKBACK_SCALE = 0.4,

	-- Where the held weapon sits from the snail's middle: along the aim, up, and toward the camera (Combat's HELD_*)
	BACKDROP_HELD_FORWARD = 0.8,
	BACKDROP_HELD_HEIGHT = -0.3,
	BACKDROP_HELD_DEPTH = 1.5,

	--%%%%%%%%%%%%%%%%%%%% Travel

	-- The teleport screen
	TELEPORT_GUI = "TeleportGui",

	-- The match a new player is sent to before they see the lobby
	TUTORIAL_MAP = "PicnicPlains",
	TUTORIAL_DIFFICULTY = "Tutorial",

	-- Studio playtests skip the tutorial match (nothing saves there) unless Workspace has this attribute set to true
	STUDIO_TUTORIAL_ATTRIBUTE = "StudioTutorial",
}

return _settings
