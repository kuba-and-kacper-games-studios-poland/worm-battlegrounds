--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Combat"

--- @type Combat_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Folders ]]

local effectsFolder: Instance
local arenaFolder: Instance

--[[ Feel ]]

-- Shakes the camera on top of where MatchCamera puts it
--- @type CameraShake_Shaker
local shaker

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

--- @class Combat_Client_Effects
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Folders ]]

	effectsFolder = I.Dirs.UmeWorkspace:WaitForChild(_localName)
	arenaFolder = I.Dirs.UmeWorkspace:WaitForChild("Arena")

	--[[ Feel ]]

	shaker = I.CameraShake.new(I.S.Workspace.CurrentCamera)

	--[[ Connections ]]

	I.Network.Fired("Combat_Explosion", Module._onExplosion)
	I.Network.Fired("Combat_Tracer", Module._onTracer)
	I.Network.Fired("Combat_Hit", Module._onHit)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Explosion

--[[
	Draws a blast, throws bits of the ground it hit and plays its sound, then shakes the camera and vibrates a phone or
	pad by how big and how close to the view it is.
]]
function Module._onExplosion(position: Vector3, radius: number, _itemId: string, shiny: boolean)
	--[[ Local Variables ]]

	local size: number = math.max(radius, 1)
	local strength: number = Module._getStrength(position, radius)

	--[[ Drawing ]]

	Module._drawBlast(position, size, shiny)
	Module._throwDebris(position, size)

	--[[ Feel ]]

	I.Sound.Play({
		Name = if radius >= _settings.BIG_BLAST_SOUND_RADIUS then "Explosion_Big" else "Explosion_Small",
		Location = position,
		SoundGroup = "SFX",
		RollOffMin = _settings.SOUND_ROLLOFF_MIN,
		RollOffMax = _settings.SOUND_ROLLOFF_MAX,
		PitchMin = 0.9,
		PitchMax = 1.1,
	})
	Module._shake(strength)
	if strength >= _settings.HAPTIC_BIG then
		I.Haptic.PlayOnce("Combat_BlastBig")
	elseif strength >= _settings.HAPTIC_SMALL then
		I.Haptic.PlayOnce("Combat_BlastSmall")
	end
end

--%%%%%%%%%%%%%%%%%%%% On Tracer

--[[
	Draws a shot's lines from the muzzle to where each bullet (or swing) landed, as neon beams that fade, with a small
	flash where each one landed.
]]
--- @param hits { Vector3 }
function Module._onTracer(_itemId: string, from: Vector3, hits)
	--[[ Drawing ]]

	for _index: number, to: Vector3 in ipairs(hits) do
		local length: number = (to - from).Magnitude
		if length < 0.05 then
			continue
		end
		local line: Part = I.Create("Part")({
			Name = "Tracer",
			Size = Vector3.new(0.15, 0.15, length),
			CFrame = CFrame.lookAt((from + to) / 2, to),
			Color = Color3.fromRGB(255, 240, 160),
			Material = Enum.Material.Neon,
			Anchored = true,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			Parent = effectsFolder,
		})

		local Tracer_TweenInfo: TweenInfo = TweenInfo.new(0.25)
		local Tracer_TweenGoal = { Transparency = 1 }
		local Tracer_Tween: Tween = I.S.TweenService:Create(line, Tracer_TweenInfo, Tracer_TweenGoal)
		Tracer_Tween:Play()
		Tracer_Tween.Completed:Once(function()
			line:Destroy()
		end)

		Module._spawnBall(to, Color3.fromRGB(255, 240, 160), 1.5, 0.15)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Hit

--[[
	Vibrates a phone or pad when the local player's own snail is hurt.
]]
function Module._onHit(participantId: string, damage: number, _position: Vector3)
	--[[ Data ]]

	local mine: Model? = I.Snails.GetMine()

	--[[ Checks ]]

	-- Check if it hurt the local player's snail
	if not mine or mine.Name ~= participantId or damage <= 0 then
		return
	end

	--[[ Feel ]]

	I.Haptic.PlayOnce("Combat_Hurt")
end

--%%%%%%%%%%%%%%%%%%%% Draw Blast

