--[[
	Created By:     Nari
]]

--- @type Ume
local I
local _localName: string = "UIEmitter"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Defaults = require(script.Parent:FindFirstChild("Defaults")) --- @type UIEmitter_Defaults
local Attraction = require(script.Parent:FindFirstChild("Attraction")) --- @type UIEmitter_Attraction
local Particle = require(script.Parent:FindFirstChild("Particle")) --- @type UIEmitter_Particle
local Sampler = require(script.Parent:FindFirstChild("Sampler")) --- @type UIEmitter_Sampler

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local MAX_DELTA_TIME: number = Defaults.MAX_DELTA_TIME
local MAX_SPAWNS_PER_STEP: number = Defaults.MAX_SPAWNS_PER_STEP
local MAX_INITIAL_SPAWNS_PER_STEP: number = Defaults.MAX_INITIAL_SPAWNS_PER_STEP
local CULL_INTERVAL: number = Defaults.CULL_INTERVAL
local DEFAULT_GRAVITY: Vector3 = Vector3.new(Defaults.DEFAULTS.Gravity.X, Defaults.DEFAULTS.Gravity.Y, 0)

local ACTIVE_EMITTERS = {} --- @type { UIEmitter_State }
local SCHEDULER_CONNECTION: RBXScriptConnection? = nil
local STEPPING: boolean = false

local EvalCurve = Sampler.EvalCurve --- @type (curve: UIEmitter_NumberCurve, alpha: number) -> number
local EvalNumberSource = Sampler.EvalNumberSource --- @type (source: UIEmitter_NumberSource | nil, alpha: number, fallback: number) -> number
local EvalVectorSource = Sampler.EvalVectorSource --- @type (source: UIEmitter_VectorValue | nil, alpha: number, fallback: Vector3) -> Vector3
local EvalVelocitySource = Sampler.EvalVelocitySource --- @type (source: UIEmitter_VelocitySource, alpha: number) -> Vector3
local ApplyAttraction = Attraction.ApplyAttraction --- @type (entry: UIEmitter_Entry, targetPosition: Vector3, deltaTime: number, cfg: UIEmitter_CompiledConfig, progress: number) -> ()
local AdvancePausedAge = Attraction.AdvancePausedAge --- @type (entry: UIEmitter_Entry, targetPosition: Vector3, deltaTime: number, cfg: UIEmitter_CompiledConfig) -> ()
local ResolveArrival = Attraction.ResolveArrival --- @type (entry: UIEmitter_Entry, targetPosition: Vector3, cfg: UIEmitter_CompiledConfig, progress: number) -> boolean
local ApplyShakeVelocity = Particle.ApplyShakeVelocity --- @type (entry: UIEmitter_Entry, progress: number) -> ()
local ApplyOrbitMotion = Particle.ApplyOrbitMotion --- @type (entry: UIEmitter_Entry, frame: UIEmitter_Frame, deltaTime: number, progress: number) -> ()
local AdvanceFlipbook = Particle.AdvanceFlipbook --- @type (entry: UIEmitter_Entry, deltaTime: number) -> ()
local ApplyParticleVisual = Particle.ApplyParticleVisual --- @type (entry: UIEmitter_Entry, alphaOverride: number | nil) -> ()
local WritePosition = Particle.WritePosition --- @type (entry: UIEmitter_Entry) -> ()
local IsOutsideCullRect = Particle.IsOutsideCullRect --- @type (entry: UIEmitter_Entry, frame: UIEmitter_Frame) -> boolean
local ReleaseParticleEntry = Particle.ReleaseParticleEntry --- @type (internal: UIEmitter_State, index: number) -> ()

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

--- @class UIEmitter_Scheduler
local Scheduler = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Injection

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Stores the Ume instance for RunService Heartbeat.
]]
--- @param umeInstance Ume
function Scheduler.InjectUme(umeInstance)
	--[[ Setting ]]

	I = umeInstance
end

