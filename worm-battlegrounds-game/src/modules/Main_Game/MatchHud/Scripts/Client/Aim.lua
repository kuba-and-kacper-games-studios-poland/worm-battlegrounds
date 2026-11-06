--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchHud"

--- @type MatchHud_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local LoadoutBar = require(script.Parent:FindFirstChild("LoadoutBar")) --- @type MatchHud_Client_LoadoutBar

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ Aim ]]

-- The crosshair's direction (0 is right, counterclockwise), and the last screen point the mouse or finger was at
local angle: number = math.rad(45)
local pointer: Vector2? = nil

-- What holds the fire button down: "Mouse", "Touch", "Pad", or nil while not charging
local charging: string? = nil
local chargeStart: number = 0
local power: number = 0

local target: Vector3? = nil
local lastSent: number = 0
local stepConnection: RBXScriptConnection?

-- The item the player last fired, so a click while it rolls blows up a black hole grenade
local firedItem: string? = nil

--[[ Others' Aim ]]

-- The worm whose aim this player watches (the active one, while its aim keeps arriving), and the aim drawn
local watched: Model? = nil
local watchedAngle: number = 0
local watchedPower: number = 0
local watchConnection: RBXScriptConnection?

--[[ Look ]]

local crosshair: Part
local powerDots = {} --- @type { BillboardGui }
local powerSizes = {} --- @type { number }
local targetMarker: Part

-- The power bar's name from the gui ("Power"), written before its percentage
local powerText: string

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

--- @class MatchHud_Client_Aim
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start(gui: ScreenGui)
	--[[ Elements ]]

	elems["Power"] = gui:FindFirstChild("U_Power", true) --- @type Frame
	elems["PowerFill"] = elems["Power"]:FindFirstChild("Fill", true) --- @type Frame
	elems["PowerStatus"] = elems["Power"]:FindFirstChild("Status", true) --- @type TextLabel
	elems["Angle"] = elems["Power"]:FindFirstChild("S_Angle", true) --- @type TextLabel
	powerText = elems["PowerStatus"].Text

	--[[ Building ]]

	Module._buildLook(I.Dirs.UmeWorkspace:WaitForChild("Combat"))
	elems["Power"].Visible = false

	--[[ Connections ]]

	I.S.UserInputService.InputBegan:Connect(Module._onInputBegan)
	I.S.UserInputService.InputChanged:Connect(Module._onInputChanged)
	I.S.UserInputService.InputEnded:Connect(Module._onInputEnded)
	I.Topic.Subscribe("Match_MyTurn", Module._onMyTurn)

	-- Every worm's aim (players' and bots'), to draw its crosshair and power for this player too
	local wormsFolder: Instance = I.Dirs.UmeWorkspace:WaitForChild("Worms")
	wormsFolder.ChildAdded:Connect(Module._watchWorm)
	for _index: number, model: Instance in ipairs(wormsFolder:GetChildren()) do
		Module._watchWorm(model)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Build Look

--[[
	Makes the crosshair, the power circles and the homing target marker, hidden. shortcut: the crosshair is drawn in code
	from frames; swap in a kit picture when the owner draws one.
]]
function Module._buildLook(combatFolder: Instance)
	--[[ Crosshair ]]

	crosshair = I.Create("Part")({
		Name = "AimCrosshair",
		Size = Vector3.one * 0.1,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Transparency = 1,
		Parent = combatFolder,
	})
	local billboard: BillboardGui = I.Create("BillboardGui")({
		Name = "Crosshair",
		-- Sized in studs, so it grows and shrinks with the camera's zoom like the world around it
		Size = UDim2.fromScale(_settings.CROSSHAIR_SIZE, _settings.CROSSHAIR_SIZE),
		AlwaysOnTop = true,
		LightInfluence = 0,
		Enabled = false,
		Parent = crosshair,
	})
	local ring: Frame = I.Create("Frame")({
		Name = "Ring",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.7),
		BackgroundTransparency = 1,
		Parent = billboard,
	})
	I.Create("UICorner")({ CornerRadius = UDim.new(0.5, 0), Parent = ring })
	I.Create("UIStroke")({ Color = _settings.CROSSHAIR_COLOR, Thickness = 3, Parent = ring })
	for _index: number, size: UDim2 in ipairs({ UDim2.new(1, 0, 0, 3), UDim2.new(0, 3, 1, 0) }) do
		I.Create("Frame")({
			Name = "Line",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = size,
			BackgroundColor3 = _settings.CROSSHAIR_COLOR,
			BorderSizePixel = 0,
			Parent = billboard,
		})
	end

	--[[ Power ]]

	-- Flat circles drawn over the arena like the crosshair, sized in studs so they follow the camera's zoom
	local powerFolder: Folder = I.Create("Folder")({ Name = "AimPower", Parent = combatFolder })
	for index: number = 1, _settings.POWER_DOTS do
		local along: number = (index - 1) / math.max(_settings.POWER_DOTS - 1, 1)
		local size: number = _settings.POWER_DOT_SIZE[1] + (_settings.POWER_DOT_SIZE[2] - _settings.POWER_DOT_SIZE[1]) * along
		local holder: Part = I.Create("Part")({
			Name = `Dot{index}`,
			Size = Vector3.one * 0.1,
			Anchored = true,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			Transparency = 1,
			Parent = powerFolder,
		})
		local dot: BillboardGui = I.Create("BillboardGui")({
			Name = "Dot",
			Size = UDim2.fromScale(size, size),
			AlwaysOnTop = true,
			LightInfluence = 0,
			Enabled = false,
			Parent = holder,
		})
		local circle: Frame = I.Create("Frame")({
			Name = "Circle",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = _settings.POWER_COLORS[1]:Lerp(_settings.POWER_COLORS[2], along),
			BorderSizePixel = 0,
			Parent = dot,
		})
		I.Create("UICorner")({ CornerRadius = UDim.new(0.5, 0), Parent = circle })
		powerDots[index] = dot
		powerSizes[index] = size
	end

	--[[ Target ]]

	targetMarker = I.Create("Part")({
		Name = "AimTarget",
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * 1.5,
		Color = _settings.TARGET_COLOR,
		Material = Enum.Material.Neon,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Transparency = 1,
		Parent = combatFolder,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Input Began

--[[
	A press (mouse, finger or RT) on the player's turn: fires a Feet weapon at once, picks a homing missile's target with
	the first press, fires a gun or melee weapon where the crosshair points, and starts charging anything thrown or
	launched. Right click, Esc and B let go of a charge without firing; a second finger cancels it (the camera pans).
]]
function Module._onInputBegan(input: InputObject, processed: boolean)
	--[[ Local Variables ]]

	local press: boolean = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch

	--[[ Cancelling ]]

	if input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
		Module._stopCharging()
		return
	end
	if charging == "Touch" and input.UserInputType == Enum.UserInputType.Touch then
		Module._stopCharging()
		return
	end

	--[[ Checks ]]

	-- Skip presses the guis took
	if processed or not (press or input.KeyCode == Enum.KeyCode.ButtonR2) then
		return
	end

	-- A press while my black hole grenade rolls blows it up
	if firedItem == "BlackHoleGrenade" and I.Match.GetPhase() == "Flight" then
		I.Network.Fire("Combat_Detonate")
		return
	end

	-- Check if the player may shoot now
	if charging or not I.Match.IsMyTurn() or I.Match.GetPhase() ~= "Turn" then
		return
	end

	--[[ Aiming ]]

	local row = I.G_Arsenal.Get(LoadoutBar.GetSelected()) --- @type Arsenal_WeaponData
	if press then
		pointer = Vector2.new(input.Position.X, input.Position.Y)
		Module._aimAtPointer()
	end
	if row.Aim == "Target" and not target and press then
		target = Module._getPlanePoint(Vector2.new(input.Position.X, input.Position.Y))
		targetMarker.Position = target
		targetMarker.Transparency = 0.2
		return
	end
	if row.Aim == "Feet" or row.Aim == "Straight" or row.Aim == "Melee" then
		Module._fire()
		return
	end

	--[[ Charging ]]

	charging = if input.UserInputType == Enum.UserInputType.MouseButton1 then "Mouse" elseif press then "Touch" else "Pad"
	chargeStart = os.clock()
	power = 0
end

--%%%%%%%%%%%%%%%%%%%% On Input Changed

--[[
	The crosshair follows the mouse, a charging finger, or the right stick's direction.
]]
function Module._onInputChanged(input: InputObject, _processed: boolean)
	--[[ Pointer ]]

	if input.UserInputType == Enum.UserInputType.MouseMovement or (charging == "Touch" and input.UserInputType == Enum.UserInputType.Touch) then
		pointer = Vector2.new(input.Position.X, input.Position.Y)
		return
	end

	--[[ Stick ]]

	-- LT with the right stick pans the camera instead
	if input.KeyCode == Enum.KeyCode.Thumbstick2 and input.Position.Magnitude >= _settings.STICK_DEADZONE and not I.S.UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonL2) then
		pointer = nil
		angle = math.atan2(input.Position.Y, input.Position.X)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Input Ended

--[[
	Letting go of the button that charges fires the shot at the power it shows. A turn that ended first dropped the
	charge, so nothing fires.
]]
function Module._onInputEnded(input: InputObject, _processed: boolean)
	--[[ Checks ]]

	-- Check if this is the button that charges
	local released: string? = if input.UserInputType == Enum.UserInputType.MouseButton1
		then "Mouse"
		elseif input.UserInputType == Enum.UserInputType.Touch then "Touch"
		elseif input.KeyCode == Enum.KeyCode.ButtonR2 then "Pad"
		else nil
	if not charging or released ~= charging then
		return
	end

	--[[ Firing ]]

	Module._fire()
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Every frame of the player's turn: points the crosshair at the mouse or finger, charges the power while the button is
	held (up to full, back down to none and up again, every CHARGE_SECONDS), draws the crosshair and power circles,
	shows the power and angle, and sends the aim to the other players every AIM_SEND_INTERVAL.
]]
function Module._step()
	--[[ Checks ]]

	-- Hide the aim between shots and for weapons fired at the feet
	local itemId: string = LoadoutBar.GetSelected()
	local mine: Model? = I.Worms.GetMine()
	if I.Match.GetPhase() ~= "Turn" or not mine or I.G_Arsenal.Get(itemId).Aim == "Feet" then
		Module._stopCharging()
		Module._hideLook()
		elems["Power"].Visible = false
		return
	end

	--[[ Aiming ]]

	Module._aimAtPointer()

	--[[ Charging ]]

	-- The power bounces between none and full until the button is let go; it never fires by itself
	if charging then
		local cycle: number = ((os.clock() - chargeStart) / I.Settings["Combat"].CHARGE_SECONDS) % 2
		power = 1 - math.abs(cycle - 1)
	end

	--[[ Drawing ]]

	Module._draw(mine, angle, power)
	elems["Power"].Visible = true
	elems["PowerFill"].Size = UDim2.fromScale(power, 1)
	elems["PowerStatus"].Text = `{powerText} {math.round(power * 100)}%`
	elems["Angle"].Text = `{math.round(math.deg(math.asin(math.sin(angle))))}°`

	--[[ Sending ]]

	if os.clock() - lastSent >= _settings.AIM_SEND_INTERVAL then
		lastSent = os.clock()
		I.Network.UFire("Combat_Aim", angle, power)
	end
