--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Progression"

--- @type Progression_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: any }

--[[ Effects ]]

-- The emitters the unlock showing now made, cleared when it closes
local emitters = {} --- @type { UIEmitter_Instance }

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

--- @class Progression_Client_Unlock
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	--[[ Elements ]]

	local unlock: Frame = I.UserInterface.UI["LevelPlate"]:FindFirstChild("U_Unlock")
	elems["Unlock"] = unlock
	for _index: number, name: string in ipairs({
		"S_Shade",
		"S_Glow",
		"S_Rays",
		"S_RaysBack",
		"S_Kicker",
		"S_KickerScale",
		"S_Orb",
		"S_OrbScale",
		"S_OrbGlow",
		"S_OrbDiamond",
		"S_OrbGradient",
		"S_OrbLevel",
		"S_CardSlot",
		"S_CardScale",
		"S_CardGlow",
		"S_CardStroke",
		"S_Foil",
		"S_Gold",
		"S_Model",
		"S_Icon",
		"S_CardName",
		"S_LevelTagText",
		"S_LevelTagGradient",
		"S_Title",
		"S_TitleGradient",
		"S_TitleScale",
		"S_Name",
		"S_NameScale",
		"S_Perk",
		"S_PerkScale",
		"S_Tap",
		"S_Fx",
		"S_Flash",
	}) do
		elems[name] = unlock:FindFirstChild(name, true)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	**CLIENT** |
	Plays a level's weapon reward over the replay and returns once the player taps it away: the dark and the glow come
	in, the level's diamond pops up and charges (rattling, swelling, light flying into it), flashes open into the
	weapon's card on turning rays with a burst, SHINY! or GOLDEN! slams in, then the name, its line and TAP TO CONTINUE,
	with sparkles rising round the card.
]]
function Module.Play(level: number)
	--[[ Data ]]

	--- @type Progression_WeaponReward?
	local reward = _settings.WEAPON_REWARDS[level]

	--[[ Checks ]]

	-- Check if the level opens a weapon's look
	if not reward then
		return
	end

	--[[ Local Variables ]]

	local look = _settings.UNLOCK_LOOKS[reward.Variant] --- @type Progression_UnlockLook
	local unit: number = elems["S_Fx"].AbsoluteSize.Y / 1080
	local diamond: Frame = elems["S_OrbDiamond"]

	--[[ Opening ]]

	Module._dress(level, reward, look)
	Module._reset()
	elems["Unlock"].Visible = true
	Module._tween(elems["S_Shade"], _settings.UNLOCK_FADE_TWEENINFO, { BackgroundTransparency = _settings.UNLOCK_SHADE })
	Module._tween(elems["S_Glow"], _settings.UNLOCK_FADE_TWEENINFO, { ImageTransparency = 0.6 })
	task.wait(0.25)

	--[[ Diamond ]]

	elems["S_Orb"].Visible = true
	Module._tween(elems["S_OrbScale"], _settings.UNLOCK_POP_TWEENINFO, { Scale = 1 })
	Module._tween(elems["S_KickerScale"], _settings.UNLOCK_POP_TWEENINFO, { Scale = 1 })
	I.Sound.Play({ Name = "Crate_GoldHit", SoundGroup = "UI" })
	task.wait(0.55)

	--[[ Charging ]]

	-- Light flies into the diamond faster and faster while it rattles harder and swells
	I.Sound.Play({ Name = "Crate_Shake", SoundGroup = "UI" })
	local inward = Module._newEmitter({
		Texture = _settings.REPLAY_TEXTURES.Spark,
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
	})
	local centre: Vector2 = diamond.AbsolutePosition + diamond.AbsoluteSize / 2
	local start: number = os.clock()
	while os.clock() - start < _settings.UNLOCK_CHARGE_SECONDS do
		local now: number = os.clock()
		local through: number = (now - start) / _settings.UNLOCK_CHARGE_SECONDS
		diamond.Rotation = 45 + math.sin(now * 55) * (2 + _settings.UNLOCK_RATTLE_DEGREES * through)
		elems["S_OrbScale"].Scale = 1 + 0.2 * through + math.sin(now * 31) * 0.025 * through
		elems["S_OrbGlow"].ImageTransparency = 0.35 - 0.33 * through
		elems["S_OrbGlow"].Size = UDim2.fromScale(2.4 + 1.8 * through, 2.4 + 1.8 * through)
		elems["S_Glow"].ImageTransparency = 0.6 - 0.45 * through
		elems["S_Rays"].ImageTransparency = 1 - 0.3 * through
		local angle: number = math.random() * math.pi * 2
		local reach: number = (260 + math.random() * 160) * unit
		inward:Emit(if through > 0.6 then 3 else 1, centre + Vector2.new(math.cos(angle), math.sin(angle)) * reach)
		I.S.RunService.Heartbeat:Wait()
	end

	--[[ Flash ]]

	I.Sound.Play({ Name = "Crate_Land", SoundGroup = "UI" })
	elems["S_Flash"].BackgroundTransparency = 0
	Module._tween(elems["S_Flash"], _settings.UNLOCK_FLASH_TWEENINFO, { BackgroundTransparency = 1 })
	elems["S_Orb"].Visible = false
	Module._tween(elems["S_Rays"], _settings.UNLOCK_FADE_TWEENINFO, { ImageTransparency = _settings.UNLOCK_RAYS })
	Module._tween(elems["S_RaysBack"], _settings.UNLOCK_FADE_TWEENINFO, { ImageTransparency = _settings.UNLOCK_RAYS_BACK })
	Module._tween(elems["S_Glow"], _settings.UNLOCK_FADE_TWEENINFO, { ImageTransparency = _settings.UNLOCK_GLOW })

	--[[ Card ]]

	elems["S_CardSlot"].Visible = true
	elems["S_CardScale"].Scale = 0.35
	Module._tween(elems["S_CardScale"], _settings.UNLOCK_CARD_TWEENINFO, { Scale = 1 })
	Module._burst(centre, look, unit, 1)
	task.wait(0.5)

	--[[ Title ]]

	elems["S_TitleScale"].Scale = 2.6
	Module._tween(elems["S_TitleScale"], _settings.UNLOCK_SLAM_TWEENINFO, { Scale = 1 })
	task.wait(_settings.UNLOCK_SLAM_TWEENINFO.Time * 0.6)
	I.Sound.Play({ Name = look.Sound, SoundGroup = "SFX" })
	elems["S_CardScale"].Scale = 1.06
	Module._tween(elems["S_CardScale"], _settings.UNLOCK_FADE_TWEENINFO, { Scale = 1 })
	Module._burst(elems["S_Title"].AbsolutePosition + elems["S_Title"].AbsoluteSize / 2, look, unit, 0.45)

	--[[ Lines ]]

	task.wait(0.2)
	Module._tween(elems["S_NameScale"], _settings.UNLOCK_POP_TWEENINFO, { Scale = 1 })
	task.wait(0.12)
	Module._tween(elems["S_PerkScale"], _settings.UNLOCK_POP_TWEENINFO, { Scale = 1 })
	task.wait(0.6)
	elems["S_Tap"].Visible = true

	--[[ Sparkles ]]

	local sparkles = Module._newEmitter({
		Texture = _settings.REPLAY_TEXTURES.Star,
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
		Rate = _settings.UNLOCK_SPARKLE_RATE,
		Color = look.Accent,
		CullOffscreen = false,
	})
	sparkles:Play()

	--[[ Waiting ]]

	Module._waitForTap()

	--[[ Closing ]]

	Module._close()
