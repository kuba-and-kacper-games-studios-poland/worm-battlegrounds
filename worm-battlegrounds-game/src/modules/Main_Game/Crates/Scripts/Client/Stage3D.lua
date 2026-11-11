--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Crates"

--- @type Crates_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Effects = require(script.Parent:FindFirstChild("Effects")) --- @type Crates_Client_Effects

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ State ]]

-- The crates on the stage, the viewport's camera and the loop that moves them
local crates = {} --- @type { Crates_StageCrate }
local camera: Camera
local loop: RBXScriptConnection? = nil

-- Counts plays, so Clear (or a newer play) stops an older one; whether it waits for the tap, and the tap
local playId: number = 0
local waiting: boolean = false
local tapped: boolean = false

-- Whether the crate is the legendary's golden one, the light it's lit by otherwise, and the last sparkle
local golden: boolean = false
local ambient: Color3 = Color3.new()
local light: Color3 = Color3.new()
local lastSparkle: number = 0

-- Whether the stage runs light (a big pack: STAGE_LIGHT_COUNT), and the front crate the pack's effects come from
local lean: boolean = false
local front = nil --- @type Crates_StageCrate?

-- The stage glow's own size and transparency, which a light pack's opening swells
local glowSize: UDim2 = UDim2.new()
local glowTransparency: number = 0

--[[ Models ]]

--[[
	Where each moving piece of a crate model turns, in studs from the model's pivot (the middle of its floor): the
	walls on their bottom edges, the hatches on the side walls' top edges
]]
--- @type { [string]: Vector3 }
local HINGES = {
	Front = Vector3.new(0, 0.35, -1.5),
	Back = Vector3.new(0, 0.35, 1.5),
	Left = Vector3.new(2, 0.35, 0),
	Right = Vector3.new(-2, 0.35, 0),
	HatchL = Vector3.new(2, 2.75, 0),
	HatchR = Vector3.new(-2, 2.75, 0),
}

-- The pieces every crate model has
--- @type { string }
local PIECES = { "Base", "Inner", "Front", "Back", "Left", "Right", "HatchL", "HatchR" }

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

