--[[
	Created By: 	HungryN00B
]]

local _localName: string = "LevelPlatePreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local UmeGui: Instance = script:FindFirstAncestor("UmeGui")
local LibsDir: Instance = UmeGui:FindFirstChild("Libs")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local TweenService: TweenService = game:GetService("TweenService")
local RunService: RunService = game:GetService("RunService")
local Workspace: Workspace = game:GetService("Workspace")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Libs

local Runtime = require(LibsDir:FindFirstChild("Runtime")) --- @type UmeGui_Runtime
local UIEmitter = require(LibsDir:FindFirstChild("Mirror"):FindFirstChild("UIEmitter")) --- @type UmeGui_Ume_Library_UIEmitter

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Examples ]]

--[[
	The level rewards (the owner's pick, 2026-11-24): the level, the weapon, its picture (Arsenal's Icon), the variant
	and the line under its name
]]
--- @type { { any } }
local REWARDS = {
	{ 10, "Grenade", "rbxassetid://88613468948489", "Shiny", "+5% damage and a pearly shine in every match" },
	{ 20, "Shotgun", "rbxassetid://104705832389891", "Shiny", "+5% damage and a pearly shine in every match" },
	{ 30, "Bazooka", "rbxassetid://89888640314244", "Shiny", "+5% damage and a pearly shine in every match" },
	{ 60, "Grenade", "rbxassetid://88613468948489", "Golden", "+5% damage, and solid gold in every match" },
	{ 75, "Shotgun", "rbxassetid://104705832389891", "Golden", "+5% damage, and solid gold in every match" },
	{ 90, "Bazooka", "rbxassetid://89888640314244", "Golden", "+5% damage, and the pros' solid gold in every match" },
}

--[[ Looks ]]

--[[
	Each variant's colours: the glow, rays and card (Crates' SHINY_COLOR and GOLDEN_COLOR), the diamond's
	and the title's gradients (GOLDEN!'s is LEVEL UP!'s), the level tag's and the particles'
]]
--- @type { [string]: { [string]: any } }
local LOOKS = {
	Shiny = {
		Accent = Color3.fromRGB(255, 175, 235),
		Rays = Color3.fromRGB(255, 205, 245),
		Gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 175, 235)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 190, 255)),
		}),
		Tag = ColorSequence.new(Color3.fromRGB(255, 205, 245), Color3.fromRGB(230, 130, 215)),
		Particles = { Color3.fromRGB(255, 175, 235), Color3.fromRGB(255, 255, 255), Color3.fromRGB(140, 255, 220), Color3.fromRGB(140, 190, 255) },
	},
	Golden = {
		Accent = Color3.fromRGB(255, 205, 60),
		Rays = Color3.fromRGB(255, 200, 80),
		Gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 246, 192)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 194, 26)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 138, 0)),
		}),
		Tag = ColorSequence.new(Color3.fromRGB(255, 224, 102), Color3.fromRGB(255, 181, 31)),
		Particles = { Color3.fromRGB(255, 210, 63), Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 140, 20) },
	},
}

--[[
	The weapon's model on the card: its turn when it's placed (degrees, then the view's Turn motion turns it), the
	camera's field of view and distance (times the model's longest side), and Combat's Golden look's Gild (dark,
	bright), GildCover and VARIANT_COVER_GROW
]]
local MODEL_YAW: number = 60
local MODEL_FOV: number = 30
local MODEL_DISTANCE: number = 1.75

--- @type { Color3 }
local GILD = { Color3.fromRGB(70, 42, 10), Color3.fromRGB(255, 200, 70) }

local GILD_COVER: number = 0.3
local GILD_GROW: number = 1.02

