--[[
    Created By:     Nari
]]

local _localName = "Ragdoll"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

local DEFAULT_PRESET: string = "Arcade"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _data = script:FindFirstChild("Data")
local _scripts = script:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local Presets = require(_data:FindFirstChild("Presets")) --- @type { [string]: Ragdoll_Preset }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Build = require(_scripts:FindFirstChild("Build")) --- @type Ragdoll_Build
local Body = require(_scripts:FindFirstChild("Body")) --- @type Ragdoll_Body

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { [Model]: Ragdoll_RigCache }
local rigCaches = setmetatable({}, { __mode = "k" })

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Cache

--[[
	Returns the model's rig cache, scanning again once a constraints folder appears (for example after it replicates).
]]
--- @return Ragdoll_RigCache
local function getCache(model: Model)
	--[[ Data ]]

	local cache = rigCaches[model] --- @type Ragdoll_RigCache?

	--[[ Creating ]]

	-- Create the cache on first use
	if not cache then
		cache = {
			Motors = {},
			AnimationJoints = {},
			Sockets = {},
			ForeignSockets = {},
			RootWelds = {},
			RootSocketOwned = false,
			Active = false,
			Scanned = false,
			FoundFolder = false,
		}
		rigCaches[model] = cache
	end

	--[[ Scanning ]]

	local foundFolder: boolean = Build.HasConstraints(model)

	-- Rescan once the constraints folder appears
	if not cache.Scanned or (foundFolder and not cache.FoundFolder) then
		Build.Scan(model, cache)
		cache.Scanned = true
		cache.FoundFolder = foundFolder
	end

	--[[ Returning ]]

	return cache
end

--%%%%%%%%%%%%%%%%%%%% Assert Model

--[[
	Errors when the value is not a Model.
]]
local function assertModel(model: any, functionName: string)
	--[[ Checks ]]

	-- Check if the value is a Model
	assert(typeof(model) == "Instance" and model:IsA("Model"), `[{_localName}::{script.Name}]: Parameter #1 to Ragdoll.{functionName} must be a Model; got {typeof(model)}`)
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

--- @class Ume_Library_Ragdoll : Ume_Library
local Ragdoll = {

	--[[ Data ]]

	Presets = Presets,
}

--%%%%%%%%%%%%%%%%%%%% Inject Ume

--[[
	Assigns this library onto Ume.
]]
--- @param umeInstance Ume
function Ragdoll._injectUme(umeInstance)
	--- @type Ume
	local I = umeInstance

	--[[ Assigning ]]

	I.Ragdoll = Ragdoll --- @type Ume_Library_Ragdoll
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Rig

--[[
	Builds the ragdoll constraints of a character and keeps its joints on death. Safe to call more than once.
	Rig player characters on the server so the sockets replicate to every client.
]]
function Ragdoll.Rig(model: Model)
	--[[ Checks ]]

	assertModel(model, "Rig")

	--[[ Humanoid ]]

	local humanoid: Humanoid? = model:FindFirstChildOfClass("Humanoid")

	-- Keep the joints when the humanoid dies
	if humanoid then
		humanoid.BreakJointsOnDeath = false
	end

	--[[ Building ]]

	Build.Rig(model)

	--[[ Saving ]]

	local cache = rigCaches[model] --- @type Ragdoll_RigCache?

	-- Force a rescan on the next lookup
	if cache then
		cache.Scanned = false
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Joints

--[[
	Swaps the motors for the ball sockets (or back). The root align only runs while ragdolled.
	Call it on the server too, so other clients see the loose joints.
]]
function Ragdoll.SetJoints(model: Model, ragdoll: boolean)
	--[[ Checks ]]

	assertModel(model, "SetJoints")

	--[[ Data ]]

	local cache = getCache(model) --- @type Ragdoll_RigCache

	--[[ Joints ]]

	for _index: number, motor: Motor6D in ipairs(cache.Motors) do
		motor.Enabled = not ragdoll
	end

	for _index: number, joint: AnimationConstraint in ipairs(cache.AnimationJoints) do
		joint.Enabled = not ragdoll
	end

	for _index: number, weld: WeldConstraint in ipairs(cache.RootWelds) do
		weld.Enabled = not ragdoll
	end

	--[[ Sockets ]]

	for _index: number, socket: BallSocketConstraint in ipairs(cache.Sockets) do
		socket.Enabled = ragdoll
	end

	-- Leave foreign root sockets enabled once they were turned on
	if cache.RootSocket and (cache.RootSocketOwned or ragdoll) then
		cache.RootSocket.Enabled = ragdoll
	end

	-- Toggle the upright align when the rig has one
	if cache.RootAlign then
		cache.RootAlign.Enabled = ragdoll
	end
