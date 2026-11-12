--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
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

-- Until when a hit stop holds the world (os.clock)
local stoppedUntil: number = 0

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
function Module._onExplosion(position: Vector3, radius: number, _itemId: string, _shiny: boolean)
	--[[ Local Variables ]]

	local size: number = math.max(radius, 1)
	local strength: number = Module._getStrength(position, radius / _settings.FEEL_FULL_RADIUS)

	--[[ Drawing ]]

	I.Vfx.Play(Module._getBlastVfx(size), CFrame.new(position), effectsFolder, size / _settings.BLAST_VFX_RADIUS)
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
	Draws a shot's lines from the muzzle to where each bullet (or swing) landed, as neon beams that fade: a gun flashes
	at its muzzle, kicks the camera, and each bullet bursts where it landed; One Punch blasts along its swing.
]]
--- @param hits { Vector3 }
function Module._onTracer(itemId: string, from: Vector3, hits)
	--[[ Local Variables ]]

	local muzzleVfx: string? = _settings.MUZZLE_VFX[itemId]

	--[[ Effects ]]

	if muzzleVfx then
		I.Vfx.Play(muzzleVfx, CFrame.new(from), effectsFolder)
		Module._shake(Module._getStrength(from, _settings.GUN_SHAKE))
	end
	if itemId == "OnePunch" and hits[1] then
		I.Vfx.Play("Punch", CFrame.lookAt(hits[1], hits[1] * 2 - from), effectsFolder, _settings.PUNCH_VFX_SCALE)
	end

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

		if muzzleVfx then
			I.Vfx.Play("Flash_Bullet", CFrame.new(to), effectsFolder)
			I.Vfx.Play("Explosion_Gun", CFrame.new(to), effectsFolder)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% On Hit

--[[
	Shakes the camera by how hard the blow was (harder on a knockout), stops the world for a beat on a big one (longer on
	a knockout, with the camera punching in on the snail and the knockout's ding), and vibrates a phone or pad when the
	local player's own snail is hurt.
]]
function Module._onHit(participantId: string, damage: number, position: Vector3, knockout: boolean?)
	--[[ Data ]]

	local mine: Model? = I.Snails.GetMine()

	--[[ Shaking ]]

	Module._shake(Module._getStrength(position, damage / _settings.HIT_SHAKE_DAMAGE + if knockout then _settings.KNOCKOUT_SHAKE else 0))

	--[[ Hit Stop ]]

	if knockout then
		Module._hitStop(_settings.HITSTOP_KNOCKOUT)
		I.MatchCamera.PunchIn(position)
		I.Sound.Play({ Name = "Match_Knockout", SoundGroup = "SFX" })
	elseif damage >= _settings.HITSTOP_DAMAGE then
		Module._hitStop(_settings.HITSTOP_SECONDS)
	end

	--[[ Checks ]]

	-- Check if it hurt the local player's snail
	if not mine or mine.Name ~= participantId or damage <= 0 then
		return
	end

	--[[ Feel ]]

	I.Haptic.PlayOnce("Combat_Hurt")
end

--%%%%%%%%%%%%%%%%%%%% Hit Stop

--[[
	Stops the world for a beat: the effects' particles and the thrown chunks of ground freeze and the camera holds
	(MatchCamera's Freeze), then all go on as they were. A stop already running isn't stretched.
]]
function Module._hitStop(seconds: number)
	--[[ Checks ]]

	-- Check if a stop is already running
	if os.clock() < stoppedUntil then
		return
	end

	--[[ Local Variables ]]

	local emitters = {} --- @type { [ParticleEmitter]: number }
	local chunks = {} --- @type { [BasePart]: Vector3 }
	stoppedUntil = os.clock() + seconds

	--[[ Freezing ]]

	for _index: number, child: Instance in ipairs(effectsFolder:GetDescendants()) do
		if child:IsA("ParticleEmitter") then
			emitters[child] = child.TimeScale
			child.TimeScale = 0
		elseif child:IsA("BasePart") and child.Name == "Debris" and not child.Anchored then
			chunks[child] = child.AssemblyLinearVelocity
			child.Anchored = true
		end
	end
	I.MatchCamera.Freeze(seconds)

	--[[ Releasing ]]

	task.delay(seconds, function()
		for emitter: ParticleEmitter, timeScale: number in pairs(emitters) do
			emitter.TimeScale = timeScale
		end
		for chunk: BasePart, velocity: Vector3 in pairs(chunks) do
			if chunk.Parent then
				chunk.Anchored = false
				chunk.AssemblyLinearVelocity = velocity
			end
		end
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
	Jolts the camera along the arena's plane, then rumbles it there with a little roll, harder the stronger the blow.
]]
function Module._shake(strength: number)
	--[[ Checks ]]

	-- Skip blows too far or too small to feel
	if strength <= 0 then
		return
	end

	--[[ Shaking ]]

	shaker:PlayOnce({
		Magnitude = _settings.SHAKE_KICK * strength,
		Roughness = 35,
		PositionInfluence = Vector3.new(0.5, 0.5, 0),
		RotationInfluence = Vector3.new(0, 0, 0.6),
	}, 0.03, 0.01, _settings.SHAKE_KICK_SETTLE)
	shaker:PlayOnce({
		Magnitude = _settings.SHAKE_MAGNITUDE * strength,
		Roughness = 12,
		PositionInfluence = Vector3.new(0.5, 0.5, 0),
		RotationInfluence = Vector3.new(0, 0, 0.6),
	}, 0.05, 0.02, _settings.SHAKE_SETTLE)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Strength

--[[
	How hard a blow of this amount (1 is full strength) is felt here: less the farther it is from the middle of the
	view. 0 outside a match or past FEEL_RANGE.
]]
--- @return number
function Module._getStrength(position: Vector3, amount: number)
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

	return amount * falloff
end

--%%%%%%%%%%%%%%%%%%%% Get Blast Vfx

--[[
	The blast effect for a blast this big: the last BLAST_VFX row whose radius it reaches.
]]
--- @return string
function Module._getBlastVfx(radius: number)
	--[[ Local Variables ]]

	local name: string = _settings.BLAST_VFX[1][2]

	--[[ Searching ]]

	for _index: number, row: { any } in ipairs(_settings.BLAST_VFX) do
		if radius >= row[1] then
			name = row[2]
		end
	end

	--[[ Returning ]]

	return name
end

return Module