end

--%%%%%%%%%%%%%%%%%%%% Dress

--[[
	Dresses the unlock for a level's reward: its texts, the weapon's model (or picture) on the card, the variant's
	colours on the light, the card, the diamond, the title and the level tag, and the foil or the gold rim.
]]
--- @param reward Progression_WeaponReward
--- @param look Progression_UnlockLook
function Module._dress(level: number, reward, look)
	--[[ Data ]]

	--- @type Arsenal_WeaponData
	local weapon = I.G_Arsenal.Get(reward.Item)

	--[[ Texts ]]

	elems["S_Kicker"].Text = `Level {level} reward`
	elems["S_OrbLevel"].Text = tostring(level)
	elems["S_LevelTagText"].Text = `Level {level}`
	elems["S_CardName"].Text = weapon.Name
	elems["S_Title"].Text = `{reward.Variant}!`
	elems["S_Name"].Text = `{reward.Variant} {weapon.Name} unlocked`
	elems["S_Perk"].Text = reward.Line

	--[[ Model ]]

	elems["S_Icon"].Image = weapon.Icon
	Module._showModel(reward.Item, reward.Variant == "Golden")

	--[[ Colours ]]

	elems["S_Glow"].ImageColor3 = look.Accent
	elems["S_Rays"].ImageColor3 = look.Rays
	elems["S_RaysBack"].ImageColor3 = look.Rays
	elems["S_OrbGlow"].ImageColor3 = look.Rays
	elems["S_CardGlow"].ImageColor3 = look.Accent
	elems["S_CardStroke"].ImageColor3 = look.Accent
	elems["S_OrbGradient"].Color = look.Gradient
	elems["S_TitleGradient"].Color = look.Gradient
	elems["S_LevelTagGradient"].Color = look.Tag
	elems["S_Foil"].Visible = reward.Variant == "Shiny"
	elems["S_Gold"].Visible = reward.Variant == "Golden"