-- The pictures the particles draw with (Progression's REPLAY_TEXTURES)
local STAR_TEXTURE: string = "rbxassetid://95186884093199"
local SPARK_TEXTURE: string = "rbxassetid://97296507263981"

--[[ Timing ]]

-- Seconds the diamond charges before it flashes open, and how far its rattle swings at the end (degrees)
local CHARGE_SECONDS: number = 1.3
local RATTLE_DEGREES: number = 12

-- How see-through the dark rests, and the rays, back rays and glow once the card is in
local SHADE_REST: number = 0.12
local RAYS_REST: number = 0.45
local RAYS_BACK_REST: number = 0.78
local GLOW_REST: number = 0.3

local POP_TWEENINFO: TweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CARD_TWEENINFO: TweenInfo = TweenInfo.new(0.52, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local SLAM_TWEENINFO: TweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local FADE_TWEENINFO: TweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FLASH_TWEENINFO: TweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

--[[ State ]]

-- Which play is running (a new one stops the last), and the emitters it made
local playId: number = 0
local emitters = {} --- @type { UmeGui_UIEmitter_Instance }

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

--- @class UmeGui_Guis_WormBattlegrounds_LevelPlate_Preview
local Module = {

	--[[ Settings ]]

	--- @type { UmeGui_Node }
	Settings = {
		{
			Control = "Dropdown",
			Id = "S_Reward",
			Label = "Reward",
			Options = { "Lv 10 Shiny Grenade", "Lv 20 Shiny Shotgun", "Lv 30 Shiny Bazooka", "Lv 60 Golden Grenade", "Lv 75 Golden Shotgun", "Lv 90 Golden Bazooka" },
			Value = "Lv 90 Golden Bazooka",
		},
		{ Control = "Segmented", Id = "S_Moment", Label = "Moment", Options = { "Charge", "Reveal" }, Value = "Reveal" },
		{ Control = "Button", Id = "S_Play", Text = "Play the unlock" },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Shows the weapon reward as the Progression module would: the picked reward dressed in its variant, held at its charge
	(the diamond waiting) or its reveal (the card, SHINY! or GOLDEN!, the lines).
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local reward = Module._getReward(preview) --- @type { any }
	local revealed: boolean = preview.Values.S_Moment ~= "Charge"

	--[[ Stopping ]]

	playId += 1
	Module._clearEmitters()

	--[[ Applying ]]

	Module._dress(preview, reward)
	Module._setMoment(preview, revealed)
end

--%%%%%%%%%%%%%%%%%%%% Action

--[[
	Plays the whole unlock from the dark to TAP TO CONTINUE.
]]
--- @param preview UmeGui_Preview
function Module.Action(preview, id: string)
	--[[ Checks ]]

	-- Skip buttons other than Play
	if id ~= "S_Play" then
		return
	end

	--[[ Playing ]]

	task.spawn(Module._play, preview)
end

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	The unlock in order: the dark and the glow come in, the level's diamond pops up and charges (rattling, swelling,
	light drawn into it), flashes open into the card on its rays with a burst, SHINY! or GOLDEN! slams in, the lines
	pop up, TAP TO CONTINUE pulses, and sparkles keep rising round the card.
]]
--- @param preview UmeGui_Preview
function Module._play(preview)
	--[[ Local Variables ]]

	playId += 1
	local id: number = playId
	local reward = Module._getReward(preview) --- @type { any }
	local look = LOOKS[reward[4]] --- @type { [string]: any }
	local unit: number = Module._get(preview, "S_Fx").AbsoluteSize.Y / 1080
	Module._clearEmitters()
	Module._dress(preview, reward)

	--[[ Elements ]]

	local shade: Frame = Module._get(preview, "S_Shade")
	local glow: ImageLabel = Module._get(preview, "S_Glow")
	local rays: ImageLabel = Module._get(preview, "S_Rays")
	local raysBack: ImageLabel = Module._get(preview, "S_RaysBack")
	local orb: Frame = Module._get(preview, "S_Orb")
	local orbScale: UIScale = Module._get(preview, "S_OrbScale")
	local orbGlow: ImageLabel = Module._get(preview, "S_OrbGlow")
	local diamond: Frame = Module._get(preview, "S_OrbDiamond")
	local slot: Frame = Module._get(preview, "S_CardSlot")
	local cardScale: UIScale = Module._get(preview, "S_CardScale")
	local title: TextLabel = Module._get(preview, "S_Title")
	local flash: Frame = Module._get(preview, "S_Flash")

	--[[ Resetting ]]

	Module._get(preview, "U_Unlock").Visible = true
	shade.BackgroundTransparency = 1
	glow.ImageTransparency = 1
	rays.ImageTransparency = 1
	raysBack.ImageTransparency = 1
	orb.Visible = false
	orbScale.Scale = 0
	orbGlow.ImageTransparency = 0.35
	orbGlow.Size = UDim2.fromScale(2.4, 2.4)
	diamond.Rotation = 45
	slot.Visible = false
	cardScale.Scale = 0
	for _index: number, name: string in ipairs({ "S_KickerScale", "S_TitleScale", "S_NameScale", "S_PerkScale" }) do
		Module._get(preview, name).Scale = 0
	end
	Module._get(preview, "S_Tap").Visible = false
	flash.BackgroundTransparency = 1

	--[[ Dark ]]

	Module._tween(shade, FADE_TWEENINFO, { BackgroundTransparency = SHADE_REST })
	Module._tween(glow, FADE_TWEENINFO, { ImageTransparency = 0.6 })
	task.wait(0.25)

	--[[ Diamond ]]

	orb.Visible = true
	Module._tween(orbScale, POP_TWEENINFO, { Scale = 1 })
	Module._tween(Module._get(preview, "S_KickerScale"), POP_TWEENINFO, { Scale = 1 })
	task.wait(0.55)

	--[[ Charging ]]

	-- Light flies into the diamond faster and faster while it rattles harder and swells
	local inward = Module._newEmitter(preview, {
		Texture = SPARK_TEXTURE,
		SizeSpace = "Offset",
		AspectRatio = 3,
		Size = NumberSequence.new(30 * unit, 10 * unit),
		Lifetime = NumberRange.new(0.6, 0.9),
		Velocity = NumberRange.new(20 * unit, 60 * unit),
		SpreadAngle = 360,
		FaceMovementDirection = true,
		AttractTo = diamond,
		AttractStrength = 7000 * unit,
		AttractDestroyOnArrive = true,
		Color = look.Accent,
		CullOffscreen = false,
	}) --- @type UmeGui_UIEmitter_Instance
	local centre: Vector2 = diamond.AbsolutePosition + diamond.AbsoluteSize / 2
	local start: number = os.clock()
	while os.clock() - start < CHARGE_SECONDS do
		if id ~= playId then
			return
		end
		local through: number = (os.clock() - start) / CHARGE_SECONDS
		local now: number = os.clock()
		diamond.Rotation = 45 + math.sin(now * 55) * (2 + RATTLE_DEGREES * through)
		orbScale.Scale = 1 + 0.2 * through + math.sin(now * 31) * 0.025 * through
		orbGlow.ImageTransparency = 0.35 - 0.33 * through
		orbGlow.Size = UDim2.fromScale(2.4 + 1.8 * through, 2.4 + 1.8 * through)
		glow.ImageTransparency = 0.6 - 0.45 * through
		rays.ImageTransparency = 1 - 0.3 * through
		local angle: number = math.random() * math.pi * 2
		local reach: number = (260 + math.random() * 160) * unit
		inward:Emit(if through > 0.6 then 3 else 1, centre + Vector2.new(math.cos(angle), math.sin(angle)) * reach)
		RunService.Heartbeat:Wait()
	end

	--[[ Flash ]]

	flash.BackgroundTransparency = 0
	Module._tween(flash, FLASH_TWEENINFO, { BackgroundTransparency = 1 })
	orb.Visible = false
	Module._tween(rays, FADE_TWEENINFO, { ImageTransparency = RAYS_REST })
	Module._tween(raysBack, FADE_TWEENINFO, { ImageTransparency = RAYS_BACK_REST })
	Module._tween(glow, FADE_TWEENINFO, { ImageTransparency = GLOW_REST })

	--[[ Card ]]

	slot.Visible = true
	cardScale.Scale = 0.35
	Module._tween(cardScale, CARD_TWEENINFO, { Scale = 1 })
	Module._burst(preview, centre, look, unit, 1)
	task.wait(0.5)
	if id ~= playId then
		return
	end

	--[[ Title ]]

	local titleScale: UIScale = Module._get(preview, "S_TitleScale")
	titleScale.Scale = 2.6
	Module._tween(titleScale, SLAM_TWEENINFO, { Scale = 1 })
	task.wait(SLAM_TWEENINFO.Time * 0.6)
	cardScale.Scale = 1.06
	Module._tween(cardScale, FADE_TWEENINFO, { Scale = 1 })
	Module._burst(preview, title.AbsolutePosition + title.AbsoluteSize / 2, look, unit, 0.45)

	--[[ Lines ]]

	task.wait(0.2)
	Module._tween(Module._get(preview, "S_NameScale"), POP_TWEENINFO, { Scale = 1 })
	task.wait(0.12)
	Module._tween(Module._get(preview, "S_PerkScale"), POP_TWEENINFO, { Scale = 1 })
	task.wait(0.6)
	if id ~= playId then
		return
	end
	Module._get(preview, "S_Tap").Visible = true

	--[[ Sparkles ]]

	Module._startSparkles(preview, look, unit)
end

--%%%%%%%%%%%%%%%%%%%% Dress

--[[
	Dresses the unlock for a reward: its texts, the weapon's picture, the variant's colours on the light, the card, the
	diamond, the title and the level tag, and the foil or the gold rim.
]]
--- @param reward { any }
--- @param preview UmeGui_Preview
function Module._dress(preview, reward)
	--[[ Local Variables ]]

	local level: number = reward[1]
	local weapon: string = reward[2]
	local variant: string = reward[4]
	local look = LOOKS[variant] --- @type { [string]: any }
	local golden: boolean = variant == "Golden"

	--[[ Texts ]]

	Module._get(preview, "S_Kicker").Text = `Level {level} reward`
	Module._get(preview, "S_OrbLevel").Text = tostring(level)
	Module._get(preview, "S_LevelTagText").Text = `Level {level}`
	Module._get(preview, "S_CardName").Text = weapon
	Module._get(preview, "S_Title").Text = `{variant}!`
	Module._get(preview, "S_Name").Text = `{variant} {weapon} unlocked`
	Module._get(preview, "S_Perk").Text = reward[5]

	--[[ Model ]]

	Module._get(preview, "S_Icon").Image = reward[3]
	Module._showModel(preview, weapon, golden)

	--[[ Colours ]]

	Module._get(preview, "S_Glow").ImageColor3 = look.Accent
	Module._get(preview, "S_Rays").ImageColor3 = look.Rays
	Module._get(preview, "S_RaysBack").ImageColor3 = look.Rays
	Module._get(preview, "S_OrbGlow").ImageColor3 = look.Rays
	Module._get(preview, "S_CardGlow").ImageColor3 = look.Accent
	Module._get(preview, "S_CardStroke").ImageColor3 = look.Accent
	Module._get(preview, "S_OrbGradient").Color = look.Gradient
	Module._get(preview, "S_TitleGradient").Color = look.Gradient
	Module._get(preview, "S_LevelTagGradient").Color = look.Tag
	Module._get(preview, "S_Foil").Visible = not golden
	Module._get(preview, "S_Gold").Visible = golden
end

--%%%%%%%%%%%%%%%%%%%% Show Model

--[[
	Puts the weapon's model (Arsenal's, from the place) in the card's view, framed side on, gilded when Golden the way
	Combat gilds a held Golden weapon; the picture shows instead when the place has no model.
]]
--- @param preview UmeGui_Preview
function Module._showModel(preview, weapon: string, golden: boolean)
	--[[ Local Variables ]]

	local viewport: ViewportFrame = Module._get(preview, "S_Model")
	local assets: Instance? = Workspace:FindFirstChild("ReplicatedStorage_Assets", true)
	local arsenal: Instance? = assets and assets:FindFirstChild("Arsenal")
	local prefab: Model? = arsenal and arsenal:FindFirstChild(weapon, true)

	--[[ Clearing ]]

	viewport:ClearAllChildren()
	viewport.Visible = prefab ~= nil
	Module._get(preview, "S_Icon").Visible = prefab == nil

	--[[ Checks ]]

	-- Check if the place has the weapon's model
	if not prefab then
		return
	end

	--[[ Building ]]

	local model: Model = prefab:Clone()
	model:PivotTo(CFrame.new())
	local box: CFrame
	local size: Vector3
	box, size = model:GetBoundingBox()
	model:PivotTo(CFrame.new(-box.Position) * CFrame.Angles(0, math.rad(MODEL_YAW), 0))
	if golden then
		Module._gild(model)
	end
	model.Parent = viewport

	--[[ Camera ]]

	local reach: number = math.max(size.X, size.Y, size.Z)
	local camera: Camera = Instance.new("Camera")
	camera.FieldOfView = MODEL_FOV
	camera.CFrame = CFrame.lookAt(Vector3.new(0, reach * 0.32, -reach * MODEL_DISTANCE), Vector3.new())
	camera.Parent = viewport
	viewport.CurrentCamera = camera
