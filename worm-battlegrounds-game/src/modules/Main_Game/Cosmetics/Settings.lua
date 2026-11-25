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

	--[[
		The emote shop sends one buy at a time, at most one every this many seconds, so fast presses stay under
		Cosmetics_BuyEmote's rate limit (2 a second) instead of being refused
	]]
	EMOTE_BUY_INTERVAL = 0.55,

	--[[
		The emote bubble over a lobby party card stands on the avatar's top right, inside the avatar so any layout or
		scale carries it: its tail's tip CARD_BUBBLE_ANCHOR of the avatar across and down, the bubble CARD_BUBBLE_SIZE of
		the avatar's height tall
	]]
	CARD_BUBBLE_ANCHOR = Vector2.new(0.84, 0.1),
	CARD_BUBBLE_SIZE = 0.62,

	--%%%%%%%%%%%%%%%%%%%% Emote Wheel

	-- The match HUD's emote button's emote: its picture on the button, and what a quick tap plays before any other
	WHEEL_BUTTON_EMOTE = "Emote_Wave",

	--[[
		Holding WHEEL_KEY (keyboard) or the Console module's Emotes button (X on a pad) opens the wheel; letting go plays
		the emote pointed at, and a press shorter than WHEEL_TAP_SECONDS plays the last one again instead
	]]
	WHEEL_KEY = Enum.KeyCode.T,
	WHEEL_TAP_SECONDS = 0.25,

	-- The left stick points at a slice once it leans this far
	WHEEL_STICK_DEADZONE = 0.5,

	--[[
		The ring, in shares of the wheel's size: the slices' icons sit WHEEL_ICON_RADIUS out from the middle, and the
		pointer points at the slice in its direction from the middle, at nothing inside WHEEL_DEAD_RADIUS (the middle's
		disc); WHEEL_SLICE_GAP degrees part two slices
	]]
	WHEEL_ICON_RADIUS = 0.32,
	WHEEL_DEAD_RADIUS = 0.17,
	WHEEL_SLICE_GAP = 2,

	--[[
		The slice pointed at grows to WHEEL_HOVER_SCALE (WHEEL_HOVER_TWEENINFO). Opening, the wheel spins in from
		WHEEL_OPEN_SPIN degrees and WHEEL_OPEN_SCALE of its size (WHEEL_OPEN_TWEENINFO)
	]]
	WHEEL_HOVER_SCALE = 1.06,
	WHEEL_HOVER_TWEENINFO = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	WHEEL_OPEN_SPIN = -40,
	WHEEL_OPEN_SCALE = 0.6,
	WHEEL_OPEN_TWEENINFO = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

	--[[
		A slice not owned yet shows WHEEL_LEVEL_TEXT under its lock (above level 1), and the middle says under its name
		the level it unlocks at, or once it has, where to buy it
	]]
	WHEEL_LEVEL_TEXT = "Lv %d",
	WHEEL_LOCKED_TEXT = "Unlocks at level %d",
	WHEEL_SHOP_TEXT = "Get it in the emote shop",

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

	-- The guis that show emotes: the match's emote wheel, and the party list emotes show over in the lobby
	MATCH_HUD_GUI_NAME = "MatchHud",
	PARTY_GUI_NAME = "Party",
}

return _settings
