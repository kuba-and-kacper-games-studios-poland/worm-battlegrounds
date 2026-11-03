--[[
	Created By:     Nari
]]

local _localName: string = "UIEmitter"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Defaults = require(script.Parent:FindFirstChild("Defaults")) --- @type UIEmitter_Defaults
local Config = require(script.Parent:FindFirstChild("Config")) --- @type UIEmitter_Config
local Sampler = require(script.Parent:FindFirstChild("Sampler")) --- @type UIEmitter_Sampler

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local DEFAULTS = Defaults.DEFAULTS --- @type { [string]: any }
local DEFAULT_GRAVITY: Vector3 = Vector3.new(DEFAULTS.Gravity.X, DEFAULTS.Gravity.Y, 0)
local CENTER_ANCHOR: Vector2 = Vector2.new(0.5, 0.5)
local FAST_FORWARD_STEP: number = 1 / 60

-- Write quantization: 8-bit color/transparency, sub-pixel scale sizes, tenth-degree rotation.
local CHANNEL_STEPS: number = 255
local SCALE_STEPS: number = 10000
local ROTATION_STEPS: number = 10

local EvalCurve = Sampler.EvalCurve --- @type (curve: UIEmitter_NumberCurve, alpha: number) -> number
local EvalColorCurve = Sampler.EvalColorCurve --- @type (curve: UIEmitter_ColorCurve, alpha: number) -> (number, number, number)
local EvalNumberSource = Sampler.EvalNumberSource --- @type (source: UIEmitter_NumberSource | nil, alpha: number, fallback: number) -> number
local SampleNumber: (value: any, fallback: number) -> number = Sampler.SampleNumber
local SampleNumberSource = Sampler.SampleNumberSource --- @type (value: any, fallback: number) -> UIEmitter_NumberSource

local random: (min: number?, max: number?) -> number = math.random
local clamp: (x: number, min: number, max: number) -> number = math.clamp
local round: (x: number) -> number = math.round
local floor: (x: number) -> number = math.floor
local cos: (x: number) -> number = math.cos
local sin: (x: number) -> number = math.sin
local atan2: (y: number, x: number) -> number = math.atan2
local deg: (radians: number) -> number = math.deg

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Set Property

--[[
	Writes one property so pcall can run it without allocating a closure.
]]
local function setProperty(particle: GuiObject, property: string, value: any)
	particle[property] = value
end

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

--- @class UIEmitter_Particle
local Particle = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Frame Context

--%%%%%%%%%%%%%%%%%%%% Build Frame Context

--[[
	Reads emitter layout once per frame or burst and caches it on the emitter for spawns and updates.
]]
--- @param internal UIEmitter_State
--- @return UIEmitter_Frame
function Particle.BuildFrameContext(internal)
	--[[ Layout Reads ]]

	local cfg = internal._config --- @type UIEmitter_CompiledConfig
	local frame = internal._frame --- @type UIEmitter_Frame
	local parent: GuiObject = cfg.Parent
	local container: GuiObject = cfg.Container
	local parentAbsolutePosition: Vector2 = parent.AbsolutePosition
	local containerAbsolutePosition: Vector2 = container.AbsolutePosition
	local containerAbsoluteSize: Vector2 = container.AbsoluteSize
	local parentAbsoluteSize: Vector2 = if container == parent then containerAbsoluteSize else parent.AbsoluteSize
	local emissionArea: Vector2 = cfg.EmissionArea
	local cullMin: Vector3 = Vector3.new(containerAbsolutePosition.X - parentAbsolutePosition.X, containerAbsolutePosition.Y - parentAbsolutePosition.Y, 0)
	local containerExtent: Vector3 = Vector3.new(containerAbsoluteSize.X, containerAbsoluteSize.Y, 0)

	--[[ Caching ]]

	frame.ParentAbsolutePosition = parentAbsolutePosition
	frame.ParentAbsoluteSize = parentAbsoluteSize
	frame.SpawnPoint = Config.ResolvePositionInBounds(internal._plan.SpawnPosition, containerAbsolutePosition, containerAbsoluteSize)
	frame.SpawnArea = Vector2.new(containerAbsoluteSize.X * emissionArea.X, containerAbsoluteSize.Y * emissionArea.Y)
	frame.CullMin = cullMin
	frame.CullMax = cullMin + containerExtent
	frame.OrbitCenter = cullMin + containerExtent * 0.5
	frame.OrbitHalfMin = math.min(containerAbsoluteSize.X, containerAbsoluteSize.Y) * 0.5

	--[[ Returning ]]

	return frame
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Visual Timeline

--%%%%%%%%%%%%%%%%%%%% Get Visual Alpha

--[[
	Normalized lifetime alpha for visual curves (supports compressed post-release phase).
]]
--- @param entry UIEmitter_Entry
--- @return number
function Particle._getVisualAlpha(entry)
	--[[ Release Phase ]]

	local releaseStartAge: number? = entry.ReleaseStartAge

	if releaseStartAge then
		local span: number? = entry.AttractReleaseDuration
		local pauseProgress: number? = entry.AttractPauseAtProgress

		if span and span > 0 and pauseProgress then
			local t: number = clamp((entry.Age - releaseStartAge) / span, 0, 1)

			return pauseProgress + (1 - pauseProgress) * t
		end
	end

	--[[ Normal Phase ]]

	return entry.Age / entry.NominalLifetime
end

--%%%%%%%%%%%%%%%%%%%% Get Particle Rotation

