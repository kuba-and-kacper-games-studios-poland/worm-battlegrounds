--- @class Crates_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Opening

	-- How many crates a pack opens: one buy button each (U_BuyX<count>), priced by the crate's One, Three and Ten
	--- @type { number }
	COUNTS = { 1, 3, 10 },

	-- Copies of an item that make it shiny
	SHINY_COPIES = 10,

	-- Currencies bought with Robux: rolling crates with them is a paid random item, hidden where the policy restricts it
	--- @type { string }
	PAID_CURRENCIES = { "Diamonds" },

	--%%%%%%%%%%%%%%%%%%%% Special Crates

	-- The crate VIP players open free once a day, and the odds it rolls with
	VIP_CRATE = "Skin",
	VIP_ODDS = "Coins",

	-- The crate the tutorial gives, once
	TUTORIAL_CRATE = "Tutorial",

	--%%%%%%%%%%%%%%%%%%%% Intro

	-- Seconds the shop takes to make way for the crates
	INTRO_TWEENINFO = TweenInfo.new(0.56, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	QUICK_INTRO_TWEENINFO = TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),

	--%%%%%%%%%%%%%%%%%%%% Stage

	--[[
		Where the 3D crates stand by pack size (studs; the camera looks along +Z at their fronts), their scale and turn,
		and the camera and the point it looks at: one in the middle; three as one in front and two behind; ten as a
		pyramid of 1, 2, 3 and 4
	]]
	--- @type { [number]: Crates_StageLayout }
	STAGE_LAYOUTS = {
		[1] = {
			Spots = { Vector3.new(0, 0, 0) },
			Scale = 1,
			Yaw = -0.5,
			Camera = Vector3.new(0, 7.2, -16.2),
			Focus = Vector3.new(0, 1.3, 0),
		},
		[3] = {
			Spots = { Vector3.new(0, 0, -2.4), Vector3.new(4.3, 0, 2), Vector3.new(-4.3, 0, 2) },
			Scale = 0.88,
			Yaw = -0.3,
			Camera = Vector3.new(0, 9.5, -22.5),
			Focus = Vector3.new(0, 1, 0.2),
		},
		[10] = {
			Spots = {
				Vector3.new(0, 0, -5.2),
				Vector3.new(-2.6, 0, -1.3),
				Vector3.new(2.6, 0, -1.3),
				Vector3.new(-5.2, 0, 2.6),
				Vector3.new(0, 0, 2.6),
				Vector3.new(5.2, 0, 2.6),
				Vector3.new(-7.8, 0, 6.5),
				Vector3.new(-2.6, 0, 6.5),
				Vector3.new(2.6, 0, 6.5),
				Vector3.new(7.8, 0, 6.5),
			},
			Scale = 0.78,
			Yaw = -0.22,
			Camera = Vector3.new(0, 13.5, -30.5),
			Focus = Vector3.new(0, 0.6, 1.6),
		},
	},

	-- The stage camera's field of view (degrees), and the screen shape the layouts are framed for
	STAGE_FOV = 26,
	STAGE_ASPECT = 16 / 9,

	-- Seconds a crate takes to drop in (and with Quick open), how high it starts, and how much later each next one drops
	STAGE_DROP_SECONDS = 0.62,
	STAGE_QUICK_DROP_SECONDS = 0.36,
	STAGE_DROP_HEIGHT = 9,

	--- @type { [number]: number }
	STAGE_DROP_GAP = { [1] = 0, [3] = 0.11, [10] = 0.055 },

	--[[
		The opening's steps (seconds): the rattle, the hatches springing, the walls falling and the light swelling into
		the flash; how much later each next crate opens; Quick open plays it all this much faster
	]]
	STAGE_RATTLE_SECONDS = 0.52,
	STAGE_HATCH_SECONDS = 0.3,
	STAGE_WALL_SECONDS = 0.38,
	STAGE_SWELL_SECONDS = 0.24,

	--- @type { [number]: number }
	STAGE_OPEN_GAP = { [1] = 0, [3] = 0.12, [10] = 0.06 },

	STAGE_QUICK_SPEED = 0.55,

	-- How far the hatches and walls swing open (degrees), and how much the light swells before the flash, by pack size
	STAGE_HATCH_DEGREES = 129,
	STAGE_WALL_DEGREES = 93,

	--- @type { [number]: number }
	STAGE_SWELL = { [1] = 1.8, [3] = 1, [10] = 0.5 },

	-- The golden crate's light: the viewport's ambient and light colour
	STAGE_GOLD_AMBIENT = Color3.fromRGB(255, 200, 90),
	STAGE_GOLD_LIGHT = Color3.fromRGB(255, 222, 140),

	--[[
		From this many crates the stage runs light: the crates have no balls of light (the stage's glow swells instead),
		and the pack shares one set of effects (the front crate's)
	]]
	STAGE_LIGHT_COUNT = 10,

	--%%%%%%%%%%%%%%%%%%%% Reels

	--[[
		How long the reels roll, by how many there are (the tutorial's fixed crate gives two): the first reel's
		seconds and how much later each next one stops (the rarest result stops last); QUICK_* while Quick open is on
	]]
	--- @type { [number]: number }
	ROLL_SECONDS = { [1] = 6, [2] = 5, [3] = 5, [10] = 3.9 },

	--- @type { [number]: number }
	ROLL_STAGGER = { [1] = 0, [2] = 0.62, [3] = 0.62, [10] = 0.28 },

	--- @type { [number]: number }
	QUICK_ROLL_SECONDS = { [1] = 1.7, [2] = 1.3, [3] = 1.3, [10] = 1.1 },

	--- @type { [number]: number }
	QUICK_ROLL_STAGGER = { [1] = 0, [2] = 0.23, [3] = 0.23, [10] = 0.095 },

	-- The reel's curve, CS2's own: a cubic bezier's two control points (fast, then a long creep)
	--- @type { number }
	ROLL_CURVE = { 0.075, 0.82, 0.165, 1 },

	-- Where across the winning card the line stops, as a share of the card (CS's 10 % to 90 %)
	LAND_SPREAD = NumberRange.new(0.1, 0.9),

	-- Cards on a horizontal reel and the winner's place, then the ten-pack's columns
	STRIP_CARDS = 38,
	WIN_CARD = 33,
	COLUMN_CARDS = 26,
	COLUMN_WIN_CARD = 4,

	--[[
		Where the reels sit, in pixels of a 1920 x 1080 screen (scaled to the real one): each pack's band height and
		the middle of each band; the ten-pack's column size, the gap between columns and their middle
	]]
	--- @type { [number]: number }
	BAND_HEIGHT = { [1] = 300, [2] = 228, [3] = 228 },

	--- @type { [number]: { number } }
	BAND_Y = { [1] = { 480 }, [2] = { 414, 666 }, [3] = { 314, 566, 818 } },

	COLUMN_SIZE = Vector2.new(150, 660),
	COLUMN_GAP = 12,
	COLUMN_Y = 540,

	-- A card's height as a share of its band (its width of a column), its width to height, and the gap between cards
	CARD_FILL = 0.7,
	COLUMN_CARD_FILL = 0.92,
	CARD_ASPECT = 1.1169,
	CARD_GAP = 0.08,

	-- The tallest a card's name gets, as a share of the card's height: short names stay this size, long ones wrap and shrink
	CARD_NAME_TEXT = 0.1,

	-- The one-crate reel's lens over the line: its width in cards, and how much it enlarges
	LENS_WIDTH = 1.5,
	LENS_ZOOM = 1.06,
	LENS_DIM = 0.45,

	-- The fewest seconds between two ticks, and their pitch spread
	TICK_GAP = 0.042,
	TICK_PITCH = NumberRange.new(0.975, 1.035),

	-- Seconds a skip takes to bring every reel in, then the pause and the glide onto the card's centre
	SKIP_SECONDS = 0.38,
	SETTLE_DELAY = 0.24,
	SETTLE_SECONDS = 0.38,

	-- The heartbeat under an epic or legendary slowing in: from this rarity, seconds before it lands, and its beats
	TEASE_FROM_RARITY = "Epic",
	TEASE_SECONDS = 2.6,

	--- @type { number }
	TEASE_BEATS = { 0, 0.55, 1.02, 1.42, 1.74, 2, 2.2 },

	-- The golden reel's seconds (a legendary: which one), and while Quick open is on
	GOLDEN_SECONDS = 3.2,
	QUICK_GOLDEN_SECONDS = 1.5,

	-- The line's colour, the premium crate's, and the golden reel's band
	MARKER_COLOR = Color3.fromRGB(255, 210, 58),
	PREMIUM_MARKER_COLOR = Color3.fromRGB(255, 240, 168),
	GOLDEN_BAND_COLOR = Color3.fromRGB(60, 40, 0),
	GOLDEN_LINE_COLOR = Color3.fromRGB(255, 200, 40),

	--%%%%%%%%%%%%%%%%%%%% Results

	--[[
		Each legendary's own drop, by item id (Scripts/Client/Drops.lua); a legendary missing here gets the plain
		legendary reveal
	]]
	--- @type { [string]: string }
	LEGENDARY_DROPS = {
		BlackHoleGrenade = "BlackHole",
		VarietyGrenade = "Variety",
		Skin_Skeleton = "Skeleton",
		LowGravityPotion = "LowGravity",
	},

	-- Each rarity's reveal: its rays' transparency (1 shows none)
	--- @type { [string]: number }
	REVEAL_RAYS = { Common = 1, Uncommon = 0.84, Rare = 0.72, Epic = 0.58, Legendary = 0.4 },

	--[[
		Where a pack's cards land, in pixels of a 1920 x 1080 screen: the three-pack's row (card width, middle,
		spacing) and the ten-pack's grid of two rows of five
	]]
	TRIO_CARD_WIDTH = 380,
	TRIO_Y = 420,
	TRIO_SPACING = 450,
	TEN_CARD_WIDTH = 228,

	--- @type { number }
	TEN_ROWS_Y = { 268, 588 },

	TEN_SPACING = 300,

	-- Seconds between naming a pack's cards, and how long a legendary in a pack holds the middle
	TRIO_STEP = 0.42,
	TEN_STEP = 0.11,
	PACK_LEGENDARY_HOLD = 2.2,

	--%%%%%%%%%%%%%%%%%%%% Effects

	-- The pictures the effects draw with: art/crates' own, and the game's earlier glow, sparkle, coin and smiley
	--- @type { [string]: string }
	FX_TEXTURES = {
		Spark = "rbxassetid://97296507263981",
		Star = "rbxassetid://95186884093199",
		Glow = "rbxassetid://124537809204603",
		Ring = "rbxassetid://134479561564722",
		Coin = "rbxassetid://108986846988315",
		Smiley = "rbxassetid://75798902746408",
		Bone = "rbxassetid://108730143339514",
		Bubble = "rbxassetid://138788798394435",
	},

	-- The variety grenade's confetti colours
	--- @type { Color3 }
	CONFETTI_COLORS = {
		Color3.fromRGB(255, 77, 77),
		Color3.fromRGB(255, 179, 71),
		Color3.fromRGB(255, 224, 102),
		Color3.fromRGB(90, 220, 110),
		Color3.fromRGB(92, 225, 255),
		Color3.fromRGB(123, 107, 255),
		Color3.fromRGB(255, 95, 210),
	},

	-- The black hole's colours, and the frames of its disk's flipbook (columns, rows, a frame's pixels, frames a second)
	--- @type { Color3 }
	VORTEX_COLORS = { Color3.fromRGB(180, 92, 255), Color3.fromRGB(92, 225, 255), Color3.fromRGB(255, 95, 210) },

	DISK_GRID = Vector2.new(4, 8),
	DISK_FRAME = Vector2.new(256, 128),
	DISK_FPS = 18,

	--%%%%%%%%%%%%%%%%%%%% Showcase

	-- Seconds the showcase's rays and the premium halo take to turn once, and the crate's bob (seconds, screen share)
	RAYS_SPIN_SECONDS = 46,
	HALO_SPIN_SECONDS = 26,
	BOB_SECONDS = 3.2,
	BOB_HEIGHT = 0.012,

	-- The 3D crate on the pedestal: its camera (studs, looking along +Z at its front) and field of view
	SHOWCASE_CAMERA = Vector3.new(0, 5.2, -10.8),
	SHOWCASE_FOCUS = Vector3.new(0, 1.25, 0),
	SHOWCASE_FOV = 26,

	-- The crate's turn (radians) and how far and how slowly (seconds) it sways either side of it
	SHOWCASE_YAW = -0.45,
	SHOWCASE_SWAY = 0.4,
	SHOWCASE_SWAY_SECONDS = 7,

	-- The crate leaping off the pedestal when a crate is bought, as the bought crates drop onto the stage
	SHOWCASE_LIFT_TWEENINFO = TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In),

	-- The dim behind the screen: the premium crate's violet, and while a crate opens
	BACKDROP_PREMIUM_COLOR = Color3.fromRGB(10, 4, 32),
	BACKDROP_PREMIUM_TRANSPARENCY = 0.35,
	BACKDROP_OPEN_COLOR = Color3.fromRGB(4, 5, 10),
	BACKDROP_OPEN_TRANSPARENCY = 0.12,
	BACKDROP_LIGHT_TRANSPARENCY = 0.45,
	BACKDROP_TWEENINFO = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),

	--%%%%%%%%%%%%%%%%%%%% Gui

	GUI_NAME = "Crates",

	-- The currencies crates are paid in, one balance chip each (U_Pay<currency>), in the order a crate picks first
	--- @type { string }
	PAY_CURRENCIES = { "Coins", "Diamonds" },

	-- The x1 button's price while the crate is free (VIP's daily crate)
	PRICE_FREE = "FREE",

	--[[
		The lobby gui with the corner menu (U_Menu: S_Weapons and S_Skins open a crate's tab), and the badge on its
		Weapons button: this text while a free crate waits, else how many crates the player's coins open, shown as
		BADGE_MAX+ past BADGE_MAX
	]]
	LOBBY_GUI_NAME = "Lobby",
	BADGE_FREE = "FREE",
	BADGE_MAX = 9,
}

return _settings
