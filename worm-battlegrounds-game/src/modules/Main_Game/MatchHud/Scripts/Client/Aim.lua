--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
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
local prefabs = {} --- @type { [string]: Instance }

--[[ Aim ]]

-- The aim's direction (0 is right, counterclockwise) and power
local angle: number = math.rad(45)
local power: number = 0

-- How the player aims now: "Charge" (a held press fills the power), "Lock" (eased onto an aim guide), or nil
local aiming: string? = nil

-- The press that charges the shot (the mouse button, a finger on FIRE or RT) and when it started: letting it go fires
local chargeInput: InputObject? = nil
local chargeStart: number = 0

-- A right-click lock-on: the angle (X) and power (Y) it eases from, the guide it eases to, and when it started
local lockFrom: Vector2 = Vector2.zero
local lockGuide = nil --- @type Combat_AimGuide?
local lockStart: number = 0

-- Where the mouse or finger last pointed, in screen pixels: the aim points from the snail toward it (nil on a pad)
local pointer: Vector2? = nil

-- The finger pointing the aim on a touch screen, while it's down
local pointingTouch: InputObject? = nil

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

local crosshairColor: Color3? = nil
local powerDots = {} --- @type { Frame }
local powerSizes = {} --- @type { number }
local powerShares = {} --- @type { number }
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
	elems["Aim"] = gui:FindFirstChild("U_Aim") --- @type Frame
	elems["Crosshair"] = elems["Aim"]:FindFirstChild("S_Crosshair") --- @type Frame
	elems["RingLine"] = elems["Crosshair"]:FindFirstChild("S_RingLine", true) --- @type UIStroke
	elems["ArmA"] = elems["Crosshair"]:FindFirstChild("S_ArmA") --- @type Frame
	elems["ArmB"] = elems["Crosshair"]:FindFirstChild("S_ArmB") --- @type Frame
	prefabs["PowerDot"] = elems["Aim"]:FindFirstChild("PREFAB | PowerDot") --- @type Frame

	--[[ Building ]]

	Module._buildLook(I.Dirs.UmeWorkspace:WaitForChild("Combat"))
	elems["Power"].Visible = false
	elems["Fire"].Visible = false

	--[[ Connections ]]

	elems["Fire"].InputBegan:Connect(Module._onFireBegan)
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
	Makes the power cone's circles from the gui's PREFAB | PowerDot (each later one drawn over the one before, coloured
	dark red to pale yellow) and the homing target marker, hidden.
]]
function Module._buildLook(combatFolder: Instance)
	--[[ Power ]]

	for index: number = 1, _settings.POWER_DOTS do
		--[[ Local Variables ]]

		local along: number = (index - 1) / math.max(_settings.POWER_DOTS - 1, 1)

		--[[ Cloning ]]

		local dot: Frame = prefabs["PowerDot"]:Clone()
		dot.Name = "PowerDot"
		dot.BackgroundColor3 = _settings.POWER_COLORS[1]:Lerp(_settings.POWER_COLORS[2], along)
		dot.ZIndex = index
		dot.Visible = false
		dot.Parent = elems["Aim"]

		--[[ Saving ]]

		powerDots[index] = dot
		powerSizes[index] = _settings.POWER_DOT_SIZE[1] + (_settings.POWER_DOT_SIZE[2] - _settings.POWER_DOT_SIZE[1]) * along
		powerShares[index] = along
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
	A press on the player's turn: the mouse button or RT shoots (Start Shot), and a finger on the arena points the aim
	(a homing missile's first click or tap picks its target instead). With an admin's aim guide showing, a right click
	locks on to it and the next press fires; otherwise right click, Esc and the pad's CancelAim drop the aim, and a second
	finger stops pointing (the camera pans).
]]
function Module._onInputBegan(input: InputObject, processed: boolean)
	--[[ Local Variables ]]

	local press: boolean = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch

	--[[ Locking On ]]

	if input.UserInputType == Enum.UserInputType.MouseButton2 and Module._lockOn(Vector2.new(input.Position.X, input.Position.Y)) then
		return
	end

	--[[ Cancelling ]]

	if input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.Escape or I.Console.IsAction("CancelAim", input.KeyCode) then
		Module._cancel()
		return
	end

	--[[ Checks ]]

	-- Skip presses the guis took (FIRE charges through its own press)
	if processed or not (press or I.Console.IsAction("Fire", input.KeyCode)) then
		return
	end

	-- A second finger moves the camera, so the first stops pointing the aim
	if pointingTouch and input.UserInputType == Enum.UserInputType.Touch then
		pointingTouch = nil
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

	--[[ Target ]]

	-- A homing missile's first click or tap picks its target
	if press and I.G_Arsenal.Get(LoadoutBar.GetSelected()).Aim == "Target" and not target then
		target = Module._getPlanePoint(Vector2.new(input.Position.X, input.Position.Y))
		targetMarker.Position = target
		targetMarker.Transparency = 0.2
		return
	end

	--[[ Pointing ]]

	-- A finger points the aim while it's down; on touch only FIRE shoots
	if input.UserInputType == Enum.UserInputType.Touch then
		pointingTouch = input
		pointer = Vector2.new(input.Position.X, input.Position.Y)
		return
	end

	--[[ Shooting ]]

	Module._startShot(input)