--[[
	Returns rotation with optional movement-direction facing.
]]
--- @param entry UIEmitter_Entry
--- @return number
function Particle._getParticleRotation(entry)
	--[[ Static Rotation ]]

	if not entry.FaceMovementDirection then
		return entry.Rotation
	end

	local velocity: Vector3 = entry.Velocity

	if velocity.Magnitude <= 0.001 then
		return entry.Rotation
	end

	--[[ Velocity Direction ]]

	-- Rotation remains an offset from the particle's default art direction.
	return deg(atan2(velocity.Y, velocity.X)) + entry.Rotation
end

--%%%%%%%%%%%%%%%%%%%% Apply Particle Visual

--[[
	Applies size, transparency, color, and rotation at one lifetime alpha, writing only changed properties.
]]
--- @param entry UIEmitter_Entry
function Particle.ApplyParticleVisual(entry, alphaOverride: number?)
	--[[ Local Variables ]]

	local particle: GuiObject = entry.Particle
	local alpha: number = if alphaOverride ~= nil then alphaOverride else Particle._getVisualAlpha(entry)

	--[[ Size ]]

	local size = entry.Size --- @type UIEmitter_NumberSource
	local squash = entry.Squash --- @type UIEmitter_NumberSource

	if type(size) ~= "number" then
		size = EvalCurve(size, alpha)
	end

	if type(squash) ~= "number" then
		squash = EvalCurve(squash, alpha)
	end

	size = (if size > 0 then size else 0) * entry.SizeScale
	squash = if squash > 0.001 then squash else 0.001

	-- Raw size feeds culling; the write keys below are quantized
	entry.LastSize = size
	entry.LastSquash = squash

	local sizeOffset: boolean = entry.SizeOffset
	local sizeKeyX: number = if sizeOffset then floor(size * squash) else round(size * squash * SCALE_STEPS)
	local sizeKeyY: number = if sizeOffset then floor(size / squash) else round(size / squash * SCALE_STEPS)

	if sizeKeyX ~= entry.SizeKeyX or sizeKeyY ~= entry.SizeKeyY then
		entry.SizeKeyX = sizeKeyX
		entry.SizeKeyY = sizeKeyY
		particle.Size = if sizeOffset then UDim2.fromOffset(sizeKeyX, sizeKeyY) else UDim2.fromScale(sizeKeyX / SCALE_STEPS, sizeKeyY / SCALE_STEPS)
	end

	--[[ Transparency ]]

	--- @type UIEmitter_NumberSource
	local transparency = entry.Transparency

	if type(transparency) ~= "number" then
		transparency = EvalCurve(transparency, alpha)
	end

	local transparencyKey: number = round(clamp(transparency * entry.TransparencyScale, 0, 1) * CHANNEL_STEPS)

	if transparencyKey ~= entry.LastTransparency then
		entry.LastTransparency = transparencyKey

		if entry.HasTexture then
			particle.ImageTransparency = transparencyKey / CHANNEL_STEPS
		else
			particle.BackgroundTransparency = transparencyKey / CHANNEL_STEPS
		end
	end

	--[[ Color ]]

	local colorCurve = entry.Color --- @type UIEmitter_ColorCurve
	local constantColor: Color3? = colorCurve.Constant

	-- Constant colors are written once at spawn
	if constantColor == nil or entry.LastRed == nil then
		local red: number
		local green: number
		local blue: number

		if constantColor then
			red, green, blue = constantColor.R, constantColor.G, constantColor.B
		else
			red, green, blue = EvalColorCurve(colorCurve, alpha)
		end

		red = round(red * CHANNEL_STEPS)
		green = round(green * CHANNEL_STEPS)
		blue = round(blue * CHANNEL_STEPS)

		if red ~= entry.LastRed or green ~= entry.LastGreen or blue ~= entry.LastBlue then
			local color: Color3 = constantColor or Color3.fromRGB(red, green, blue)

			entry.LastRed = red
			entry.LastGreen = green
			entry.LastBlue = blue

			if entry.HasTexture then
				particle.ImageColor3 = color
			else
				particle.BackgroundColor3 = color
			end
		end
	end

	--[[ Rotation ]]

	local rotationKey: number = round(Particle._getParticleRotation(entry) * ROTATION_STEPS)

	if rotationKey ~= entry.LastRotation then
		entry.LastRotation = rotationKey
		particle.Rotation = rotationKey / ROTATION_STEPS
	end
end

--%%%%%%%%%%%%%%%%%%%% Write Position

--[[
	Writes the particle position only when its pixel offset changes.
]]
--- @param entry UIEmitter_Entry
function Particle.WritePosition(entry)
	--[[ Pixel Snap ]]

	local position: Vector3 = entry.Position
	local x: number = round(position.X)
	local y: number = round(position.Y)

	--[[ Writing ]]

	if x ~= entry.PixelX or y ~= entry.PixelY then
		entry.PixelX = x
		entry.PixelY = y
		entry.Particle.Position = UDim2.fromOffset(x, y)
	end
end

--%%%%%%%%%%%%%%%%%%%% Is Outside Cull Rect

