--[[
	Created By:     Nari
]]

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Defaults = require(script.Parent:FindFirstChild("Defaults")) --- @type UIEmitter_Defaults

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { [string]: any }
local DEFAULTS = Defaults.DEFAULTS

local DEFAULT_DIRECTION: Vector3 = Vector3.new(DEFAULTS.Direction.X, DEFAULTS.Direction.Y, 0)
local FALLBACK_DIRECTION: Vector3 = Vector3.new(0, -1, 0)

local NUMBER_CURVE_CACHE = setmetatable({}, { __mode = "k" }) --- @type { [NumberSequence]: UIEmitter_NumberCurve }
local COLOR_CURVE_CACHE = setmetatable({}, { __mode = "k" }) --- @type { [ColorSequence]: UIEmitter_ColorCurve }

local random: (min: number?, max: number?) -> number = math.random
local rad: (degrees: number) -> number = math.rad
local cos: (x: number) -> number = math.cos
local sin: (x: number) -> number = math.sin
local clamp: (x: number, min: number, max: number) -> number = math.clamp

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

--- @class UIEmitter_Sampler
local Sampler = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Numbers

--%%%%%%%%%%%%%%%%%%%% Random Between

--[[
	Returns a random number between two bounds.
]]
--- @return number
function Sampler.RandomBetween(minValue: number, maxValue: number)
	--[[ Bounds ]]

	if minValue > maxValue then
		minValue, maxValue = maxValue, minValue
	end

	return minValue + random() * (maxValue - minValue)
end

--%%%%%%%%%%%%%%%%%%%% Can Sample Number

--[[
	Checks whether a value can be sampled as a number.
]]
--- @return boolean
function Sampler.CanSampleNumber(value: any)
	--[[ Type Dispatch ]]

	local valueType: string = typeof(value)

	if valueType == "number" or valueType == "NumberRange" then
		return true
	end

	if valueType == "table" and #value == 2 then
		return Sampler.CanSampleNumber(value[1]) and Sampler.CanSampleNumber(value[2])
	end

	return false
end

--%%%%%%%%%%%%%%%%%%%% Can Use Number Curve

--[[
	Checks whether a value supports constants, random ranges, or lifetime curves.
]]
--- @return boolean
function Sampler.CanUseNumberCurve(value: any)
	--[[ Type Dispatch ]]

	if typeof(value) == "NumberSequence" then
		return true
	end

	if typeof(value) == "table" and #value == 2 then
		return Sampler.CanUseNumberCurve(value[1]) and Sampler.CanUseNumberCurve(value[2])
	end

	return Sampler.CanSampleNumber(value)
end

--%%%%%%%%%%%%%%%%%%%% Sample Number

--[[
	Samples a spawn-time number, evaluating a curve at birth when necessary.
]]
--- @return number
function Sampler.SampleNumber(value: any, fallback: number)
	--[[ Type Dispatch ]]

	local valueType: string = typeof(value)

	if valueType == "number" then
		return value
	end

	if valueType == "NumberRange" then
		return Sampler.RandomBetween(value.Min, value.Max)
	end

	if valueType == "NumberSequence" then
		local curve = Sampler.CompileNumberSequence(value) --- @type UIEmitter_NumberCurve
		local envelopes = curve.Envelopes --- @type { number }?
		local envelope: number = if envelopes then envelopes[1] else 0

		-- Birth value is the first keypoint plus its sampled envelope.
		return curve.Values[1] + (if envelope > 0 then Sampler.RandomBetween(-envelope, envelope) else 0)
	end

	if valueType == "table" and #value == 2 then
		local minValue: number = Sampler.SampleNumber(value[1], fallback)
		local maxValue: number = Sampler.SampleNumber(value[2], fallback)

		return Sampler.RandomBetween(minValue, maxValue)
	end

	return fallback
end

--%%%%%%%%%%%%%%%%%%%% Has Number Sequence

