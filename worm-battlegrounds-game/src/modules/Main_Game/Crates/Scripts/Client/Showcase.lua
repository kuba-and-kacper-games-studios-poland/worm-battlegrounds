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

--[[ General ]]

local moduleGui: ScreenGui

--[[ State ]]

-- The crate shown, whether a crate is opening (the showcase stands still), and the loop that turns it
local shownCrate: string = ""
local opening: boolean = false
local loop: RBXScriptConnection? = nil

-- The 3D model on the pedestal and the crate it belongs to, and the viewport's camera
local model: Model? = nil
local modelCrate: string = ""
local camera: Camera

-- One ambient emitter per kind, made on first use, and the one playing
local ambients = {} --- @type { [string]: UIEmitter_Instance }
local playing = nil --- @type UIEmitter_Instance?

-- The showcase's own transparencies, put back after an opening
local rest = {} --- @type { [string]: number }

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

--- @class Crates_Client_Showcase
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.GUI_NAME]
	elems["Center"] = moduleGui:FindFirstChild("U_Center", true) --- @type Frame
	elems["Crate"] = elems["Center"]:FindFirstChild("U_Crate", true) --- @type ViewportFrame
	elems["Beam"] = elems["Center"]:FindFirstChild("S_Beam", true) --- @type ImageLabel
	elems["Glow"] = elems["Center"]:FindFirstChild("S_Glow", true) --- @type ImageLabel
	elems["Rays"] = elems["Center"]:FindFirstChild("S_Rays", true) --- @type ImageLabel
	elems["Halo"] = elems["Center"]:FindFirstChild("S_Halo", true) --- @type ImageLabel
	elems["Pedestal"] = elems["Center"]:FindFirstChild("S_Pedestal", true) --- @type ImageLabel
	elems["PedestalRing"] = elems["Center"]:FindFirstChild("S_PedestalRing", true) --- @type ImageLabel
	elems["Particles"] = elems["Center"]:FindFirstChild("S_Particles", true) --- @type Frame
	elems["Tier"] = elems["Center"]:FindFirstChild("S_Tier", true) --- @type Frame
	elems["Plate"] = elems["Center"]:FindFirstChild("S_Plate", true) --- @type Frame
	elems["Backdrop"] = moduleGui:FindFirstChild("U_Backdrop", true) --- @type Frame
	elems["Light"] = elems["Backdrop"]:FindFirstChild("S_Light", true) --- @type ImageLabel
	for _index: number, name: string in ipairs({ "Beam", "Glow", "Rays" }) do
		rest[name] = elems[name].ImageTransparency
	end

	--[[ Camera ]]

	camera = Instance.new("Camera")
	camera.FieldOfView = _settings.SHOWCASE_FOV
	camera.CFrame = CFrame.lookAt(_settings.SHOWCASE_CAMERA, _settings.SHOWCASE_FOCUS)
	camera.Parent = elems["Crate"]
	elems["Crate"].CurrentCamera = camera

	-- The model goes in a WorldModel: moving a part straight in a ViewportFrame redraws every mesh in it
	elems["World"] = Instance.new("WorldModel") --- @type WorldModel
	elems["World"].Parent = elems["Crate"]

	--[[ Connections ]]

	I.Topic.Subscribe("WidgetManager_Opened", Module._onOpened)
	I.Topic.Subscribe("WidgetManager_Closed", Module._onClosed)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% On Opened

--[[
	Turns the showcase while the crates widget is open.
]]
function Module._onOpened(widgetName: string)
	--[[ Checks ]]

	-- Check if it's the crates widget
	if widgetName ~= _settings.GUI_NAME then
		return
	end

	--[[ Looping ]]

	if loop then
		loop:Disconnect()
	end
	loop = I.S.RunService.RenderStepped:Connect(Module._step)
	if playing and not opening then
		playing:Play()
	end
end

--%%%%%%%%%%%%%%%%%%%% On Closed