--[[
	Checks whether a particle is fully outside the container rect of this frame.
]]
--- @param entry UIEmitter_Entry
--- @param frame UIEmitter_Frame
--- @return boolean
function Particle.IsOutsideCullRect(entry, frame)
	--[[ Local Variables ]]

	local size: number = entry.LastSize or 0
	local squash: number = entry.LastSquash or 1
	local width: number
	local height: number

	--[[ Geometry ]]

	if entry.SizeOffset then
		width = size * squash
		height = size / squash
	else
		local parentSize: Vector2 = frame.ParentAbsoluteSize
		local aspectRatio: number? = entry.AspectRatio

		width = parentSize.X * size * squash
		height = parentSize.Y * size / squash

		-- Mirror UIAspectRatioConstraint fitting inside the scaled box
		if aspectRatio and aspectRatio > 0 and height > 0 then
			if width / height > aspectRatio then
				width = height * aspectRatio
			else
				height = width / aspectRatio
			end
		end
	end

	--[[ Bounds ]]

	local position: Vector3 = entry.Position
	local minPoint: Vector3 = frame.CullMin
	local maxPoint: Vector3 = frame.CullMax
	local halfWidth: number = width * 0.5
	local halfHeight: number = height * 0.5

	return position.X + halfWidth < minPoint.X or position.X - halfWidth > maxPoint.X or position.Y + halfHeight < minPoint.Y or position.Y - halfHeight > maxPoint.Y
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Shake

--%%%%%%%%%%%%%%%%%%%% Build Shake Change Times

--[[
	Builds sorted shake flip times spread across a particle lifetime.
]]
--- @return { number }
function Particle._buildShakeChangeTimes(lifetime: number, changeCount: number)
	--[[ Change Times ]]

	--- @type { number }
	local changeTimes = table.create(changeCount)

	for index: number = 1, changeCount do
		changeTimes[index] = Sampler.RandomBetween(lifetime * 0.12, lifetime * 0.88)
	end

	table.sort(changeTimes)

	return changeTimes
end

--%%%%%%%%%%%%%%%%%%%% Update Shake Direction

--[[
	Schedules smooth horizontal shake turns at random lifetime milestones.
]]
--- @param entry UIEmitter_Entry
function Particle._updateShakeDirection(entry)
	--[[ Local Variables ]]

	local changeTimes = entry.ShakeChangeTimes --- @type { number }
	local changeIndex: number = entry.ShakeChangeIndex

	--[[ Direction Flips ]]

	while changeIndex <= #changeTimes and entry.Age >= changeTimes[changeIndex] do
		local currentFactor: number = entry.ShakeHorizontalBlend or entry.ShakeHorizontalSign

		-- Start an eased blend toward the opposite side
		entry.ShakeTargetSign = if currentFactor >= 0 then -1 else 1
		entry.ShakeBlendStart = currentFactor
		entry.ShakeBlendStartAge = entry.Age
		changeIndex += 1
	end

	entry.ShakeChangeIndex = changeIndex
end

--%%%%%%%%%%%%%%%%%%%% Apply Shake Velocity

--[[
	Applies constant upward drift with eased horizontal shake.
]]
--- @param entry UIEmitter_Entry
function Particle.ApplyShakeVelocity(entry, progress: number)
	--[[ Local Variables ]]

	local shakeSpeed: number = EvalNumberSource(entry.ShakeSpeed, progress, 0)
	local horizontalDrift: number = if entry.HorizontalDrift == nil then 0 else EvalNumberSource(entry.HorizontalDrift, progress, 0) * entry.HorizontalDriftSign

	--[[ Direction Blend ]]

	Particle._updateShakeDirection(entry)

	if entry.ShakeBlendStartAge then
		local duration: number = math.max(EvalNumberSource(entry.ShakeDirectionBlendDuration, progress, 0.001), 0.001)
		local blendAlpha: number = clamp((entry.Age - entry.ShakeBlendStartAge) / duration, 0, 1)
		local smoothAlpha: number = blendAlpha * blendAlpha * (3 - 2 * blendAlpha)

		entry.ShakeHorizontalBlend = entry.ShakeBlendStart + (entry.ShakeTargetSign - entry.ShakeBlendStart) * smoothAlpha

		if blendAlpha >= 1 then
			entry.ShakeHorizontalSign = entry.ShakeTargetSign
			entry.ShakeHorizontalBlend = entry.ShakeTargetSign
			entry.ShakeBlendStartAge = nil
		end
	else
		entry.ShakeHorizontalBlend = entry.ShakeHorizontalSign
	end

	--[[ Velocity ]]

	local lockVertical: boolean? = entry.ShakeLockVertical
	local horizontal: number = entry.ShakeHorizontalBlend * shakeSpeed

	entry.Velocity = Vector3.new(if lockVertical then horizontal else (entry.BaseHorizontalSpeed or 0) + horizontalDrift + horizontal, if lockVertical and entry.UpSpeed then entry.UpSpeed else entry.Velocity.Y, 0)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Orbit

--%%%%%%%%%%%%%%%%%%%% Sample Orbit Radius Source

--[[
	Creates a lifetime-aware orbital radius source.
]]
--- @param cfg UIEmitter_CompiledConfig
--- @return UIEmitter_OrbitRadiusSource
function Particle._sampleOrbitRadiusSource(cfg, halfMin: number)
	--[[ Scale Radius ]]

	if cfg.OrbitRadiusScale ~= nil then
		return {
			Mode = "Scale",
			Value = SampleNumberSource(cfg.OrbitRadiusScale, 0.35),
		}
	end

	--[[ Pixel Radius ]]

	if cfg.OrbitRadius ~= nil then
		return {
			Mode = "Offset",
			Value = SampleNumberSource(cfg.OrbitRadius, halfMin * 0.35),
		}
	end

	return {
		Mode = "Offset",
		Value = halfMin * 0.35,
	}