--[[
	Checks whether a value contains a lifetime curve.
]]
--- @return boolean
function Sampler.HasNumberSequence(value: any)
	--[[ Type Dispatch ]]

	if typeof(value) == "NumberSequence" then
		return true
	end

	if typeof(value) == "table" then
		for _: any, child: any in value do
			if Sampler.HasNumberSequence(child) then
				return true
			end
		end
	end

	return false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Curves

--%%%%%%%%%%%%%%%%%%%% Compile Number Sequence

--[[
	Flattens a NumberSequence into cached Lua arrays so frames never touch Keypoints.
]]
--- @return UIEmitter_NumberCurve
function Sampler.CompileNumberSequence(sequence: NumberSequence)
	--[[ Cache ]]

	--- @type UIEmitter_NumberCurve?
	local cached = NUMBER_CURVE_CACHE[sequence]

	if cached then
		return cached
	end

	--[[ Flattening ]]

	local keypoints = sequence.Keypoints --- @type { NumberSequenceKeypoint }
	local count: number = #keypoints
	local times = table.create(count) --- @type { number }
	local values = table.create(count) --- @type { number }
	local envelopes = nil --- @type { number }?
	local flat: boolean = true

	for index: number, keypoint: NumberSequenceKeypoint in keypoints do
		times[index] = keypoint.Time
		values[index] = keypoint.Value

		if keypoint.Envelope > 0 then
			envelopes = envelopes or table.create(count, 0)
			envelopes[index] = keypoint.Envelope
		end

		if keypoint.Value ~= values[1] then
			flat = false
		end
	end

	--[[ Caching ]]

	--- @type UIEmitter_NumberCurve
	local curve = {
		Times = times,
		Values = values,
		Envelopes = envelopes,
		Count = count,
		Constant = if flat and envelopes == nil then values[1] else nil,
	}

	NUMBER_CURVE_CACHE[sequence] = curve

	return curve
end

--%%%%%%%%%%%%%%%%%%%% Compile Color Sequence

--[[
	Flattens a ColorSequence into cached channel arrays.
]]
--- @return UIEmitter_ColorCurve
function Sampler.CompileColorSequence(sequence: ColorSequence)
	--[[ Cache ]]

	--- @type UIEmitter_ColorCurve?
	local cached = COLOR_CURVE_CACHE[sequence]

	if cached then
		return cached
	end

	--[[ Flattening ]]

	local keypoints = sequence.Keypoints --- @type { ColorSequenceKeypoint }
	local count: number = #keypoints
	local times = table.create(count) --- @type { number }
	local reds = table.create(count) --- @type { number }
	local greens = table.create(count) --- @type { number }
	local blues = table.create(count) --- @type { number }
	local flat: boolean = true

	for index: number, keypoint: ColorSequenceKeypoint in keypoints do
		local color: Color3 = keypoint.Value

		times[index] = keypoint.Time
		reds[index] = color.R
		greens[index] = color.G
		blues[index] = color.B

		if color ~= keypoints[1].Value then
			flat = false
		end
	end

	--[[ Caching ]]

	--- @type UIEmitter_ColorCurve
	local curve = {
		Times = times,
		R = reds,
		G = greens,
		B = blues,
		Count = count,
		Constant = if flat then keypoints[1].Value else nil,
	}

	COLOR_CURVE_CACHE[sequence] = curve

	return curve
end

--%%%%%%%%%%%%%%%%%%%% Eval Curve

--[[
	Interpolates a compiled number curve at normalized time.
]]
--- @param curve UIEmitter_NumberCurve
--- @return number
function Sampler.EvalCurve(curve, alpha: number)
	--[[ Edge Keypoints ]]

	local times = curve.Times --- @type { number }
	local values = curve.Values --- @type { number }
	local count: number = curve.Count

	if alpha <= times[1] then
		return values[1]
	end

	if alpha >= times[count] then
		return values[count]
	end

	--[[ Interpolation ]]

	for index: number = 2, count do
		local endTime: number = times[index]

		if alpha <= endTime then
			local startTime: number = times[index - 1]
			local startValue: number = values[index - 1]
			local span: number = endTime - startTime

			if span <= 0 then
				return startValue
			end

			return startValue + (values[index] - startValue) * (alpha - startTime) / span
		end
	end

	return values[count]
