--[[
	Created By:     Nari
]]

local _localName: string = "UIEmitter"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Defaults = require(script.Parent:FindFirstChild("Defaults")) --- @type UmeGui_UIEmitter_Defaults
local Config = require(script.Parent:FindFirstChild("Config")) --- @type UmeGui_UIEmitter_Config
local Scheduler = require(script.Parent:FindFirstChild("Scheduler")) --- @type UmeGui_UIEmitter_Scheduler
local Particle = require(script.Parent:FindFirstChild("Particle")) --- @type UmeGui_UIEmitter_Particle

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local INTERNAL_KEY = {} --- @type { [any]: any }
local CONFIG_KEYS = Defaults.CONFIG_KEYS --- @type { [string]: boolean }
local MAX_POOL_SIZE: number = Defaults.MAX_POOL_SIZE

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Set Internal

--[[
	Stores an internal state table on the public proxy.
]]
--- @param proxy { [any]: any }
--- @param internal UmeGui_UIEmitter_State
local function setInternal(proxy, internal)
	rawset(proxy, INTERNAL_KEY, internal)
end

--%%%%%%%%%%%%%%%%%%%% Get Internal

--[[
	Returns internal state table for a proxy instance.
]]
--- @param proxy { [any]: any }
--- @return UmeGui_UIEmitter_State?
local function getInternal(proxy)
	return rawget(proxy, INTERNAL_KEY)
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

--- @class UmeGui_UIEmitter_Emitter
local Emitter = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Lifecycle

--%%%%%%%%%%%%%%%%%%%% Emit

--[[
	Spawns an immediate burst of particles.
	An optional absolute point overrides the configured spawn point and emission shape for that burst.
]]
function Emitter:Emit(count: number?, spawnAbsolutePoint: Vector2?)
	--[[ Checks ]]

	--- @type UmeGui_UIEmitter_State
	local internal = getInternal(self)
	assert(internal, `[{_localName}::{script.Name}]: Invalid emitter.`)
	assert(not internal._destroyed, `[{_localName}::{script.Name}]: Emitter is destroyed.`)

	local amount: number = if count == nil then 1 else count
	assert(typeof(amount) == "number" and amount >= 0, `[{_localName}::{script.Name}]: Emit count must be a non-negative number.`)
	assert(spawnAbsolutePoint == nil or typeof(spawnAbsolutePoint) == "Vector2", `[{_localName}::{script.Name}]: Emit spawn point must be a Vector2.`)

	--[[ Spawning ]]

	local spawnCount: number = math.floor(amount)
	local frame = if spawnCount > 0 then Particle.BuildFrameContext(internal) else nil --- @type UmeGui_UIEmitter_Frame?

	for _: number = 1, spawnCount do
		Particle.Spawn(internal, frame, nil, spawnAbsolutePoint)
	end

	--[[ Updating ]]

	if spawnCount > 0 then
		Scheduler.EnsureUpdateLoop(internal)
	end
end

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Starts continuous emission using Rate as particles per second.
]]
function Emitter:Play()
	--[[ Checks ]]

	--- @type UmeGui_UIEmitter_State
	local internal = getInternal(self)
	assert(internal, `[{_localName}::{script.Name}]: Invalid emitter.`)
	assert(not internal._destroyed, `[{_localName}::{script.Name}]: Emitter is destroyed.`)

	if internal._playing then
		return
	end

	if not internal._initialWarmStartStarted then
		--- @type UmeGui_UIEmitter_CompiledConfig
		local config = internal._config

		internal._initialWarmStartStarted = true
		internal._initialSpawnRemaining = math.floor(config.InitialParticles)
	end

	internal._playing = true
	internal._spawnAccumulator = 0

	--[[ Updating ]]

	Scheduler.EnsureUpdateLoop(internal)
end

--%%%%%%%%%%%%%%%%%%%% Stop

--[[
	Stops continuous emission while existing particles finish naturally.
]]
function Emitter:Stop()
	--[[ Checks ]]

	--- @type UmeGui_UIEmitter_State
	local internal = getInternal(self)
	assert(internal, `[{_localName}::{script.Name}]: Invalid emitter.`)

	--[[ Stopping ]]

	internal._playing = false
	internal._spawnAccumulator = 0

	--[[ Updating ]]

	if #internal._particles == 0 then
		Scheduler.DisconnectUpdateLoop(internal)
	end
end

--%%%%%%%%%%%%%%%%%%%% Prewarm