--[[
	Stops the showcase's loop and ambience when the crates widget closes.
]]
function Module._onClosed(widgetName: string)
	--[[ Checks ]]

	-- Check if it's the crates widget
	if widgetName ~= _settings.GUI_NAME then
		return
	end

	--[[ Stopping ]]

	if loop then
		loop:Disconnect()
		loop = nil
	end
	if playing then
		playing:Stop()
		playing:Clear()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Draw

--[[
	Dresses the showcase in a crate's theme: its 3D model on the pedestal, the glow, rays, beam and pedestal ring in its
	colour, its particles, its name plate and STANDARD or PREMIUM tag, and for the premium crate the halo and the violet
	backdrop. A new crate pops onto the pedestal (with the premium shimmer for the premium crate).
]]
function Module.Draw(crateId: string)
	--[[ Data ]]

	local row = I.G_Crates.Get(crateId) --- @type Crates_CrateData?
	if not row then
		return
	end

	--[[ Local Variables ]]

	local changed: boolean = crateId ~= shownCrate
	local tier: Frame = elems["Tier"]
	local look: string = if row.Premium then "Premium" else "Standard"
	shownCrate = crateId

	--[[ Model ]]

	-- The model follows the crate, but not mid-opening: the crate that leapt off stays until the shop is back
	if crateId ~= modelCrate and not opening then
		modelCrate = crateId
		Module._setModel(row)
	end

	--[[ Colours ]]

	elems["Glow"].ImageColor3 = row.Glow
	elems["Rays"].ImageColor3 = row.Glow
	elems["Beam"].ImageColor3 = row.Glow
	elems["PedestalRing"].ImageColor3 = if row.Premium then row.Accent else row.Glow
	elems["Halo"].Visible = row.Premium and not opening

	--[[ Texts ]]

	tier:FindFirstChild("S_TierText", true).Text = look
	tier:FindFirstChild("S_TierMain", true).ImageColor3 = tier:GetAttribute(`Look_{look}MainColor`)
	tier:FindFirstChild("S_TierStroke", true).ImageColor3 = tier:GetAttribute(`Look_{look}StrokeColor`)
	elems["Plate"]:FindFirstChild("S_Name", true).Text = row.Name

	--[[ Backdrop ]]

	if not opening then
		Module.SetBackdrop(row.Premium)
	end

	--[[ Ambience ]]

	if playing then
		playing:Stop()
	end
	playing = Module._getAmbient(row.Ambient)
	playing.Color = if row.Ambient == "Glints" then Color3.fromRGB(255, 246, 196) else row.Glow
	if loop and not opening then
		playing:Play()
	end

	--[[ Popping ]]

	if changed and not opening then
		Module._pop()
		if row.Premium then
			I.Sound.Play({ Name = "Crate_Premium", SoundGroup = "SFX", Volume = 0.9 })
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Opening

--[[
	While a crate opens the showcase stands still and strips to the crate and its light (no pedestal, plate, tag, halo
	or particles); after, it's dressed again and the crate pops back onto the pedestal.
]]
function Module.SetOpening(isOpening: boolean)
	--[[ Saving ]]

	opening = isOpening

	--[[ Visibility ]]

	for _index: number, name: string in ipairs({ "Pedestal", "PedestalRing", "Tier", "Plate" }) do
		elems[name].Visible = not isOpening
	end
	if isOpening then
		elems["Halo"].Visible = false
		if playing then
			playing:Stop()
			playing:Clear()
		end
		return
	end

	--[[ Restoring ]]

	local crate: ViewportFrame = elems["Crate"]
	crate.ImageTransparency = 0
	crate.Size = UDim2.fromScale(1, 1)
	crate.Position = UDim2.fromScale(0.5, 0.5)
	for _index: number, name: string in ipairs({ "Beam", "Glow", "Rays" }) do
		elems[name].ImageTransparency = rest[name]
	end

	--[[ Drawing ]]

	Module._pop()
	if shownCrate ~= "" then
		Module.Draw(shownCrate)
	end