end

--%%%%%%%%%%%%%%%%%%%% Start

--[[
	Ragdolls a model with a preset feel (`Arcade` by default) and an optional launch and duration.
	Run it where the model's physics is simulated: the owning client for player characters, the server for NPCs.
	Rigs the model first when needed. A later call while ragdolled only extends the duration.
]]
--- @param options Ragdoll_StartOptions?
function Ragdoll.Start(model: Model, options)
	--[[ Checks ]]

	assertModel(model, "Start")

	--[[ Local Variables ]]

	options = options or {}

	--[[ Data ]]

	local preset = if type(options.Preset) == "table" then options.Preset else Ragdoll.GetPreset(options.Preset or DEFAULT_PRESET) --- @type Ragdoll_Preset?

	--[[ Checks ]]

	-- Check if the preset exists
	if not preset then
		return
	end

	--[[ Rigging ]]

	-- Rig the model when it has no constraints yet
	if not Build.HasConstraints(model) then
		Ragdoll.Rig(model)
	end

	--[[ Data ]]

	local cache = getCache(model) --- @type Ragdoll_RigCache

	--[[ Beginning ]]

	-- Skip setup when already ragdolled
	if not cache.Active then
		cache.Active = true

		Body.ApplyJointLimits(cache, preset, Build.GetJointGroup)
		Ragdoll.SetJoints(model, true)

		-- Follow the preset's upright setting when the rig has an align
		if cache.RootAlign then
			cache.RootAlign.Enabled = preset.KeepUpright
		end

		Body.EnsureColliders(model, cache)
		Body.SetCollidersEnabled(cache, true, preset)
		Body.HoldCollision(model, cache)
		Body.BeginHumanoid(model)
	end

	--[[ Launching ]]

	-- Skip the launch without a velocity
	if options.Velocity and options.Velocity.Magnitude > 0 then
		Body.Launch(model, options.Velocity, preset, function()
			return cache.Active
		end)
	end

	--[[ Scheduling ]]

	-- Skip timers that would end sooner than the current one
	if not options.Duration or (cache.EndsAt and cache.EndsAt >= os.clock() + options.Duration) then
		return
	end

	local endsAt: number = os.clock() + options.Duration
	cache.EndsAt = endsAt

	task.delay(options.Duration, function()
		-- Skip timers replaced by a longer one or ended early
		if cache.EndsAt ~= endsAt then
			return
		end

		Ragdoll.Stop(model)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Stop

--[[
	Ends the ragdoll, restores joints and collision, and stands a living character back up.
]]
function Ragdoll.Stop(model: Model)
	--[[ Checks ]]

	assertModel(model, "Stop")

	--[[ Data ]]

	local cache = rigCaches[model] --- @type Ragdoll_RigCache?

	--[[ Checks ]]

	-- Check if the model is ragdolled
	if not cache or not cache.Active then
		return
	end

	--[[ Restoring ]]

	cache.Active = false
	cache.EndsAt = nil

	Ragdoll.SetJoints(model, false)
	Body.RestoreJointLimits(cache)
	Body.SetCollidersEnabled(cache, false, nil)
	Body.ReleaseCollision(cache)

	--[[ Recovering ]]

	-- Skip models that were removed meanwhile
	if not model.Parent then
		return
	end

	Body.FinishHumanoid(model)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Preset

--[[
	Returns the ragdoll preset with this name.
]]
--- @return Ragdoll_Preset?
function Ragdoll.GetPreset(presetName: string)
	--[[ Checks ]]

	-- Check if the preset exists
	if not Presets[presetName] then
		warn(`[{_localName}::{script.Name}]: Preset ({presetName}) is missing!`)
		return nil
	end

	--[[ Returning ]]

	return Presets[presetName]
end

--%%%%%%%%%%%%%%%%%%%% Is Ragdolled

--[[
	Returns whether the model is ragdolled by this environment.
]]
--- @return boolean
function Ragdoll.IsRagdolled(model: Model)
	--[[ Data ]]

	local cache = rigCaches[model] --- @type Ragdoll_RigCache?

	--[[ Returning ]]

	return cache ~= nil and cache.Active
end

return Ragdoll
