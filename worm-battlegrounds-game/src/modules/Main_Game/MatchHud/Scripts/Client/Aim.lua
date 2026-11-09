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

-- The aim's direction (0 is right, counterclockwise) and power
local angle: number = math.rad(45)
local power: number = 0

-- How the player aims now: "Drag" (mouse or finger held down), "Pad" (right stick and RT), "Lock" (eased onto an aim guide), or nil
local aiming: string? = nil
local padStart: number = 0

-- A right-click lock-on: the angle (X) and power (Y) it eases from, the guide it eases to, and when it started
local lockFrom: Vector2 = Vector2.zero
local lockGuide = nil --- @type Combat_AimGuide?
local lockStart: number = 0

-- Where the mouse or finger last pointed, in screen pixels: the aim points from the snail toward it (nil on a pad)
local pointer: Vector2? = nil

local target: Vector3? = nil
local lastSent: number = 0
local stepConnection: RBXScriptConnection?

-- The item the player last fired, so a click while it rolls blows up a black hole grenade
local firedItem: string? = nil

--[[ Others' Aim ]]

-- The snail whose aim this player watches (the active one, while its aim keeps arriving), and the aim drawn
local watched: Model? = nil
local watchedAngle: number = 0
local watchedPower: number = 0
local watchConnection: RBXScriptConnection?

--[[ Look ]]

local crosshair: Part
local powerDots = {} --- @type { BillboardGui }
local powerSizes = {} --- @type { number }
local targetMarker: Part

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
	elems["PowerBar"] = elems["Power"]:FindFirstChild("S_Bar") --- @type ImageLabel
	elems["Handle"] = elems["Power"]:FindFirstChild("S_Handle") --- @type ImageButton
	elems["Amount"] = elems["Handle"]:FindFirstChild("S_Amount") --- @type TextLabel
	elems["Info"] = elems["Power"]:FindFirstChild("S_Info") --- @type TextLabel
	elems["Fire"] = gui:FindFirstChild("U_Fire", true) --- @type ImageButton
	elems["FireIcon"] = elems["Fire"]:FindFirstChild("S_Icon") --- @type ImageLabel

	--[[ Building ]]

	Module._buildLook(I.Dirs.UmeWorkspace:WaitForChild("Combat"))
	elems["Power"].Visible = false
	elems["Fire"].Visible = false

	--[[ Connections ]]

	I.Interact.OnPress(elems["Fire"], Module._onFirePressed)
	I.S.UserInputService.InputBegan:Connect(Module._onInputBegan)
	I.S.UserInputService.InputChanged:Connect(Module._onInputChanged)
	I.S.UserInputService.InputEnded:Connect(Module._onInputEnded)
	I.Topic.Subscribe("Match_MyTurn", Module._onMyTurn)

	-- Every snail's aim (players' and bots'), to draw its crosshair and power for this player too
	local snailsFolder: Instance = I.Dirs.UmeWorkspace:WaitForChild("Snails")
	snailsFolder.ChildAdded:Connect(Module._watchSnail)
	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		Module._watchSnail(model)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Build Look

--[[
	Makes the crosshair (the studio's picture, CROSSHAIR_IMAGE), the power circles and the homing target marker, hidden.
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
	I.Create("ImageLabel")({
		Name = "Picture",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = _settings.CROSSHAIR_IMAGE,
		Parent = billboard,
	})

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
	the first press, and starts a drag (mouse, finger) or the power bar (RT). With an admin's aim guide showing, a right
	click locks on to it and the next press fires; otherwise right click, Esc and B cancel the aim, and so does a second
	finger (the camera pans).
]]
function Module._onInputBegan(input: InputObject, processed: boolean)
	--[[ Local Variables ]]

	local press: boolean = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch

	--[[ Locking On ]]

	if input.UserInputType == Enum.UserInputType.MouseButton2 and Module._lockOn(Vector2.new(input.Position.X, input.Position.Y)) then
		return
	end

	--[[ Cancelling ]]

	if input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
		Module._cancel()
		return
	end
	if aiming == "Drag" and input.UserInputType == Enum.UserInputType.Touch then
		Module._cancel()
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

	-- A press while locked on fires at the guide's aim, even before the ease reaches it
	if aiming == "Lock" and press then
		angle = lockGuide.Angle
		power = lockGuide.Power or 1
		Module._fire()
		return
	end

	-- Check if the player may shoot now
	if aiming or not I.Match.IsMyTurn() or I.Match.GetPhase() ~= "Turn" then
		return
	end

	--[[ Aiming ]]

	local row = I.G_Arsenal.Get(LoadoutBar.GetSelected()) --- @type Arsenal_WeaponData
	if row.Aim == "Feet" then
		Module._fire()
		return
	end
	if row.Aim == "Target" and not target and press then
		target = Module._getPlanePoint(Vector2.new(input.Position.X, input.Position.Y))
		targetMarker.Position = target
		targetMarker.Transparency = 0.2
		return
	end

	--[[ Starting ]]

	aiming = if press then "Drag" else "Pad"
	if press then
		pointer = Vector2.new(input.Position.X, input.Position.Y)
	end
	padStart = os.clock()
	power = 0
end

--%%%%%%%%%%%%%%%%%%%% On Input Changed

--[[
	Follows the mouse (held or not) and a held finger, which the aim points at every frame (Step), or the right stick's
	direction.
]]
function Module._onInputChanged(input: InputObject, _processed: boolean)
	--[[ Pointing ]]

	if input.UserInputType == Enum.UserInputType.MouseMovement or (aiming == "Drag" and input.UserInputType == Enum.UserInputType.Touch) then
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
	On release: the mouse let go far enough from the snail (closer than MIN_PULL cancels) or RT fires at the aim shown;
	a finger let go keeps its aim and power for the FIRE button. A turn that ended first dropped the aim.
]]
function Module._onInputEnded(input: InputObject, _processed: boolean)
	--[[ Dragging ]]

	if aiming == "Drag" and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		local mine: Model? = I.Snails.GetMine()
		pointer = Vector2.new(input.Position.X, input.Position.Y)
		if not mine or Module._getPull(mine, pointer).Magnitude < _settings.MIN_PULL then
			Module._cancel()
		elseif input.UserInputType == Enum.UserInputType.Touch then
			-- On touch the aim stays until FIRE is pressed or another drag replaces it
			Module._aimAtPointer(mine)
			aiming = nil
		else
			Module._aimAtPointer(mine)
			Module._fire()
		end
		return
	end

	--[[ Pad ]]

	if aiming == "Pad" and input.KeyCode == Enum.KeyCode.ButtonR2 then
		Module._fire()
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Every frame of the player's turn: runs the pad's power bar while RT is held (up to full, back down to none and up
	again, every CHARGE_SECONDS), draws the angle marker and power circles, shows the power on the slider and the angle
	over it (with a homing missile, "Click on a target", then "Shoot!" until the aim starts), the FIRE button on touch
	screens with the held weapon's icon, and sends the aim to the other players every AIM_SEND_INTERVAL.
]]
function Module._step()
	--[[ Checks ]]

	-- Hide the aim between shots and for weapons fired at the feet
	local itemId: string = LoadoutBar.GetSelected()
	local mine: Model? = I.Snails.GetMine()
	if I.Match.GetPhase() ~= "Turn" or not mine or I.G_Arsenal.Get(itemId).Aim == "Feet" then
		Module._cancel()
		Module._hideLook()
		elems["Power"].Visible = false
		elems["Fire"].Visible = false
		return
	end

	--[[ Pointing ]]

	-- Every frame, as the camera and the snail move under a still mouse too; a lock-on ignores the mouse
	if aiming == "Lock" then
		Module._easeLock()
	elseif pointer and aiming ~= "Pad" then
		Module._aimAtPointer(mine)
	end

	--[[ Power Bar ]]

	-- The pad's power bounces between none and full until RT is let go; it never fires by itself
	if aiming == "Pad" then
		local cycle: number = ((os.clock() - padStart) / I.Settings["Combat"].CHARGE_SECONDS) % 2
		power = 1 - math.abs(cycle - 1)
	end

	--[[ Drawing ]]

	Module._draw(mine, angle, power)

	--[[ Slider ]]

	-- The bar's gradient cuts the picture at the power (its fill is BAR_FILL of its width), so it never squashes; the handle rides its edge
	local bar: ImageLabel = elems["PowerBar"]
	local edge: number = math.clamp(power, 0.001, 0.998) * _settings.BAR_FILL
	bar.UIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(edge, 0),
		NumberSequenceKeypoint.new(edge + 0.001, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
	elems["Handle"].Position = UDim2.fromScale(bar.Position.X.Scale + bar.Size.X.Scale * _settings.BAR_FILL * power, elems["Handle"].Position.Y.Scale)
	elems["Amount"].Text = `{math.round(power * 100)}%`
	elems["Info"].Text = `{math.round(math.deg(math.asin(math.sin(angle))))}°`
	elems["Power"].Visible = true
	elems["Fire"].Visible = I.Platform.Current == "Mobile"
	elems["FireIcon"].Image = I.G_Arsenal.Get(itemId).Icon

	-- A homing missile asks for its target first, then to shoot
	if I.G_Arsenal.Get(itemId).Aim == "Target" and not aiming then
		elems["Info"].Text = if target then _settings.TARGET_HINTS.Shoot else _settings.TARGET_HINTS.Pick
	end

	--[[ Sending ]]

	if os.clock() - lastSent >= _settings.AIM_SEND_INTERVAL then
		lastSent = os.clock()
		I.Network.UFire("Combat_Aim", angle, power)
	end
end

--%%%%%%%%%%%%%%%%%%%% Aim At Pointer

--[[
	Points the aim from the player's snail toward the mouse or finger (through the arena's plane, so the crosshair lies
	on the line to it), and while it's held sets the power by how far it is from the snail: none at MIN_PULL, full at
	MAX_PULL.
]]
function Module._aimAtPointer(model: Model)
	--[[ Local Variables ]]

	local toPointer: Vector3 = Module._getPlanePoint(pointer) - model.PrimaryPart.Position
	local pull: number = Module._getPull(model, pointer).Magnitude

	--[[ Checks ]]

	-- Check if it points away from the snail's middle
	if Vector2.new(toPointer.X, toPointer.Y).Magnitude < 1e-3 then
		return
	end

	--[[ Aiming ]]

	angle = math.atan2(toPointer.Y, toPointer.X)
	if aiming == "Drag" then
		power = math.clamp((pull - _settings.MIN_PULL) / (_settings.MAX_PULL - _settings.MIN_PULL), 0, 1)
	end