end

--%%%%%%%%%%%%%%%%%%%% Gild

--[[
	Turns a model gold as Combat's Variants gilds a held Golden weapon: a SurfaceAppearance tinted the bright gold with a
	metal gold copy over its part, GILD_COVER see-through, and a plain part a gold between dark and bright by its brightness.
]]
function Module._gild(model: Model)
	--[[ Gilding ]]

	for _index: number, part: Instance in ipairs(model:GetDescendants()) do
		if not part:IsA("BasePart") or part.Transparency >= 1 then
			continue
		end
		local appearance: SurfaceAppearance? = part:FindFirstChildWhichIsA("SurfaceAppearance")
		if appearance then
			appearance.Color = GILD[2]
			local copy: BasePart = part:Clone()
			copy:ClearAllChildren()
			if copy:IsA("MeshPart") then
				copy.TextureID = ""
			end
			copy.Size *= GILD_GROW
			copy.Color = GILD[2]
			copy.Material = Enum.Material.Metal
			copy.Transparency = GILD_COVER
			copy.CFrame = part.CFrame
			copy.Parent = part.Parent
		else
			local brightness: number = part.Color.R * 0.299 + part.Color.G * 0.587 + part.Color.B * 0.114
			part.Color = GILD[1]:Lerp(GILD[2], brightness)
			part.Material = Enum.Material.Metal
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Moment