end

--%%%%%%%%%%%%%%%%%%%% Eval Color Curve

--[[
	Interpolates a compiled color curve and returns raw channels.
]]
--- @param curve UIEmitter_ColorCurve
--- @return number, number, number
function Sampler.EvalColorCurve(curve, alpha: number)
	--[[ Edge Keypoints ]]

	local times = curve.Times --- @type { number }
	local reds = curve.R --- @type { number }
	local greens = curve.G --- @type { number }
	local blues = curve.B --- @type { number }
	local count: number = curve.Count

	if alpha <= times[1] then
		return reds[1], greens[1], blues[1]
	end

	if alpha >= times[count] then
		return reds[count], greens[count], blues[count]
	end

	--[[ Interpolation ]]

	for index: number = 2, count do
		local endTime: number = times[index]

		if alpha <= endTime then
			local previous: number = index - 1
			local startTime: number = times[previous]
			local span: number = endTime - startTime

			if span <= 0 then
				return reds[previous], greens[previous], blues[previous]
			end

			local localAlpha: number = (alpha - startTime) / span
			local red: number = reds[previous]
			local green: number = greens[previous]
			local blue: number = blues[previous]

			return red + (reds[index] - red) * localAlpha, green + (greens[index] - green) * localAlpha, blue + (blues[index] - blue) * localAlpha
		end
	end

	return reds[count], greens[count], blues[count]
end

--%%%%%%%%%%%%%%%%%%%% Sample Curve

--[[
	Samples keypoint envelopes once per particle; flat or envelope-free curves are shared.
]]
--- @return UIEmitter_NumberSource
function Sampler._sampleCurve(sequence: NumberSequence)
	--[[ Shared Curve ]]

	--- @type UIEmitter_NumberCurve
	local curve = Sampler.CompileNumberSequence(sequence)

	if curve.Constant ~= nil then
		return curve.Constant
	end

	--- @type { number }?
	local envelopes = curve.Envelopes

	if envelopes == nil then
		return curve
	end

	--[[ Envelope Sampling ]]

	local count: number = curve.Count
	local baseValues = curve.Values --- @type { number }
	local values = table.create(count) --- @type { number }

	-- NumberSequence envelopes are random at spawn time, not every frame.
	for index: number = 1, count do
		local envelope: number = envelopes[index]

		values[index] = if envelope > 0 then baseValues[index] + Sampler.RandomBetween(-envelope, envelope) else baseValues[index]
	end

	return {
		Times = curve.Times,
		Values = values,
		Count = count,
	}
end

--%%%%%%%%%%%%%%%%%%%% Sample Number Source

--[[
	Samples a number while preserving a NumberSequence as a per-particle curve.
]]
--- @return UIEmitter_NumberSource
function Sampler.SampleNumberSource(value: any, fallback: number)
	--[[ Type Dispatch ]]

	if typeof(value) == "NumberSequence" then
		return Sampler._sampleCurve(value)
	end

	return Sampler.SampleNumber(value, fallback)
end

--%%%%%%%%%%%%%%%%%%%% Eval Number Source

--[[
	Evaluates a sampled number source at normalized lifetime progress.
]]
--- @param source UIEmitter_NumberSource?
--- @return number
function Sampler.EvalNumberSource(source, alpha: number, fallback: number)
	--[[ Type Dispatch ]]

	local sourceType: string = type(source)

	if sourceType == "number" then
		return source
	end

	if sourceType == "table" then
		return Sampler.EvalCurve(source, alpha)
	end

	return fallback
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Vectors

--%%%%%%%%%%%%%%%%%%%% Can Sample Vector2