end

--%%%%%%%%%%%%%%%%%%%% Eval Orbit Radius Source

--[[
	Evaluates an orbital radius source against current container dimensions.
]]
--- @param source UIEmitter_OrbitRadiusSource
--- @return number
function Particle._evalOrbitRadiusSource(source, alpha: number, halfMin: number)
	--[[ Evaluating ]]

	local value: number = EvalNumberSource(source.Value, alpha, halfMin * 0.35)

	if source.Mode == "Scale" then
		return halfMin * clamp(value, 0, 1)
	end

	return math.max(value, 0)
end

--%%%%%%%%%%%%%%%%%%%% Apply Orbit Motion

--[[
	Advances one particle around the container center.
]]
--- @param entry UIEmitter_Entry
--- @param frame UIEmitter_Frame
function Particle.ApplyOrbitMotion(entry, frame, deltaTime: number, progress: number)
	--[[ Angle ]]

	entry.OrbitAngle += EvalNumberSource(entry.OrbitSpeed, progress, 0) * entry.OrbitDirection * deltaTime

	--[[ Position ]]

	local angle: number = entry.OrbitAngle
	local radius: number = Particle._evalOrbitRadiusSource(entry.OrbitRadiusSource, progress, frame.OrbitHalfMin)

	entry.OrbitRadius = radius
	entry.Position = frame.OrbitCenter + Vector3.new(cos(angle) * radius, sin(angle) * radius, 0)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Flipbook

--%%%%%%%%%%%%%%%%%%%% Apply Flipbook Frame

--[[
	Writes the current flipbook frame offset onto the particle ImageLabel in row-major order.
]]
--- @param entry UIEmitter_Entry
function Particle._applyFlipbookFrame(entry)
	--[[ Grid Lookup ]]

	local cellSize: Vector2 = entry.FlipbookCellSize
	local gridX: number = entry.FlipbookGridX
	local frameIndex: number = entry.FlipbookFrame

	--[[ Writing ]]

	entry.Particle.ImageRectOffset = Vector2.new((frameIndex % gridX) * cellSize.X, floor(frameIndex / gridX) * cellSize.Y)
end

--%%%%%%%%%%%%%%%%%%%% Advance Flipbook

--[[
	Advances flipbook frame state; only writes ImageRect when the frame changes.
]]
--- @param entry UIEmitter_Entry
function Particle.AdvanceFlipbook(entry, deltaTime: number)
	--[[ Checks ]]

	if entry.FlipbookStopped then
		return
	end

	--[[ Local Variables ]]

	local frameDuration: number = 1 / entry.FlipbookFPS
	local frameCount: number = entry.FlipbookFrameCount
	local mode: string? = entry.FlipbookMode
	local timer: number = entry.FlipbookFrameTimer + deltaTime
	local changed: boolean = false

	--[[ Stepping ]]

	while timer >= frameDuration do
		timer -= frameDuration
		changed = true

		if mode == "random" then
			entry.FlipbookFrame = random(0, frameCount - 1)
		elseif mode == "oneshot" then
			-- Hold the final frame once reached
			if entry.FlipbookFrame >= frameCount - 1 then
				entry.FlipbookFrame = frameCount - 1
				entry.FlipbookStopped = true
				break
			end

			entry.FlipbookFrame += 1
		elseif mode == "pingpong" then
			entry.FlipbookFrame += entry.FlipbookDirection

			if entry.FlipbookFrame >= frameCount - 1 then
				entry.FlipbookFrame = frameCount - 1
				entry.FlipbookDirection = -1
			elseif entry.FlipbookFrame <= 0 then
				entry.FlipbookFrame = 0
				entry.FlipbookDirection = 1
			end
		else
			entry.FlipbookFrame = (entry.FlipbookFrame + 1) % frameCount
		end
	end

	entry.FlipbookFrameTimer = timer

	--[[ Writing ]]

	if changed then
		Particle._applyFlipbookFrame(entry)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Warm Start

--%%%%%%%%%%%%%%%%%%%% Sample Initial Age Progress

--[[
	Samples normalized lifetime progress for warm-started particles.
]]
--- @param cfg UIEmitter_CompiledConfig
--- @return number
function Particle.SampleInitialAgeProgress(cfg)
	--[[ Defaults ]]

	if cfg.InitialAgeProgress == nil then
		return 0.5
	end

	return clamp(SampleNumber(cfg.InitialAgeProgress, 0.5), 0, 0.999)
end

--%%%%%%%%%%%%%%%%%%%% Fast Forward Entry