end

--%%%%%%%%%%%%%%%%%%%% Lock On

--[[
	On the player's turn with an admin's aim guide showing, starts easing the aim onto the guide whose target is nearest
	the mouse on the screen (a homing missile's target becomes that snail). Returns whether it locked on.
]]
--- @return boolean
function Module._lockOn(position: Vector2)
	--[[ Data ]]

	local guides = I.Combat.GetAimGuides() --- @type { Combat_AimGuide }

	--[[ Checks ]]

	-- Check if the player may aim now, with a guide to lock on to
	if #guides == 0 or not I.Match.IsMyTurn() or I.Match.GetPhase() ~= "Turn" then
		return false
	end

	--[[ Picking ]]

	local camera: Camera = I.S.Workspace.CurrentCamera
	local nearest: number = math.huge
	--- @param guide Combat_AimGuide
	for _index: number, guide in ipairs(guides) do
		local screen: Vector3 = camera:WorldToScreenPoint(guide.Target)
		local distance: number = (Vector2.new(screen.X, screen.Y) - position).Magnitude
		if distance < nearest then
			nearest = distance
			lockGuide = guide
		end
	end

	--[[ Locking ]]

	lockFrom = Vector2.new(angle, power)
	lockStart = os.clock()
	aiming = "Lock"
	if I.G_Arsenal.Get(LoadoutBar.GetSelected()).Aim == "Target" then
		target = lockGuide.Target
		targetMarker.Position = target
		targetMarker.Transparency = 0.2
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Ease Lock

--[[
	Moves the aim from where the lock-on started toward its guide's angle and power, easing out over AIMBOT_EASE
	seconds (a gun's guide has no power, so it fills).
]]
function Module._easeLock()
	--[[ Local Variables ]]

	local share: number = math.clamp((os.clock() - lockStart) / _settings.AIMBOT_EASE, 0, 1)
	local eased: number = 1 - (1 - share) ^ 3

	-- The short way round, so a lock across the top never swings through the ground
	local turn: number = (lockGuide.Angle - lockFrom.X + math.pi) % (2 * math.pi) - math.pi

	--[[ Aiming ]]

	angle = lockFrom.X + turn * eased
	power = lockFrom.Y + ((lockGuide.Power or 1) - lockFrom.Y) * eased
end

--%%%%%%%%%%%%%%%%%%%% Draw

--[[
	Puts the crosshair CROSSHAIR_DISTANCE studs from a snail in its aim's direction, turns the held weapon with it, and
	lights as many power circles from the weapon's muzzle toward it as the power fills. Both keep their size on the
	screen whatever the camera's zoom.
]]
function Module._draw(model: Model, aimAngle: number, aimPower: number)
	--[[ Checks ]]

	-- Check if the snail is still in play
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
	local muzzle: Vector3 = I.Combat.GetMuzzle() or center + direction * (I.Settings["Snails"].ROOT_SIZE / 2 + I.Settings["Combat"].MUZZLE_GAP)

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
	Hides the crosshair and the power circles, and hands the held weapon back to the snail's replicated aim.
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
	Sends the shot (Combat_Fire) with the angle, the power and a homing missile's target, ticks a phone or pad, then
	clears the aim.
]]
function Module._fire()
	--[[ Local Variables ]]

	local itemId: string = LoadoutBar.GetSelected()
	local mine: Model? = I.Snails.GetMine()
	local aim: string = I.G_Arsenal.Get(itemId).Aim
	local shotAngle: number = angle
	local shotPower: number = power

	-- A weapon fired at the feet goes the way the snail faces; guns and melee weapons need no power
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

	Module._cancel()
	Module._hideLook()
	target = nil
	targetMarker.Transparency = 1