end

--%%%%%%%%%%%%%%%%%%%% Aim At Pointer

--[[
	Turns the crosshair toward the mouse or finger, from wherever the player's worm stands now.
]]
function Module._aimAtPointer()
	--[[ Local Variables ]]

	local mine: Model? = I.Worms.GetMine()

	--[[ Checks ]]

	-- Check if a pointer aims and the worm is still in play
	if not pointer or not mine or not mine.PrimaryPart then
		return
	end

	--[[ Calculating ]]

	local offset: Vector3 = Module._getPlanePoint(pointer) - mine.PrimaryPart.Position
	if offset.Magnitude > 0.5 then
		angle = math.atan2(offset.Y, offset.X)
	end
end

--%%%%%%%%%%%%%%%%%%%% Draw

--[[
	Puts the crosshair CROSSHAIR_DISTANCE studs from a worm in its aim's direction, turns the held weapon with it, and
	lights as many power circles from the weapon's muzzle toward it as the power fills. Both keep their size on the
	screen whatever the camera's zoom.
]]
function Module._draw(model: Model, aimAngle: number, aimPower: number)
	--[[ Checks ]]

	-- Check if the worm is still in play
	if not model.PrimaryPart then
		Module._hideLook()
		return
	end

	--[[ Local Variables ]]

	local direction: Vector3 = Vector3.new(math.cos(aimAngle), math.sin(aimAngle), 0)
	local center: Vector3 = model.PrimaryPart.Position
	local aimPoint: Vector3 = center + direction * _settings.CROSSHAIR_DISTANCE

	-- Sizes are studs at the match camera's starting distance, grown or shrunk with the zoom
	local zoom: number = (I.S.Workspace.CurrentCamera.CFrame.Position - center).Magnitude / I.Settings["MatchCamera"].DISTANCE

	--[[ Weapon ]]

	-- The held weapon turns with this screen's aim at once; without one, the circles start at the old muzzle gap
	I.Combat.SetAim(aimAngle)
	local muzzle: Vector3 = I.Combat.GetMuzzle() or center + direction * (I.Settings["Worms"].ROOT_SIZE / 2 + I.Settings["Combat"].MUZZLE_GAP)

	--[[ Crosshair ]]

	local crosshairGui: BillboardGui = crosshair:FindFirstChild("Crosshair")
	crosshair.Position = aimPoint
	crosshairGui.Size = UDim2.fromScale(_settings.CROSSHAIR_SIZE * zoom, _settings.CROSSHAIR_SIZE * zoom)
	crosshairGui.Enabled = true

	--[[ Power ]]

	local lit: number = math.ceil(aimPower * #powerDots - 0.05)
	for index: number, dot: BillboardGui in ipairs(powerDots) do
		dot.Parent.Position = muzzle:Lerp(aimPoint, index / #powerDots)
		dot.Size = UDim2.fromScale(powerSizes[index] * zoom, powerSizes[index] * zoom)
		dot.Enabled = index <= lit
	end
end

--%%%%%%%%%%%%%%%%%%%% Hide Look

--[[
	Hides the crosshair and the power circles, and hands the held weapon back to the worm's replicated aim.
]]
function Module._hideLook()
	--[[ Hiding ]]

	I.Combat.SetAim(nil)

	crosshair:FindFirstChild("Crosshair").Enabled = false
	for _index: number, dot: BillboardGui in ipairs(powerDots) do
		dot.Enabled = false
	end
end

--%%%%%%%%%%%%%%%%%%%% Fire

--[[
	Sends the shot (Combat_Fire) with the angle, the charged power and a homing missile's target, ticks a phone or pad,
	then clears the charge.
]]
function Module._fire()
	--[[ Local Variables ]]

	local itemId: string = LoadoutBar.GetSelected()
	local mine: Model? = I.Worms.GetMine()
	local aim: string = I.G_Arsenal.Get(itemId).Aim
	local shotAngle: number = angle
	local shotPower: number = power

	-- A weapon fired at the feet goes the way the worm faces; guns and melee weapons need no power
	if aim == "Feet" then
		shotAngle = if mine and mine:GetAttribute("Facing") == -1 then math.pi else 0
		shotPower = 0
	elseif aim == "Straight" or aim == "Melee" then
		shotPower = 1
	end

	--[[ Sending ]]

	I.Network.Fire("Combat_Fire", itemId, shotAngle, shotPower, target)
	I.Haptic.PlayOnce("Combat_Fire")
	firedItem = itemId

	--[[ Clearing ]]

	Module._stopCharging()
	Module._hideLook()
	target = nil
	targetMarker.Transparency = 1
end

--%%%%%%%%%%%%%%%%%%%% Stop Charging

--[[
	Lets go of a charge without firing. A homing missile's target stays picked.
]]
function Module._stopCharging()
	--[[ Saving ]]

	charging = nil
	power = 0
end

--%%%%%%%%%%%%%%%%%%%% On My Turn

--[[
	Shows the crosshair through the player's turn, starting the way their worm faces, and clears it and a picked target
	when the turn ends.
]]
function Module._onMyTurn(myTurn: boolean)
	--[[ Clearing ]]

	Module._stopCharging()
	Module._hideLook()
	target = nil
	targetMarker.Transparency = 1
	elems["Power"].Visible = false
	if stepConnection then
		stepConnection:Disconnect()
		stepConnection = nil
	end

	--[[ Checks ]]

	-- Check if the turn is the player's
	if not myTurn then
		return
	end

	--[[ Starting ]]

	local mine: Model? = I.Worms.GetMine()
	angle = if mine and mine:GetAttribute("Facing") == -1 then math.rad(135) else math.rad(45)
	firedItem = nil
	Module._stopWatching()
	stepConnection = I.S.RunService.RenderStepped:Connect(Module._step)
end

--%%%%%%%%%%%%%%%%%%%% Watch Worm

--[[
	Listens for a worm's aim stamps (AimTime, which the server sets with each aim update, players' and bots').
]]
function Module._watchWorm(model: Instance)
	--[[ Connections ]]

	model:GetAttributeChangedSignal("AimTime"):Connect(function()
		Module._onOtherAim(model)
	end)
end

--%%%%%%%%%%%%%%%%%%%% On Other Aim

--[[
	Another worm aims: starts drawing its crosshair and power for this player. This player's own worm draws its aim on
	their turn.
]]
function Module._onOtherAim(model: Model)
	--[[ Checks ]]

	-- Skip this player's own worm, and a shot just fired (AimTime 0)
	if model == I.Worms.GetMine() or (model:GetAttribute("AimTime") or 0) == 0 then
		return
	end

	--[[ Saving ]]

	if watched ~= model then
		watched = model
		watchedAngle = model:GetAttribute("AimAngle") or 0
		watchedPower = model:GetAttribute("AimPower") or 0
	end

	--[[ Connections ]]

	if not watchConnection then
		watchConnection = I.S.RunService.RenderStepped:Connect(Module._watchStep)
	end
end

--%%%%%%%%%%%%%%%%%%%% Watch Step

--[[
	Draws the watched worm's crosshair and power, eased toward its latest aim, until its aim stops arriving or the
	player's own turn starts.
]]
function Module._watchStep(deltaTime: number)
	--[[ Checks ]]

	-- Check if the watched worm still aims, with a weapon that has a crosshair
	local model: Model? = watched
	local itemId: string? = model and model:GetAttribute("HeldItem")
	local fresh: boolean = model ~= nil and model.Parent ~= nil and I.S.Workspace:GetServerTimeNow() - (model:GetAttribute("AimTime") or 0) <= _settings.AIM_SHOW_GRACE
	if stepConnection or not fresh or not itemId or I.G_Arsenal.Get(itemId).Aim == "Feet" then
		Module._stopWatching()
		return
	end

	--[[ Easing ]]

	local alpha: number = 1 - math.exp(-_settings.AIM_SMOOTHING * deltaTime)
	local turn: number = ((model:GetAttribute("AimAngle") - watchedAngle + math.pi) % (2 * math.pi)) - math.pi
	watchedAngle += turn * alpha
	watchedPower += (model:GetAttribute("AimPower") - watchedPower) * alpha

	--[[ Drawing ]]

	Module._draw(model, watchedAngle, watchedPower)
end

--%%%%%%%%%%%%%%%%%%%% Stop Watching

--[[
	Stops drawing another worm's aim and hides it.
]]
function Module._stopWatching()
	--[[ Checks ]]

	-- Check if an aim is being watched
	if not watchConnection then
		return
	end

	--[[ Saving ]]

	watchConnection:Disconnect()
	watchConnection = nil
	watched = nil

	--[[ Hiding ]]

	Module._hideLook()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Plane Point

--[[
	Returns the point on the arena's plane (Z = 0) under a screen position.
]]
--- @return Vector3
function Module._getPlanePoint(screenPosition: Vector2)
	--[[ Local Variables ]]

	local ray: Ray = I.S.Workspace.CurrentCamera:ScreenPointToRay(screenPosition.X, screenPosition.Y)
	local distance: number = if math.abs(ray.Direction.Z) > 1e-4 then -ray.Origin.Z / ray.Direction.Z else 0

	--[[ Returning ]]

	return ray.Origin + ray.Direction * distance
end

return Module