end

--%%%%%%%%%%%%%%%%%%%% On Input Changed

--[[
	Follows the mouse (held or not) and the pointing finger, which the aim points at every frame (Step), or the right
	stick's direction.
]]
function Module._onInputChanged(input: InputObject, _processed: boolean)
	--[[ Pointing ]]

	if input.UserInputType == Enum.UserInputType.MouseMovement or input == pointingTouch then
		pointer = Vector2.new(input.Position.X, input.Position.Y)
		return
	end

	--[[ Stick ]]

	-- The stick moves the camera instead while CameraPan's button is held
	if I.Console.IsAction("Aim", input.KeyCode) and input.Position.Magnitude >= _settings.STICK_DEADZONE and not I.Console.IsHeld("CameraPan") then
		pointer = nil
		angle = math.atan2(input.Position.Y, input.Position.X)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Input Ended

--[[
	On release: the pointing finger leaves the aim where it pointed, and letting go of the press that charges fires the
	shot. A turn that ended first dropped the charge.
]]
function Module._onInputEnded(input: InputObject, _processed: boolean)
	--[[ Pointing ]]

	if input == pointingTouch then
		pointingTouch = nil
		return
	end

	--[[ Firing ]]

	if aiming == "Charge" and Module._isChargeRelease(input) then
		Module._fire()
	end
end

--%%%%%%%%%%%%%%%%%%%% On Fire Began

--[[
	A finger (or the mouse) on the FIRE button, touch screens' way to shoot on the player's turn: a press like the
	mouse button's (Start Shot), so held it charges and letting go anywhere fires. A homing missile needs its target
	first.
]]
function Module._onFireBegan(input: InputObject)
	--[[ Checks ]]

	-- Only a finger or the mouse presses FIRE
	if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end

	-- Check if the player may shoot now
	if aiming or not I.Match.IsMyTurn() or I.Match.GetPhase() ~= "Turn" then
		return
	end

	-- Check if a homing missile has its target
	if I.G_Arsenal.Get(LoadoutBar.GetSelected()).Aim == "Target" and not target then
		return
	end

	--[[ Shooting ]]

	Module._startShot(input)
end

--%%%%%%%%%%%%%%%%%%%% Start Shot

