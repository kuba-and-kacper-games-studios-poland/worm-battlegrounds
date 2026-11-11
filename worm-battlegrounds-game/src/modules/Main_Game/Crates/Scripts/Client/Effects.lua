--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--- @type Crates_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ State ]]

-- One burst emitter per kind and layer, made on first use; the streams playing now
local emitters = {} --- @type { [string]: UIEmitter_Instance }
local streams = {} --- @type { UIEmitter_Instance }

-- The screen shake running now
local shakeConnection: RBXScriptConnection? = nil

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

--- @class Crates_Client_Effects
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	local moduleGui: ScreenGui = I.UserInterface.UI[_settings.GUI_NAME]
	elems["Open"] = moduleGui:FindFirstChild("U_Open", true) --- @type Frame
	elems["Stage"] = moduleGui:FindFirstChild("U_Stage", true) --- @type Frame
	elems["Result"] = moduleGui:FindFirstChild("U_Result", true) --- @type Frame
	elems["Back"] = elems["Result"]:FindFirstChild("S_FxBack", true) --- @type Frame
	elems["Front"] = elems["Result"]:FindFirstChild("S_FxFront", true) --- @type Frame
	elems["Flash"] = elems["Result"]:FindFirstChild("S_Flash", true) --- @type Frame
	elems["Tint"] = elems["Result"]:FindFirstChild("S_Tint", true) --- @type Frame
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Burst

--[[
	Throws a burst of one kind of particle from a point on the screen (absolute pixels), in a colour when given, in
	front of the result or behind it.
]]
--- @param kind Crates_Burst
function Module.Burst(kind, point: Vector2, count: number, color: Color3?, back: boolean?)
	--[[ Local Variables ]]

	local emitter = Module._getEmitter(kind, back == true) --- @type UIEmitter_Instance

	--[[ Emitting ]]

	if color then
		emitter.Color = color
	end
	emitter:Emit(math.max(1, math.round(count)), point)
end

--%%%%%%%%%%%%%%%%%%%% Ring

--[[
	A shockwave ring growing from one diameter to another (in 1080p pixels) as it fades.
]]
function Module.Ring(point: Vector2, color: Color3, from: number, to: number, seconds: number)
	--[[ Local Variables ]]

	local unit: number = Module.GetUnit()
	local emitter = Module._getEmitter("Ring", false) --- @type UIEmitter_Instance

	--[[ Emitting ]]

	emitter.Color = color
	emitter.Lifetime = seconds
	emitter.Size = NumberSequence.new(from * unit, to * unit)
	emitter:Emit(1, point)
end

--%%%%%%%%%%%%%%%%%%%% Confetti

