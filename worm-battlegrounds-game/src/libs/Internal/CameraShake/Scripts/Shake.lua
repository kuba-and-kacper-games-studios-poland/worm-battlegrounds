--[[
	Created By:     voidsky
	Edited By:      Nari
]]

local _localName = "CameraShake"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

local DEFAULT_POSITION_INFLUENCE: Vector3 = Vector3.new(0.15, 0.15, 0.15)
local DEFAULT_ROTATION_INFLUENCE: Vector3 = Vector3.new(1, 1, 1)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Clamp Time

--[[
	Clamps a time value to a non-negative number.
]]
--- @return number
local function clampTime(value: number?)
	return math.max(value or 0, 0)
end

--%%%%%%%%%%%%%%%%%%%% Sample Noise Offset

--[[
	Samples a smooth 3D noise offset in the range roughly [-0.5, 0.5] per axis.
]]
--- @return Vector3
local function sampleNoiseOffset(tickValue: number)
	--[[ Sampling ]]

	local x: number = math.noise(tickValue, 0) * 0.5
	local y: number = math.noise(0, tickValue) * 0.5
	local z: number = math.noise(tickValue, tickValue) * 0.5

	return Vector3.new(x, y, z)
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

local Shake = {}
Shake.__index = Shake

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% New

--[[
	Creates a new shake in the Inactive state, ready to be Played.
]]
--- @param config CameraShake_Config
--- @return CameraShake_Shake
function Shake.new(config)
	--[[ Checks ]]

	assert(type(config) == "table", `[{_localName}::{script.Name}]: Parameter #1 to Shake.{debug.info(1, "n")} must be a table; got {typeof(config)}`)
	assert(type(config.Magnitude) == "number", `[{_localName}::{script.Name}]: Config.Magnitude must be a number; got {typeof(config.Magnitude)}`)
	assert(type(config.Roughness) == "number", `[{_localName}::{script.Name}]: Config.Roughness must be a number; got {typeof(config.Roughness)}`)

	--[[ Local Variables ]]

	local positionInfluence: Vector3 = if typeof(config.PositionInfluence) == "Vector3" then config.PositionInfluence else DEFAULT_POSITION_INFLUENCE
	local rotationInfluence: Vector3 = if typeof(config.RotationInfluence) == "Vector3" then config.RotationInfluence else DEFAULT_ROTATION_INFLUENCE

	--[[ Returning ]]

	--- @type CameraShake_Shake
	local self = setmetatable({
		Magnitude = config.Magnitude,
		Roughness = config.Roughness,

		PositionInfluence = positionInfluence,
		RotationInfluence = rotationInfluence,

		_tick = Random.new():NextNumber(-100, 100),

		_sustain = false,
		_oneShot = false,
		_currentFadeTime = 0,
		_fadeInDuration = 0,
		_fadeOutDuration = 0,
		_holdRemaining = nil,
	}, Shake)

	return self
end

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Starts (or restarts) a sustained shake with a fade-in.
]]
function Shake:Play(fadeTime: number?)
	--[[ Checks ]]

	assert(type(fadeTime) == "number" or fadeTime == nil, `[{_localName}::{script.Name}]: Parameter #1 to Shake:{debug.info(1, "n")} must be a number or nil; got {typeof(fadeTime)}`)

	--[[ Local Variables ]]

	local duration: number = clampTime(fadeTime)

	--[[ Fade State ]]

	self._oneShot = false
	self._sustain = true
	self._fadeInDuration = duration
	self._fadeOutDuration = 0
	self._holdRemaining = nil

	-- Start at full strength when there is no fade-in
	if duration <= 0 then
		self._currentFadeTime = 1
	else
		self._currentFadeTime = 0
	end
end

--%%%%%%%%%%%%%%%%%%%% Play Once

--[[
	Fades in, holds for the given duration, then fades out automatically.
]]
function Shake:PlayOnce(holdDuration: number, fadeInTime: number?, fadeOutTime: number?)
	--[[ Checks ]]

	assert(type(holdDuration) == "number", `[{_localName}::{script.Name}]: Parameter #1 to Shake:{debug.info(1, "n")} must be a number; got {typeof(holdDuration)}`)
	assert(type(fadeInTime) == "number" or fadeInTime == nil, `[{_localName}::{script.Name}]: Parameter #2 to Shake:{debug.info(1, "n")} must be a number or nil; got {typeof(fadeInTime)}`)
	assert(type(fadeOutTime) == "number" or fadeOutTime == nil, `[{_localName}::{script.Name}]: Parameter #3 to Shake:{debug.info(1, "n")} must be a number or nil; got {typeof(fadeOutTime)}`)

	--[[ Local Variables ]]

	local fadeInDuration: number = clampTime(fadeInTime)
	local fadeOutDuration: number = clampTime(fadeOutTime)

	--[[ Fade State ]]

	self._oneShot = true
	self._sustain = true
	self._fadeInDuration = fadeInDuration
	self._fadeOutDuration = fadeOutDuration
	self._holdRemaining = math.max(holdDuration, 0)

	-- Start at full strength when there is no fade-in
	if fadeInDuration <= 0 then
		self._currentFadeTime = 1
	else
		self._currentFadeTime = 0
	end
