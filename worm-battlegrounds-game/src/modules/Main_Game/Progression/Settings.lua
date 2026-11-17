--- @class Progression_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Rewards

	-- The item each level gives when it's reached
	--- @type { [number]: string }
	LEVEL_REWARDS = {
		[25] = "Skin_Prisoner",
		[50] = "Skin_FbiAgent",
		[100] = "Skin_Wizard",
	},

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

	-- The plate's place at the top of the lobby, and where and how big it shows while the replay plays
	PLATE_POSITION = UDim2.fromScale(0.5, 0.018),
	REPLAY_POSITION = UDim2.fromScale(0.5, 0.3),
	REPLAY_SCALE = 1.8,
	PLATE_TWEENINFO = TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	PLATE_BACK_TWEENINFO = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),

	-- How dark the lobby gets behind the replay
	REPLAY_DIM = 0.45,

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
}

return _settings