--[[
	Holds the unlock still at its charge (the diamond waiting in the dark) or its reveal (everything in).
]]
--- @param preview UmeGui_Preview
function Module._setMoment(preview, revealed: boolean)
	--[[ Applying ]]

	Module._get(preview, "U_Unlock").Visible = true
	Module._get(preview, "S_Shade").BackgroundTransparency = SHADE_REST
	Module._get(preview, "S_Glow").ImageTransparency = if revealed then GLOW_REST else 0.35
	Module._get(preview, "S_Rays").ImageTransparency = if revealed then RAYS_REST else 1
	Module._get(preview, "S_RaysBack").ImageTransparency = if revealed then RAYS_BACK_REST else 1
	Module._get(preview, "S_Orb").Visible = not revealed
	Module._get(preview, "S_OrbScale").Scale = 1.1
	Module._get(preview, "S_OrbGlow").ImageTransparency = 0.15
	Module._get(preview, "S_OrbDiamond").Rotation = 45
	Module._get(preview, "S_CardSlot").Visible = revealed
	Module._get(preview, "S_KickerScale").Scale = 1
	for _index: number, name: string in ipairs({ "S_CardScale", "S_TitleScale", "S_NameScale", "S_PerkScale" }) do
		Module._get(preview, name).Scale = if revealed then 1 else 0
	end
	Module._get(preview, "S_Tap").Visible = revealed
	Module._get(preview, "S_Flash").BackgroundTransparency = 1
