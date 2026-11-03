--[[
	Created By:     Nari
]]

local _localName: string = "UIEmitter"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Config = require(script.Parent:FindFirstChild("Config")) --- @type UmeGui_UIEmitter_Config
local Sampler = require(script.Parent:FindFirstChild("Sampler")) --- @type UmeGui_UIEmitter_Sampler

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local EvalNumberSource = Sampler.EvalNumberSource --- @type (source: UmeGui_UIEmitter_NumberSource | nil, alpha: number, fallback: number) -> number

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

--- @class UmeGui_UIEmitter_Attraction
local Attraction = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Live Values

--%%%%%%%%%%%%%%%%%%%% Effective Number

--[[
	Returns a non-negative attract number from live config or the particle snapshot.
]]
--- @param entry UmeGui_UIEmitter_Entry
--- @param entryValue UmeGui_UIEmitter_NumberSource
--- @return number
function Attraction._effectiveNumber(entry, cfgValue: any, entryValue, progress: number)
	--[[ Live Number ]]

	-- Live mode only overrides with plain numbers; curves fall back to the particle snapshot
	if entry.AttractLiveFromEmitter and type(cfgValue) == "number" then
		return if cfgValue > 0 then cfgValue else 0
	end

	--[[ Snapshot ]]

	local value: number = EvalNumberSource(entryValue, progress, 0)

	return if value > 0 then value else 0
end

--%%%%%%%%%%%%%%%%%%%% Effective Attract Arrive Radius

--[[
	Returns arrival radius from live config or particle snapshot.
]]
--- @param entry UmeGui_UIEmitter_Entry
--- @param cfg UmeGui_UIEmitter_CompiledConfig
--- @return number
function Attraction._effectiveAttractArriveRadius(entry, cfg, progress: number)
	--[[ Clamping ]]

	local radius: number = Attraction._effectiveNumber(entry, cfg.AttractArriveRadius, entry.AttractArriveRadius, progress)

	return if radius > 0.001 then radius else 0.001
end

--%%%%%%%%%%%%%%%%%%%% Effective Attract Stop On Arrive

--[[
	Returns whether attraction should stop on arrival.
]]
--- @param entry UmeGui_UIEmitter_Entry
--- @param cfg UmeGui_UIEmitter_CompiledConfig
--- @return boolean
function Attraction.EffectiveAttractStopOnArrive(entry, cfg)
	--[[ Live Value ]]

	if entry.AttractLiveFromEmitter then
		return cfg.AttractStopOnArrive
	end

	return entry.AttractStopOnArrive
end

--%%%%%%%%%%%%%%%%%%%% Effective Attract Destroy On Arrive

--[[
	Returns whether attraction should destroy on arrival.
]]
--- @param entry UmeGui_UIEmitter_Entry
--- @param cfg UmeGui_UIEmitter_CompiledConfig
--- @return boolean
function Attraction.EffectiveAttractDestroyOnArrive(entry, cfg)
	--[[ Live Value ]]

	if entry.AttractLiveFromEmitter then
		return cfg.AttractDestroyOnArrive
	end

	return entry.AttractDestroyOnArrive
end

--%%%%%%%%%%%%%%%%%%%% Get Progress

--[[
	Returns clamped lifetime progress for the particle's current age.
]]
--- @param entry UmeGui_UIEmitter_Entry
--- @return number
function Attraction._getProgress(entry)
	--[[ Clamping ]]

	local progress: number = entry.Age / entry.NominalLifetime

	return if progress < 1 then progress else 1
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Target Resolution

--%%%%%%%%%%%%%%%%%%%% Resolve Attract Value To Absolute

--[[
	Resolves one attraction target value into an absolute screen point.
]]
--- @param cfg UmeGui_UIEmitter_CompiledConfig
--- @return Vector2?
function Attraction._resolveAttractValueToAbsolute(value: any, cfg)
	--[[ Type Dispatch ]]

	local valueType: string = typeof(value)

	if valueType == "Instance" then
		if value:IsA("GuiObject") then
			return value.AbsolutePosition + value.AbsoluteSize * 0.5
		end

		return nil
	end

	if valueType == "UDim2" then
		return Config.ResolvePositionToAbsolute(value, cfg.Container)
	end

	if valueType == "Vector2" then
		if cfg.AttractToSpace == "absolute" then
			return value
		end

		return Config.ResolvePositionToAbsolute(value, cfg.Container)
	end

	return nil
end

--%%%%%%%%%%%%%%%%%%%% Resolve Attract Target To Local