end

--%%%%%%%%%%%%%%%%%%%% On Fire Pressed

--[[
	The FIRE button (touch screens): fires at the aim shown on the player's turn, once the shot has what it needs (a
	homing missile's target, power for a thrown weapon); not while a finger still drags.
]]
function Module._onFirePressed()
	--[[ Checks ]]

	-- Check if the player may shoot now
	if aiming or not I.Match.IsMyTurn() or I.Match.GetPhase() ~= "Turn" then
		return
	end

	-- Check if the shot has its target and its power
	local aim: string = I.G_Arsenal.Get(LoadoutBar.GetSelected()).Aim
	if (aim == "Target" and not target) or ((aim == "Arc" or aim == "Target") and power <= 0) then
		return
	end

	--[[ Firing ]]

	Module._fire()
end

--%%%%%%%%%%%%%%%%%%%% Cancel

--[[
	Stops aiming without firing, and empties the power. A homing missile's target stays picked.
]]
function Module._cancel()
	--[[ Saving ]]

	aiming = nil
	power = 0
end

--%%%%%%%%%%%%%%%%%%%% On My Turn

--[[
	Shows the angle marker through the player's turn, starting the way their snail faces, and clears it and a picked
	target when the turn ends.
]]
function Module._onMyTurn(myTurn: boolean)
	--[[ Clearing ]]

	Module._cancel()
	Module._hideLook()
	target = nil
	targetMarker.Transparency = 1
	elems["Power"].Visible = false
	elems["Fire"].Visible = false
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

	local mine: Model? = I.Snails.GetMine()
	angle = if mine and mine:GetAttribute("Facing") == -1 then math.rad(135) else math.rad(45)
	firedItem = nil
	Module._stopWatching()
	stepConnection = I.S.RunService.RenderStepped:Connect(Module._step)