end

--%%%%%%%%%%%%%%%%%%%% Reset

--[[
	Puts every part of the unlock where its opening starts: everything see-through, scaled to nothing or hidden.
]]
function Module._reset()
	--[[ Applying ]]

	elems["S_Shade"].BackgroundTransparency = 1
	elems["S_Glow"].ImageTransparency = 1
	elems["S_Rays"].ImageTransparency = 1
	elems["S_RaysBack"].ImageTransparency = 1
	elems["S_Orb"].Visible = false
	elems["S_OrbScale"].Scale = 0
	elems["S_OrbGlow"].ImageTransparency = 0.35
	elems["S_OrbGlow"].Size = UDim2.fromScale(2.4, 2.4)
	elems["S_OrbDiamond"].Rotation = 45
	elems["S_CardSlot"].Visible = false
	elems["S_CardScale"].Scale = 0
	elems["S_KickerScale"].Scale = 0
	elems["S_TitleScale"].Scale = 0
	elems["S_NameScale"].Scale = 0
	elems["S_PerkScale"].Scale = 0
	elems["S_Tap"].Visible = false
	elems["S_Flash"].BackgroundTransparency = 1
end

--%%%%%%%%%%%%%%%%%%%% Close

--[[
	Fades the unlock away, then hides it and clears its particles and model.
]]
function Module._close()
	--[[ Fading ]]

	local Close_TweenInfo: TweenInfo = _settings.PLATE_BACK_TWEENINFO
	Module._tween(elems["S_Shade"], Close_TweenInfo, { BackgroundTransparency = 1 })
	Module._tween(elems["S_Glow"], Close_TweenInfo, { ImageTransparency = 1 })
	Module._tween(elems["S_Rays"], Close_TweenInfo, { ImageTransparency = 1 })
	Module._tween(elems["S_RaysBack"], Close_TweenInfo, { ImageTransparency = 1 })
	for _index: number, name: string in ipairs({ "S_CardScale", "S_KickerScale", "S_TitleScale", "S_NameScale", "S_PerkScale" }) do
		Module._tween(elems[name], Close_TweenInfo, { Scale = 0 })
	end
	elems["S_Tap"].Visible = false
	task.wait(Close_TweenInfo.Time)

	--[[ Clearing ]]

	--- @param emitter UIEmitter_Instance
	for _index: number, emitter in ipairs(emitters) do
		emitter:Destroy()
	end
	table.clear(emitters)
	elems["S_Model"]:ClearAllChildren()
	elems["Unlock"].Visible = false
end

--%%%%%%%%%%%%%%%%%%%% Show Model

