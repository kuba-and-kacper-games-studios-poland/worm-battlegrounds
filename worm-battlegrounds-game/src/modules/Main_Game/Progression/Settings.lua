--- @class Progression_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Rewards

	--[[
		The item each level gives when it's reached. Only items in the game: the Prisoner (25), FBI Agent (50) and Wizard
		(100) skins have no pieces or pictures yet, so no level gives them (the owner, 2026-11-25: "if it's not in the
		game don't grant it"); once they're made, they come back here and players past those levels get them then
	]]
	--- @type { [number]: string }
	LEVEL_REWARDS = {},

	--[[
		The starter weapons' looks each level opens (the owner's pick, 2026-11-24: crates never drop them, "the pros at
		90 level have the golden bazooka"): the weapon, Shiny or Golden (both deal +5% damage, Golden is gold too), and
		the line the unlock shows under its name. A weapon is the best variant its levels opened, or its copies made it
	]]
	--- @type { [number]: Progression_WeaponReward }
	WEAPON_REWARDS = {
		[10] = { Item = "Grenade", Variant = "Shiny", Line = "+5% damage and a pearly shine in every match" },
		[20] = { Item = "Shotgun", Variant = "Shiny", Line = "+5% damage and a pearly shine in every match" },
		[30] = { Item = "Bazooka", Variant = "Shiny", Line = "+5% damage and a pearly shine in every match" },
		[60] = { Item = "Grenade", Variant = "Golden", Line = "+5% damage, and solid gold in every match" },
		[75] = { Item = "Shotgun", Variant = "Golden", Line = "+5% damage, and solid gold in every match" },
		[90] = { Item = "Bazooka", Variant = "Golden", Line = "+5% damage, and the pros' solid gold in every match" },
	},

	--%%%%%%%%%%%%%%%%%%%% Weapon Unlock

	--[[
		Each variant's look on the unlock screen: the glow, rays and card (Crates' SHINY_COLOR and GOLDEN_COLOR), the
		diamond's and the title's gradients (Golden's is LEVEL UP!'s), the level tag's, the particles' colours, and the
		sound SHINY! or GOLDEN! slams in with
	]]
	--- @type { [string]: Progression_UnlockLook }
	UNLOCK_LOOKS = {
		Shiny = {
			Accent = Color3.fromRGB(255, 175, 235),
			Rays = Color3.fromRGB(255, 205, 245),
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 175, 235)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 190, 255)),
			}),
			Tag = ColorSequence.new(Color3.fromRGB(255, 205, 245), Color3.fromRGB(230, 130, 215)),
			Particles = { Color3.fromRGB(255, 175, 235), Color3.fromRGB(255, 255, 255), Color3.fromRGB(140, 255, 220), Color3.fromRGB(140, 190, 255) },
			Sound = "Reveal_Shiny",
		},
		Golden = {
			Accent = Color3.fromRGB(255, 205, 60),
			Rays = Color3.fromRGB(255, 200, 80),
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 246, 192)),
				ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 194, 26)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 138, 0)),
			}),
			Tag = ColorSequence.new(Color3.fromRGB(255, 224, 102), Color3.fromRGB(255, 181, 31)),
			Particles = { Color3.fromRGB(255, 210, 63), Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 140, 20) },
			Sound = "Variant_Golden",
		},
	},

	--[[
		The weapon's model on the card: its turn when placed (degrees; the view's Turn motion turns it on), the camera's
		field of view and distance (times the model's longest side), and Combat's Golden look (VARIANT_LOOKS' Gild,
		GildCover and VARIANT_COVER_GROW: Combat doesn't run in the lobby)
	]]
	UNLOCK_MODEL_YAW = 60,
	UNLOCK_MODEL_FOV = 30,
	UNLOCK_MODEL_DISTANCE = 1.75,

	--- @type { Color3 }
	UNLOCK_GILD = { Color3.fromRGB(70, 42, 10), Color3.fromRGB(255, 200, 70) },

	UNLOCK_GILD_COVER = 0.3,
	UNLOCK_GILD_GROW = 1.02,

	-- Seconds the diamond charges before it flashes open, and how far its rattle swings at the end (degrees)
	UNLOCK_CHARGE_SECONDS = 1.3,
	UNLOCK_RATTLE_DEGREES = 12,

	-- How see-through the dark, the rays, the back rays and the glow rest once the card is in
	UNLOCK_SHADE = 0.12,
	UNLOCK_RAYS = 0.45,
	UNLOCK_RAYS_BACK = 0.78,
	UNLOCK_GLOW = 0.3,

	-- How many stars and sparks the diamond bursts with, and sparkles a second rise round the card while it shows
	UNLOCK_STARS = 80,
	UNLOCK_SPARKS = 36,
	UNLOCK_SPARKLE_RATE = 14,

	UNLOCK_POP_TWEENINFO = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	UNLOCK_CARD_TWEENINFO = TweenInfo.new(0.52, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	UNLOCK_SLAM_TWEENINFO = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	UNLOCK_FADE_TWEENINFO = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	UNLOCK_FLASH_TWEENINFO = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

	--%%%%%%%%%%%%%%%%%%%% Frames

	--[[
		The prestige frames round a player's picture, from the level each unlocks (the owner's pick, 2026-11-17): the
		rim's colours, whether a light sweeps across it, and whether its colours spin round it
	]]
	--- @type { Progression_Tier }
	FRAME_TIERS = {
		{
			Name = "Rookie",
			Level = 1,
			Colors = { Color3.fromRGB(255, 170, 60), Color3.fromRGB(230, 120, 25) },
			Shine = false,
			Spin = false,
		},
		{
			Name = "Bronze",
			Level = 5,
			Colors = { Color3.fromRGB(240, 176, 122), Color3.fromRGB(160, 90, 42), Color3.fromRGB(224, 154, 90) },
			Shine = false,
			Spin = false,
		},
		{
			Name = "Silver",
			Level = 15,
			Colors = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(154, 167, 184), Color3.fromRGB(232, 238, 245) },
			Shine = false,
			Spin = false,
		},
		{
			Name = "Gold",
			Level = 25,
			Colors = { Color3.fromRGB(255, 243, 160), Color3.fromRGB(255, 176, 0), Color3.fromRGB(168, 100, 0), Color3.fromRGB(255, 224, 102) },
			Shine = true,
			Spin = false,
		},
		{
			Name = "Emerald",
			Level = 50,
			Colors = { Color3.fromRGB(184, 255, 207), Color3.fromRGB(22, 168, 90), Color3.fromRGB(11, 90, 50), Color3.fromRGB(125, 255, 176) },
			Shine = true,
			Spin = false,
		},
		{
			Name = "Diamond",
			Level = 75,
			Colors = { Color3.fromRGB(232, 253, 255), Color3.fromRGB(95, 216, 255), Color3.fromRGB(42, 127, 208), Color3.fromRGB(200, 244, 255) },
			Shine = true,
			Spin = false,
		},
		{
			Name = "Mythic",
			Level = 100,
			Colors = {
				Color3.fromRGB(255, 90, 209),
				Color3.fromRGB(255, 210, 63),
				Color3.fromRGB(90, 208, 106),
				Color3.fromRGB(63, 166, 255),
				Color3.fromRGB(167, 123, 255),
				Color3.fromRGB(255, 90, 209),
			},
			Shine = true,
			Spin = true,
		},
	},

	-- Seconds a shining frame's light takes to sweep across it, and the pause before the next sweep
	FRAME_SHINE_SECONDS = 1.2,
	FRAME_SHINE_PAUSE = 2,

	-- Degrees a second a spinning frame's colours turn
	FRAME_SPIN_SPEED = 120,

	--%%%%%%%%%%%%%%%%%%%% Plate

	-- How big the stage shows in the middle while the replay plays (its place and size there are the gui's)
	REPLAY_SCALE = 1,
	PLATE_TWEENINFO = TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	PLATE_BACK_TWEENINFO = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),

	-- How dark the lobby gets behind the replay (its panels and nameplates hide: Lobby's SetTakeover)
	REPLAY_DIM = 0.62,

	--[[
		How each prestige tier dresses the crest, by FRAME_TIERS' order (the owner, 2026-11-25: "based on level it gets
		better"): how see-through its rays, back rays and glow are (1 hides them), and how many times REPLAY_STARS a
		level-up throws
	]]
	--- @type { Progression_ReplayTierLook }
	REPLAY_TIER_LOOKS = {
		{ Rays = 1, RaysBack = 1, Glow = 0.72, Stars = 1 },
		{ Rays = 0.8, RaysBack = 1, Glow = 0.62, Stars = 1 },
		{ Rays = 0.7, RaysBack = 0.9, Glow = 0.52, Stars = 1.2 },
		{ Rays = 0.58, RaysBack = 0.82, Glow = 0.42, Stars = 1.4 },
		{ Rays = 0.5, RaysBack = 0.75, Glow = 0.36, Stars = 1.6 },
		{ Rays = 0.42, RaysBack = 0.68, Glow = 0.3, Stars = 1.8 },
		{ Rays = 0.32, RaysBack = 0.58, Glow = 0.22, Stars = 2.2 },
	},

	-- A rank pip the player hasn't reached yet
	PIP_OFF_COLOR = Color3.fromRGB(70, 72, 92),

	-- How big the crest punches in on a level-up, and how white a new rank flashes (1 none)
	CREST_PUNCH = 1.22,
	RANK_FLASH = 0.35,
	LEVEL_UP_TWEENINFO = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	RANK_FLASH_TWEENINFO = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

	--%%%%%%%%%%%%%%%%%%%% Rewards Card

	--[[
		The next reward's card at the bar's end: the glow behind a skin or an emote (a weapon's is its variant's Accent, a
		frame's its tier's colour), the tag's colours while it waits (NEXT) and once reached (UNLOCKED!), and how big it
		pops when reached
	]]
	REWARD_COLOR = Color3.fromRGB(255, 200, 80),
	REWARD_TAG_NEXT = ColorSequence.new(Color3.fromRGB(150, 156, 178), Color3.fromRGB(96, 100, 122)),
	REWARD_TAG_UNLOCKED = ColorSequence.new(Color3.fromRGB(255, 224, 102), Color3.fromRGB(255, 181, 31)),
	REWARD_POP = 1.35,

	-- Where the bar's middle stands across the stage while the card shows at its end (the gui's S_Track); without a card, 0.5
	TRACK_X = 0.45,

	-- The share of the bar under the diamonds that the crest on its left end covers: its fill starts there, so a little XP shows
	REST_FILL_START = 0.14,

	--[[
		Each XP tile's picture, by its line's Key (MatchRewards' XP_LABELS): the gamepad glyph for a match played (the
		owner, 2026-11-25: the play triangle read as a button, the rocket as a spaceship), the crown badge for a victory,
		the crosshair glyph for knockouts, the star badge for levels an admin added (a line with another Key, from an
		older saved replay, shows the match's)
	]]
	--- @type { [string]: string }
	XP_ICONS = {
		Played = "rbxassetid://86467359142321",
		Win = "rbxassetid://103399252005394",
		Knockouts = "rbxassetid://88744460498201",
		Admin = "rbxassetid://120533067442932",
	},

	--%%%%%%%%%%%%%%%%%%%% Replay

	-- Seconds after the lobby shows before the replay starts (the teleport card slides off first)
	REPLAY_DELAY = 1.2,

	-- Seconds between the XP lines popping in, and the seconds the bar takes to fill with one line's XP (at most)
	REPLAY_LINE_GAP = 0.35,
	REPLAY_FILL_SECONDS = 0.9,

	-- How many XP ticks play while a line fills the bar, and how far their pitch climbs from empty to full
	REPLAY_TICKS = 14,
	REPLAY_TICK_PITCH = NumberRange.new(0.9, 1.6),

	-- Seconds a level-up holds (LEVEL UP! and what it opened), and the hold before the plate flies back
	REPLAY_LEVEL_HOLD = 1.6,
	REPLAY_END_HOLD = 1.2,

	-- Seconds the new frame's sting (Frame_Unlock) swells before its hit, where the burst lands
	FRAME_UNLOCK_LEAD = 0.5,

	-- The particles: sparks flying from each line into the bar, and the stars a level-up throws
	--- @type { [string]: string }
	REPLAY_TEXTURES = {
		Spark = "rbxassetid://97296507263981",
		Star = "rbxassetid://95186884093199",
	},
	REPLAY_SPARKS = 10,
	REPLAY_STARS = 60,

	--- @type { Color3 }
	REPLAY_COLORS = { Color3.fromRGB(255, 210, 63), Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 140, 20) },

	--%%%%%%%%%%%%%%%%%%%% Diamonds

	--[[
		The diamonds a match paid play before the XP (the owner, 2026-11-24: "like Brawl Stars with the trophies"; diamonds
		since 2026-11-25, when coins went): one diamond flies for every DIAMONDS_PER_ICON (50 diamonds: 10 fly), at most
		DIAMOND_ICONS_MAX, DIAMOND_ICON_SIZE pixels on a 1920 x 1080 screen
	]]
	DIAMONDS_PER_ICON = 5,
	DIAMOND_ICONS_MAX = 30,
	DIAMOND_ICON_SIZE = 46,

	-- Seconds "+amount" shows over the snail before the diamonds burst out, and the most the flight may take
	DIAMOND_BURST_DELAY = 0.55,
	DIAMOND_FLIGHT_TIMEOUT = 4,

	-- How far each landing diamond's sound climbs in pitch, from the first to the last
	DIAMOND_TICK_CLIMB = 0.6,

	DIAMOND_POP_TWEENINFO = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	DIAMOND_HIDE_TWEENINFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),

	--%%%%%%%%%%%%%%%%%%%% Bought Diamonds

	--[[
		A bought pack plays the same payout once the shop closes (the owner, 2026-11-25: "make it satisfying - add like
		fanfares"), with more diamonds for a bigger pack: PURCHASE_ICONS_PER_ROOT times the amount's square root, between
		PURCHASE_ICONS_MIN and PURCHASE_ICONS_MAX (250: 20, 1,000: 40, 2,500: 63)
	]]
	PURCHASE_ICONS_PER_ROOT = 1.25,
	PURCHASE_ICONS_MIN = 20,
	PURCHASE_ICONS_MAX = 64,

	-- Seconds after the shop closes before the payout starts (the window's close tween)
	PURCHASE_DELAY = 0.35,

	-- The gift's pop as "+amount" shows, and the level-up fanfare as the last diamond lands
	PURCHASE_POP_SOUND = "Free_Claim",
	PURCHASE_LAND_SOUND = "Level_Up",

	--[[
		The potion vignette, borrowed for the payout: gem blue, breathing between two strengths (its edges'
		BackgroundTransparency) while the diamonds fly, a flash as they land, then gone
	]]
	PURCHASE_VIGNETTE_COLOR = Color3.fromRGB(60, 140, 255),

	--- @type { number }
	PURCHASE_VIGNETTE_BREATH = { 0.1, 0.45 },

	PURCHASE_VIGNETTE_IN_TWEENINFO = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	PURCHASE_VIGNETTE_BREATH_TWEENINFO = TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	PURCHASE_VIGNETTE_FLASH_TWEENINFO = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	PURCHASE_VIGNETTE_OUT_TWEENINFO = TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
}

return _settings