end

--%%%%%%%%%%%%%%%%%%%% Lift

--[[
	Hands the crate over to the opening: it leaps up off the pedestal and fades as its light goes, while the bought
	crates drop onto the stage.
]]
function Module.Lift()
	--[[ Tweening ]]

	local Lift_TweenInfo: TweenInfo = _settings.SHOWCASE_LIFT_TWEENINFO
	local Lift_TweenGoal = { Position = UDim2.fromScale(0.5, -0.6), ImageTransparency = 1 }
	local Lift_Tween: Tween = I.S.TweenService:Create(elems["Crate"], Lift_TweenInfo, Lift_TweenGoal)
	Lift_Tween:Play()
	for _index: number, name: string in ipairs({ "Beam", "Glow", "Rays" }) do
		local Fade_TweenGoal = { ImageTransparency = 1 }
		local Fade_Tween: Tween = I.S.TweenService:Create(elems[name], Lift_TweenInfo, Fade_TweenGoal)
		Fade_Tween:Play()
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Backdrop

--[[
	Fades the dim behind the screen: the premium crate's violet light, or clear.
]]
function Module.SetBackdrop(premium: boolean)
	--[[ Tweening ]]

	local Backdrop_TweenGoal = {
		BackgroundColor3 = _settings.BACKDROP_PREMIUM_COLOR,
		BackgroundTransparency = if premium then _settings.BACKDROP_PREMIUM_TRANSPARENCY else 1,
	}
	local Backdrop_Tween: Tween = I.S.TweenService:Create(elems["Backdrop"], _settings.BACKDROP_TWEENINFO, Backdrop_TweenGoal)
	Backdrop_Tween:Play()

	local Light_TweenGoal = { ImageTransparency = if premium then _settings.BACKDROP_LIGHT_TRANSPARENCY else 1 }
	local Light_Tween: Tween = I.S.TweenService:Create(elems["Light"], _settings.BACKDROP_TWEENINFO, Light_TweenGoal)
	Light_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Each frame while the widget is open and no crate is opening (the showcase is hidden then): the rays and the halo
	turn, the crate bobs on its pedestal and sways from side to side, and the glow breathes.
]]
function Module._step()
	--[[ Checks ]]

	-- Check if the showcase shows
	if not moduleGui.Enabled or opening then
		return
	end

	--[[ Local Variables ]]

	local now: number = os.clock()
	local wave: number = math.sin(now / _settings.BOB_SECONDS * math.pi * 2)

	--[[ Turning ]]

	elems["Rays"].Rotation = (now / _settings.RAYS_SPIN_SECONDS * 360) % 360
	elems["Halo"].Rotation = (now / _settings.HALO_SPIN_SECONDS * 360) % 360

	--[[ Bobbing ]]

	local sway: number = math.sin(now / _settings.SHOWCASE_SWAY_SECONDS * math.pi * 2)
	elems["Crate"].Position = UDim2.fromScale(0.5, 0.5 - _settings.BOB_HEIGHT * 2.5 * (wave + 1) / 2)
	elems["Glow"].ImageTransparency = rest["Glow"] + 0.08 * (1 - wave) / 2
	if model then
		model:PivotTo(CFrame.Angles(wave * 0.03, _settings.SHOWCASE_YAW + sway * _settings.SHOWCASE_SWAY, 0))
	end
end

--%%%%%%%%%%%%%%%%%%%% Pop

--[[
	Pops the crate onto the pedestal: it grows from small with a bounce.
]]
function Module._pop()
	--[[ Applying ]]

	local crate: ViewportFrame = elems["Crate"]
	crate.Size = UDim2.fromScale(0.6, 0.6)

	--[[ Tweening ]]

	local Pop_TweenInfo: TweenInfo = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local Pop_TweenGoal = { Size = UDim2.fromScale(1, 1) }
	local Pop_Tween: Tween = I.S.TweenService:Create(crate, Pop_TweenInfo, Pop_TweenGoal)
	Pop_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Set Model