end

--%%%%%%%%%%%%%%%%%%%% Watch Snail

--[[
	Listens for a snail's aim stamps (AimTime, which the server sets with each aim update, players' and bots').
]]
function Module._watchSnail(model: Instance)
	--[[ Connections ]]

	model:GetAttributeChangedSignal("AimTime"):Connect(function()
		Module._onOtherAim(model)
	end)
end

--%%%%%%%%%%%%%%%%%%%% On Other Aim

--[[
	Another snail aims: starts drawing its crosshair and power for this player. This player's own snail draws its aim on
	their turn.
]]
function Module._onOtherAim(model: Model)
	--[[ Checks ]]

	-- Skip this player's own snail, and a shot just fired (AimTime 0)
	if model == I.Snails.GetMine() or (model:GetAttribute("AimTime") or 0) == 0 then
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
	Draws the watched snail's crosshair and power, eased toward its latest aim, until its aim stops arriving or the
	player's own turn starts.
]]
function Module._watchStep(deltaTime: number)
	--[[ Checks ]]

	-- Check if the watched snail still aims, with a weapon that has a crosshair
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
	Stops drawing another snail's aim and hides it.
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

--%%%%%%%%%%%%%%%%%%%% Get Pull

--[[
	Returns how far a screen position is from a snail's middle on the screen, in shares of the screen's height (up is
	negative Y), so the power fills at the same distance on a phone and on a big monitor.
]]
--- @return Vector2
function Module._getPull(model: Model, position: Vector2)
	--[[ Local Variables ]]

	local camera: Camera = I.S.Workspace.CurrentCamera
	local center: Vector3 = camera:WorldToScreenPoint(model.PrimaryPart.Position)

	--[[ Returning ]]

	return (position - Vector2.new(center.X, center.Y)) / camera.ViewportSize.Y
end

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
