--[[
	Created By: 	HungryN00B
	Edited By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Atmosphere"

--- @type Atmosphere_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Folders ]]

local worldFolder: Instance

--[[ Streaks ]]

-- The streaks' part, kept over the camera's view while a map shows, and its emitters' own rates and speeds
local part: BasePart? = nil
local rates = {} --- @type { [ParticleEmitter]: number }
local speeds = {} --- @type { [ParticleEmitter]: NumberRange }

--[[ State ]]

-- The map's front face (the streaks fly in front of it), and whether a map shows
local frontZ: number = 0
local showing: boolean = false

-- The match's wind: its way (1 toward +X, -1 toward -X) and its strength, a share of the most
local direction: number = 1
local strength: number = 0

-- The wind last blown on this map (nil until its first), so a change gusts
local lastWind: number? = nil

--[[ Sound ]]

-- The map's wind loop and its sound name, and the last gust peak that could whoosh
local loop: Sound? = nil
local loopName: string? = nil
local lastPeak: number = 0

local random: Random = Random.new()

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

--- @class Atmosphere_Client_Wind
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(world: Instance)
	--[[ Folders ]]

	worldFolder = world

	--[[ Connections ]]

	-- After MatchCamera (at the Camera priority) and its shake, so the streaks cover where the camera ended up
	I.S.RunService:BindToRenderStep(`{_localName}_Wind`, Enum.RenderPriority.Camera.Value + 2, Module._step)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Keeps the streaks' part over the camera's view, in front of the map and reaching further on the side the wind comes
	from, breathes their rate in gusts, and in strong wind lets a gust whoosh at its peak.
]]
function Module._step()
	--[[ Checks ]]

	-- Skip while no map shows or the air is still
	if not showing or not part or strength <= 0 then
		return
	end

	--[[ Local Variables ]]

	local camera: Camera = I.S.Workspace.CurrentCamera
	local position: Vector3 = camera.CFrame.Position
	local nearZ: number = frontZ + _settings.WIND_DEPTH[1]
	local farZ: number = frontZ + _settings.WIND_DEPTH[2]
	local halfHeight: number = math.max(position.Z - nearZ, 1) * math.tan(math.rad(camera.FieldOfView / 2))
	local viewWidth: number = halfHeight * 2 * camera.ViewportSize.X / math.max(camera.ViewportSize.Y, 1)
	local gust: number = 1 + _settings.WIND_GUST_SHARE * math.sin(os.clock() * 2 * math.pi / _settings.WIND_GUST_SECONDS)

	-- The gusts peak a quarter of the way through each cycle
	local peak: number = math.floor(os.clock() / _settings.WIND_GUST_SECONDS - 0.25)

	--[[ Placing ]]

	part.Size = Vector3.new(viewWidth * (1 + _settings.WIND_UPWIND_SHARE), halfHeight * 2, farZ - nearZ)
	part.CFrame = CFrame.new(position.X - direction * viewWidth * _settings.WIND_UPWIND_SHARE / 2, position.Y, (nearZ + farZ) / 2)

	--[[ Gusting ]]

	for emitter: ParticleEmitter, rate: number in pairs(rates) do
		emitter.Rate = rate * strength * gust
	end

	--[[ Whooshing ]]

	if peak ~= lastPeak then
		lastPeak = peak
		if strength >= _settings.WIND_GUST_SOUND_FROM and random:NextNumber() < strength then
			local volumes = _settings.WIND_GUST_SOUND_VOLUME --- @type { number }
			I.Sound.Play({
				Name = _settings.WIND_GUST_SOUND,
				SoundGroup = "SFX",
				Volume = volumes[1] + (volumes[2] - volumes[1]) * strength,
				PitchMin = 0.9,
				PitchMax = 1.1,
			})
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Shows the wind over a map, in its streaks' colour and with its loop, or stops it when there's no map (the lobby, or
	a map still loading).
]]
function Module.Show(bounds: BasePart?, color: Color3?, soundName: string?)
	--[[ Saving ]]

	showing = bounds ~= nil
	lastWind = nil
	if bounds then
		frontZ = bounds.Position.Z + bounds.Size.Z / 2
	end

	--[[ Building ]]

	if showing and not part then
		Module._build()
	end

	--[[ Sound ]]

	-- Another map's loop fades out and goes; this map's starts silent and eases in with the wind
	if not showing then
		Module._fadeOut()
		loopName = nil
	elseif soundName ~= loopName then
		Module._fadeOut()
		loopName = soundName
		loop = if soundName then I.Sound.Play({ Name = soundName, SoundGroup = "SFX", Looped = true, Volume = 0 }) else nil
	end

	--[[ Applying ]]

	for emitter: ParticleEmitter, _rate: number in pairs(rates) do
		emitter.Enabled = showing
		if color then
			emitter.Color = ColorSequence.new(color)
		end
	end
	Module._blow()
end

--%%%%%%%%%%%%%%%%%%%% Set Wind