--[[
	Puts the weapon's model in the card's view, framed side on and gilded when Golden (Arsenal's Gild, as Combat gilds a held one); the
	picture shows instead when it has no model.
]]
function Module._showModel(itemId: string, golden: boolean)
	--[[ Local Variables ]]

	local viewport: ViewportFrame = elems["S_Model"]
	local prefab: Model? = I.G_Arsenal.GetModel(itemId)

	--[[ Clearing ]]

	viewport:ClearAllChildren()
	viewport.Visible = prefab ~= nil
	elems["S_Icon"].Visible = prefab == nil

	--[[ Checks ]]

	-- Check if the weapon has a model
	if not prefab then
		return
	end

	--[[ Building ]]

	local model: Model = prefab:Clone()
	model:PivotTo(CFrame.new())
	local box: CFrame
	local size: Vector3
	box, size = model:GetBoundingBox()
	model:PivotTo(CFrame.new(-box.Position) * CFrame.Angles(0, math.rad(_settings.UNLOCK_MODEL_YAW), 0))
	if golden then
		local parts = {} --- @type { BasePart }
		for _index: number, part: Instance in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") and part.Transparency < 1 then
				table.insert(parts, part)
			end
		end
		I.G_Arsenal.Gild(parts, _settings.UNLOCK_GILD[1], _settings.UNLOCK_GILD[2], _settings.UNLOCK_GILD_COVER, _settings.UNLOCK_GILD_GROW)
	end
	model.Parent = viewport

	--[[ Camera ]]

	local reach: number = math.max(size.X, size.Y, size.Z)
	local camera: Camera = I.Create("Camera")({
		FieldOfView = _settings.UNLOCK_MODEL_FOV,
		CFrame = CFrame.lookAt(Vector3.new(0, reach * 0.32, -reach * _settings.UNLOCK_MODEL_DISTANCE), Vector3.new()),
		Parent = viewport,
	})
	viewport.CurrentCamera = camera
end

--%%%%%%%%%%%%%%%%%%%% Burst

--[[
	Throws a burst of stars in the variant's colours and a ring of white sparks from a point, scaled by strength.
]]
--- @param look Progression_UnlockLook
function Module._burst(point: Vector2, look, unit: number, strength: number)
	--[[ Building ]]

	local stars = Module._newEmitter({
		Texture = _settings.REPLAY_TEXTURES.Star,
		SizeSpace = "Offset",
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.2, 40 * unit, 14 * unit), NumberSequenceKeypoint.new(1, 0) }),
		Lifetime = NumberRange.new(0.7, 1.5),
		Velocity = NumberRange.new(350 * unit, 1100 * unit),
		SpreadAngle = 360,
		Drag = 1.8,
		RotationSpeed = NumberRange.new(-160, 160),
		CullOffscreen = false,
	})
	local sparks = Module._newEmitter({
		Texture = _settings.REPLAY_TEXTURES.Spark,
		SizeSpace = "Offset",
		AspectRatio = 3,
		Size = NumberSequence.new(48 * unit, 6 * unit),
		Lifetime = NumberRange.new(0.35, 0.6),
		Velocity = NumberRange.new(1200 * unit, 1700 * unit),
		SpreadAngle = 360,
		Drag = 3,
		FaceMovementDirection = true,
		Color = Color3.new(1, 1, 1),
		CullOffscreen = false,
	})

	--[[ Emitting ]]

	for _index: number, color: Color3 in ipairs(look.Particles) do
		stars.Color = color
		stars:Emit(math.round(_settings.UNLOCK_STARS * strength / #look.Particles), point)
	end
	sparks:Emit(math.round(_settings.UNLOCK_SPARKS * strength), point)
end

--%%%%%%%%%%%%%%%%%%%% New Emitter

--[[
	Makes an emitter in the unlock's particle layer, kept so closing clears it.
]]
--- @param params { [string]: any }
--- @return UIEmitter_Instance
function Module._newEmitter(params)
	--[[ Building ]]

	params.Parent = elems["S_Fx"]
	params.Container = elems["S_Fx"]
	params.Rate = params.Rate or 0
	local emitter = I.UIEmitter.new(params) --- @type UIEmitter_Instance
	table.insert(emitters, emitter)

	--[[ Returning ]]

	return emitter
end

--%%%%%%%%%%%%%%%%%%%% Wait For Tap

--[[
	Waits for a click, a tap or A.
]]
function Module._waitForTap()
	--[[ Waiting ]]

	local tapped: boolean = false
	local connection: RBXScriptConnection = I.S.UserInputService.InputBegan:Connect(function(input: InputObject)
		local press: boolean = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA
		tapped = tapped or press
	end)
	while not tapped do
		task.wait()
	end
	connection:Disconnect()
	I.Sound.Play({ Name = "Button_Click", SoundGroup = "UI" })
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
	local Step_Tween: Tween = I.S.TweenService:Create(instance, Step_TweenInfo, Step_TweenGoal)
	Step_Tween:Play()
end

return Module