end

--%%%%%%%%%%%%%%%%%%%% Stop

--[[
	Starts the fade-out of the shake.
]]
function Shake:Stop(fadeTime: number?)
	--[[ Checks ]]

	assert(type(fadeTime) == "number" or fadeTime == nil, `[{_localName}::{script.Name}]: Parameter #1 to Shake:{debug.info(1, "n")} must be a number or nil; got {typeof(fadeTime)}`)

	--[[ Local Variables ]]

	local duration: number = clampTime(fadeTime)

	--[[ Fade State ]]

	self._oneShot = false
	self._sustain = false
	self._fadeInDuration = 0
	self._fadeOutDuration = duration
	self._holdRemaining = nil

	-- End at once when there is no fade-out
	if duration <= 0 then
		self._currentFadeTime = 0
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Magnitude

--[[
	Updates the shake magnitude while the shake is active.
]]
function Shake:SetMagnitude(magnitude: number)
	--[[ Checks ]]

	assert(type(magnitude) == "number", `[{_localName}::{script.Name}]: Parameter #1 to Shake:{debug.info(1, "n")} must be a number; got {typeof(magnitude)}`)

	--[[ Applying ]]

	self.Magnitude = magnitude
end

--%%%%%%%%%%%%%%%%%%%% Set Roughness

--[[
	Updates the shake roughness while the shake is active.
]]
function Shake:SetRoughness(roughness: number)
	--[[ Checks ]]

	assert(type(roughness) == "number", `[{_localName}::{script.Name}]: Parameter #1 to Shake:{debug.info(1, "n")} must be a number; got {typeof(roughness)}`)

	--[[ Applying ]]

	self.Roughness = roughness
end

--%%%%%%%%%%%%%%%%%%%% Set Position Influence

--[[
	Updates the position influence while the shake is active.
]]
function Shake:SetPositionInfluence(influence: Vector3)
	--[[ Checks ]]

	assert(typeof(influence) == "Vector3", `[{_localName}::{script.Name}]: Parameter #1 to Shake:{debug.info(1, "n")} must be a Vector3; got {typeof(influence)}`)

	--[[ Applying ]]

	self.PositionInfluence = influence
end

--%%%%%%%%%%%%%%%%%%%% Set Rotation Influence

--[[
	Updates the rotation influence while the shake is active.
]]
function Shake:SetRotationInfluence(influence: Vector3)
	--[[ Checks ]]

	assert(typeof(influence) == "Vector3", `[{_localName}::{script.Name}]: Parameter #1 to Shake:{debug.info(1, "n")} must be a Vector3; got {typeof(influence)}`)

	--[[ Applying ]]

	self.RotationInfluence = influence
end

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	Advances the fade state and returns the current shake offset for this frame.
]]
--- @return Vector3
function Shake:Update(dt: number)
	--[[ Checks ]]

	-- Skip frames that cannot advance the shake
	if type(dt) ~= "number" or dt <= 0 then
		return Vector3.zero
	end

	--[[ Fade Progression ]]

	local currentFadeTime: number = self._currentFadeTime

	if self._sustain and self._fadeInDuration > 0 and currentFadeTime < 1 then
		currentFadeTime = math.min(currentFadeTime + (dt / self._fadeInDuration), 1)
	elseif self._sustain and self._oneShot and self._holdRemaining ~= nil and currentFadeTime >= 1 then
		self._holdRemaining -= dt

		if self._holdRemaining <= 0 then
			self._sustain = false
			self._holdRemaining = nil

			if self._fadeOutDuration <= 0 then
				currentFadeTime = 0
			end
		end
	elseif not self._sustain and currentFadeTime > 0 then
		if self._fadeOutDuration > 0 then
			currentFadeTime = math.max(currentFadeTime - (dt / self._fadeOutDuration), 0)
		else
			currentFadeTime = 0
		end
	end

	self._currentFadeTime = currentFadeTime

	--[[ Checks ]]

	-- Skip shakes that faded out
	if currentFadeTime <= 0 then
		return Vector3.zero
	end

	--[[ Tick Progression ]]

	local roughnessScale: number = if self._sustain then 1 else currentFadeTime
	self._tick += dt * self.Roughness * roughnessScale

	--[[ Offset ]]

	return sampleNoiseOffset(self._tick) * self.Magnitude * currentFadeTime
end

--%%%%%%%%%%%%%%%%%%%% Get State

--[[
	Returns the current lifecycle state of the shake.
]]
--- @return CameraShake_State
function Shake:GetState()
	--[[ Returning ]]

	if self._sustain then
		if self._currentFadeTime < 1 and self._fadeInDuration > 0 then
			return "FadingIn"
		end

		return "Sustained"
	end

	if self._currentFadeTime > 0 then
		return "FadingOut"
	end

	return "Inactive"
end

--%%%%%%%%%%%%%%%%%%%% Is Active

--[[
	Returns whether the shake still contributes any motion.
]]
--- @return boolean
function Shake:IsActive()
	return self._sustain or self._currentFadeTime > 0
end

return Shake