--[[
	Checks whether a value can be sampled as a Vector2.
]]
--- @return boolean
function Sampler.CanSampleVector2(value: any)
	--[[ Type Dispatch ]]

	local valueType: string = typeof(value)

	if valueType == "Vector2" or valueType == "Vector3" then
		return true
	end

	if valueType == "table" and #value == 2 then
		return Sampler.CanUseNumberCurve(value[1]) and Sampler.CanUseNumberCurve(value[2])
	end

	return false
end

--%%%%%%%%%%%%%%%%%%%% Sample Vector

--[[
	Samples Vector2, Vector3, or two-axis range tables into a planar Vector3.
]]
--- @return Vector3
function Sampler._sampleVector(value: any, fallback: Vector3)
	--[[ Type Dispatch ]]

	local valueType: string = typeof(value)

	if valueType == "Vector2" or valueType == "Vector3" then
		return Vector3.new(value.X, value.Y, 0)
	end

	if valueType == "table" and #value == 2 then
		return Vector3.new(Sampler.SampleNumber(value[1], fallback.X), Sampler.SampleNumber(value[2], fallback.Y), 0)
	end

	return fallback
end

--%%%%%%%%%%%%%%%%%%%% Sample Vector Source

--[[
	Samples vector axes while preserving lifetime curves; constant axes collapse to a Vector3.
]]
--- @return UIEmitter_VectorValue
function Sampler.SampleVectorSource(value: any, fallback: Vector3)
	--[[ Type Dispatch ]]

	local valueType: string = typeof(value)

	if valueType == "Vector2" or valueType == "Vector3" then
		return Vector3.new(value.X, value.Y, 0)
	end

	if valueType == "table" and #value == 2 then
		local xSource = Sampler.SampleNumberSource(value[1], fallback.X) --- @type UIEmitter_NumberSource
		local ySource = Sampler.SampleNumberSource(value[2], fallback.Y) --- @type UIEmitter_NumberSource

		if type(xSource) == "number" and type(ySource) == "number" then
			return Vector3.new(xSource, ySource, 0)
		end

		return {
			X = xSource,
			Y = ySource,
		}
	end

	return fallback
end

--%%%%%%%%%%%%%%%%%%%% Eval Vector Source

--[[
	Evaluates vector axes at one normalized lifetime progress.
]]
--- @param source UIEmitter_VectorValue?
--- @return Vector3
function Sampler.EvalVectorSource(source, alpha: number, fallback: Vector3)
	--[[ Type Dispatch ]]

	if type(source) == "table" then
		return Vector3.new(Sampler.EvalNumberSource(source.X, alpha, fallback.X), Sampler.EvalNumberSource(source.Y, alpha, fallback.Y), 0)
	end

	return source or fallback
end

--%%%%%%%%%%%%%%%%%%%% Rotate Direction

--[[
	Returns the normalized direction rotated by theta radians.
]]
--- @return Vector3
function Sampler._rotateDirection(direction: Vector3, theta: number)
	--[[ Base Direction ]]

	local base: Vector3 = if direction.Magnitude <= 0 then FALLBACK_DIRECTION else direction.Unit

	if theta == 0 then
		return base
	end

	--[[ Rotation ]]

	local cosTheta: number = cos(theta)
	local sinTheta: number = sin(theta)

	return Vector3.new(base.X * cosTheta - base.Y * sinTheta, base.X * sinTheta + base.Y * cosTheta, 0).Unit
end

--%%%%%%%%%%%%%%%%%%%% Is Velocity Vector Range

--[[
	Checks whether a table value is a two-axis velocity range.
]]
--- @return boolean
function Sampler.IsVelocityVectorRange(value: any)
	--[[ Checks ]]

	if typeof(value) ~= "table" or #value ~= 2 then
		return false
	end

	return typeof(value[1]) == "table"
		or typeof(value[2]) == "table"
		or typeof(value[1]) == "NumberRange"
		or typeof(value[2]) == "NumberRange"
		or typeof(value[1]) == "NumberSequence"
		or typeof(value[2]) == "NumberSequence"