--[[
	Shoots with a press (the mouse button, RT or a finger on FIRE): a weapon fired at the feet, a gun and a melee weapon
	go at once; any other starts charging, its power filling while the press is held (Step).
]]
function Module._startShot(input: InputObject)
	--[[ Firing ]]

	-- Weapons with no power fire on the press
	local aim: string = I.G_Arsenal.Get(LoadoutBar.GetSelected()).Aim
	if aim == "Feet" or aim == "Straight" or aim == "Melee" then
		Module._fire()
		return
	end

	--[[ Charging ]]

	aiming = "Charge"
	chargeInput = input
	chargeStart = os.clock()
	power = 0
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Every frame of the player's turn: fills a held press's power from none to full over Combat's CHARGE_SECONDS and
	fires it at full, draws the crosshair and the power circles, shows the power on the slider and the angle over it
	(with a homing missile, "Click on a target", then "Shoot!" until it charges), the FIRE button on touch screens with
	the held weapon's icon, and sends the aim to the other players every AIM_SEND_INTERVAL.
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
	elseif pointer then
		Module._aimAtPointer(mine)
	end

	--[[ Charging ]]

	-- The power fills at one even rate while the press is held, and a full charge fires by itself
	if aiming == "Charge" then
		power = math.min((os.clock() - chargeStart) / I.Settings["Combat"].CHARGE_SECONDS, 1)
		if power >= 1 then
			Module._fire()
			return
		end
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
	Points the aim from the player's snail toward the mouse or finger, through the arena's plane, so the crosshair lies
	on the line to it.
]]
function Module._aimAtPointer(model: Model)
	--[[ Local Variables ]]

	local toPointer: Vector3 = Module._getPlanePoint(pointer) - model.PrimaryPart.Position

	--[[ Checks ]]

	-- Check if it points away from the snail's middle
	if Vector2.new(toPointer.X, toPointer.Y).Magnitude < 1e-3 then
		return
	end

	--[[ Aiming ]]

	angle = math.atan2(toPointer.Y, toPointer.X)
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
	Draws a snail's aim on the HUD's aim layer, in pixels over the snail: the power's cone of circles along the aim from
	POWER_START (clear of the snail's ball), each growing in as the power fills, then the crosshair past its end,
	spinning, in the snail's colour. Lengths are units, a stud at the match camera's starting distance, so the aim is
	the same on the screen at any zoom. The held weapon turns with the aim at once.
]]
function Module._draw(model: Model, aimAngle: number, aimPower: number)
	--[[ Checks ]]

	-- Check if the snail is still in play
	if not model.PrimaryPart then
		Module._hideLook()
		return
	end

	--[[ Local Variables ]]

	local camera: Camera = I.S.Workspace.CurrentCamera
	local center: Vector3 = model.PrimaryPart.Position
	local color: Color3 = model:GetAttribute("Color") or Color3.new(1, 1, 1)

	-- The snail's middle and the aim's way on the screen, in the aim layer's pixels
	local screenCenter: Vector3 = camera:WorldToScreenPoint(center)
	local screenAhead: Vector3 = camera:WorldToScreenPoint(center + Vector3.new(math.cos(aimAngle), math.sin(aimAngle), 0))
	local origin: Vector2 = Vector2.new(screenCenter.X, screenCenter.Y) - elems["Aim"].AbsolutePosition
	local direction: Vector2 = Vector2.new(screenAhead.X - screenCenter.X, screenAhead.Y - screenCenter.Y).Unit

	-- Pixels in a unit, and in a stud at the snail now (more when zoomed in)
	local tanHalf: number = math.tan(math.rad(camera.FieldOfView) / 2)
	local unit: number = camera.ViewportSize.Y / (2 * I.Settings["MatchCamera"].DISTANCE * tanHalf)
	local stud: number = camera.ViewportSize.Y / (2 * (camera.CFrame.Position - center).Magnitude * tanHalf)

	-- Zoomed in, the cone starts past the snail's grown ball; the crosshair sits past the cone's end
	local first: number = math.max(_settings.POWER_START * unit, (I.Settings["Snails"].ROOT_SIZE / 2 + I.Settings["Combat"].MUZZLE_GAP) * stud)
	local reach: number = first + (_settings.POWER_LENGTH + _settings.POWER_DOT_SIZE[2] / 2 + _settings.POWER_GAP + _settings.CROSSHAIR_SIZE / 2) * unit
	local crosshairAt: Vector2 = origin + direction * reach
	local fill: number = aimPower * #powerDots

	--[[ Weapon ]]

	-- The held weapon turns with this screen's aim at once
	I.Combat.SetAim(aimAngle)

	--[[ Crosshair ]]

	elems["Crosshair"].Position = UDim2.fromOffset(crosshairAt.X, crosshairAt.Y)
	elems["Crosshair"].Size = UDim2.fromOffset(_settings.CROSSHAIR_SIZE * unit, _settings.CROSSHAIR_SIZE * unit)
	elems["Crosshair"].Rotation = os.clock() * _settings.CROSSHAIR_SPIN % 360
	elems["Crosshair"].Visible = true

	-- The aiming snail's colour: its team's, or its own in a free-for-all
	if color ~= crosshairColor then
		crosshairColor = color
		elems["RingLine"].Color = color
		elems["ArmA"].BackgroundColor3 = color
		elems["ArmB"].BackgroundColor3 = color
	end

	--[[ Power ]]

	-- Each circle grows from nothing to its size as the power passes it, so the cone's tip moves every frame
	for index: number, dot: Frame in ipairs(powerDots) do
		local grown: number = math.clamp(fill - (index - 1), 0, 1) * powerSizes[index] * unit
		local at: Vector2 = origin + direction * (first + _settings.POWER_LENGTH * unit * powerShares[index])
		dot.Position = UDim2.fromOffset(at.X, at.Y)
		dot.Size = UDim2.fromOffset(grown, grown)
		dot.Visible = grown > 0
	end
end

--%%%%%%%%%%%%%%%%%%%% Hide Look

--[[
	Hides the crosshair and the power circles, and hands the held weapon back to the snail's replicated aim.
]]
function Module._hideLook()
	--[[ Hiding ]]

	I.Combat.SetAim(nil)

	elems["Crosshair"].Visible = false
	for _index: number, dot: Frame in ipairs(powerDots) do
		dot.Visible = false
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

--%%%%%%%%%%%%%%%%%%%% Cancel

--[[
	Stops aiming without firing, and empties the power. A homing missile's target stays picked.
]]
function Module._cancel()
	--[[ Saving ]]

	aiming = nil
	chargeInput = nil
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

--%%%%%%%%%%%%%%%%%%%% Is Charge Release

--[[
	Returns whether a released input lets go of the press that charges the shot: the same finger, or the same mouse
	button or pad button.
]]
--- @return boolean
function Module._isChargeRelease(input: InputObject)
	return input == chargeInput or (chargeInput ~= nil and input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType == chargeInput.UserInputType and input.KeyCode == chargeInput.KeyCode)
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
