--[[
	Created By:     Nari
]]

local _localName: string = "UIEmitter"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Defaults = require(script.Parent:FindFirstChild("Defaults")) --- @type UIEmitter_Defaults
local Sampler = require(script.Parent:FindFirstChild("Sampler")) --- @type UIEmitter_Sampler

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local CONFIG_KEYS = Defaults.CONFIG_KEYS --- @type { [string]: boolean }
local DEFAULTS = Defaults.DEFAULTS --- @type { [string]: any }

local WARNED_PARTICLE_EMITTER_IGNORE: boolean = false

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

--- @class UIEmitter_Config
local Config = {
	CONFIG_KEYS = CONFIG_KEYS,
	DEFAULTS = DEFAULTS,
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Normalization

--%%%%%%%%%%%%%%%%%%%% Normalize Texture

--[[
	Converts string or numeric texture values into a usable Roblox image id.
]]
--- @return string
function Config._normalizeTexture(texture: any)
	--[[ Defaults ]]

	if texture == nil then
		return DEFAULTS.Texture
	end

	--[[ Normalizing ]]

	assert(typeof(texture) == "string", `[{_localName}::{script.Name}]: Texture must be a string.`)

	if texture == "" or texture:match("^rbxassetid://") or texture:match("^rbxthumb://") then
		return texture
	end

	if texture:match("^%d+$") then
		return "rbxassetid://" .. texture
	end

	return texture
end

--%%%%%%%%%%%%%%%%%%%% Normalize Color

--[[
	Converts color input into a ColorSequence.
]]
--- @return ColorSequence
function Config._normalizeColor(color: any)
	--[[ Type Dispatch ]]

	local colorType: string = typeof(color)

	if colorType == "ColorSequence" then
		return color
	end

	if colorType == "Color3" then
		return ColorSequence.new(color)
	end

	error(`[{_localName}::{script.Name}]: Color must be a Color3 or ColorSequence.`, 3)
end

--%%%%%%%%%%%%%%%%%%%% Normalize Size

--[[
	Validates fixed, random, and curve-based size input.
]]
--- @return number | NumberRange | NumberSequence | table
function Config._normalizeSize(size: any)
	--[[ Checks ]]

	if Sampler.CanUseNumberCurve(size) then
		return size
	end

	error(`[{_localName}::{script.Name}]: Size must be a number, NumberRange, NumberSequence, or (min, max) table.`, 3)
end

--%%%%%%%%%%%%%%%%%%%% Normalize Emission Area

--[[
	Converts emission area input into container-relative scale.
]]
--- @return Vector2
function Config._normalizeEmissionArea(area: any)
	--[[ Type Dispatch ]]

	local areaType: string = typeof(area)

	if areaType == "Vector2" then
		return area
	end

	if areaType == "number" then
		return Vector2.new(area, area)
	end

	error(`[{_localName}::{script.Name}]: EmissionArea must be a number or Vector2.`, 3)
end

--%%%%%%%%%%%%%%%%%%%% Normalize Gravity

--[[
	Converts gravity or acceleration input into UI-space Vector2.
]]
--- @return Vector2 | any
function Config._normalizeGravity(value: any)
	--[[ World To UI ]]

	if typeof(value) == "Vector3" then
		-- Roblox world Y+ is up while UI Y+ is down.
		return Vector2.new(value.X, -value.Y)
	end

	return value
end

--%%%%%%%%%%%%%%%%%%%% Normalize Flipbook Image Size

--[[
	Converts flipbook image size input into Vector2 pixels.
]]
--- @return Vector2?
function Config._normalizeFlipbookImageSize(value: any)
	--[[ Optional ]]

	if value == nil then
		return nil
	end

	--[[ Type Dispatch ]]

	if typeof(value) == "Vector2" then
		return value
	end

	error(`[{_localName}::{script.Name}]: FlipbookImageSize must be a Vector2.`, 3)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Queries

--%%%%%%%%%%%%%%%%%%%% Can Resolve Attract To

--[[
	Checks whether a value can be resolved as an attraction target.
]]
--- @return boolean
function Config._canResolveAttractTo(value: any)
	--[[ Type Dispatch ]]

	local valueType: string = typeof(value)

	return value == nil or valueType == "UDim2" or valueType == "Vector2" or valueType == "function" or (valueType == "Instance" and value:IsA("GuiObject"))
end

--%%%%%%%%%%%%%%%%%%%% Is Flipbook Enabled

--[[
	Returns whether flipbook animation is fully configured.
]]
--- @param cfg UIEmitter_CompiledConfig
--- @return boolean
function Config.IsFlipbookEnabled(cfg)
	return cfg.FlipbookImageSize ~= nil and cfg.FlipbookGridX ~= nil and cfg.FlipbookGridY ~= nil and cfg.FlipbookFPS ~= nil
end

--%%%%%%%%%%%%%%%%%%%% Resolve Position In Bounds

--[[
	Resolves a configured position against already-read container bounds.
]]
--- @return Vector2
function Config.ResolvePositionInBounds(position: any, containerPosition: Vector2, containerSize: Vector2)
	--[[ Type Dispatch ]]

	local positionType: string = typeof(position)

	if positionType == "UDim2" then
		return containerPosition + Vector2.new(containerSize.X * position.X.Scale + position.X.Offset, containerSize.Y * position.Y.Scale + position.Y.Offset)
	end

	if positionType == "Vector2" then
		return containerPosition + position
	end

	return containerPosition + containerSize * 0.5
end

--%%%%%%%%%%%%%%%%%%%% Resolve Position To Absolute

--[[
	Resolves a configured position into an absolute screen point.
]]
--- @return Vector2
function Config.ResolvePositionToAbsolute(position: any, container: GuiObject)
	return Config.ResolvePositionInBounds(position, container.AbsolutePosition, container.AbsoluteSize)
end

--%%%%%%%%%%%%%%%%%%%% Get Spawn Absolute Point

--[[
	Returns a random absolute spawn point from the emitter shape using cached frame layout.
]]
--- @param cfg UIEmitter_CompiledConfig
--- @param frame UIEmitter_Frame
--- @return Vector2
function Config.GetSpawnAbsolutePoint(cfg, frame)
	--[[ Base Point ]]

	local point: Vector2 = frame.SpawnPoint
	local area: Vector2 = frame.SpawnArea
	local shape: string = cfg.EmissionShape

	--[[ Shape Offset ]]

	if shape == "point" or (area.X <= 0 and area.Y <= 0) then
		return point
	end

	if shape == "circle" then
		local radius: number = math.min(area.X, area.Y) * 0.5
		local angle: number = math.random() * math.pi * 2
		-- Square root keeps random points evenly spread inside the circle.
		local distance: number = math.sqrt(math.random()) * radius

		return point + Vector2.new(math.cos(angle), math.sin(angle)) * distance
	end

	return point + Vector2.new(Sampler.RandomBetween(-area.X * 0.5, area.X * 0.5), Sampler.RandomBetween(-area.Y * 0.5, area.Y * 0.5))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Particle Emitter Adapter

--%%%%%%%%%%%%%%%%%%%% Warn Ignored Particle Emitter Fields

--[[
	Warns once about ParticleEmitter fields that do not map cleanly to UI.
]]
function Config._warnIgnoredParticleEmitterFields()
	--[[ Already Warned ]]

	if WARNED_PARTICLE_EMITTER_IGNORE then
		return
	end

	WARNED_PARTICLE_EMITTER_IGNORE = true
	warn(`[{_localName}::{script.Name}]: ParticleEmitter adapter maps visual curves, lifetime, rate, drag, speed, spread, texture, and acceleration. Shape and 3D-only fields are ignored.`)
end

--%%%%%%%%%%%%%%%%%%%% Config From Particle Emitter

--[[
	Maps a Roblox ParticleEmitter into UIEmitter config.
]]
--- @return UIEmitter_Params
function Config._configFromParticleEmitter(emitter: ParticleEmitter)
	--[[ Warning ]]

	Config._warnIgnoredParticleEmitterFields()

	--[[ Mapping ]]

	local parent: Instance? = emitter.Parent

	assert(parent and typeof(parent) == "Instance" and parent:IsA("GuiObject"), `[{_localName}::{script.Name}]: ParticleEmitter.Parent must be a GuiObject for UI emission.`)

	local acceleration: Vector3 = emitter.Acceleration
	local spread: Vector2 = emitter.SpreadAngle

	return {
		Parent = parent,
		Container = parent,
		Texture = emitter.Texture,
		Color = emitter.Color,
		Size = emitter.Size,
		Transparency = emitter.Transparency,
		Lifetime = emitter.Lifetime,
		Rate = emitter.Rate,
		Drag = emitter.Drag,
		Rotation = emitter.Rotation,
		RotationSpeed = emitter.RotSpeed,
		Speed = emitter.Speed,
		Velocity = DEFAULTS.Velocity,
		Direction = Vector2.new(0, -1),
		-- Roblox acceleration Y+ is upward; UI Y+ moves down the screen.
		Gravity = Vector2.new(acceleration.X, -acceleration.Y),
		-- Average asymmetric 3D spread into a single UI cone.
		SpreadAngle = (spread.X + spread.Y) * 0.5,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Validation

--%%%%%%%%%%%%%%%%%%%% Validate Table Params

--[[
	Returns a normalized and validated config table.
]]
--- @param params { [string]: any }
--- @return UIEmitter_CompiledConfig
function Config.ValidateTableParams(params)
	--[[ Key Validation ]]

	for key: string in params do
		if not CONFIG_KEYS[key] then
			error(`[{_localName}::{script.Name}]: Unknown parameter "{key}".`, 3)
		end
	end

	--[[ Defaults Merge ]]

	--- @type UIEmitter_CompiledConfig
	local cfg = table.clone(DEFAULTS)

	for key: string, value: any in params do
		cfg[key] = value
	end

	--[[ Aliases ]]

	-- LifeTime and Acceleration keep the API close to Roblox naming.
	if cfg.LifeTime ~= nil then
		cfg.Lifetime = cfg.LifeTime
	end

	if cfg.Acceleration ~= nil then
		cfg.Gravity = cfg.Acceleration
	end

	-- Clear aliases so a later Lifetime or Gravity write is not overridden by a stale alias.
	cfg.LifeTime = nil
	cfg.Acceleration = nil

	--[[ Normalization ]]

	cfg.Texture = Config._normalizeTexture(cfg.Texture)
	cfg.Color = Config._normalizeColor(cfg.Color)
	cfg.Size = Config._normalizeSize(cfg.Size)
	cfg.Gravity = Config._normalizeGravity(cfg.Gravity)
	cfg.EmissionArea = Config._normalizeEmissionArea(cfg.EmissionArea)
	cfg.FlipbookImageSize = Config._normalizeFlipbookImageSize(cfg.FlipbookImageSize)

	if cfg.Container == nil then
		cfg.Container = cfg.Parent
	end

	if cfg.Properties == nil then
		cfg.Properties = {}
	end

	--[[ Placement ]]

	assert(cfg.Parent and typeof(cfg.Parent) == "Instance" and cfg.Parent:IsA("GuiObject"), `[{_localName}::{script.Name}]: Parent must be a GuiObject.`)
	assert(typeof(cfg.Container) == "Instance" and cfg.Container:IsA("GuiObject"), `[{_localName}::{script.Name}]: Container must be a GuiObject.`)
	assert(typeof(cfg.EmissionShape) == "string", `[{_localName}::{script.Name}]: EmissionShape must be a string.`)
	assert(cfg.EmitterPosition == nil or typeof(cfg.EmitterPosition) == "UDim2" or typeof(cfg.EmitterPosition) == "Vector2", `[{_localName}::{script.Name}]: EmitterPosition must be nil, UDim2, or Vector2.`)
	assert(cfg.EmissionArea.X >= 0 and cfg.EmissionArea.Y >= 0, `[{_localName}::{script.Name}]: EmissionArea scale must be non-negative.`)

	--[[ Appearance ]]

	local squash: any = cfg.Squash

	assert(typeof(cfg.ZIndex) == "number", `[{_localName}::{script.Name}]: ZIndex must be a number.`)
	assert(Sampler.CanUseNumberCurve(squash), `[{_localName}::{script.Name}]: Squash must be a number, NumberRange, NumberSequence, or (min, max) table.`)
	assert(Sampler.CanUseNumberCurve(cfg.Transparency), `[{_localName}::{script.Name}]: Transparency must be a number, NumberRange, NumberSequence, or (min, max) table.`)
	assert(cfg.SizeScale == nil or Sampler.CanSampleNumber(cfg.SizeScale), `[{_localName}::{script.Name}]: SizeScale must be nil, a number, NumberRange, or (min, max) table.`)
	assert(cfg.TransparencyScale == nil or Sampler.CanSampleNumber(cfg.TransparencyScale), `[{_localName}::{script.Name}]: TransparencyScale must be nil, a number, NumberRange, or (min, max) table.`)
	assert(cfg.AspectRatio == nil or (typeof(cfg.AspectRatio) == "number" and cfg.AspectRatio > 0), `[{_localName}::{script.Name}]: AspectRatio must be nil or a number > 0.`)
	assert(typeof(cfg.Properties) == "table", `[{_localName}::{script.Name}]: Properties must be a table.`)
	cfg.Properties = table.clone(cfg.Properties)

	--[[ Flipbook ]]

	local hasAnyFlipbook: boolean = cfg.FlipbookImageSize ~= nil or cfg.FlipbookGridX ~= nil or cfg.FlipbookGridY ~= nil or cfg.FlipbookFPS ~= nil

	if hasAnyFlipbook then
		assert(cfg.Texture ~= "", `[{_localName}::{script.Name}]: Flipbook requires a non-empty Texture.`)
		assert(typeof(cfg.FlipbookImageSize) == "Vector2" and cfg.FlipbookImageSize.X > 0 and cfg.FlipbookImageSize.Y > 0, `[{_localName}::{script.Name}]: FlipbookImageSize must be a Vector2 with both axes > 0.`)
		assert(typeof(cfg.FlipbookGridX) == "number" and cfg.FlipbookGridX >= 1 and cfg.FlipbookGridX == math.floor(cfg.FlipbookGridX), `[{_localName}::{script.Name}]: FlipbookGridX must be an integer >= 1.`)
		assert(typeof(cfg.FlipbookGridY) == "number" and cfg.FlipbookGridY >= 1 and cfg.FlipbookGridY == math.floor(cfg.FlipbookGridY), `[{_localName}::{script.Name}]: FlipbookGridY must be an integer >= 1.`)
		assert(Sampler.CanSampleNumber(cfg.FlipbookFPS), `[{_localName}::{script.Name}]: FlipbookFPS must be a number, NumberRange, or (min, max) table.`)
	end

	assert(typeof(cfg.FlipbookStartRandom) == "boolean", `[{_localName}::{script.Name}]: FlipbookStartRandom must be a boolean.`)
	assert(typeof(cfg.FlipbookMode) == "string", `[{_localName}::{script.Name}]: FlipbookMode must be a string.`)

	--[[ Motion ]]

	local drag: any = cfg.Drag

	assert(Sampler.CanUseNumberCurve(drag), `[{_localName}::{script.Name}]: Drag must be a number, NumberRange, NumberSequence, or (min, max) table.`)
	assert(cfg.InitialVelocity == nil or typeof(cfg.InitialVelocity) == "function", `[{_localName}::{script.Name}]: InitialVelocity must be nil or a function.`)
	assert(Sampler.CanUseNumberCurve(cfg.Velocity) or typeof(cfg.Velocity) == "Vector2", `[{_localName}::{script.Name}]: Velocity must be a number, Vector2, NumberRange, NumberSequence, or table.`)
	assert(cfg.Speed == nil or Sampler.CanUseNumberCurve(cfg.Speed), `[{_localName}::{script.Name}]: Speed must be a number, NumberRange, NumberSequence, or (min, max) table.`)
	assert(Sampler.CanSampleVector2(cfg.Direction), `[{_localName}::{script.Name}]: Direction must be a Vector2 or two-axis table.`)
	assert(Sampler.CanSampleVector2(cfg.Gravity), `[{_localName}::{script.Name}]: Gravity must be a Vector2, Vector3, or two-axis table.`)
	assert(Sampler.CanUseNumberCurve(cfg.SpreadAngle), `[{_localName}::{script.Name}]: SpreadAngle must be a number, NumberRange, NumberSequence, or (min, max) table.`)
	assert(Sampler.CanUseNumberCurve(cfg.Rotation), `[{_localName}::{script.Name}]: Rotation must be a number, NumberRange, NumberSequence, or (min, max) table.`)
	assert(Sampler.CanUseNumberCurve(cfg.RotationSpeed), `[{_localName}::{script.Name}]: RotationSpeed must be a number, NumberRange, NumberSequence, or (min, max) table.`)
	assert(typeof(cfg.FaceMovementDirection) == "boolean", `[{_localName}::{script.Name}]: FaceMovementDirection must be a boolean.`)

	--[[ Shake ]]

	assert(cfg.ShakeSpeed == nil or Sampler.CanUseNumberCurve(cfg.ShakeSpeed), `[{_localName}::{script.Name}]: ShakeSpeed must be nil, a number, NumberRange, NumberSequence, or (min, max) table.`)
	assert(cfg.ShakeDirectionChanges == nil or Sampler.CanSampleNumber(cfg.ShakeDirectionChanges), `[{_localName}::{script.Name}]: ShakeDirectionChanges must be nil, a number, NumberRange, or (min, max) table.`)
	assert(
		cfg.ShakeDirectionBlendDuration == nil or Sampler.CanUseNumberCurve(cfg.ShakeDirectionBlendDuration),
		`[{_localName}::{script.Name}]: ShakeDirectionBlendDuration must be nil, a number, NumberRange, NumberSequence, or (min, max) table.`
	)
	assert(typeof(cfg.ShakeLockVertical) == "boolean", `[{_localName}::{script.Name}]: ShakeLockVertical must be a boolean.`)
	assert(cfg.HorizontalDrift == nil or Sampler.CanUseNumberCurve(cfg.HorizontalDrift), `[{_localName}::{script.Name}]: HorizontalDrift must be nil, a number, NumberRange, NumberSequence, or (min, max) table.`)

	--[[ Orbit ]]

	assert(cfg.OrbitSpeed == nil or Sampler.CanUseNumberCurve(cfg.OrbitSpeed), `[{_localName}::{script.Name}]: OrbitSpeed must be nil, a number, NumberRange, NumberSequence, or (min, max) table.`)
	assert(cfg.OrbitRadius == nil or Sampler.CanUseNumberCurve(cfg.OrbitRadius), `[{_localName}::{script.Name}]: OrbitRadius must be nil, a number, NumberRange, NumberSequence, or (min, max) table.`)
	assert(cfg.OrbitRadiusScale == nil or Sampler.CanUseNumberCurve(cfg.OrbitRadiusScale), `[{_localName}::{script.Name}]: OrbitRadiusScale must be nil, a number, NumberRange, NumberSequence, or (min, max) table.`)

	--[[ Attraction ]]

	assert(Config._canResolveAttractTo(cfg.AttractTo), `[{_localName}::{script.Name}]: AttractTo must be nil, UDim2, Vector2, GuiObject, or function.`)
	assert(typeof(cfg.AttractToSpace) == "string", `[{_localName}::{script.Name}]: AttractToSpace must be Container or Absolute.`)
	assert(Sampler.CanSampleNumber(cfg.AttractAfter), `[{_localName}::{script.Name}]: AttractAfter must be a number, NumberRange, or (min, max) table.`)
	assert(Sampler.CanUseNumberCurve(cfg.AttractStrength), `[{_localName}::{script.Name}]: AttractStrength must be a number, NumberRange, NumberSequence, or (min, max) table.`)
	assert(Sampler.CanUseNumberCurve(cfg.AttractMaxSpeed), `[{_localName}::{script.Name}]: AttractMaxSpeed must be a number, NumberRange, NumberSequence, or (min, max) table.`)
	assert(typeof(cfg.AttractStopOnArrive) == "boolean", `[{_localName}::{script.Name}]: AttractStopOnArrive must be a boolean.`)
	assert(typeof(cfg.AttractDestroyOnArrive) == "boolean", `[{_localName}::{script.Name}]: AttractDestroyOnArrive must be a boolean.`)
	assert(typeof(cfg.AttractLiveFromEmitter) == "boolean", `[{_localName}::{script.Name}]: AttractLiveFromEmitter must be a boolean.`)
	assert(cfg.AttractPauseAtProgress == nil or Sampler.CanSampleNumber(cfg.AttractPauseAtProgress), `[{_localName}::{script.Name}]: AttractPauseAtProgress must be nil, a number, NumberRange, or (min, max) table.`)
	assert(cfg.AttractPauseMaxTime == nil or Sampler.CanSampleNumber(cfg.AttractPauseMaxTime), `[{_localName}::{script.Name}]: AttractPauseMaxTime must be nil, a number, NumberRange, or (min, max) table.`)
	assert(cfg.AttractReleaseDuration == nil or Sampler.CanSampleNumber(cfg.AttractReleaseDuration), `[{_localName}::{script.Name}]: AttractReleaseDuration must be nil, a number, NumberRange, or (min, max) table.`)
	assert(Sampler.CanUseNumberCurve(cfg.AttractArriveRadius), `[{_localName}::{script.Name}]: AttractArriveRadius must be a number, NumberRange, NumberSequence, or (min, max) table.`)
	assert(cfg.AttractOnArrive == nil or typeof(cfg.AttractOnArrive) == "function", `[{_localName}::{script.Name}]: AttractOnArrive must be nil or a function.`)

	--[[ Lifetime ]]

	assert(Sampler.CanSampleNumber(cfg.Lifetime), `[{_localName}::{script.Name}]: Lifetime must be a number, NumberRange, or (min, max) table.`)

	--[[ Emission ]]

	assert(typeof(cfg.InitialParticles) == "number" and cfg.InitialParticles >= 0, `[{_localName}::{script.Name}]: InitialParticles must be a number >= 0.`)
	assert(cfg.InitialAgeProgress == nil or Sampler.CanSampleNumber(cfg.InitialAgeProgress), `[{_localName}::{script.Name}]: InitialAgeProgress must be nil, a number, NumberRange, or (min, max) table.`)
	assert(cfg.InitialSpawnPerStep == nil or (typeof(cfg.InitialSpawnPerStep) == "number" and cfg.InitialSpawnPerStep > 0), `[{_localName}::{script.Name}]: InitialSpawnPerStep must be nil or a number > 0.`)
	assert(typeof(cfg.Rate) == "number" and cfg.Rate >= 0, `[{_localName}::{script.Name}]: Rate must be a number >= 0.`)
	assert(typeof(cfg.MaxParticles) == "number" and cfg.MaxParticles >= 0, `[{_localName}::{script.Name}]: MaxParticles must be a number >= 0.`)
	assert(typeof(cfg.CullOffscreen) == "boolean", `[{_localName}::{script.Name}]: CullOffscreen must be a boolean.`)

	--[[ Enum Normalization ]]

	cfg.EmissionShape = string.lower(cfg.EmissionShape)
	cfg.AttractToSpace = string.lower(cfg.AttractToSpace)
	cfg.SizeSpace = string.lower(cfg.SizeSpace)
	cfg.FlipbookMode = string.lower(cfg.FlipbookMode)

	assert(cfg.EmissionShape == "point" or cfg.EmissionShape == "rectangle" or cfg.EmissionShape == "circle", `[{_localName}::{script.Name}]: EmissionShape must be Point, Rectangle, or Circle.`)
	assert(cfg.AttractToSpace == "container" or cfg.AttractToSpace == "absolute", `[{_localName}::{script.Name}]: AttractToSpace must be Container or Absolute.`)
	assert(cfg.SizeSpace == "offset" or cfg.SizeSpace == "scale", `[{_localName}::{script.Name}]: SizeSpace must be Offset or Scale.`)
	assert(
		cfg.FlipbookMode == "loop" or cfg.FlipbookMode == "oneshot" or cfg.FlipbookMode == "pingpong" or cfg.FlipbookMode == "random",
		`[{_localName}::{script.Name}]: FlipbookMode must be Loop, OneShot, PingPong, or Random.`
	)

	--[[ Derived Defaults ]]

	cfg._arriveOnlyWhenPausedDerived = cfg.AttractArriveOnlyWhenPaused == nil

	if cfg.AttractArriveOnlyWhenPaused == nil then
		cfg.AttractArriveOnlyWhenPaused = cfg.AttractPauseAtProgress ~= nil
	end

	assert(typeof(cfg.AttractArriveOnlyWhenPaused) == "boolean", `[{_localName}::{script.Name}]: AttractArriveOnlyWhenPaused must be a boolean.`)

	--[[ Flipbook Derived ]]

	if Config.IsFlipbookEnabled(cfg) then
		cfg.FlipbookCellSize = Vector2.new(cfg.FlipbookImageSize.X / cfg.FlipbookGridX, cfg.FlipbookImageSize.Y / cfg.FlipbookGridY)
		cfg.FlipbookFrameCount = cfg.FlipbookGridX * cfg.FlipbookGridY
	else
		cfg.FlipbookCellSize = nil
		cfg.FlipbookFrameCount = nil
	end

	return cfg
end

--%%%%%%%%%%%%%%%%%%%% Clone For Update

--[[
	Returns the user-facing params of a validated config so one key can be changed and re-validated.
]]
--- @param cfg UIEmitter_CompiledConfig
--- @return { [string]: any }
function Config.CloneForUpdate(cfg)
	--[[ Cloning ]]

	--- @type { [string]: any }
	local params = table.clone(cfg)

	--[[ Derived Fields ]]

	-- Derived fields are recomputed during validation.
	params.FlipbookCellSize = nil
	params.FlipbookFrameCount = nil
	params._arriveOnlyWhenPausedDerived = nil

	if cfg._arriveOnlyWhenPausedDerived then
		params.AttractArriveOnlyWhenPaused = nil
	end

	--[[ Returning ]]

	return params
end

--%%%%%%%%%%%%%%%%%%%% Compile

--[[
	Builds the per-config spawn plan so hot paths skip repeated type dispatch and curve parsing.
]]
--- @param cfg UIEmitter_CompiledConfig
--- @return UIEmitter_Plan
function Config.Compile(cfg)
	--[[ Local Variables ]]

	local hasTexture: boolean = cfg.Texture ~= ""
	local velocity: any = cfg.Velocity
	local velocityKind: "Vector" | "Range" | "Directional" = "Directional"
	local velocityDynamic: boolean = false
	local velocityConstant: Vector3? = nil

	--[[ Velocity ]]

	if typeof(velocity) == "Vector2" then
		velocityKind = "Vector"
		velocityConstant = Vector3.new(velocity.X, velocity.Y, 0)
	elseif Sampler.IsVelocityVectorRange(velocity) then
		velocityKind = "Range"
		velocityDynamic = Sampler.HasNumberSequence(velocity)
	else
		local speedSource: any = if cfg.Speed ~= nil then cfg.Speed else velocity

		velocityDynamic = Sampler.HasNumberSequence(speedSource) or Sampler.HasNumberSequence(cfg.Direction) or Sampler.HasNumberSequence(cfg.SpreadAngle)
	end

	--[[ Spawn Position ]]

	local spawnPosition: UDim2 | Vector2 | nil = cfg.EmitterPosition

	if spawnPosition == nil then
		local propertyPosition: any = cfg.Properties.Position

		if typeof(propertyPosition) == "UDim2" or typeof(propertyPosition) == "Vector2" then
			spawnPosition = propertyPosition
		end
	end

	--[[ Properties ]]

	--- @type { { any } }
	local properties = {}

	for property: string, value: any in cfg.Properties do
		if property ~= "Position" then
			table.insert(properties, { property, value })
		end
	end

	--[[ Returning ]]

	return {
		HasTexture = hasTexture,
		ClassName = if hasTexture then "ImageLabel" else "Frame",
		SizeOffset = cfg.SizeSpace == "offset",
		ColorCurve = Sampler.CompileColorSequence(cfg.Color),
		VelocityKind = velocityKind,
		VelocityDynamic = velocityDynamic,
		VelocityConstant = velocityConstant,
		FlipbookEnabled = hasTexture and Config.IsFlipbookEnabled(cfg),
		SpawnPosition = spawnPosition,
		Properties = properties,
		FailedProperties = {},
	}
end

--%%%%%%%%%%%%%%%%%%%% Get Config From Params

--[[
	Returns a validated config from a table or ParticleEmitter.
]]
--- @param params UIEmitter_Params | ParticleEmitter
--- @return UIEmitter_CompiledConfig
function Config.GetConfigFromParams(params)
	--[[ ParticleEmitter Adapter ]]

	if typeof(params) == "Instance" and params:IsA("ParticleEmitter") then
		return Config.ValidateTableParams(Config._configFromParticleEmitter(params))
	end

	--[[ Config Table ]]

	if typeof(params) == "table" then
		return Config.ValidateTableParams(params)
	end

	--[[ Invalid Params ]]

	error(`[{_localName}::{script.Name}]: params must be a config table or ParticleEmitter instance.`, 2)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Config