--[[
	Advances one particle to a later point in its lifetime with gravity and drag.
]]
--- @param entry UIEmitter_Entry
--- @param frame UIEmitter_Frame
function Particle._fastForwardEntry(entry, ageProgress: number, frame)
	--[[ Age Progress ]]

	ageProgress = clamp(ageProgress, 0, 0.999)
	local age: number = entry.Lifetime * ageProgress

	entry.Age = age
	entry.Elapsed = age

	--[[ Motion ]]

	if entry.OrbitSpeed then
		local radius: number = Particle._evalOrbitRadiusSource(entry.OrbitRadiusSource, ageProgress, frame.OrbitHalfMin)

		entry.OrbitAngle += EvalNumberSource(entry.OrbitSpeed, ageProgress, 0) * entry.OrbitDirection * age
		entry.OrbitRadius = radius
		entry.Position = frame.OrbitCenter + Vector3.new(cos(entry.OrbitAngle) * radius, sin(entry.OrbitAngle) * radius, 0)
	elseif entry.ShakeSpeed then
		Particle.ApplyShakeVelocity(entry, ageProgress)
		entry.Position += entry.Velocity * age
	else
		local steps: number = math.max(math.ceil(age / FAST_FORWARD_STEP), 1)
		local stepDelta: number = age / steps

		if entry.GravitySource == nil and entry.DragSource == nil and entry.VelocitySource == nil and entry.Drag <= 0 then
			-- Closed form of the stepped integration below when nothing varies over lifetime.
			entry.Position += entry.Velocity * age + entry.Gravity * (0.5 * age * (age + stepDelta))
			entry.Velocity += entry.Gravity * age
		else
			local velocity: Vector3 = entry.Velocity

			for step: number = 1, steps do
				local progress: number = ageProgress * step / steps
				local gravity: Vector3 = if entry.GravitySource then Sampler.EvalVectorSource(entry.GravitySource, progress, DEFAULT_GRAVITY) else entry.Gravity
				local drag: number = if entry.DragSource then math.max(EvalCurve(entry.DragSource, progress), 0) else entry.Drag

				if entry.VelocitySource then
					velocity = Sampler.EvalVelocitySource(entry.VelocitySource, progress)
				end

				velocity += gravity * stepDelta

				if drag > 0 then
					velocity *= 1 / (1 + drag * stepDelta)
				end

				entry.Position += velocity * stepDelta
				entry.Gravity = gravity
				entry.Drag = drag
			end

			entry.Velocity = velocity
		end
	end

	--[[ Rotation ]]

	if not entry.RotationStatic then
		entry.RotationOffset += EvalNumberSource(entry.RotationSpeedSource, ageProgress, 0) * age
		entry.Rotation = EvalNumberSource(entry.RotationSource, ageProgress, 0) + entry.RotationOffset
	end

	--[[ Flipbook ]]

	if entry.FlipbookEnabled then
		Particle.AdvanceFlipbook(entry, age)
	end

	--[[ Visuals ]]

	Particle.ApplyParticleVisual(entry)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Gui Setup

--%%%%%%%%%%%%%%%%%%%% Acquire Entry

--[[
	Pops a reusable particle entry from the class pool or creates a new GuiObject.
]]
--- @param internal UIEmitter_State
--- @param plan UIEmitter_Plan
--- @return UIEmitter_Entry
function Particle._acquireEntry(internal, plan)
	--[[ Pool Lookup ]]

	--- @type { UIEmitter_Entry }
	local pool = internal._pool[plan.ClassName]

	while #pool > 0 do
		local entry = table.remove(pool) --- @type UIEmitter_Entry
		local particle: GuiObject = entry.Particle

		internal._poolCount -= 1

		-- Reuse only particles that are still alive in the hierarchy
		if particle.Parent ~= nil then
			return entry
		end

		particle:Destroy()
	end

	--[[ Returning ]]

	return Particle._createEntry(plan)
end

--%%%%%%%%%%%%%%%%%%%% Create Entry

--[[
	Creates a hidden GuiObject particle and its reusable entry table.
]]
--- @param plan UIEmitter_Plan
--- @return UIEmitter_Entry
function Particle._createEntry(plan)
	--[[ Creating ]]

	local particle: GuiObject = Instance.new(plan.ClassName)

	particle.Name = "UIParticle"
	particle.Visible = false
	particle.Selectable = false
	particle.BorderSizePixel = 0
	particle.AnchorPoint = CENTER_ANCHOR

	--[[ Returning ]]

	return {
		Particle = particle,
		Constraint = nil,
	}
end

--%%%%%%%%%%%%%%%%%%%% Prewarm Pool

--[[
	Fills the class pool with hidden parented particles so later spawns skip creation and parenting.
]]
--- @param internal UIEmitter_State
function Particle.PrewarmPool(internal, count: number)
	--[[ Local Variables ]]

	local cfg = internal._config --- @type UIEmitter_CompiledConfig
	local plan = internal._plan --- @type UIEmitter_Plan
	local pool = internal._pool[plan.ClassName] --- @type { UIEmitter_Entry }
	local target: number = math.min(count, internal._poolLimit)

	--[[ Creating ]]

	while internal._poolCount < target do
		--- @type UIEmitter_Entry
		local entry = Particle._createEntry(plan)

		Particle._setupGui(entry, cfg, plan)
		entry.Particle.Parent = cfg.Parent
		table.insert(pool, entry)
		internal._poolCount += 1
	end
end

--%%%%%%%%%%%%%%%%%%%% Setup Gui