--%%%%%%%%%%%%%%%%%%%% Get Run Service

--[[
	Returns the framework RunService dependency once the library has been injected.
]]
--- @return RunService
function Scheduler._getRunService()
	--[[ Checks ]]

	assert(I and I.S and I.S.RunService, `[{_localName}::{script.Name}]: Ume services were not injected before emitter use.`)

	return I.S.RunService
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Registry

--%%%%%%%%%%%%%%%%%%%% Compact Active Emitters

--[[
	Removes deactivated emitters from the active list and disconnects Heartbeat when idle.
]]
function Scheduler._compactActiveEmitters()
	--[[ Compacting ]]

	local writeIndex: number = 0

	for readIndex: number = 1, #ACTIVE_EMITTERS do
		--- @type UIEmitter_State
		local internal = ACTIVE_EMITTERS[readIndex]

		ACTIVE_EMITTERS[readIndex] = nil

		if internal._active then
			writeIndex += 1
			ACTIVE_EMITTERS[writeIndex] = internal
		end
	end

	--[[ Disconnecting ]]

	if writeIndex == 0 and SCHEDULER_CONNECTION then
		SCHEDULER_CONNECTION:Disconnect()
		SCHEDULER_CONNECTION = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Activate Emitter

--[[
	Adds an emitter to the shared scheduler and connects Heartbeat on first use.
]]
--- @param internal UIEmitter_State
function Scheduler._activateEmitter(internal)
	--[[ Checks ]]

	if internal._active then
		return
	end

	--[[ Registering ]]

	internal._active = true

	-- A pending removal from this frame is still in the list, so it only needs re-flagging
	if not internal._listed then
		internal._listed = true
		table.insert(ACTIVE_EMITTERS, internal)
	end

	--[[ Connecting ]]

	if not SCHEDULER_CONNECTION then
		SCHEDULER_CONNECTION = Scheduler._getRunService().Heartbeat:Connect(Scheduler._stepActiveEmitters)
	end
end

--%%%%%%%%%%%%%%%%%%%% Deactivate Emitter

--[[
	Flags an emitter inactive; the list is compacted outside the step loop.
]]
--- @param internal UIEmitter_State
function Scheduler._deactivateEmitter(internal)
	--[[ Checks ]]

	if not internal._active then
		return
	end

	--[[ Unregistering ]]

	internal._active = false

	-- Removal is deferred while stepping so the active list is never shifted mid-iteration
	if not STEPPING then
		internal._listed = false
		Scheduler._compactActiveEmitters()
	end
end

--%%%%%%%%%%%%%%%%%%%% Disconnect Update Loop

--[[
	Removes an emitter from the shared update loop when no work remains.
]]
--- @param internal UIEmitter_State
function Scheduler.DisconnectUpdateLoop(internal)
	--[[ Deactivating ]]

	Scheduler._deactivateEmitter(internal)
end

--%%%%%%%%%%%%%%%%%%%% Ensure Update Loop

--[[
	Ensures this emitter has an active Heartbeat loop.
]]
--- @param internal UIEmitter_State
function Scheduler.EnsureUpdateLoop(internal)
	--[[ Activating ]]

	Scheduler._activateEmitter(internal)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stepping

--%%%%%%%%%%%%%%%%%%%% Step Active Emitters