--[[
	Resolves the current emitter-level attraction target once for this frame.
]]
--- @param internal UmeGui_UIEmitter_State
--- @param frame UmeGui_UIEmitter_Frame
--- @return Vector3?
function Attraction.ResolveAttractTargetToLocal(internal, frame)
	--[[ Config Target ]]

	local cfg = internal._config --- @type UmeGui_UIEmitter_CompiledConfig
	local attractTo: any = cfg.AttractTo

	if attractTo == nil then
		return nil
	end

	--[[ Callback Target ]]

	if type(attractTo) == "function" then
		local success: boolean
		local result: any | string?
		success, result = pcall(attractTo, cfg.Container)

		if not success then
			-- Warn once per emitter so a broken callback does not flood output
			if not internal._warnedAttractTo then
				internal._warnedAttractTo = true
				warn(`[{_localName}::{script.Name}]: AttractTo callback failed: {result}`)
			end

			return nil
		end

		attractTo = result
	end

	--[[ Absolute To Local ]]

	local targetAbsolute: Vector2? = Attraction._resolveAttractValueToAbsolute(attractTo, cfg)

	if not targetAbsolute then
		return nil
	end

	-- Particle positions are stored in Parent-local space.
	local parentAbsolutePosition: Vector2 = frame.ParentAbsolutePosition

	return Vector3.new(targetAbsolute.X - parentAbsolutePosition.X, targetAbsolute.Y - parentAbsolutePosition.Y, 0)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Pause Hold

--%%%%%%%%%%%%%%%%%%%% Can Count Attract Arrival

--[[
	When arrival is gated to the pause hold, only counts while lifetime is held at the pause point.
]]
--- @param entry UmeGui_UIEmitter_Entry
--- @return boolean
function Attraction._canCountAttractArrival(entry)
	--[[ Gating ]]

	local pauseProgress: number? = entry.AttractPauseAtProgress

	if not entry.AttractArriveOnlyWhenPaused or pauseProgress == nil then
		return true
	end

	return entry.Age >= entry.NominalLifetime * pauseProgress and not entry.AttractLifecycleReleased
end

--%%%%%%%%%%%%%%%%%%%% Is Attract Target Reached

--[[
	Checks whether the particle has reached its attraction radius.
]]
--- @param entry UmeGui_UIEmitter_Entry
--- @param cfg UmeGui_UIEmitter_CompiledConfig
--- @return boolean
function Attraction.IsAttractTargetReached(entry, targetPosition: Vector3, cfg, progress: number)
	--[[ Checks ]]

	if not Attraction._canCountAttractArrival(entry) then
		return false
	end

	--[[ Distance Check ]]

	return (targetPosition - entry.Position).Magnitude <= Attraction._effectiveAttractArriveRadius(entry, cfg, progress)
end

--%%%%%%%%%%%%%%%%%%%% Begin Arrive Stop

--[[
	Stops a particle on its attract target and starts an optional scale-down release.
]]
--- @param entry UmeGui_UIEmitter_Entry
function Attraction.BeginArriveStop(entry, targetPosition: Vector3)
	--[[ Stop ]]

	entry.AttractStopped = true
	entry.Velocity = Vector3.zero
	entry.Position = targetPosition

	--[[ Scale-Down Release ]]

	local releaseDuration: number? = entry.AttractReleaseDuration

	if entry.AttractLifecycleReleased or not releaseDuration or releaseDuration <= 0 then
		return
	end

	entry.AttractLifecycleReleased = true
	entry.AttractPauseAtProgress = math.clamp(entry.Age / entry.NominalLifetime, 0, 0.999)
	entry.ReleaseStartAge = entry.Age
	entry.Lifetime = entry.Age + releaseDuration
end

--%%%%%%%%%%%%%%%%%%%% Resolve Arrival

--[[
	Fires the arrival callback once, applies stop-on-arrive, and reports whether the particle should be destroyed.
]]
--- @param entry UmeGui_UIEmitter_Entry
--- @param cfg UmeGui_UIEmitter_CompiledConfig
--- @return boolean
function Attraction.ResolveArrival(entry, targetPosition: Vector3, cfg, progress: number)
	--[[ Arrival Notify ]]

	if not entry.AttractArrived and Attraction.IsAttractTargetReached(entry, targetPosition, cfg, progress) then
		local callback: ((particle: GuiObject) -> ())? = entry.AttractOnArrive

		entry.AttractArrived = true

		if callback then
			local success: boolean
			local result: any | string?
			success, result = pcall(callback, entry.Particle)

			if not success then
				warn(`[{_localName}::{script.Name}]: AttractOnArrive callback failed: {result}`)
			end
		end
	end

	--[[ Stop On Arrive ]]

	if not entry.AttractStopped and Attraction.EffectiveAttractStopOnArrive(entry, cfg) and Attraction.IsAttractTargetReached(entry, targetPosition, cfg, progress) then
		Attraction.BeginArriveStop(entry, targetPosition)
	end

	--[[ Destroy On Arrive ]]

	return Attraction.EffectiveAttractDestroyOnArrive(entry, cfg) and Attraction.IsAttractTargetReached(entry, targetPosition, cfg, progress)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Steering