--[[
	Applies spawn-time GuiObject properties that stay fixed for the particle lifetime.
]]
--- @param entry UIEmitter_Entry
--- @param cfg UIEmitter_CompiledConfig
--- @param plan UIEmitter_Plan
function Particle._setupGui(entry, cfg, plan)
	--[[ Base Properties ]]

	local particle: GuiObject = entry.Particle

	particle.ZIndex = cfg.ZIndex

	if plan.HasTexture then
		particle.BackgroundTransparency = 1
		particle.Image = cfg.Texture
		particle.ScaleType = Enum.ScaleType.Stretch
		-- Reset flipbook crop so pooled ImageLabels do not keep a previous rect.
		particle.ImageRectOffset = Vector2.zero
		particle.ImageRectSize = Vector2.zero
	end

	--[[ Aspect Ratio ]]

	local aspectRatio: number? = cfg.AspectRatio
	local constraint: UIAspectRatioConstraint? = entry.Constraint

	if aspectRatio ~= nil then
		if not constraint then
			constraint = Instance.new("UIAspectRatioConstraint")
			constraint.Parent = particle
			entry.Constraint = constraint
		end

		constraint.AspectRatio = aspectRatio
	elseif constraint then
		constraint:Destroy()
		entry.Constraint = nil
	end

	--[[ Custom Properties ]]

	--- @type { [string]: boolean }
	local failedProperties = plan.FailedProperties

	--- @param pair { any }
	for _index: number, pair in plan.Properties do
		local property: string = pair[1]

		-- Skip properties that already failed so spawns do not spam warnings
		if not failedProperties[property] then
			local success: boolean
			local result: any | string?
			success, result = pcall(setProperty, particle, property, pair[2])

			if not success then
				failedProperties[property] = true
				warn(`[{_localName}::{script.Name}]: Failed to apply particle property "{tostring(property)}": {result}`)
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Init Entry