--[[
	Runs every active emitter from one shared Heartbeat connection.
]]
function Scheduler._stepActiveEmitters(deltaTime: number)
	--[[ Delta Clamp ]]

	local stepDelta: number = if deltaTime < MAX_DELTA_TIME then deltaTime else MAX_DELTA_TIME

	--[[ Emitters ]]

	STEPPING = true

	-- Emitters activated by callbacks mid-step are appended and stepped this frame
	local index: number = 1

	while index <= #ACTIVE_EMITTERS do
		--- @type UIEmitter_State
		local internal = ACTIVE_EMITTERS[index]

		if internal._active then
			local success: boolean
			local result: any | string?
			success, result = pcall(Scheduler._stepEmitter, internal, stepDelta)

			-- One failing emitter must not stall every other emitter
			if not success then
				internal._failures += 1
				warn(`[{_localName}::{script.Name}]: Emitter step failed: {result}`)

				if internal._failures >= 3 then
					warn(`[{_localName}::{script.Name}]: Emitter paused after repeated failures.`)
					internal._playing = false
					internal._initialSpawnRemaining = 0

					-- Hide frozen particles so a paused emitter leaves nothing stuck on screen
					for particleIndex: number = #internal._particles, 1, -1 do
						ReleaseParticleEntry(internal, particleIndex)
					end

					Scheduler._deactivateEmitter(internal)
				end
			elseif internal._failures > 0 then
				internal._failures = 0
			end
		end

		index += 1
	end

	STEPPING = false

	--[[ Compacting ]]

	local needsCompact: boolean = false

	--- @param internal UIEmitter_State
	for _index: number, internal in ACTIVE_EMITTERS do
		if not internal._active then
			internal._listed = false
			needsCompact = true
		end
	end

	if needsCompact or #ACTIVE_EMITTERS == 0 then
		Scheduler._compactActiveEmitters()
	end
end

--%%%%%%%%%%%%%%%%%%%% Step Emitter

--[[
	Updates continuous emission and all live particles.
]]
--- @param internal UIEmitter_State
function Scheduler._stepEmitter(internal, deltaTime: number)
	--[[ Checks ]]

	-- Stop updating destroyed emitters
	if internal._destroyed then
		Scheduler.DisconnectUpdateLoop(internal)
		return
	end

	local config = internal._config --- @type UIEmitter_CompiledConfig
	local parent: GuiObject = config.Parent

	-- Stop emitting once the parent left the hierarchy so the loop can go idle
	if parent.Parent == nil then
		internal._playing = false
		internal._initialSpawnRemaining = 0
	end

	--[[ Local Variables ]]

	local particles = internal._particles --- @type { UIEmitter_Entry }
	local wantsInitial: boolean = internal._initialSpawnRemaining > 0
	local wantsRate: boolean = internal._playing and config.Rate > 0
	local frame = nil --- @type UIEmitter_Frame?

	if wantsInitial or wantsRate or #particles > 0 then
		frame = Particle.BuildFrameContext(internal)
	end

	--[[ Initial Warm Start ]]

	if wantsInitial then
		local spawnBudget: number = math.min(internal._initialSpawnRemaining, config.InitialSpawnPerStep or MAX_INITIAL_SPAWNS_PER_STEP)

		for _: number = 1, spawnBudget do
			internal._initialSpawnRemaining -= 1
			Particle.Spawn(internal, frame, Particle.SampleInitialAgeProgress(config))
		end
	end

	--[[ Continuous Emission ]]

	if wantsRate then
		local spawnsThisStep: number = 0

		internal._spawnAccumulator += config.Rate * deltaTime

		while internal._spawnAccumulator >= 1 and spawnsThisStep < MAX_SPAWNS_PER_STEP do
			internal._spawnAccumulator -= 1
			spawnsThisStep += 1
			Particle.Spawn(internal, frame, nil)
		end

		-- Drop most backlog after a slow frame to avoid hitch cascades
		if spawnsThisStep >= MAX_SPAWNS_PER_STEP then
			internal._spawnAccumulator = math.min(internal._spawnAccumulator, 1)
		end
	end

	--[[ Particle Updates ]]

	if #particles > 0 then
		Scheduler._stepParticles(internal, frame, deltaTime)
	end

	--[[ Idle Disconnect ]]

	if (not internal._playing or config.Rate <= 0) and internal._initialSpawnRemaining <= 0 and #particles == 0 then
		Scheduler.DisconnectUpdateLoop(internal)
	end
end

--%%%%%%%%%%%%%%%%%%%% Step Particles