--[[
	Blows the streaks with the match's wind: their way from its sign, how many and how fast from its strength (none in
	still air). A change of wind on a map that shows gusts across the view.
]]
function Module.SetWind(wind: number)
	--[[ Local Variables ]]

	local changed: boolean = showing and lastWind ~= nil and wind ~= lastWind

	--[[ Saving ]]

	direction = if wind < 0 then -1 else 1
	strength = math.clamp(math.abs(wind) / I.Settings["Match"].WIND_MAX, 0, 1)
	if showing then
		lastWind = wind
	end

	--[[ Applying ]]

	Module._blow()
	if changed then
		Module._gustChange()
	end
end

--%%%%%%%%%%%%%%%%%%%% Gust Change

--[[
	Shows the wind changing: a burst of WIND_CHANGE_BURST streaks across the view the new way (a few in still air)
	with the gust's whoosh.
]]
function Module._gustChange()
	--[[ Checks ]]

	-- Check if the streaks are built
	if not part then
		return
	end

	--[[ Bursting ]]

	for emitter: ParticleEmitter, _rate: number in pairs(rates) do
		emitter:Emit(math.max(math.round(_settings.WIND_CHANGE_BURST * strength), _settings.WIND_CHANGE_BURST_MIN))
	end

	--[[ Sound ]]

	I.Sound.Play({
		Name = _settings.WIND_GUST_SOUND,
		SoundGroup = "SFX",
		Volume = _settings.WIND_GUST_SOUND_VOLUME[2],
		PitchMin = 0.9,
		PitchMax = 1.1,
	})
end

--%%%%%%%%%%%%%%%%%%%% Blow

--[[
	Turns the streaks the wind's way and sets their speed by its strength; in still air none start.
]]
function Module._blow()
	--[[ Local Variables ]]

	local speedShare: number = _settings.WIND_SPEED_SHARE[1] + (_settings.WIND_SPEED_SHARE[2] - _settings.WIND_SPEED_SHARE[1]) * strength

	--[[ Applying ]]

	for emitter: ParticleEmitter, speed: NumberRange in pairs(speeds) do
		emitter.EmissionDirection = if direction < 0 then Enum.NormalId.Left else Enum.NormalId.Right
		emitter.Speed = NumberRange.new(speed.Min * speedShare, speed.Max * speedShare)
		if strength <= 0 then
			emitter.Rate = 0
		end
	end

	--[[ Volume ]]

	if loop then
		local volumes = _settings.WIND_SOUND_VOLUME --- @type { number }
		local Volume_TweenGoal = { Volume = if showing and strength > 0 then volumes[1] + (volumes[2] - volumes[1]) * strength else 0 }
		local Volume_Tween: Tween = I.S.TweenService:Create(loop, _settings.WIND_SOUND_TWEENINFO, Volume_TweenGoal)
		Volume_Tween:Play()
	end
end

--%%%%%%%%%%%%%%%%%%%% Fade Out

--[[
	Fades the wind's loop out and removes it.
]]
function Module._fadeOut()
	--[[ Checks ]]

	-- Check if a loop plays
	if not loop then
		return
	end

	--[[ Fading ]]

	local fading: Sound = loop
	loop = nil
	local FadeOut_TweenGoal = { Volume = 0 }
	local FadeOut_Tween: Tween = I.S.TweenService:Create(fading, _settings.WIND_SOUND_TWEENINFO, FadeOut_TweenGoal)
	FadeOut_Tween:Play()
	FadeOut_Tween.Completed:Once(function()
		fading:Destroy()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Copies the trails' prefab into the world folder, sized, faded and spread by the settings, and notes each emitter's rate at
	the strongest wind (WIND_RATE) and its own speed.
]]
function Module._build()
	--[[ Data ]]

	local prefab: BasePart? = I.Vfx.Get(_settings.WIND_EFFECT)
	if not prefab then
		return
	end

	--[[ Building ]]

	local copy: BasePart = prefab:Clone()
	copy.Name = _settings.WIND_EFFECT
	for _index: number, emitter: Instance in ipairs(copy:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		-- Fewer, bigger and fainter than the prefab, leaving close to level, as the settings say
		local keypoints = {} --- @type { NumberSequenceKeypoint }
		for _index2: number, keypoint: NumberSequenceKeypoint in ipairs(emitter.Size.Keypoints) do
			table.insert(keypoints, NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * _settings.WIND_SIZE_SCALE, keypoint.Envelope * _settings.WIND_SIZE_SCALE))
		end
		emitter.Size = NumberSequence.new(keypoints)
		local fades = {} --- @type { NumberSequenceKeypoint }
		for _index2: number, keypoint: NumberSequenceKeypoint in ipairs(emitter.Transparency.Keypoints) do
			table.insert(fades, NumberSequenceKeypoint.new(keypoint.Time, 1 - (1 - keypoint.Value) * _settings.WIND_OPACITY, keypoint.Envelope * _settings.WIND_OPACITY))
		end
		emitter.Transparency = NumberSequence.new(fades)
		emitter.SpreadAngle = Vector2.new(_settings.WIND_SPREAD, _settings.WIND_SPREAD)
		rates[emitter] = _settings.WIND_RATE
		speeds[emitter] = emitter.Speed
		emitter.Rate = 0
	end
	copy.Parent = worldFolder

	--[[ Saving ]]

	part = copy
end

return Module