--[[
	Samples every per-particle value from the current emitter config into a reused entry table.
	`spawnAbsoluteOverride` replaces the configured spawn point and emission shape when set.
]]
--- @param entry UIEmitter_Entry
--- @param cfg UIEmitter_CompiledConfig
--- @param plan UIEmitter_Plan
--- @param frame UIEmitter_Frame
function Particle._initEntry(entry, cfg, plan, frame, spawnAbsoluteOverride: Vector2?)
	--[[ Spawn Point ]]

	local spawnAbsolutePoint: Vector2 = spawnAbsoluteOverride or Config.GetSpawnAbsolutePoint(cfg, frame)
	local parentAbsolutePosition: Vector2 = frame.ParentAbsolutePosition
	local lifetime: number = math.max(SampleNumber(cfg.Lifetime, DEFAULTS.Lifetime), 0.001)

	--[[ Velocity ]]

	local velocity: Vector3
	local velocitySource --- @type UIEmitter_VelocitySource?
	velocity, velocitySource = Sampler.SampleVelocity(cfg, plan)

	if cfg.InitialVelocity then
		local initialVelocity: any = cfg.InitialVelocity(spawnAbsolutePoint)

		if typeof(initialVelocity) == "Vector2" then
			velocity = Vector3.new(initialVelocity.X, initialVelocity.Y, 0)
			velocitySource = nil
		end
	end

	--[[ Motion Sources ]]

	local gravitySource = Sampler.SampleVectorSource(cfg.Gravity, DEFAULT_GRAVITY) --- @type UIEmitter_VectorValue
	local dragSource = SampleNumberSource(cfg.Drag, DEFAULTS.Drag) --- @type UIEmitter_NumberSource
	local rotationSource = SampleNumberSource(cfg.Rotation, DEFAULTS.Rotation) --- @type UIEmitter_NumberSource
	local rotationSpeedSource = SampleNumberSource(cfg.RotationSpeed, DEFAULTS.RotationSpeed) --- @type UIEmitter_NumberSource
	local rotationStatic: boolean = type(rotationSource) == "number" and rotationSpeedSource == 0

	--[[ Shake ]]

	local shakeSpeed = if cfg.ShakeSpeed == nil then nil else SampleNumberSource(cfg.ShakeSpeed, 0) --- @type UIEmitter_NumberSource?
	local initialShakeSign: number? = if shakeSpeed then (if random() < 0.5 then -1 else 1) else nil
	local horizontalDrift = if shakeSpeed and cfg.HorizontalDrift ~= nil then SampleNumberSource(cfg.HorizontalDrift, 0) else nil --- @type UIEmitter_NumberSource?

	--[[ Orbit ]]

	local orbitEnabled: boolean = cfg.OrbitSpeed ~= nil
	local orbitHalfMin: number = frame.OrbitHalfMin
	local orbitRadiusSource = if orbitEnabled then Particle._sampleOrbitRadiusSource(cfg, orbitHalfMin) else nil --- @type UIEmitter_OrbitRadiusSource?
	local orbitRadius: number? = if orbitEnabled then Particle._evalOrbitRadiusSource(orbitRadiusSource, 0, orbitHalfMin) else nil
	local orbitAngle: number? = if orbitEnabled then Sampler.RandomBetween(0, math.pi * 2) else nil
	local position: Vector3 = if orbitEnabled
		then frame.OrbitCenter + Vector3.new(cos(orbitAngle) * orbitRadius, sin(orbitAngle) * orbitRadius, 0)
		else Vector3.new(spawnAbsolutePoint.X - parentAbsolutePosition.X, spawnAbsolutePoint.Y - parentAbsolutePosition.Y, 0)

	--[[ Shake Launch ]]

	local lockVertical: boolean = shakeSpeed ~= nil and cfg.ShakeLockVertical
	local baseHorizontalSpeed: number? = if shakeSpeed and not cfg.ShakeLockVertical then velocity.X else nil

	if lockVertical and not orbitEnabled then
		velocity = Vector3.new(EvalNumberSource(shakeSpeed, 0, 0) * initialShakeSign, -math.abs(velocity.Y), 0)
	end

	--[[ Attraction ]]

	local attractReleaseDuration: number? = if cfg.AttractReleaseDuration == nil then nil else math.max(SampleNumber(cfg.AttractReleaseDuration, 0), 0)

	if attractReleaseDuration == 0 then
		attractReleaseDuration = nil
	end

	--[[ Appearance ]]

	local sizeSource = SampleNumberSource(cfg.Size, 0) --- @type UIEmitter_NumberSource
	local squashSource = SampleNumberSource(cfg.Squash, DEFAULTS.Squash) --- @type UIEmitter_NumberSource
	local transparencySource = SampleNumberSource(cfg.Transparency, 0) --- @type UIEmitter_NumberSource
	local colorCurve = plan.ColorCurve --- @type UIEmitter_ColorCurve

	--[[ Flipbook ]]

	local flipbookEnabled: boolean = plan.FlipbookEnabled
	local flipbookFrameCount: number? = if flipbookEnabled then cfg.FlipbookFrameCount else nil

	--[[ Motion State ]]

	entry.Position = position
	entry.Velocity = velocity
	entry.VelocitySource = velocitySource
	entry.Gravity = Sampler.EvalVectorSource(gravitySource, 0, DEFAULT_GRAVITY)
	entry.GravitySource = if type(gravitySource) == "table" then gravitySource else nil
	entry.Drag = math.max(EvalNumberSource(dragSource, 0, DEFAULTS.Drag), 0)
	entry.DragSource = if type(dragSource) == "table" then dragSource else nil

	--[[ Lifetime State ]]

	entry.NominalLifetime = lifetime
	entry.Lifetime = lifetime
	entry.Age = 0
	entry.Elapsed = 0
	entry.ReleaseStartAge = nil

	--[[ Attraction State ]]

	entry.AttractAfter = math.max(SampleNumber(cfg.AttractAfter, DEFAULTS.AttractAfter), 0)
	entry.AttractStrength = SampleNumberSource(cfg.AttractStrength, DEFAULTS.AttractStrength)
	entry.AttractMaxSpeed = SampleNumberSource(cfg.AttractMaxSpeed, DEFAULTS.AttractMaxSpeed)
	entry.AttractArriveRadius = SampleNumberSource(cfg.AttractArriveRadius, DEFAULTS.AttractArriveRadius)
	entry.AttractStopOnArrive = cfg.AttractStopOnArrive
	entry.AttractDestroyOnArrive = cfg.AttractDestroyOnArrive
	entry.AttractLiveFromEmitter = cfg.AttractLiveFromEmitter
	entry.AttractOnArrive = cfg.AttractOnArrive
	entry.AttractArrived = false
	entry.AttractStopped = false
	entry.AttractPauseAtProgress = Sampler.SampleAttractPauseProgress(cfg.AttractPauseAtProgress)
	entry.AttractPauseMaxTime = if cfg.AttractPauseMaxTime == nil then nil else math.max(SampleNumber(cfg.AttractPauseMaxTime, 0), 0)
	entry.AttractPauseHoldTime = 0
	entry.AttractReleaseDuration = attractReleaseDuration
	entry.AttractArriveOnlyWhenPaused = cfg.AttractArriveOnlyWhenPaused
	entry.AttractLifecycleReleased = false

	--[[ Appearance State ]]

	entry.HasTexture = plan.HasTexture
	entry.Color = colorCurve
	entry.Size = sizeSource
	entry.SizeOffset = plan.SizeOffset
	entry.SizeScale = if cfg.SizeScale == nil then 1 else clamp(SampleNumber(cfg.SizeScale, 1), 0, 1)
	entry.AspectRatio = cfg.AspectRatio
	entry.Squash = squashSource
	entry.Transparency = transparencySource
	entry.TransparencyScale = if cfg.TransparencyScale == nil then 1 else clamp(SampleNumber(cfg.TransparencyScale, 1), 0, 1)
	entry.Rotation = EvalNumberSource(rotationSource, 0, DEFAULTS.Rotation)
	entry.RotationSource = rotationSource
	entry.RotationSpeedSource = rotationSpeedSource
	entry.RotationOffset = 0
	entry.RotationStatic = rotationStatic
	entry.FaceMovementDirection = cfg.FaceMovementDirection
	-- Visuals that never change after spawn skip the per-frame visual pass entirely.
	entry.VisualStatic = rotationStatic and not cfg.FaceMovementDirection and type(sizeSource) == "number" and type(squashSource) == "number" and type(transparencySource) == "number" and colorCurve.Constant ~= nil

	--[[ Written Values ]]

	entry.LastSize = nil
	entry.LastSquash = nil
	entry.SizeKeyX = nil
	entry.SizeKeyY = nil
	entry.LastTransparency = nil
	entry.LastRed = nil
	entry.LastGreen = nil
	entry.LastBlue = nil
	entry.LastRotation = nil
	entry.PixelX = nil
	entry.PixelY = nil

	--[[ Shake State ]]

	entry.ShakeSpeed = shakeSpeed
	entry.ShakeHorizontalSign = initialShakeSign
	entry.ShakeHorizontalBlend = initialShakeSign
	entry.ShakeTargetSign = initialShakeSign
	entry.ShakeBlendStart = initialShakeSign
	entry.ShakeBlendStartAge = nil
	entry.ShakeDirectionBlendDuration = if shakeSpeed then SampleNumberSource(cfg.ShakeDirectionBlendDuration, DEFAULTS.ShakeDirectionBlendDuration) else nil
	entry.ShakeChangeTimes = if shakeSpeed then Particle._buildShakeChangeTimes(lifetime, math.max(floor(SampleNumber(cfg.ShakeDirectionChanges, DEFAULTS.ShakeDirectionChanges.Min)), 1)) else nil
	entry.ShakeChangeIndex = if shakeSpeed then 1 else nil
	entry.ShakeLockVertical = if shakeSpeed then cfg.ShakeLockVertical else nil
	entry.BaseHorizontalSpeed = baseHorizontalSpeed
	entry.HorizontalDrift = horizontalDrift
	entry.HorizontalDriftSign = if horizontalDrift and random() < 0.5 then -1 else 1
	entry.UpSpeed = if lockVertical then -math.abs(velocity.Y) else nil

	--[[ Orbit State ]]

	entry.OrbitSpeed = if orbitEnabled then SampleNumberSource(cfg.OrbitSpeed, 1) else nil
	entry.OrbitDirection = if orbitEnabled and random() < 0.5 then -1 else 1
	entry.OrbitRadius = orbitRadius
	entry.OrbitRadiusSource = orbitRadiusSource
	entry.OrbitAngle = orbitAngle

	--[[ Flipbook State ]]

	entry.FlipbookEnabled = flipbookEnabled
	entry.FlipbookFPS = if flipbookEnabled then math.max(SampleNumber(cfg.FlipbookFPS, 12), 0.001) else nil
	entry.FlipbookMode = if flipbookEnabled then cfg.FlipbookMode else nil
	entry.FlipbookGridX = if flipbookEnabled then cfg.FlipbookGridX else nil
	entry.FlipbookCellSize = if flipbookEnabled then cfg.FlipbookCellSize else nil
	entry.FlipbookFrameCount = flipbookFrameCount
	entry.FlipbookFrame = if flipbookEnabled and (cfg.FlipbookMode == "random" or cfg.FlipbookStartRandom) then random(0, flipbookFrameCount - 1) else 0
	entry.FlipbookFrameTimer = 0
	entry.FlipbookDirection = 1
	entry.FlipbookStopped = false

	if flipbookEnabled then
		-- Cell size is fixed per particle, so only the offset changes on later frames.
		entry.Particle.ImageRectSize = entry.FlipbookCellSize
		Particle._applyFlipbookFrame(entry)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Lifecycle