--- @class Crates_Client_Stage3D
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	local moduleGui: ScreenGui = I.UserInterface.UI[_settings.GUI_NAME]
	elems["Stage"] = moduleGui:FindFirstChild("U_Stage", true) --- @type Frame
	elems["Glow"] = elems["Stage"]:FindFirstChild("S_Glow") --- @type ImageLabel
	elems["Rays"] = elems["Stage"]:FindFirstChild("S_Rays") --- @type ImageLabel
	elems["Viewport"] = elems["Stage"]:FindFirstChild("S_Viewport") --- @type ViewportFrame
	elems["Tap"] = elems["Stage"]:FindFirstChild("S_Tap") --- @type TextLabel
	elems["TapScale"] = elems["Tap"]:FindFirstChild("S_TapScale") --- @type UIScale
	elems["TapSub"] = elems["Stage"]:FindFirstChild("S_TapSub") --- @type TextLabel
	elems["Hit"] = elems["Stage"]:FindFirstChild("S_Hit") --- @type ImageButton
	ambient = elems["Viewport"].Ambient
	light = elems["Viewport"].LightColor
	glowSize = elems["Glow"].Size
	glowTransparency = elems["Glow"].ImageTransparency

	--[[ Camera ]]

	camera = Instance.new("Camera")
	camera.FieldOfView = _settings.STAGE_FOV
	camera.Parent = elems["Viewport"]
	elems["Viewport"].CurrentCamera = camera

	-- The crates go in a WorldModel: moving a part straight in a ViewportFrame redraws every mesh in it
	elems["World"] = Instance.new("WorldModel") --- @type WorldModel
	elems["World"].Parent = elems["Viewport"]

	--[[ Connections ]]

	I.Interact.OnPress(elems["Hit"], Module._onTap)

	--[[ Preloading ]]

	-- The crate models' meshes and textures load now, so the first opening isn't grey
	task.spawn(function()
		I.S.ContentProvider:PreloadAsync({ I.Dirs.Assets:FindFirstChild("Crates") })
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Plays the 3D crates: the bought crates drop onto the screen, wait for a tap (Quick open opens them at once), then
	rattle, spring their hatches, drop their walls and send up a ball of light that swells into the flash. The
	golden crate is a legendary's: the same crate, lit gold, on gold rays. Returns false when Clear stopped it.
]]
--- @param row Crates_CrateData
--- @return boolean
function Module.Play(row, count: number, gold: boolean, quick: boolean)
	--[[ Checks ]]

	-- Check if the crate has its 3D model
	local prefab: Model? = I.Dirs.Assets:FindFirstChild("Crates"):FindFirstChild(row.Model)
	if not prefab then
		warn(`[{_localName}::{script.Name}]: Crate model ({row.Model}) is missing!`)
		return true
	end

	--[[ Local Variables ]]

	Module.Clear()
	local thisPlay: number = playId
	local layout = _settings.STAGE_LAYOUTS[count] or _settings.STAGE_LAYOUTS[1] --- @type Crates_StageLayout
	local color: Color3 = if gold then Color3.fromRGB(255, 200, 40) else row.Glow
	local speed: number = if quick then _settings.STAGE_QUICK_SPEED else 1
	golden = gold
	lean = count >= _settings.STAGE_LIGHT_COUNT

	--[[ Stage ]]

	elems["Glow"].Size = glowSize
	elems["Glow"].ImageTransparency = glowTransparency
	elems["Glow"].ImageColor3 = color
	elems["Rays"].ImageColor3 = color
	elems["Viewport"].Ambient = if gold then _settings.STAGE_GOLD_AMBIENT else ambient
	elems["Viewport"].LightColor = if gold then _settings.STAGE_GOLD_LIGHT else light
	elems["TapSub"].Visible = false
	elems["Stage"].Visible = true
	Module._placeCamera(layout)

	--[[ Crates ]]

	--- @param spot Vector3
	for index: number, spot in ipairs(layout.Spots) do
		table.insert(crates, Module._makeCrate(prefab, spot, layout, index, color))
	end

	-- The crates drop in back to front, the front one last
	local order = Module._getOrder() --- @type { number }
	front = crates[order[#order]]
	local gap: number = (_settings.STAGE_DROP_GAP[count] or 0) * speed
	local drop: number = if quick then _settings.STAGE_QUICK_DROP_SECONDS else _settings.STAGE_DROP_SECONDS
	local now: number = os.clock()
	for place: number, index: number in ipairs(order) do
		crates[index].DropStart = now + (place - 1) * gap
		crates[index].DropSeconds = drop
	end
	loop = I.S.RunService.RenderStepped:Connect(Module._step)
	task.wait(drop + gap * (#order - 1))
	if thisPlay ~= playId then
		return false
	end

	--[[ Waiting ]]

	if gold then
		I.Sound.Play({ Name = "Crate_GoldHit", SoundGroup = "SFX", Volume = 0.8 })
		elems["TapSub"].Visible = not quick
	end
	if not quick then
		tapped = false
		waiting = true
		elems["Tap"].Text = if count > 1 then "Tap to open all" else "Tap to open"
		elems["Tap"].Visible = true
		elems["Hit"].Visible = true
		while not tapped and thisPlay == playId do
			task.wait()
		end
		waiting = false
		elems["Tap"].Visible = false
		elems["TapSub"].Visible = false
		elems["Hit"].Visible = false
		if thisPlay ~= playId then
			return false
		end
		I.Sound.Play({ Name = "Button_Click", SoundGroup = "UI", Volume = 0.7 })
	else
		task.wait(0.16)
	end

	--[[ Opening ]]

	local openGap: number = (_settings.STAGE_OPEN_GAP[count] or 0) * speed
	local length: number = (_settings.STAGE_RATTLE_SECONDS + _settings.STAGE_HATCH_SECONDS * 0.55 + _settings.STAGE_WALL_SECONDS + _settings.STAGE_SWELL_SECONDS) * speed
	now = os.clock()
	for place: number, index: number in ipairs(order) do
		crates[index].OpenStart = now + (#order - place) * openGap
		crates[index].Speed = speed
	end
	if not quick then
		I.Sound.Play({ Name = "Crate_Shake", SoundGroup = "SFX" })
	end
	task.wait(length + openGap * (#order - 1))
	if thisPlay ~= playId then
		return false
	end

	--[[ Handing Over ]]

	Effects.Flash(Color3.new(1, 1, 1), 0.9, 0.52)
	I.Sound.Play({ Name = "Crate_Land", SoundGroup = "SFX", Volume = 0.7 })
	Module.Clear()

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	Takes the crates off the stage and hides it, stopping a play in progress.
]]
function Module.Clear()
	--[[ Clearing ]]

	playId += 1
	waiting = false
	golden = false
	lean = false
	front = nil
	if loop then
		loop:Disconnect()
		loop = nil
	end
	--- @param crate Crates_StageCrate
	for _index: number, crate in ipairs(crates) do
		crate.Model:Destroy()
	end
	table.clear(crates)

	--[[ Visibility ]]

	elems["Stage"].Visible = false
	elems["Tap"].Visible = false
	elems["TapSub"].Visible = false
	elems["Hit"].Visible = false
end

--%%%%%%%%%%%%%%%%%%%% Make Crate

--[[
	Clones a crate model onto the stage at its spot, at the layout's scale and turn, with its ball of light (hidden
	until it opens; none on a light stage), and keeps each piece's place in the model for the hinges.
]]
--- @param layout Crates_StageLayout
--- @return Crates_StageCrate
function Module._makeCrate(prefab: Model, spot: Vector3, layout, index: number, color: Color3)
	--[[ Cloning ]]

	local model: Model = prefab:Clone()
	model.Name = "Crate"
	model:PivotTo(CFrame.new())
	model:ScaleTo(layout.Scale)

	--[[ Pieces ]]

	local parts = {} --- @type { [string]: BasePart }
	local rest = {} --- @type { [string]: CFrame }
	for _index: number, name: string in ipairs(PIECES) do
		local part: BasePart = model:FindFirstChild(name)
		parts[name] = part
		rest[name] = part.CFrame
	end
	parts["Inner"].Color = color:Lerp(Color3.new(1, 1, 1), 0.45)

	--[[ Light ]]

	local orb: Part? = nil
	local halo: Part? = nil
	if not lean then
		orb = Instance.new("Part")
		orb.Name = "Orb"
		orb.Shape = Enum.PartType.Ball
		orb.Material = Enum.Material.Neon
		orb.Color = color:Lerp(Color3.new(1, 1, 1), 0.55)
		orb.Anchored = true
		orb.Transparency = 1
		orb.Parent = model
		halo = orb:Clone()
		halo.Name = "Halo"
		halo.Color = color
		halo.Parent = model
	end

	--[[ Placing ]]

	model.Parent = elems["World"]

	--[[ Returning ]]

	return {
		Model = model,
		Parts = parts,
		Rest = rest,
		Orb = orb,
		Halo = halo,
		Home = CFrame.new(spot) * CFrame.Angles(0, layout.Yaw + spot.X * 0.035, 0),
		Scale = layout.Scale,
		Phase = index * 1.37,
		Spin = (math.random() - 0.5) * 0.9,
		DropStart = math.huge,
		DropSeconds = 1,
		Landed = false,
		OpenStart = nil,
		Speed = 1,
		Hatched = false,
		Burst = false,
	}
end

--%%%%%%%%%%%%%%%%%%%% Place Camera

--[[
	Points the viewport's camera at the layout, backing it off on a screen narrower than the one the layouts are
	framed for, so a pack's outer crates stay on it.
]]
--- @param layout Crates_StageLayout
function Module._placeCamera(layout)
	--[[ Local Variables ]]

	local size: Vector2 = elems["Viewport"].AbsoluteSize
	local aspect: number = size.X / math.max(1, size.Y)
	local back: number = math.max(1, _settings.STAGE_ASPECT / aspect)

	--[[ Applying ]]

	camera.CFrame = CFrame.lookAt(layout.Focus + (layout.Camera - layout.Focus) * back, layout.Focus)
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Each frame while the stage shows: every crate's drop, idle bob, rattle, hatches, walls and light, the turning rays,
	the tap prompt's beat, and the golden crate's sparkles.
]]
function Module._step()
	--[[ Local Variables ]]

	local now: number = os.clock()

	--[[ Crates ]]

	--- @param crate Crates_StageCrate
	for _index: number, crate in ipairs(crates) do
		if crate.OpenStart and now >= crate.OpenStart then
			Module._stepOpen(crate, now - crate.OpenStart)
		elseif now < crate.DropStart + crate.DropSeconds then
			Module._stepDrop(crate, now)
		else
			Module._stepIdle(crate, now)
		end
		Module._pose(crate)
	end

	--[[ Stage ]]

	elems["Rays"].Rotation = (now / (if golden then 16 else _settings.RAYS_SPIN_SECONDS) * 360) % 360
	if waiting then
		elems["TapScale"].Scale = 1 + math.sin(now * math.pi * 1.6) * 0.04
	end
	if golden and now - lastSparkle > 0.09 and #crates > 0 then
		lastSparkle = now
		local point: Vector2 = Module._getPoint(crates[1].Home.Position + Vector3.new((math.random() - 0.5) * 6, math.random() * 4, 0))
		Effects.Burst("Stars", point, 1, Color3.fromRGB(255, 230, 140))
	end
end

--%%%%%%%%%%%%%%%%%%%% Step Drop

--[[
	A crate dropping in: it falls from above, turning to face its way, and bounces on landing (a puff of dust and a
	thud as it first touches down; on a light stage only the front crate puffs, wider, for the whole pack).
]]
--- @param crate Crates_StageCrate
function Module._stepDrop(crate, now: number)
	--[[ Local Variables ]]

	local t: number = math.clamp((now - crate.DropStart) / crate.DropSeconds, 0, 1)

	--[[ Falling ]]

	crate.Lift = _settings.STAGE_DROP_HEIGHT * (1 - I.S.TweenService:GetValue(t, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out))
	crate.Turn = crate.Spin * (1 - I.S.TweenService:GetValue(t, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out))
	crate.Tilt = CFrame.identity

	--[[ Landing ]]

	if not crate.Landed and t >= 0.364 then
		crate.Landed = true
		local point: Vector2 = Module._getPoint(crate.Home.Position)
		I.Sound.Play({ Name = "Crate_Settle", SoundGroup = "SFX", Volume = if #crates > 3 then 0.45 else 0.9, PitchMin = 0.9, PitchMax = 1.05 })
		if lean and crate == front then
			Effects.Ring(point, Color3.new(1, 1, 1), 60 * crate.Scale, 1100 * crate.Scale, 0.45)
			Effects.Burst("Stars", point, 12, Color3.new(1, 1, 1))
		elseif not lean then
			Effects.Ring(point, Color3.new(1, 1, 1), 60 * crate.Scale, 440 * crate.Scale, 0.4)
			Effects.Burst("Stars", point, if #crates > 3 then 3 else 8, Color3.new(1, 1, 1))
		end
		if #crates == 1 then
			Effects.Shake(0.16, 6)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Step Idle

--[[
	A crate waiting: it bobs and sways a little; while the tap prompt shows, its hatches lift on the prompt's beat.
]]
--- @param crate Crates_StageCrate
function Module._stepIdle(crate, now: number)
	--[[ Local Variables ]]

	local t: number = now + crate.Phase
	local beat: number = if waiting then math.max(0, math.sin(now * math.pi * 1.6)) ^ 8 else 0

	--[[ Bobbing ]]

	crate.Lift = 0.08 + math.sin(t * 2.1) * 0.08
	crate.Turn = math.sin(t * 0.8) * 0.1
	crate.Tilt = CFrame.Angles(0, 0, math.sin(t * 1.3) * 0.012)
	crate.Strain = beat * 0.05
	crate.Hatch = 0
	crate.Wall = 0
	crate.Light = 0
end

--%%%%%%%%%%%%%%%%%%%% Step Open

--[[
	A crate opening: it rattles, harder and faster, its hatches straining; the hatches spring open (a shaft of sparks);
	the walls fall outward (a ring in its colour) as the ball of light rises, and the light swells into the flash.
]]
--- @param crate Crates_StageCrate
function Module._stepOpen(crate, elapsed: number)
	--[[ Local Variables ]]

	local speed: number = crate.Speed
	local rattle: number = _settings.STAGE_RATTLE_SECONDS * speed
	local hatchTime: number = _settings.STAGE_HATCH_SECONDS * speed
	local wallTime: number = _settings.STAGE_WALL_SECONDS * speed
	local swellTime: number = _settings.STAGE_SWELL_SECONDS * speed

	--[[ Rattle ]]

	if elapsed < rattle then
		local t: number = elapsed / rattle
		local amp: number = 0.025 + t * 0.07
		crate.Tilt = CFrame.Angles(math.sin(elapsed * 41 + 1) * amp * 0.5, 0, math.sin(elapsed * 55) * amp)
		crate.Lift = math.abs(math.sin(elapsed * 55)) * 0.12 * (0.4 + t)
		crate.Turn = 0
		crate.Strain = math.max(0, math.sin(elapsed * 110)) * (0.05 + t * 0.12)
		return
	end

	--[[ Hatches ]]

	local th: number = math.clamp((elapsed - rattle) / hatchTime, 0, 1)
	crate.Tilt = CFrame.identity
	crate.Strain = 0
	crate.Hatch = math.rad(_settings.STAGE_HATCH_DEGREES) * I.S.TweenService:GetValue(th, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	crate.Lift = math.sin(th * math.pi) * 0.35
	if not crate.Hatched then
		crate.Hatched = true
		Module._onHatch(crate)
	end

	--[[ Walls ]]

	local tw: number = math.clamp((elapsed - rattle - hatchTime * 0.55) / wallTime, 0, 1)
	crate.Wall = math.rad(_settings.STAGE_WALL_DEGREES) * I.S.TweenService:GetValue(tw, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	if not crate.Burst and tw > 0.05 then
		crate.Burst = true
		Module._onBurst(crate)
	end

	--[[ Light ]]

	local to: number = math.clamp((elapsed - rattle - hatchTime * 0.2) / (hatchTime * 0.8 + wallTime), 0, 1)
	local ts: number = math.clamp((elapsed - rattle - hatchTime * 0.55 - wallTime) / swellTime, 0, 1)
	local swell: number = _settings.STAGE_SWELL[#crates] or 1
	crate.LightHeight = 1 + I.S.TweenService:GetValue(to, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out) * 2.6
	crate.Light = I.S.TweenService:GetValue(math.min(1, to * 1.6), Enum.EasingStyle.Back, Enum.EasingDirection.Out) * (1 + math.sin(elapsed * 30) * 0.06) * (1 + ts * ts * ts * swell)
end

--%%%%%%%%%%%%%%%%%%%% Pose

--[[
	Moves a crate's pieces to its pose: the whole crate lifted, turned and tilted; each wall turned on its hinge; each
	hatch turned on its own hinge as it rides on its side wall; the ball of light at its height and size.
]]
--- @param crate Crates_StageCrate
function Module._pose(crate)
	--[[ Local Variables ]]

	local scale: number = crate.Scale
	local root: CFrame = crate.Home * CFrame.new(0, (crate.Lift or 0) * scale, 0) * CFrame.Angles(0, crate.Turn or 0, 0) * (crate.Tilt or CFrame.identity)
	local wall: number = crate.Wall or 0
	local hatch: number = (crate.Hatch or 0) + (crate.Strain or 0)
	local parts = crate.Parts --- @type { [string]: BasePart }
	local rest = crate.Rest --- @type { [string]: CFrame }
	local left: CFrame = Module._getHinge("Left", CFrame.Angles(0, 0, -wall), scale)
	local right: CFrame = Module._getHinge("Right", CFrame.Angles(0, 0, wall), scale)

	--[[ Pieces ]]

	parts["Base"].CFrame = root * rest["Base"]
	parts["Inner"].CFrame = root * rest["Inner"]
	parts["Front"].CFrame = root * Module._getHinge("Front", CFrame.Angles(-wall, 0, 0), scale) * rest["Front"]
	parts["Back"].CFrame = root * Module._getHinge("Back", CFrame.Angles(wall, 0, 0), scale) * rest["Back"]
	parts["Left"].CFrame = root * left * rest["Left"]
	parts["Right"].CFrame = root * right * rest["Right"]
	parts["HatchL"].CFrame = root * left * Module._getHinge("HatchL", CFrame.Angles(0, 0, -hatch), scale) * rest["HatchL"]
	parts["HatchR"].CFrame = root * right * Module._getHinge("HatchR", CFrame.Angles(0, 0, hatch), scale) * rest["HatchR"]

	--[[ Light ]]

	local orb: Part? = crate.Orb
	local halo: Part? = crate.Halo
	if orb and halo then
		local size: number = (crate.Light or 0) * scale
		local at: CFrame = crate.Home * CFrame.new(0, (crate.LightHeight or 1) * scale, 0)
		orb.Transparency = if size > 0 then 0 else 1
		halo.Transparency = if size > 0 then 0.84 else 1
		orb.Size = Vector3.one * math.max(0.05, 1.24 * size)
		halo.Size = Vector3.one * math.max(0.05, 2.2 * size)
		orb.CFrame = at
		halo.CFrame = at
	end
end

--%%%%%%%%%%%%%%%%%%%% On Tap

--[[
	The player tapped the crates (or pressed A or Space): they open.
]]
function Module._onTap()
	--[[ Checks ]]

	-- Check if the stage waits for the tap
	if not waiting then
		return
	end

	--[[ Saving ]]

	tapped = true
end

--%%%%%%%%%%%%%%%%%%%% On Hatch

--[[
	A crate's hatches spring open: the lock's sound (once for a pack) and sparks shooting up out of it (on a light
	stage, only out of the front crate).
]]
--- @param crate Crates_StageCrate
function Module._onHatch(crate)
	--[[ Checks ]]

	-- Skip the back crates of a light stage
	if lean and crate ~= front then
		return
	end

	--[[ Local Variables ]]

	local point: Vector2 = Module._getPoint(crate.Home.Position + Vector3.new(0, 3.1 * crate.Scale, 0))
	local color: Color3 = crate.Parts["Inner"].Color

	--[[ Bursting ]]

	if crate == front then
		I.Sound.Play({ Name = "Crate_Unlock", SoundGroup = "SFX" })
	end
	Effects.Burst("Sparks", point, if lean then 30 elseif #crates > 3 then 14 else 34, color)
	if #crates == 1 then
		Effects.Shake(0.22, 8)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Burst

--[[
	A crate's walls fall: a ring in its colour, and for the front crate a soft flash. On a light stage only the front
	crate rings, wider, and the stage's glow swells behind the pack in place of the crates' balls of light.
]]
--- @param crate Crates_StageCrate
function Module._onBurst(crate)
	--[[ Checks ]]

	-- Skip the back crates of a light stage
	if lean and crate ~= front then
		return
	end

	--[[ Local Variables ]]

	local point: Vector2 = Module._getPoint(crate.Home.Position + Vector3.new(0, 1.5 * crate.Scale, 0))
	local color: Color3 = crate.Parts["Inner"].Color

	--[[ Bursting ]]

	Effects.Ring(point, color, 80 * crate.Scale, (if lean then 1300 elseif #crates > 3 then 520 else 1240) * crate.Scale, 0.5)
	if crate == front then
		Effects.Flash(color:Lerp(Color3.new(1, 1, 1), 0.6), 0.28, 0.3)
	end

	--[[ Glow ]]

	if lean then
		local Swell_TweenInfo: TweenInfo = TweenInfo.new((_settings.STAGE_WALL_SECONDS + _settings.STAGE_SWELL_SECONDS) * crate.Speed, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local Swell_TweenGoal = { ImageTransparency = 0, Size = UDim2.fromScale(glowSize.X.Scale * 1.4, glowSize.Y.Scale * 1.4) }
		local Swell_Tween: Tween = I.S.TweenService:Create(elems["Glow"], Swell_TweenInfo, Swell_TweenGoal)
		Swell_Tween:Play()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Point

--[[
	Returns where a point on the stage shows on the screen (absolute pixels), from the viewport's camera.
]]
--- @return Vector2
function Module._getPoint(world: Vector3)
	--[[ Local Variables ]]

	local viewport: ViewportFrame = elems["Viewport"]
	local size: Vector2 = viewport.AbsoluteSize
	local local3: Vector3 = camera.CFrame:PointToObjectSpace(world)
	local depth: number = math.max(0.01, -local3.Z)
	local spread: number = math.tan(math.rad(camera.FieldOfView) / 2)
	local x: number = local3.X / depth / (spread * size.X / math.max(1, size.Y))
	local y: number = local3.Y / depth / spread

	--[[ Returning ]]

	return viewport.AbsolutePosition + Vector2.new((x + 1) / 2 * size.X, (1 - y) / 2 * size.Y)
end

--%%%%%%%%%%%%%%%%%%%% Get Hinge

--[[
	Returns a turn about one of a crate's hinges (its place scaled with the crate), to put before a piece's rest place.
]]
--- @return CFrame
function Module._getHinge(name: string, turn: CFrame, scale: number)
	--[[ Local Variables ]]

	local at: Vector3 = HINGES[name] * scale

	--[[ Returning ]]

	return CFrame.new(at) * turn * CFrame.new(-at)
end

--%%%%%%%%%%%%%%%%%%%% Get Order

--[[
	Returns the crates' indexes from the back of the stage to the front (the camera looks along +Z).
]]
--- @return { number }
function Module._getOrder()
	--[[ Local Variables ]]

	local order = {} --- @type { number }
	for index: number = 1, #crates do
		table.insert(order, index)
	end

	--[[ Sorting ]]

	table.sort(order, function(a: number, b: number): boolean
		return crates[a].Home.Position.Z > crates[b].Home.Position.Z
	end)

	--[[ Returning ]]

	return order
end

return Module