--%%%%%%%%%%%%%%%%%%%% Apply Attraction

--[[
	Applies optional attraction acceleration toward a live target point.
]]
--- @param entry UmeGui_UIEmitter_Entry
--- @param cfg UmeGui_UIEmitter_CompiledConfig
function Attraction.ApplyAttraction(entry, targetPosition: Vector3, deltaTime: number, cfg, progress: number)
	--[[ Activation ]]

	if entry.AttractStopped then
		return
	end

	local strength: number = Attraction._effectiveNumber(entry, cfg.AttractStrength, entry.AttractStrength, progress)
	local attractAfter: number = if entry.AttractLiveFromEmitter and type(cfg.AttractAfter) == "number" then math.max(cfg.AttractAfter, 0) else entry.AttractAfter

	if strength <= 0 or entry.Age < attractAfter then
		return
	end

	--[[ Direction ]]

	local offset: Vector3 = targetPosition - entry.Position
	local distance: number = offset.Magnitude
	local arriveRadius: number = Attraction._effectiveAttractArriveRadius(entry, cfg, progress)
	local stopOnArrive: boolean = Attraction.EffectiveAttractStopOnArrive(entry, cfg)

	if stopOnArrive and distance <= arriveRadius and Attraction._canCountAttractArrival(entry) then
		Attraction.BeginArriveStop(entry, targetPosition)
		return
	end

	if distance <= 0.001 then
		return
	end

	--[[ Near-Target Arrival ]]

	local maxSpeed: number = Attraction._effectiveNumber(entry, cfg.AttractMaxSpeed, entry.AttractMaxSpeed, progress)
	local safeDelta: number = math.max(deltaTime, 0.001)

	if stopOnArrive and distance <= arriveRadius * 4 then
		local approachSpeed: number = distance / safeDelta * 0.8

		if maxSpeed > 0 and approachSpeed > maxSpeed then
			approachSpeed = maxSpeed
		end

		entry.Velocity = offset * (approachSpeed / distance)
		return
	end

	--[[ Steering ]]

	local velocity: Vector3 = entry.Velocity + offset * (strength * deltaTime / distance)

	-- Keep each step shorter than the remaining distance so fast particles cannot cross the target.
	if stopOnArrive then
		local brakeSpeed: number = distance / safeDelta

		if maxSpeed <= 0 or brakeSpeed < maxSpeed then
			maxSpeed = brakeSpeed
		end
	end

	if maxSpeed > 0 then
		local speed: number = velocity.Magnitude

		if speed > maxSpeed then
			velocity *= maxSpeed / speed
		end
	end

	entry.Velocity = velocity
end

--%%%%%%%%%%%%%%%%%%%% Advance Paused Age

--[[
	Advances lifetime while holding at the attraction pause point until arrival or timeout.
]]
--- @param entry UmeGui_UIEmitter_Entry
--- @param cfg UmeGui_UIEmitter_CompiledConfig
function Attraction.AdvancePausedAge(entry, targetPosition: Vector3, deltaTime: number, cfg)
	--[[ Approach ]]

	local pauseAge: number = entry.NominalLifetime * entry.AttractPauseAtProgress

	if entry.Age < pauseAge then
		entry.Age = math.min(entry.Age + deltaTime, pauseAge)
		return
	end

	--[[ Pause Hold ]]

	-- AttractPauseMaxTime measures time spent holding at the pause, not total elapsed life.
	entry.AttractPauseHoldTime += deltaTime

	local timedOut: boolean = entry.AttractPauseMaxTime ~= nil and entry.AttractPauseHoldTime >= entry.AttractPauseMaxTime

	if not timedOut and not Attraction.IsAttractTargetReached(entry, targetPosition, cfg, Attraction._getProgress(entry)) then
		entry.Age = pauseAge
		return
	end

	--[[ Release Lifetime ]]

	entry.AttractLifecycleReleased = true

	if entry.AttractReleaseDuration and entry.AttractReleaseDuration > 0 then
		entry.ReleaseStartAge = entry.Age
		entry.Lifetime = entry.Age + entry.AttractReleaseDuration
	else
		entry.Lifetime = entry.NominalLifetime
	end

	entry.Age += deltaTime
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Attraction