--[[
	A burst of confetti in every confetti colour, thrown up from a point.
]]
function Module.Confetti(point: Vector2, count: number)
	--[[ Emitting ]]

	for _index: number, color: Color3 in ipairs(_settings.CONFETTI_COLORS) do
		Module.Burst("Confetti", point, count / #_settings.CONFETTI_COLORS, color)
	end
end

--%%%%%%%%%%%%%%%%%%%% Stream

--[[
	Starts a stream of particles that runs until Clear: flames round the card's foot, bubbles rising across the
	screen, confetti falling, a vortex pulled into the middle, or dust drifting into it.
]]
--- @param overrides { [string]: any }?
--- @return UIEmitter_Instance
function Module.Stream(kind: "Flames" | "Bubbles" | "Rain" | "Vortex" | "Orbit", back: boolean, overrides)
	--[[ Local Variables ]]

	local params = Module._getStreamParams(kind, Module.GetUnit()) --- @type { [string]: any }
	params.Parent = if back then elems["Back"] else elems["Front"]
	for key: string, value: any in pairs(overrides or {}) do
		params[key] = value
	end

	--[[ Playing ]]

	local emitter = I.UIEmitter.new(params) --- @type UIEmitter_Instance
	emitter:Play()
	table.insert(streams, emitter)

	--[[ Returning ]]

	return emitter
end

--%%%%%%%%%%%%%%%%%%%% Flash

--[[
	Flashes the screen in a colour, from a peak opacity down to nothing.
]]
function Module.Flash(color: Color3, peak: number, seconds: number)
	--[[ Applying ]]

	local flash: Frame = elems["Flash"]
	flash.BackgroundColor3 = color
	flash.BackgroundTransparency = 1 - peak

	--[[ Tweening ]]

	local Flash_TweenInfo: TweenInfo = TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local Flash_TweenGoal = { BackgroundTransparency = 1 }
	local Flash_Tween: Tween = I.S.TweenService:Create(flash, Flash_TweenInfo, Flash_TweenGoal)
	Flash_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Tint

--[[
	Fades the screen's tint (behind the result) to a colour and transparency: dark for the gold card, green for the
	skeleton, violet for low gravity, clear again (transparency 1) when done.
]]
function Module.Tint(color: Color3, transparency: number, seconds: number)
	--[[ Tweening ]]

	local Tint_TweenInfo: TweenInfo = TweenInfo.new(seconds, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local Tint_TweenGoal = { BackgroundColor3 = color, BackgroundTransparency = transparency }
	local Tint_Tween: Tween = I.S.TweenService:Create(elems["Tint"], Tint_TweenInfo, Tint_TweenGoal)
	Tint_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Shake

--[[
	Shakes the reels and the result for some seconds: the amplitude (1080p pixels) fades out, or builds up when
	growing. Each layer shakes about its own anchor, so a layer pulled toward a point (the black hole) stays there.
]]
function Module.Shake(seconds: number, amplitude: number, growing: boolean?)
	--[[ Local Variables ]]

	local start: number = os.clock()
	local unit: number = Module.GetUnit()

	--[[ Shaking ]]

	if shakeConnection then
		shakeConnection:Disconnect()
	end
	shakeConnection = I.S.RunService.RenderStepped:Connect(function()
		local progress: number = (os.clock() - start) / seconds
		local strength: number = amplitude * unit * (if growing then progress * progress else 1 - progress)
		local offset: Vector2 = Vector2.new(math.random(-100, 100), math.random(-100, 100)) / 100 * strength
		if progress >= 1 then
			offset = Vector2.zero
			if shakeConnection then
				shakeConnection:Disconnect()
				shakeConnection = nil
			end
		end
		for _index: number, layer: Frame in ipairs({ elems["Open"], elems["Stage"], elems["Result"] }) do
			layer.Position = UDim2.new(layer.AnchorPoint.X, offset.X, layer.AnchorPoint.Y, offset.Y)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Rarity

--[[
	A reveal's burst for its rarity, from a puff for a common to rings, coins and sparks for a legendary; strength 1
	for the big card, less for a pack's cards. An epic at full strength also flashes and shakes the screen.
]]
function Module.Rarity(rarity: string, point: Vector2, color: Color3, strength: number)
	--[[ Bursting ]]

	if rarity == "Common" then
		Module.Burst("Stars", point, 16 * strength, Color3.new(1, 1, 1))
	elseif rarity == "Uncommon" then
		Module.Ring(point, color, 80, 720 * strength, 0.5)
		Module.Burst("Stars", point, 30 * strength, color)
	elseif rarity == "Rare" then
		Module.Ring(point, color, 80, 1040 * strength, 0.55)
		Module.Burst("Sparks", point, 44 * strength, color)
		Module.Burst("Stars", point, 14 * strength, Color3.fromRGB(207, 230, 255))
	elseif rarity == "Epic" then
		if strength >= 0.6 then
			Module.Flash(color, 0.38 * strength, 0.38)
			Module.Shake(0.26, 9 * strength)
		end
		Module.Ring(point, color, 120, 1520 * strength, 0.65)
		Module.Burst("Sparks", point, 90 * strength, color)
		Module.Burst("Stars", point, 24 * strength, Color3.fromRGB(242, 212, 255))
	else
		Module.Ring(point, color, 120, 1800 * strength, 0.7)
		Module.Burst("Coins", point, 30 * strength)
		Module.Burst("Sparks", point, 70 * strength, color)
	end
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	Ends every effect: the bursts' particles, the streams, the tint, the flash and any shake.
]]
function Module.Clear()
	--[[ Clearing ]]

	--- @param emitter UIEmitter_Instance
	for _key: string, emitter in pairs(emitters) do
		emitter:Destroy()
	end
	--- @param emitter UIEmitter_Instance
	for _index: number, emitter in ipairs(streams) do
		emitter:Destroy()
	end
	table.clear(emitters)
	table.clear(streams)

	--[[ Applying ]]

	if shakeConnection then
		shakeConnection:Disconnect()
		shakeConnection = nil
	end
	elems["Open"].Position = UDim2.fromScale(0.5, 0.5)
	elems["Result"].Position = UDim2.fromScale(0.5, 0.5)
	elems["Tint"].BackgroundTransparency = 1
	elems["Flash"].BackgroundTransparency = 1
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Unit

--[[
	Returns the screen's size against a 1920 x 1080 one, so 1080p pixels scale to it.
]]
--- @return number
function Module.GetUnit()
	--[[ Local Variables ]]

	local size: Vector2 = elems["Result"].AbsoluteSize

	--[[ Returning ]]

	return math.max(0.1, math.min(size.X / 1920, size.Y / 1080))
end

--%%%%%%%%%%%%%%%%%%%% Get Emitter

--[[
	Returns the burst emitter of a kind on a layer, made the first time it's asked for.
]]
--- @param kind Crates_Burst
--- @return UIEmitter_Instance
function Module._getEmitter(kind, back: boolean)
	--[[ Local Variables ]]

	local key: string = `{kind}{if back then "Back" else "Front"}`

	--[[ Building ]]

	if not emitters[key] then
		local params = Module._getBurstParams(kind, Module.GetUnit()) --- @type { [string]: any }
		params.Parent = if back then elems["Back"] else elems["Front"]
		params.Rate = 0
		params.CullOffscreen = false
		emitters[key] = I.UIEmitter.new(params)
	end

	--[[ Returning ]]

	return emitters[key]
end

--%%%%%%%%%%%%%%%%%%%% Get Burst Params

--[[
	Returns a burst kind's particle settings, in pixels scaled by the screen's unit.
]]
--- @param kind Crates_Burst
--- @return { [string]: any }
function Module._getBurstParams(kind, u: number)
	--[[ Local Variables ]]

	local textures = _settings.FX_TEXTURES --- @type { [string]: string }
	local fade: NumberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.7, 0.2), NumberSequenceKeypoint.new(1, 1) })

	--[[ Returning ]]

	if kind == "Sparks" then
		return {
			Texture = textures.Spark,
			SizeSpace = "Offset",
			AspectRatio = 4,
			Size = NumberSequence.new(70 * u, 18 * u),
			Lifetime = NumberRange.new(0.4, 0.9),
			Velocity = NumberRange.new(500 * u, 1500 * u),
			SpreadAngle = 360,
			Drag = 2.4,
			FaceMovementDirection = true,
			Transparency = fade,
		}
	elseif kind == "Stars" then
		return {
			Texture = textures.Star,
			SizeSpace = "Offset",
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.2, 26 * u, 8 * u), NumberSequenceKeypoint.new(1, 0) }),
			Lifetime = NumberRange.new(0.6, 1.2),
			Velocity = NumberRange.new(200 * u, 700 * u),
			SpreadAngle = 360,
			Drag = 1.6,
			RotationSpeed = NumberRange.new(-90, 90),
		}
	elseif kind == "Coins" then
		return {
			Texture = textures.Coin,
			SizeSpace = "Offset",
			Size = 34 * u,
			Squash = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.25, 0.25),
				NumberSequenceKeypoint.new(0.5, 1),
				NumberSequenceKeypoint.new(0.75, 0.25),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Lifetime = NumberRange.new(1.6, 2.4),
			Velocity = NumberRange.new(400 * u, 1100 * u),
			Direction = Vector2.new(0, -1),
			SpreadAngle = 140,
			Gravity = Vector2.new(0, 1400 * u),
			Drag = 0.6,
			Transparency = fade,
		}
	elseif kind == "Confetti" then
		return {
			Texture = "",
			SizeSpace = "Offset",
			AspectRatio = 1.8,
			Size = NumberRange.new(14 * u, 24 * u),
			Squash = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.25, 0.3),
				NumberSequenceKeypoint.new(0.5, 1),
				NumberSequenceKeypoint.new(0.75, 0.3),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Lifetime = NumberRange.new(2.4, 3.8),
			Velocity = NumberRange.new(500 * u, 1600 * u),
			Direction = Vector2.new(0, -1),
			SpreadAngle = 200,
			Gravity = Vector2.new(0, 1100 * u),
			Drag = 1.1,
			Rotation = NumberRange.new(0, 360),
			RotationSpeed = NumberRange.new(-500, 500),
			Transparency = fade,
		}
	elseif kind == "Smileys" then
		return {
			Texture = textures.Smiley,
			SizeSpace = "Offset",
			Size = NumberRange.new(48 * u, 84 * u),
			Lifetime = NumberRange.new(3, 3.8),
			Velocity = NumberRange.new(600 * u, 1300 * u),
			Direction = Vector2.new(0, -1),
			SpreadAngle = 150,
			Gravity = Vector2.new(0, 1500 * u),
			Drag = 0.4,
			RotationSpeed = NumberRange.new(-150, 150),
		}
	elseif kind == "Bones" then
		return {
			Texture = textures.Bone,
			SizeSpace = "Offset",
			AspectRatio = 1.85,
			Size = NumberRange.new(80 * u, 124 * u),
			Lifetime = NumberRange.new(1.5, 2.1),
			Velocity = NumberRange.new(500 * u, 1200 * u),
			Direction = Vector2.new(0, -1),
			SpreadAngle = 230,
			Gravity = Vector2.new(0, 1700 * u),
			Drag = 0.5,
			RotationSpeed = NumberRange.new(-600, 600),
			Transparency = fade,
		}
	elseif kind == "Flames" then
		return {
			Texture = textures.Glow,
			SizeSpace = "Offset",
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 30 * u), NumberSequenceKeypoint.new(0.4, 80 * u, 20 * u), NumberSequenceKeypoint.new(1, 10 * u) }),
			Lifetime = NumberRange.new(0.6, 1.1),
			Velocity = NumberRange.new(100 * u, 500 * u),
			SpreadAngle = 360,
			Drag = 2,
			Gravity = Vector2.new(0, -300 * u),
			Transparency = NumberSequence.new(0.2, 1),
		}
	elseif kind == "Bubbles" then
		return {
			Texture = textures.Bubble,
			SizeSpace = "Offset",
			Size = NumberRange.new(16 * u, 44 * u),
			Lifetime = NumberRange.new(1.4, 2.4),
			Velocity = NumberRange.new(80 * u, 260 * u),
			SpreadAngle = 360,
			Drag = 1.2,
			Gravity = Vector2.new(0, -60 * u),
			Transparency = fade,
		}
	end

	-- A ring: one particle growing as it fades (Ring sets its size and colour)
	return {
		Texture = textures.Ring,
		SizeSpace = "Offset",
		Size = NumberSequence.new(80 * u, 800 * u),
		Lifetime = 0.6,
		Velocity = 0,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }),
	}