end

--%%%%%%%%%%%%%%%%%%%% Burst

--[[
	Throws a burst of stars and a ring of sparks from a point, in the variant's colours, scaled by strength.
]]
--- @param preview UmeGui_Preview
--- @param look { [string]: any }
function Module._burst(preview, point: Vector2, look, unit: number, strength: number)
	--[[ Building ]]

	local stars = Module._newEmitter(preview, {
		Texture = STAR_TEXTURE,
		SizeSpace = "Offset",
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.2, 40 * unit, 14 * unit), NumberSequenceKeypoint.new(1, 0) }),
		Lifetime = NumberRange.new(0.7, 1.5),
		Velocity = NumberRange.new(350 * unit, 1100 * unit),
		SpreadAngle = 360,
		Drag = 1.8,
		RotationSpeed = NumberRange.new(-160, 160),
		CullOffscreen = false,
	}) --- @type UmeGui_UIEmitter_Instance
	local sparks = Module._newEmitter(preview, {
		Texture = SPARK_TEXTURE,
		SizeSpace = "Offset",
		AspectRatio = 3,
		Size = NumberSequence.new(48 * unit, 6 * unit),
		Lifetime = NumberRange.new(0.35, 0.6),
		Velocity = NumberRange.new(1200 * unit, 1700 * unit),
		SpreadAngle = 360,
		Drag = 3,
		FaceMovementDirection = true,
		Color = Color3.fromRGB(255, 255, 255),
		CullOffscreen = false,
	}) --- @type UmeGui_UIEmitter_Instance

	--[[ Emitting ]]

	for _index: number, color: Color3 in ipairs(look.Particles) do
		stars.Color = color
		stars:Emit(math.round(80 * strength / #look.Particles), point)
	end
	sparks:Emit(math.round(36 * strength), point)
end

--%%%%%%%%%%%%%%%%%%%% Start Sparkles

--[[
	Keeps sparkles rising round the card while it shows: gold dust for a Golden reward, pearly twinkles for a Shiny one.
]]
--- @param preview UmeGui_Preview
--- @param look { [string]: any }
function Module._startSparkles(preview, look, unit: number)
	--[[ Building ]]

	local sparkles = Module._newEmitter(preview, {
		Texture = STAR_TEXTURE,
		SizeSpace = "Offset",
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.3, 18 * unit, 6 * unit), NumberSequenceKeypoint.new(1, 0) }),
		Lifetime = NumberRange.new(1.2, 2.2),
		Velocity = NumberRange.new(30 * unit, 90 * unit),
		Direction = Vector2.new(0, -1),
		SpreadAngle = 40,
		RotationSpeed = NumberRange.new(-90, 90),
		EmitterPosition = UDim2.fromScale(0.5, 0.45),
		EmissionShape = "Rectangle",
		EmissionArea = Vector2.new(0.24, 0.42),
		Rate = 14,
		Color = look.Accent,
		CullOffscreen = false,
	}) --- @type UmeGui_UIEmitter_Instance

	--[[ Playing ]]

	sparkles:Play()