--%%%%%%%%%%%%%%%%%%%% Spawn

--[[
	Spawns one particle, optionally warm-started at a normalized age or at an absolute spawn point.
]]
--- @param internal UIEmitter_State
--- @param frame UIEmitter_Frame
function Particle.Spawn(internal, frame, ageProgress: number?, spawnAbsolutePoint: Vector2?)
	--[[ Local Variables ]]

	local cfg = internal._config --- @type UIEmitter_CompiledConfig
	local plan = internal._plan --- @type UIEmitter_Plan
	local parent: GuiObject = cfg.Parent
	local particles = internal._particles --- @type { UIEmitter_Entry }
	local maxParticles: number = cfg.MaxParticles

	--[[ Checks ]]

	-- Skip spawns for destroyed emitters or detached parents
	if internal._destroyed or parent.Parent == nil then
		return
	end

	-- Cap live particles when MaxParticles is set
	if maxParticles > 0 and #particles >= maxParticles then
		return
	end

	--[[ Creating ]]

	local entry = Particle._acquireEntry(internal, plan) --- @type UIEmitter_Entry
	local particle: GuiObject = entry.Particle

	Particle._setupGui(entry, cfg, plan)
	Particle._initEntry(entry, cfg, plan, frame, spawnAbsolutePoint)

	--[[ Visuals ]]

	if ageProgress and ageProgress > 0 then
		Particle._fastForwardEntry(entry, ageProgress, frame)
	else
		Particle.ApplyParticleVisual(entry, 0)
	end

	Particle.WritePosition(entry)

	--[[ Parenting ]]

	-- Pooled particles stay parented while hidden, so most spawns skip the reparent.
	if particle.Parent ~= parent then
		particle.Parent = parent
	end

	particle.Visible = true

	--[[ Storing ]]

	table.insert(particles, entry)
end

--%%%%%%%%%%%%%%%%%%%% Release Particle Entry

--[[
	Removes one live entry with a swap-remove and hides it into the emitter pool.
]]
--- @param internal UIEmitter_State
function Particle.ReleaseParticleEntry(internal, index: number)
	--[[ State Removal ]]

	local particles = internal._particles --- @type { UIEmitter_Entry }
	local lastIndex: number = #particles
	local entry = particles[index] --- @type UIEmitter_Entry?

	particles[index] = particles[lastIndex]
	particles[lastIndex] = nil

	--[[ Checks ]]

	if not entry then
		return
	end

	--[[ Pooling ]]

	local particle: GuiObject = entry.Particle

	-- Hiding in place is far cheaper than unparenting and reparenting on the next spawn.
	if not internal._destroyed and internal._poolCount < internal._poolLimit and particle.Parent ~= nil then
		particle.Visible = false
		table.insert(internal._pool[particle.ClassName], entry)
		internal._poolCount += 1
	else
		particle:Destroy()
	end
end

--%%%%%%%%%%%%%%%%%%%% Trim Pool

--[[
	Destroys pooled particles until the pool fits the given limit.
]]
--- @param internal UIEmitter_State
function Particle.TrimPool(internal, limit: number)
	--[[ Trimming ]]

	--- @param pool { UIEmitter_Entry }
	for _className: string, pool in internal._pool do
		while internal._poolCount > limit and #pool > 0 do
			table.remove(pool).Particle:Destroy()
			internal._poolCount -= 1
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Particle