--[[
	Advances every live particle of one emitter and writes changed GuiObject properties.
]]
--- @param internal UIEmitter_State
--- @param frame UIEmitter_Frame
function Scheduler._stepParticles(internal, frame, deltaTime: number)
	--[[ Local Variables ]]

	local config = internal._config --- @type UIEmitter_CompiledConfig
	local particles = internal._particles --- @type { UIEmitter_Entry }
	local attractTarget: Vector3? = if config.AttractTo ~= nil then Attraction.ResolveAttractTargetToLocal(internal, frame) else nil
	local cullDue: boolean = false

	--[[ Culling Timer ]]

	if config.CullOffscreen then
		internal._cullTimer += deltaTime

		if internal._cullTimer >= CULL_INTERVAL then
			internal._cullTimer = 0
			cullDue = true
		end
	end

	--[[ Particle Loop ]]

	-- Swap-remove refills the current slot, so the index only advances for surviving particles
	local index: number = 1

	while index <= #particles do
		--- @type UIEmitter_Entry
		local entry = particles[index]

		--[[ Age ]]

		entry.Elapsed += deltaTime

		if attractTarget and entry.AttractPauseAtProgress ~= nil and not entry.AttractLifecycleReleased then
			AdvancePausedAge(entry, attractTarget, deltaTime, config)
		else
			entry.Age += deltaTime
		end

		if entry.Age >= entry.Lifetime then
			ReleaseParticleEntry(internal, index)
			continue
		end

		local progress: number = entry.Age / entry.NominalLifetime

		if progress > 1 then
			progress = 1
		end

		--[[ Motion ]]

		local velocity: Vector3 = entry.Velocity
		local gravity: Vector3 = entry.Gravity
		local drag: number = entry.Drag

		if entry.GravitySource then
			gravity = EvalVectorSource(entry.GravitySource, progress, DEFAULT_GRAVITY)
			entry.Gravity = gravity
		end

		if entry.DragSource then
			drag = EvalCurve(entry.DragSource, progress)
			drag = if drag > 0 then drag else 0
			entry.Drag = drag
		end

		if entry.VelocitySource then
			velocity = EvalVelocitySource(entry.VelocitySource, progress)
		end

		velocity += gravity * deltaTime

		-- Cheaper approximation of exponential damping for many particles
		if drag > 0 then
			velocity *= 1 / (1 + drag * deltaTime)
		end

		entry.Velocity = velocity

		if attractTarget then
			ApplyAttraction(entry, attractTarget, deltaTime, config, progress)
		end

		if entry.OrbitSpeed then
			ApplyOrbitMotion(entry, frame, deltaTime, progress)
		else
			if entry.ShakeSpeed then
				ApplyShakeVelocity(entry, progress)
			end

			entry.Position += entry.Velocity * deltaTime
		end

		--[[ Arrival ]]

		if attractTarget and ResolveArrival(entry, attractTarget, config, progress) then
			ReleaseParticleEntry(internal, index)
			continue
		end

		-- Arrival callbacks may clear or destroy the emitter
		if particles[index] ~= entry then
			if internal._destroyed then
				return
			end

			continue
		end

		--[[ Rotation ]]

		if not entry.RotationStatic then
			entry.RotationOffset += EvalNumberSource(entry.RotationSpeedSource, progress, 0) * deltaTime
			entry.Rotation = EvalNumberSource(entry.RotationSource, progress, 0) + entry.RotationOffset
		end

		--[[ Flipbook ]]

		if entry.FlipbookEnabled then
			AdvanceFlipbook(entry, deltaTime)
		end

		--[[ Visuals ]]

		WritePosition(entry)

		if not entry.VisualStatic then
			ApplyParticleVisual(entry)
		end

		--[[ Culling ]]

		-- Newly spawned particles get one cull interval of grace before they can be culled
		if cullDue and entry.Elapsed >= CULL_INTERVAL and IsOutsideCullRect(entry, frame) then
			ReleaseParticleEntry(internal, index)
			continue
		end

		index += 1
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Scheduler