--[[
	Puts a crate's 3D model (its row's Model, from ReplicatedStorage_Assets/Crates) on the pedestal in place of the one
	there, its glowing floor in the crate's colour as on the stage.
]]
--- @param row Crates_CrateData
function Module._setModel(row)
	--[[ Clearing ]]

	if model then
		model:Destroy()
		model = nil
	end

	--[[ Checks ]]

	-- Check if the place has the crate's model
	local prefab: Model? = I.Dirs.Assets:FindFirstChild("Crates"):FindFirstChild(row.Model)
	if not prefab then
		warn(`[{_localName}::{script.Name}]: Crate model ({row.Model}) is missing!`)
		return
	end

	--[[ Cloning ]]

	local clone: Model = prefab:Clone()
	clone.Name = "Crate"
	clone:PivotTo(CFrame.Angles(0, _settings.SHOWCASE_YAW, 0))
	clone:FindFirstChild("Inner").Color = row.Glow:Lerp(Color3.new(1, 1, 1), 0.45)
	clone.Parent = elems["World"]
	model = clone
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Ambient

--[[
	Returns the showcase's particles of a kind (embers, glints, bubbles or sparkles), made the first time.
]]
--- @param kind Crates_Ambient
--- @return UIEmitter_Instance
function Module._getAmbient(kind)
	--[[ Checks ]]

	-- Check if it's made already
	if ambients[kind] then
		return ambients[kind]
	end

	--[[ Local Variables ]]

	local textures = _settings.FX_TEXTURES --- @type { [string]: string }
	local size: Vector2 = moduleGui.AbsoluteSize
	local u: number = math.max(0.3, math.min(size.X / 1920, size.Y / 1080))
	local soft: NumberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.15, 0.2), NumberSequenceKeypoint.new(0.8, 0.3), NumberSequenceKeypoint.new(1, 1) })
	local twinkle: NumberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 22 * u, 6 * u), NumberSequenceKeypoint.new(1, 0) })
	local params = {
		Parent = elems["Particles"],
		Rate = 14,
		SizeSpace = "Offset",
		EmitterPosition = UDim2.fromScale(0.5, 0.72),
		EmissionShape = "Rectangle",
		EmissionArea = Vector2.new(0.36, 0.04),
		Direction = Vector2.new(0, -1),
		SpreadAngle = 25,
		Transparency = soft,
	} --- @type { [string]: any }

	--[[ Building ]]

	if kind == "Embers" then
		params.Texture = textures.Glow
		params.Rate = 16
		params.Size = NumberRange.new(6 * u, 12 * u)
		params.Velocity = NumberRange.new(30 * u, 80 * u)
		params.Lifetime = NumberRange.new(2, 3.4)
		params.ShakeSpeed = NumberRange.new(8 * u, 20 * u)
	elseif kind == "Bubbles" then
		params.Texture = textures.Bubble
		params.Rate = 9
		params.Size = NumberRange.new(10 * u, 22 * u)
		params.Velocity = NumberRange.new(35 * u, 70 * u)
		params.Lifetime = NumberRange.new(2.6, 4)
		params.ShakeSpeed = NumberRange.new(10 * u, 24 * u)
	else
		params.Texture = textures.Star
		params.Rate = if kind == "Glints" then 9 else 10
		params.EmitterPosition = UDim2.fromScale(0.5, 0.42)
		params.EmissionArea = Vector2.new(0.44, 0.44)
		params.Size = twinkle
		params.Velocity = NumberRange.new(4 * u, 14 * u)
		params.Lifetime = NumberRange.new(0.8, 1.5)
		params.RotationSpeed = NumberRange.new(-40, 40)
		params.Transparency = 0
	end
	ambients[kind] = I.UIEmitter.new(params)

	--[[ Returning ]]

	return ambients[kind]
end

return Module