--[[
	Draws a blast: a white flash, a fireball that swells to the blast's size, a light, and bursts of fire, sparks and
	smoke that drift away.
]]
function Module._drawBlast(position: Vector3, size: number, shiny: boolean)
	--[[ Local Variables ]]

	local fireColor: Color3 = if shiny then Color3.fromRGB(255, 220, 80) else Color3.fromRGB(255, 130, 40)

	--[[ Balls ]]

	Module._spawnBall(position, Color3.fromRGB(255, 250, 230), size * 1.3, 0.12)
	Module._spawnBall(position, fireColor, size * 2, 0.35)

	--[[ Building ]]

	-- An invisible holder for the light and the particles
	local holder: Part = I.Create("Part")({
		Name = "BlastPuff",
		Size = Vector3.one * size * 0.5,
		Position = position,
		Transparency = 1,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Parent = effectsFolder,
	})
	local light: PointLight = I.Create("PointLight")({
		Color = fireColor,
		Brightness = 6,
		Range = size * 3,
		Parent = holder,
	})
	local fire: ParticleEmitter = I.Create("ParticleEmitter")({
		Texture = _settings.BLAST_TEXTURES.Fire,
		Color = ColorSequence.new(fireColor, Color3.fromRGB(200, 50, 20)),
		LightEmission = 1,
		Size = NumberSequence.new(size * 0.6, size * 0.2),
		Transparency = NumberSequence.new(0.1, 1),
		Lifetime = NumberRange.new(0.25, 0.45),
		Speed = NumberRange.new(size * 2, size * 4),
		Drag = 6,
		SpreadAngle = Vector2.new(180, 180),
		Rotation = NumberRange.new(0, 360),
		Enabled = false,
		Parent = holder,
	})
	local sparks: ParticleEmitter = I.Create("ParticleEmitter")({
		Texture = _settings.BLAST_TEXTURES.Sparks,
		Color = ColorSequence.new(Color3.fromRGB(255, 230, 140)),
		LightEmission = 1,
		Size = NumberSequence.new(0.5, 0),
		Lifetime = NumberRange.new(0.4, 0.7),
		Speed = NumberRange.new(size * 5, size * 9),
		Drag = 2,
		Acceleration = Vector3.new(0, -60, 0),
		SpreadAngle = Vector2.new(180, 180),
		Enabled = false,
		Parent = holder,
	})
	local smoke: ParticleEmitter = I.Create("ParticleEmitter")({
		Texture = _settings.BLAST_TEXTURES.Smoke,
		Color = ColorSequence.new(Color3.fromRGB(90, 85, 80)),
		Size = NumberSequence.new(size * 0.6, size * 1.4),
		Transparency = NumberSequence.new(0.3, 1),
		Lifetime = NumberRange.new(0.8, 1.4),
		Speed = NumberRange.new(size * 0.8, size * 1.6),
		Drag = 4,
		Acceleration = Vector3.new(0, 4, 0),
		SpreadAngle = Vector2.new(180, 180),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-60, 60),
		Enabled = false,
		Parent = holder,
	})

	--[[ Animating ]]

	fire:Emit(math.clamp(math.floor(size * 1.5), 6, 16))
	sparks:Emit(math.clamp(math.floor(size * 2), 8, 20))
	smoke:Emit(math.clamp(math.floor(size), 4, 10))

	local Light_TweenInfo: TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local Light_TweenGoal = { Brightness = 0 }
	local Light_Tween: Tween = I.S.TweenService:Create(light, Light_TweenInfo, Light_TweenGoal)
	Light_Tween:Play()

	--[[ Cleaning ]]

	-- Once the longest-lived smoke is gone
	task.delay(1.5, function()
		holder:Destroy()
	end)
end

--%%%%%%%%%%%%%%%%%%%% Throw Debris