end

--%%%%%%%%%%%%%%%%%%%% Get Stream Params

--[[
	Returns a stream kind's particle settings, in pixels scaled by the screen's unit, emitting across its layer.
]]
--- @return { [string]: any }
function Module._getStreamParams(kind: string, u: number)
	--[[ Local Variables ]]

	local textures = _settings.FX_TEXTURES --- @type { [string]: string }
	local soft: NumberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.12, 0.2), NumberSequenceKeypoint.new(0.85, 0.3), NumberSequenceKeypoint.new(1, 1) })

	--[[ Returning ]]

	if kind == "Flames" then
		-- Ghostly flames round the big card's foot
		return {
			Texture = textures.Glow,
			Color = Color3.fromRGB(90, 255, 140),
			Rate = 90,
			EmitterPosition = UDim2.fromScale(0.5, 0.58),
			EmissionShape = "Rectangle",
			EmissionArea = Vector2.new(0.36, 0.1),
			SizeSpace = "Offset",
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 30 * u), NumberSequenceKeypoint.new(0.4, 80 * u, 24 * u), NumberSequenceKeypoint.new(1, 10 * u) }),
			Lifetime = NumberRange.new(0.9, 1.6),
			Velocity = NumberRange.new(90 * u, 260 * u),
			Direction = Vector2.new(0, -1),
			SpreadAngle = 20,
			ShakeSpeed = NumberRange.new(10 * u, 30 * u),
			Transparency = soft,
		}
	elseif kind == "Bubbles" then
		-- Bubbles rising from the bottom of the screen
		return {
			Texture = textures.Bubble,
			Rate = 26,
			EmitterPosition = UDim2.fromScale(0.5, 1.02),
			EmissionShape = "Rectangle",
			EmissionArea = Vector2.new(1, 0),
			SizeSpace = "Offset",
			Size = NumberRange.new(16 * u, 60 * u),
			Lifetime = NumberRange.new(5, 8),
			Velocity = NumberRange.new(60 * u, 170 * u),
			Direction = Vector2.new(0, -1),
			ShakeSpeed = NumberRange.new(20 * u, 40 * u),
			Transparency = soft,
		}
	elseif kind == "Rain" then
		-- Confetti falling from the top of the screen (the colour set by the caller)
		return {
			Texture = "",
			Rate = 22,
			EmitterPosition = UDim2.fromScale(0.5, -0.02),
			EmissionShape = "Rectangle",
			EmissionArea = Vector2.new(1, 0),
			SizeSpace = "Offset",
			AspectRatio = 1.8,
			Size = NumberRange.new(12 * u, 20 * u),
			Squash = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.25, 0.3),
				NumberSequenceKeypoint.new(0.5, 1),
				NumberSequenceKeypoint.new(0.75, 0.3),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Lifetime = 6,
			Velocity = NumberRange.new(80 * u, 220 * u),
			Direction = Vector2.new(0, 1),
			SpreadAngle = 30,
			RotationSpeed = NumberRange.new(-300, 300),
			ShakeSpeed = NumberRange.new(20 * u, 50 * u),
			ShakeLockVertical = false,
		}
	elseif kind == "Vortex" then
		-- Streaks swirling into the black hole
		return {
			Texture = textures.Spark,
			Color = _settings.VORTEX_COLORS[1],
			Rate = 220,
			EmitterPosition = UDim2.fromScale(0.5, 0.39),
			EmissionShape = "Circle",
			EmissionArea = 1.1,
			SizeSpace = "Offset",
			AspectRatio = 4,
			Size = 60 * u,
			Lifetime = 3,
			Velocity = 0,
			InitialVelocity = function(spawnPoint: Vector2): Vector2?
				local middle: Vector2 = elems["Result"].AbsolutePosition + elems["Result"].AbsoluteSize * Vector2.new(0.5, 0.39)
				local away: Vector2 = spawnPoint - middle
				return Vector2.new(-away.Y, away.X).Unit * 520 * u
			end,
			AttractTo = UDim2.fromScale(0.5, 0.39),
			AttractStrength = NumberSequence.new(1800 * u, 9000 * u),
			AttractDestroyOnArrive = true,
			AttractArriveRadius = 30 * u,
			FaceMovementDirection = true,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 0), NumberSequenceKeypoint.new(1, 0) }),
		}
	end

	-- Dust drifting in toward the middle, round and round, behind the card
	return {
		Texture = textures.Glow,
		Color = _settings.VORTEX_COLORS[2],
		Rate = 28,
		EmitterPosition = UDim2.fromScale(0.5, 0.39),
		EmissionShape = "Circle",
		EmissionArea = 1,
		SizeSpace = "Offset",
		Size = NumberRange.new(6 * u, 12 * u),
		Lifetime = 4,
		Velocity = 0,
		InitialVelocity = function(spawnPoint: Vector2): Vector2?
			local middle: Vector2 = elems["Result"].AbsolutePosition + elems["Result"].AbsoluteSize * Vector2.new(0.5, 0.39)
			local away: Vector2 = spawnPoint - middle
			return Vector2.new(-away.Y, away.X).Unit * 160 * u
		end,
		AttractTo = UDim2.fromScale(0.5, 0.39),
		AttractStrength = 260 * u,
		AttractDestroyOnArrive = true,
		AttractArriveRadius = 140 * u,
		Transparency = soft,
	}
end

return Module