--[[
	Pre-creates hidden pooled particles so the first bursts skip instance creation and parenting.
]]
function Emitter:Prewarm(count: number)
	--[[ Checks ]]

	--- @type UmeGui_UIEmitter_State
	local internal = getInternal(self)
	assert(internal, `[{_localName}::{script.Name}]: Invalid emitter.`)
	assert(not internal._destroyed, `[{_localName}::{script.Name}]: Emitter is destroyed.`)
	assert(typeof(count) == "number" and count >= 0, `[{_localName}::{script.Name}]: Prewarm count must be a non-negative number.`)

	--[[ Pooling ]]

	Particle.PrewarmPool(internal, math.floor(count))
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	Destroys all active particles without changing the playing state.
]]
function Emitter:Clear()
	--[[ Checks ]]

	--- @type UmeGui_UIEmitter_State
	local internal = getInternal(self)
	assert(internal, `[{_localName}::{script.Name}]: Invalid emitter.`)

	--[[ Clearing ]]

	for index: number = #internal._particles, 1, -1 do
		Particle.ReleaseParticleEntry(internal, index)
	end

	--[[ Updating ]]

	if not internal._playing then
		Scheduler.DisconnectUpdateLoop(internal)
	end
end

--%%%%%%%%%%%%%%%%%%%% Destroy

--[[
	Stops emission, clears particles, and marks the emitter destroyed.
]]
function Emitter:Destroy()
	--[[ Checks ]]

	--- @type UmeGui_UIEmitter_State
	local internal = getInternal(self)
	assert(internal, `[{_localName}::{script.Name}]: Invalid emitter.`)

	if internal._destroyed then
		return
	end

	internal._destroyed = true
	internal._playing = false
	internal._spawnAccumulator = 0

	--[[ Clearing ]]

	self:Clear()
	Scheduler.DisconnectUpdateLoop(internal)

	--[[ Pool ]]

	Particle.TrimPool(internal, 0)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constructor

--%%%%%%%%%%%%%%%%%%%% New

--[[
	**CLIENT** |
	Creates a UI particle emitter from a config table or ParticleEmitter instance.
]]
--- @param params UmeGui_UIEmitter_Params | ParticleEmitter
--- @return UmeGui_UIEmitter_Instance
function Emitter.new(params)
	--[[ Checks ]]

	--- @type UmeGui_UIEmitter_CompiledConfig
	local cfg = Config.GetConfigFromParams(params)

	--[[ State ]]

	--- @type UmeGui_UIEmitter_State
	local internal = {
		_config = cfg,
		_plan = Config.Compile(cfg),
		_frame = {},
		_destroyed = false,
		_playing = false,
		_active = false,
		_listed = false,
		_failures = 0,
		_spawnAccumulator = 0,
		_cullTimer = 0,
		_initialWarmStartStarted = false,
		_initialSpawnRemaining = 0,
		_warnedAttractTo = false,
		_particles = {},
		_pool = {
			Frame = {},
			ImageLabel = {},
		},
		_poolCount = 0,
		_poolLimit = if cfg.MaxParticles > 0 then math.min(cfg.MaxParticles, MAX_POOL_SIZE) else MAX_POOL_SIZE,
	}

	--[[ Proxy ]]

	--- @type UmeGui_UIEmitter_Instance
	local proxy = setmetatable({}, {
		__index = function(tableRef: { [any]: any }, key: any)
			--[[ Methods ]]

			local method: any = Emitter[key]

			if method ~= nil then
				return method
			end

			--[[ Config ]]

			--- @type UmeGui_UIEmitter_State
			local state = getInternal(tableRef)

			return state._config[key]
		end,

		__newindex = function(tableRef: { [any]: any }, key: any, value: any)
			--[[ Config ]]

			if CONFIG_KEYS[key] then
				local state = getInternal(tableRef) --- @type UmeGui_UIEmitter_State
				local merged = Config.CloneForUpdate(state._config) --- @type { [string]: any }

				merged[key] = value
				state._config = Config.ValidateTableParams(merged)
				state._plan = Config.Compile(state._config)

				--[[ Pool Limit ]]

				if key == "MaxParticles" then
					state._poolLimit = if state._config.MaxParticles > 0 then math.min(state._config.MaxParticles, MAX_POOL_SIZE) else MAX_POOL_SIZE

					Particle.TrimPool(state, state._poolLimit)
				end

				--[[ Scheduler ]]

				if key == "Rate" and state._playing and state._config.Rate > 0 then
					-- A stopped idle scheduler must wake if Rate is re-enabled while playing.
					Scheduler.EnsureUpdateLoop(state)
				end

				return
			end

			--[[ Error ]]

			error(`[{_localName}::{script.Name}]: Unknown property "{tostring(key)}".`, 2)
		end,
	})

	--[[ Proxy State ]]

	setInternal(proxy, internal)

	return proxy
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Emitter