--[[
	Throws chunks of the terrain and props around a blast up and away from it, in their colours: they bounce on the
	terrain (never on snails or shots), lie there a moment, then fade. A blast in the air throws nothing.
]]
function Module._throwDebris(position: Vector3, size: number)
	--[[ Local Variables ]]

	local params: OverlapParams = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { arenaFolder:FindFirstChild("Terrain"), arenaFolder:FindFirstChild("Decor") }

	--- @type { BasePart }
	local touched = I.S.Workspace:GetPartBoundsInRadius(position, size + 1.5, params)

	--- @type { number }
	local sizes = _settings.DEBRIS_SIZE

	--[[ Checks ]]

	-- Check if the blast touched any ground
	if #touched == 0 then
		return
	end

	--[[ Throwing ]]

	for _index: number = 1, math.min(math.floor(size * 2), _settings.DEBRIS_MAX) do
		--[[ Local Variables ]]

		local source: BasePart = touched[random:NextInteger(1, #touched)]
		local angle: number = random:NextNumber(0.2, math.pi - 0.2)
		local direction: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), random:NextNumber(-0.2, 0.2))

		--[[ Building ]]

		local chip: Part = I.Create("Part")({
			Name = "Debris",
			Size = Vector3.new(random:NextNumber(sizes[1], sizes[2]), random:NextNumber(sizes[1], sizes[2]), random:NextNumber(sizes[1], sizes[2])),
			CFrame = CFrame.new(position + direction * size * 0.4) * CFrame.Angles(random:NextNumber(0, math.pi), random:NextNumber(0, math.pi), 0),
			Color = source.Color,
			Material = source.Material,
			MaterialVariant = source.MaterialVariant,
			CollisionGroup = "Chip",
			CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.6, 0.35),
			CanQuery = false,
			CanTouch = false,
			Parent = effectsFolder,
		})
		chip.AssemblyLinearVelocity = direction * random:NextNumber(_settings.DEBRIS_SPEED[1], _settings.DEBRIS_SPEED[2])
		chip.AssemblyAngularVelocity = random:NextUnitVector() * 12

		--[[ Fading ]]

		local Chip_TweenInfo: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, _settings.DEBRIS_LIFETIME)
		local Chip_TweenGoal = { Transparency = 1 }
		local Chip_Tween: Tween = I.S.TweenService:Create(chip, Chip_TweenInfo, Chip_TweenGoal)
		Chip_Tween:Play()
		Chip_Tween.Completed:Once(function()
			chip:Destroy()
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Shake

--[[
	Shakes the camera along the arena's plane, with a little roll, harder the stronger the blast.
]]
function Module._shake(strength: number)
	--[[ Checks ]]

	-- Skip blasts too far or too small to feel
	if strength <= 0 then
		return
	end

	--[[ Shaking ]]

	shaker:PlayOnce({
		Magnitude = _settings.SHAKE_MAGNITUDE * strength,
		Roughness = 14,
		PositionInfluence = Vector3.new(0.5, 0.5, 0),
		RotationInfluence = Vector3.new(0, 0, 0.6),
	}, 0.05, 0.02, _settings.SHAKE_SETTLE)
end

--%%%%%%%%%%%%%%%%%%%% Spawn Ball

--[[
	Makes a neon ball that swells to a size and fades over some seconds, then goes.
]]
function Module._spawnBall(position: Vector3, color: Color3, size: number, seconds: number)
	--[[ Building ]]

	local ball: Part = I.Create("Part")({
		Name = "Blast",
		Shape = Enum.PartType.Ball,
		Size = Vector3.one,
		Position = position,
		Color = color,
		Material = Enum.Material.Neon,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Parent = effectsFolder,
	})

	--[[ Animating ]]

	local Grow_TweenInfo: TweenInfo = TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local Grow_TweenGoal = { Size = Vector3.one * size, Transparency = 1 }
	local Grow_Tween: Tween = I.S.TweenService:Create(ball, Grow_TweenInfo, Grow_TweenGoal)
	Grow_Tween:Play()
	Grow_Tween.Completed:Once(function()
		ball:Destroy()
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Strength

--[[
	How hard a blast is felt: its size against FEEL_FULL_RADIUS, less the farther it is from the middle of the view.
	0 outside a match or past FEEL_RANGE.
]]
--- @return number
function Module._getStrength(position: Vector3, radius: number)
	--[[ Checks ]]

	-- Check if the player is in the match
	if not I.S.Players.LocalPlayer:GetAttribute("InMatch") then
		return 0
	end

	--[[ Local Variables ]]

	local view: Vector3 = I.S.Workspace.CurrentCamera.CFrame.Position
	local distance: number = Vector2.new(view.X - position.X, view.Y - position.Y).Magnitude
	local falloff: number = math.clamp(1 - distance / _settings.FEEL_RANGE, 0, 1)

	--[[ Returning ]]

	return radius / _settings.FEEL_FULL_RADIUS * falloff
end

return Module