end

--%%%%%%%%%%%%%%%%%%%% New Emitter

--[[
	Makes an emitter in the unlock's particle layer, kept so the next play or apply clears it.
]]
--- @param preview UmeGui_Preview
--- @param params { [string]: any }
--- @return UmeGui_UIEmitter_Instance
function Module._newEmitter(preview, params)
	--[[ Library ]]

	-- The mirrored libraries run on UmeGui's I shim; this copy of UmeGui may not have started them
	UIEmitter._injectUme(Runtime)

	--[[ Building ]]

	local fx: Frame = Module._get(preview, "S_Fx")
	params.Parent = fx
	params.Container = fx
	params.Rate = params.Rate or 0
	local emitter = UIEmitter.new(params) --- @type UmeGui_UIEmitter_Instance
	table.insert(emitters, emitter)

	--[[ Returning ]]

	return emitter
end

--%%%%%%%%%%%%%%%%%%%% Clear Emitters

--[[
	Destroys every emitter the last play made, with its particles.
]]
function Module._clearEmitters()
	--[[ Clearing ]]

	--- @param emitter UmeGui_UIEmitter_Instance
	for _index: number, emitter in ipairs(emitters) do
		emitter:Destroy()
	end
	table.clear(emitters)
end

--%%%%%%%%%%%%%%%%%%%% Tween

--[[
	Plays a tween on one instance.
]]
--- @param goal { [string]: any }
function Module._tween(instance: Instance, info: TweenInfo, goal)
	--[[ Playing ]]

	local Step_TweenInfo: TweenInfo = info
	local Step_TweenGoal = goal
	local Step_Tween: Tween = TweenService:Create(instance, Step_TweenInfo, Step_TweenGoal)
	Step_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Reward

--[[
	Returns the reward picked in the preview's settings.
]]
--- @param preview UmeGui_Preview
--- @return { any }
function Module._getReward(preview)
	--[[ Searching ]]

	--- @param reward { any }
	for _index: number, reward in ipairs(REWARDS) do
		if `Lv {reward[1]} {reward[4]} {reward[2]}` == preview.Values.S_Reward then
			return reward
		end
	end

	--[[ Returning ]]

	return REWARDS[#REWARDS]
end

--%%%%%%%%%%%%%%%%%%%% Get

--[[
	Returns the instance of an element of the unlock (U_Unlock itself, or one of its S_ elements).
]]
--- @param preview UmeGui_Preview
--- @return any
function Module._get(preview, name: string)
	--[[ Returning ]]

	if name == "U_Unlock" then
		return preview.View:Get("U_Unlock").Instance
	end
	return preview.View:Get("U_Unlock", name).Instance
end

return Module
