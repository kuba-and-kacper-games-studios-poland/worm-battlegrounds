--[[
	Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   __       __                  __            __
--  /  \     /  |                /  |          /  |
--  $$  \   /$$ |  ______    ____$$ | __    __ $$ |  ______
--  $$$  \ /$$$ | /      \  /    $$ |/  |  /  |$$ | /      \
--  $$$$  /$$$$ |/$$$$$$  |/$$$$$$$ |$$ |  $$ |$$ |/$$$$$$  |
--  $$ $$ $$/$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |$$    $$ |
--  $$ |$$$/ $$ |$$ \__$$ |$$ \__$$ |$$ \__$$ |$$ |$$$$$$$$/
--  $$ | $/  $$ |$$    $$/ $$    $$ |$$    $$/ $$ |$$       |
--  $$/      $$/  $$$$$$/   $$$$$$$/  $$$$$$/  $$/  $$$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- @class UIEmitter_Defaults
local Defaults = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Tunables

--[[ Simulation ]]

Defaults.MAX_DELTA_TIME = 1 / 30
Defaults.MAX_SPAWNS_PER_STEP = 24
Defaults.MAX_INITIAL_SPAWNS_PER_STEP = 2
Defaults.CULL_INTERVAL = 0.08

--[[ Pooling ]]

Defaults.MAX_POOL_SIZE = 256

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Config Keys

Defaults.CONFIG_KEYS = {

	--[[ Placement ]]

	Parent = true,
	Container = true,
	EmitterPosition = true,
	EmissionArea = true,
	EmissionShape = true,

	--[[ Appearance ]]

	Texture = true,
	ZIndex = true,
	Squash = true,
	Color = true,
	Size = true,
	SizeSpace = true,
	SizeScale = true,
	AspectRatio = true,
	Transparency = true,
	TransparencyScale = true,
	Properties = true,

	--[[ Flipbook ]]

	FlipbookImageSize = true,
	FlipbookGridX = true,
	FlipbookGridY = true,
	FlipbookFPS = true,
	FlipbookStartRandom = true,
	FlipbookMode = true,

	--[[ Motion ]]

	Velocity = true,
	InitialVelocity = true,
	Speed = true,
	Direction = true,
	Gravity = true,
	Acceleration = true,
	Drag = true,
	SpreadAngle = true,
	Rotation = true,
	RotationSpeed = true,
	FaceMovementDirection = true,

	--[[ Shake ]]

	ShakeSpeed = true,
	ShakeDirectionChanges = true,
	ShakeDirectionBlendDuration = true,
	ShakeLockVertical = true,
	HorizontalDrift = true,

	--[[ Orbit ]]

	OrbitSpeed = true,
	OrbitRadius = true,
	OrbitRadiusScale = true,

	--[[ Attraction ]]

	AttractTo = true,
	AttractToSpace = true,
	AttractAfter = true,
	AttractStrength = true,
	AttractMaxSpeed = true,
	AttractStopOnArrive = true,
	AttractDestroyOnArrive = true,
	AttractLiveFromEmitter = true,
	AttractPauseAtProgress = true,
	AttractPauseMaxTime = true,
	AttractArriveRadius = true,
	AttractReleaseDuration = true,
	AttractArriveOnlyWhenPaused = true,
	AttractOnArrive = true,

	--[[ Lifetime ]]

	Lifetime = true,
	LifeTime = true,

	--[[ Emission ]]

	Rate = true,
	MaxParticles = true,
	CullOffscreen = true,
	InitialParticles = true,
	InitialAgeProgress = true,
	InitialSpawnPerStep = true,
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Defaults Table

Defaults.DEFAULTS = {

	--[[ Placement ]]

	EmitterPosition = nil,
	EmissionArea = Vector2.zero,
	EmissionShape = "Point",

	--[[ Appearance ]]

	Texture = "",
	ZIndex = 0,
	Squash = 1,
	Color = ColorSequence.new(Color3.new(1, 1, 1)),
	Size = NumberSequence.new(0.1),
	SizeSpace = "Scale",
	SizeScale = nil,
	AspectRatio = 1,
	Transparency = 0,
	TransparencyScale = nil,
	Properties = {},

	--[[ Flipbook ]]

	FlipbookImageSize = nil,
	FlipbookGridX = nil,
	FlipbookGridY = nil,
	FlipbookFPS = nil,
	FlipbookStartRandom = false,
	FlipbookMode = "Loop",

	--[[ Motion ]]

	Velocity = 64,
	InitialVelocity = nil,
	Speed = nil,
	Direction = Vector2.new(0, -1),
	Gravity = Vector2.zero,
	Acceleration = nil,
	Drag = 0,
	SpreadAngle = 0,
	Rotation = 0,
	RotationSpeed = 0,
	FaceMovementDirection = false,

	--[[ Shake ]]

	ShakeSpeed = nil,
	ShakeDirectionChanges = NumberRange.new(2, 4),
	ShakeDirectionBlendDuration = 0.6,
	ShakeLockVertical = true,
	HorizontalDrift = nil,

	--[[ Orbit ]]

	OrbitSpeed = nil,
	OrbitRadius = nil,
	OrbitRadiusScale = nil,

	--[[ Attraction ]]

	AttractTo = nil,
	AttractToSpace = "Container",
	AttractAfter = 0,
	AttractStrength = 0,
	AttractMaxSpeed = 0,
	AttractStopOnArrive = false,
	AttractDestroyOnArrive = false,
	AttractLiveFromEmitter = false,
	AttractPauseAtProgress = nil,
	AttractPauseMaxTime = nil,
	AttractArriveRadius = 0,
	AttractReleaseDuration = nil,
	AttractArriveOnlyWhenPaused = nil,
	AttractOnArrive = nil,

	--[[ Lifetime ]]

	Lifetime = 1,
	LifeTime = nil,

	--[[ Emission ]]

	Rate = 10,
	MaxParticles = 0,
	CullOffscreen = true,
	InitialParticles = 0,
	InitialAgeProgress = NumberRange.new(0.2, 0.7),
	InitialSpawnPerStep = nil,
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Defaults
