--- @class Cosmetics_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Owned

	-- What every player owns from the start, given on their first join
	--- @type { string }
	STARTER_ITEMS = { "Body_GardenPink", "Shell_GardenSwirl", "Emote_Wave" },

	-- The snail's slots, in the Outfit attribute's order; Hat and Neck may be empty
	--- @type { string }
	SLOTS = { "Hat", "Neck", "Body", "Shell" },

	-- What a snail wears until the player picks otherwise, and in every slot they leave empty or don't own
	--- @type Cosmetics_Outfit
	DEFAULT_OUTFIT = { Hat = "", Neck = "", Body = "Body_GardenPink", Shell = "Shell_GardenSwirl" },

	-- Copies of a piece that make it shiny
	SHINY_COPIES = 10,

	--%%%%%%%%%%%%%%%%%%%% Emotes

	-- Seconds a player waits between two emotes
	EMOTE_COOLDOWN = 5,

	-- How long an emote plays on the snail and its bubble shows beside a name in the lobby, in seconds
	EMOTE_SECONDS = 3,

	-- The gap between a name on a lobby party card and the emote bubble beside it, in design px
	CARD_BUBBLE_GAP = 8,

	-- How far from the wheel's centre its emotes sit, as a share of its size
	WHEEL_RADIUS = 0.38,

	--%%%%%%%%%%%%%%%%%%%% Previews

	--[[
		How a piece's tile frames it on its snail, by slot: the height looked at above the piece (a hat or neck piece) or
		the snail's middle, and the camera's distance, both in the whole snail's sizes, and how far the camera turns round
		it in degrees (the shell sits on the back)
	]]
	--- @type { [string]: Cosmetics_Shot }
	PIECE_SHOTS = {
		Hat = { Height = 0, Distance = 0.44, Turn = -15 },
		Neck = { Height = 0.07, Distance = 0.56, Turn = -15 },
		Body = { Height = -0.05, Distance = 0.64, Turn = -15 },
		Shell = { Height = 0, Distance = 0.52, Turn = 125 },
	},

	-- The bone each piece rides (Classic's rig: the head, the neck, the shell's): a tile looks where the pose put it
	--- @type { [string]: string }
	PIECE_BONES = { Hat = "Bone.003", Neck = "Bone.002", Shell = "Bone.013" },

	--[[
		The Style screen's camera for each slot it shows: degrees round the snail (0 is its front) and above it, its
		distance as a share of STAGE_DISTANCE, and the height it looks at, a share of the snail up from its middle. It
		eases there when a slot opens or a piece is picked
	]]
	--- @type { [string]: Cosmetics_Focus }
	STAGE_FOCUS = {
		Hat = { Yaw = -15, Pitch = 14, Zoom = 0.95, Height = 0.1 },
		Neck = { Yaw = -15, Pitch = 4, Zoom = 0.9, Height = -0.04 },
		Body = { Yaw = -20, Pitch = 8, Zoom = 1, Height = 0.04 },
		Shell = { Yaw = 110, Pitch = 12, Zoom = 0.92, Height = 0.06 },
	},

	-- The whole snail's distance from the camera, in its sizes
	STAGE_DISTANCE = 0.8,

	--[[
		How fast the camera eases to a new view (higher is snappier; a drag turns it at once), and degrees of spin per
		pixel dragged
	]]
	STAGE_EASE = 9,
	STAGE_DRAG_SPEED = 0.45,

	-- The lowest and highest the camera tilts, in degrees above the snail
	STAGE_PITCH = NumberRange.new(-10, 55),

	--[[
		Seconds after the screen is drawn before its small viewports are drawn again: Roblox doesn't draw a viewport that
		changed while it moved (the fanning deck cards) until it changes again
	]]
	VIEWPORT_REDRAW_DELAY = 0.45,

	--%%%%%%%%%%%%%%%%%%%% Gui

	SKINS_GUI_NAME = "Skins",

	-- The lobby gui whose STYLE button shows NEW while a piece is unseen
	LOBBY_GUI_NAME = "Lobby",
	EMOTE_SHOP_GUI_NAME = "EmoteShop",

	--[[
		The guis that show emotes: the lobby's emote row, the match's emote wheel, and the party list emotes show over
		in the lobby
	]]
	LOADOUT_GUI_NAME = "Loadout",
	MATCH_HUD_GUI_NAME = "MatchHud",
	PARTY_GUI_NAME = "Party",
}

return _settings