end

--%%%%%%%%%%%%%%%%%%%% Sample Velocity

--[[
	Samples one particle's launch velocity and an optional lifetime velocity source.
]]
--- @param cfg UIEmitter_CompiledConfig
--- @param plan UIEmitter_Plan
--- @return Vector3, UIEmitter_VelocitySource?
function Sampler.SampleVelocity(cfg, plan)
	--[[ Direct Vector ]]

	local velocityKind: "Vector" | "Range" | "Directional" = plan.VelocityKind

	if velocityKind == "Vector" then
		return plan.VelocityConstant, nil
	end

	--[[ Vector Range ]]

	if velocityKind == "Range" then
		if not plan.VelocityDynamic then
			return Sampler._sampleVector(cfg.Velocity, Vector3.zero), nil
		end

		--- @type UIEmitter_VelocitySource
		local source = {
			Kind = "Vector",
			Value = Sampler.SampleVectorSource(cfg.Velocity, Vector3.zero),
		}

		return Sampler.EvalVelocitySource(source, 0), source
	end

	--[[ Directional ]]

	local speedSource: any = if cfg.Speed ~= nil then cfg.Speed else cfg.Velocity

	if not plan.VelocityDynamic then
		local speed: number = Sampler.SampleNumber(speedSource, DEFAULTS.Velocity)
		local direction: Vector3 = Sampler._sampleVector(cfg.Direction, DEFAULT_DIRECTION)
		local spread: number = Sampler.SampleNumber(cfg.SpreadAngle, DEFAULTS.SpreadAngle)
		local halfSpread: number = if spread > 0 then rad(spread * 0.5) else 0

		return Sampler._rotateDirection(direction, if halfSpread > 0 then Sampler.RandomBetween(-halfSpread, halfSpread) else 0) * speed, nil
	end

	--- @type UIEmitter_VelocitySource
	local source = {
		Kind = "Directional",
		Speed = Sampler.SampleNumberSource(speedSource, DEFAULTS.Velocity),
		Direction = Sampler.SampleVectorSource(cfg.Direction, DEFAULT_DIRECTION),
		SpreadAngle = Sampler.SampleNumberSource(cfg.SpreadAngle, DEFAULTS.SpreadAngle),
		SpreadRoll = random(),
	}

	return Sampler.EvalVelocitySource(source, 0), source
end

--%%%%%%%%%%%%%%%%%%%% Eval Velocity Source

--[[
	Evaluates one lifetime-aware velocity source.
]]
--- @param source UIEmitter_VelocitySource
--- @return Vector3
function Sampler.EvalVelocitySource(source, alpha: number)
	--[[ Type Dispatch ]]

	if source.Kind == "Vector" then
		return Sampler.EvalVectorSource(source.Value, alpha, Vector3.zero)
	end

	--[[ Directional ]]

	local direction: Vector3 = Sampler.EvalVectorSource(source.Direction, alpha, DEFAULT_DIRECTION)
	local spread: number = Sampler.EvalNumberSource(source.SpreadAngle, alpha, DEFAULTS.SpreadAngle)
	local theta: number = if spread > 0 then (clamp(source.SpreadRoll, 0, 1) * 2 - 1) * rad(spread * 0.5) else 0
	local speed: number = Sampler.EvalNumberSource(source.Speed, alpha, DEFAULTS.Velocity)

	return Sampler._rotateDirection(direction, theta) * speed
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Attraction

--%%%%%%%%%%%%%%%%%%%% Sample Attract Pause Progress

--[[
	Returns a sampled and clamped attraction pause progress.
]]
--- @return number?
function Sampler.SampleAttractPauseProgress(value: any)
	--[[ Optional ]]

	if value == nil then
		return nil
	end

	return clamp(Sampler.SampleNumber(value, 1), 0, 1)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Sampler
