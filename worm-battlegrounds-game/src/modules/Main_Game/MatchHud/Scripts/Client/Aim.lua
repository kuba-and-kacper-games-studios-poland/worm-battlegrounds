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

--[[ Aim ]]

-- The aim's direction (0 is right, counterclockwise) and power; no aim while `aimed` is false (cleared, or not set yet)
local angle: number = math.rad(45)
local power: number = 0
local aimed: boolean = false

-- Whether the player has aimed on this turn (a drag let go, or the stick), for the tutorial's guide
local aimedThisTurn: boolean = false

-- Each snail's last aim (by participant id), kept into its next turn
local aims = {} --- @type { [string]: Vector2 }

-- The press dragging the aim (the mouse button or a finger)
local dragInput: InputObject? = nil

-- The finger placing a homing missile's target, while it's down
local targetTouch: InputObject? = nil

--[[
	The right stick's lean (the Console module's Aim), and whether it waits to come back to the middle before it aims
	again (it moved the camera)
]]
local stick: Vector2 = Vector2.zero
local stickLocked: boolean = false

local target: Vector3? = nil
local targetPlacedAt: number = 0
local lastSent: number = 0
local stepConnection: RBXScriptConnection?

-- The item the player last fired, so a press while it rolls blows up a black hole grenade
local firedItem: string? = nil

-- The angle of the shot just sent, while the server hasn't moved the match on: no aim shows, nothing fires again
local firedAngle: number? = nil
local firedAt: number = 0

--[[ Others' Aim ]]

-- The snail whose aim this player watches (the active one, while its aim keeps arriving), and the aim drawn
local watched: Model? = nil
local watchedAngle: number = 0
local watchedPower: number = 0
local watchConnection: RBXScriptConnection?

--[[ Look ]]

local crosshairColor: Color3? = nil

-- The preview's dots along the start of the path (PREFAB | AimDot), from the snail out
local previewDots = {} --- @type { Frame }

--[[ Prediction ]]

-- The prediction's path dots (the aimbot's) and the dot where it lands, the shot raycasts (a shot's own collision group), and the power last fired
local predictionDots = {} --- @type { Part }
local predictionEnd: Part
local predictionParams: RaycastParams
local lastPower: number = 0

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Power Color

--[[
	Returns the power's colour at a share of full power (0 none, 1 full), between the two POWER_COLORS it falls between.
]]
local function getPowerColor(share: number): Color3
	--[[ Local Variables ]]

	local colors = _settings.POWER_COLORS --- @type { Color3 }
	local at: number = math.clamp(share, 0, 1) * (#colors - 1)
	local from: number = math.min(math.floor(at) + 1, #colors - 1)

	--[[ Returning ]]

	return colors[from]:Lerp(colors[from + 1], at - (from - 1))
end

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

	elems["Fire"] = gui:FindFirstChild("U_Fire", true) --- @type ImageButton
	elems["Retarget"] = elems["Fire"]:FindFirstChild("U_Retarget") --- @type ImageButton
	elems["Aim"] = gui:FindFirstChild("U_Aim") --- @type Frame
	elems["Crosshair"] = elems["Aim"]:FindFirstChild("S_Crosshair") --- @type Frame
	elems["RingLine"] = elems["Crosshair"]:FindFirstChild("S_RingLine", true) --- @type UIStroke
	elems["ArmA"] = elems["Crosshair"]:FindFirstChild("S_ArmA") --- @type Frame
	elems["ArmB"] = elems["Crosshair"]:FindFirstChild("S_ArmB") --- @type Frame
	elems["PowerRing"] = elems["Aim"]:FindFirstChild("S_PowerRing") --- @type Frame
	elems["Wedge"] = elems["Aim"]:FindFirstChild("S_PowerWedge") --- @type Frame
	elems["WedgeTop"] = elems["Wedge"]:FindFirstChild("S_WedgeTop") --- @type Frame
	elems["WedgeBottom"] = elems["Wedge"]:FindFirstChild("S_WedgeBottom") --- @type Frame
	elems["Readout"] = elems["Aim"]:FindFirstChild("S_Readout") --- @type TextLabel
	elems["TargetMark"] = elems["Aim"]:FindFirstChild("S_TargetMark") --- @type Frame
	elems["TargetBrackets"] = elems["TargetMark"]:FindFirstChild("S_TargetBrackets") --- @type Frame

	--[[ Building ]]

	Module._buildLook(I.Dirs.UmeWorkspace:WaitForChild("Combat"))
	elems["Fire"].Visible = false
	local dotPrefab: Frame = elems["Aim"]:FindFirstChild("PREFAB | AimDot")
	for index: number = 1, _settings.PREVIEW_DOTS do
		local dot: Frame = dotPrefab:Clone()
		dot.Name = "AimDot"
		dot.Parent = elems["Aim"]
		previewDots[index] = dot
	end

	--[[ Connections ]]

	elems["Fire"].Activated:Connect(Module._fire)
	elems["Retarget"].Activated:Connect(Module._clearTarget)
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
	Makes the prediction's dots (the aimbot's).
]]
function Module._buildLook(combatFolder: Instance)
	--[[ Prediction ]]

	for index: number = 1, _settings.PREDICTION_DOTS do
		predictionDots[index] = Module._makeDot("PredictionDot", _settings.PREDICTION_DOT_SIZE, _settings.PREDICTION_COLOR, combatFolder)
	end
	predictionEnd = Module._makeDot("PredictionEnd", _settings.PREDICTION_END_SIZE, _settings.PREDICTION_END_COLOR, combatFolder)
	predictionParams = RaycastParams.new()
	predictionParams.CollisionGroup = "Projectile"
	predictionParams.FilterType = Enum.RaycastFilterType.Exclude
	lastPower = _settings.PREDICTION_IDLE_POWER
end

--%%%%%%%%%%%%%%%%%%%% Make Dot

--[[
	Returns a hidden neon ball for the prediction line.
]]
--- @return Part
function Module._makeDot(name: string, size: number, color: Color3, parent: Instance)
	return I.Create("Part")({
		Name = name,
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * size,
		Color = color,
		Material = Enum.Material.Neon,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
		Transparency = 1,
		Parent = parent,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Input Began

--[[
	A press on the player's turn: the mouse button or a finger anywhere on the arena starts dragging the aim (a utility
	the snail holds is used instead, and a homing missile's first press places its target); FIRE_KEYS and the pad's RT
	fire the locked aim. Esc and the pad's CancelAim clear the aim, and a second finger stops the drag (the camera pans).
]]
function Module._onInputBegan(input: InputObject, processed: boolean)
	--[[ Local Variables ]]

	local press: boolean = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch

	--[[ Clearing ]]

	if input.KeyCode == Enum.KeyCode.Escape or I.Console.IsAction("CancelAim", input.KeyCode) then
		Module._clearAim()
		return
	end

	--[[ Firing ]]

	if not processed and (table.find(_settings.FIRE_KEYS, input.KeyCode) or I.Console.IsAction("Fire", input.KeyCode)) then
		Module._fire()
		return
	end

	--[[ Checks ]]

	-- Skip presses the guis took (FIRE, the weapon bar)
	if processed or not press then
		return
	end

	-- A second finger moves the camera, so the first stops dragging the aim
	if (dragInput or targetTouch) and input.UserInputType == Enum.UserInputType.Touch then
		Module._endDrag()
		targetTouch = nil
		return
	end

	-- A press while my black hole grenade rolls blows it up
	if firedItem == "BlackHoleGrenade" and I.Match.GetPhase() == "Flight" then
		I.Network.Fire("Combat_Detonate")
		return
	end

	-- Check if the player may aim now, with a weapon that has uses left and isn't cooling down
	if firedAngle or not I.Match.IsMyTurn() or I.Match.GetPhase() ~= "Turn" or not LoadoutBar.IsReady(LoadoutBar.GetSelected()) then
		return
	end

	--[[ Using ]]

	-- A utility in the snail's hands (a Medkit, a potion) is used by any press on the screen, a finger's too
	local itemId: string = LoadoutBar.GetSelected()
	if I.G_Arsenal.IsUtility(itemId) then
		LoadoutBar.UseHeld()
		return
	end

	--[[ Target ]]

	-- A homing missile's first press locks its target where it lands (a finger drags it until it lifts); later presses aim its launch
	local aimKind: string = I.G_Arsenal.Get(itemId).Aim
	if aimKind == "Target" and not target then
		Module._setTarget(Module._getPlanePoint(Vector2.new(input.Position.X, input.Position.Y)))
		targetTouch = if input.UserInputType == Enum.UserInputType.Touch then input else nil
		return
	end

	--[[ Dragging ]]

	-- A weapon placed at the feet has nothing to aim
	if aimKind == "Feet" then
		return
	end
	Module._startDrag(input)
end

--%%%%%%%%%%%%%%%%%%%% On Input Changed

--[[
	Moves the aim with the dragging press (the mouse while its button is held, or the finger), a homing missile's target
	with the finger placing it, and keeps the right stick's lean, which moves the aim every frame (Aim With Stick).
]]
function Module._onInputChanged(input: InputObject, _processed: boolean)
	--[[ Dragging ]]

	local moved: boolean = input == dragInput or (dragInput ~= nil and dragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement)
	if moved then
		Module._drag(Vector2.new(input.Position.X, input.Position.Y))
		return
	end

	--[[ Target ]]

	if input == targetTouch then
		Module._setTarget(Module._getPlanePoint(Vector2.new(input.Position.X, input.Position.Y)))
		return
	end

	--[[ Stick ]]

	if I.Console.IsAction("Aim", input.KeyCode) then
		stick = Vector2.new(input.Position.X, input.Position.Y)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Input Ended

--[[
	Letting go of the dragging press locks the aim where it is (FIRE then shoots it); a finger placing a homing missile's
	target leaves it there.
]]
function Module._onInputEnded(input: InputObject, _processed: boolean)
	--[[ Releasing ]]

	if input == targetTouch then
		targetTouch = nil
	end
	if dragInput and (input == dragInput or (input.UserInputType == dragInput.UserInputType and input.UserInputType ~= Enum.UserInputType.Touch)) then
		Module._endDrag()
	end
end

--%%%%%%%%%%%%%%%%%%%% Start Drag

--[[
	Starts dragging the aim, the crosshair jumping to the press at once (Ring: point).
]]
function Module._startDrag(input: InputObject)
	--[[ Saving ]]

	dragInput = input

	--[[ Aiming ]]

	Module._drag(Vector2.new(input.Position.X, input.Position.Y))
end

--%%%%%%%%%%%%%%%%%%%% Drag

--[[
	Puts the crosshair under the press (Ring: point): the aim points from the snail to it, and its distance past the
	power's start is the power, up to the ring. Within AIM_DEADZONE of no power, there's no aim.
]]
function Module._drag(position: Vector2)
	--[[ Local Variables ]]

	local mine: Model? = I.Snails.GetMine()
	local scales = Module._getScales(mine) --- @type MatchHud_AimScales?

	--[[ Checks ]]

	-- Check if the snail shows on the screen
	if not scales then
		return
	end

	--[[ Aiming ]]

	-- The press and the snail's middle, both in the guis' screen space
	Module._setFromOffset(scales, position - elems["Aim"].AbsolutePosition - scales.Origin)
end

--%%%%%%%%%%%%%%%%%%%% End Drag

--[[
	Ends a drag: the aim stays locked where it was left, kept for the snail's next turn.
]]
function Module._endDrag()
	--[[ Saving ]]

	dragInput = nil
	aimedThisTurn = true
	Module._remember()
end

--%%%%%%%%%%%%%%%%%%%% Set From Offset

--[[
	Aims from a crosshair's offset from the snail on the screen, in pixels (x right, y down): its way is the aim's
	angle and its distance past the power's start the power, up to full; within AIM_DEADZONE of no power the aim clears.
]]
--- @param scales MatchHud_AimScales
function Module._setFromOffset(scales, offset: Vector2)
	--[[ Checks ]]

	-- Check if the offset points somewhere
	if offset.Magnitude < 1e-3 then
		aimed = false
		power = 0
		return
	end

	--[[ Aiming ]]

	-- The screen's y runs down, the arena's up (the camera looks along -Z, its right +X)
	angle = math.atan2(-offset.Y, offset.X)
	power = math.clamp((offset.Magnitude - scales.Base) / scales.Length, 0, 1)
	aimed = power >= _settings.AIM_DEADZONE
	if not aimed then
		power = 0
	end
end

--%%%%%%%%%%%%%%%%%%%% Clear Aim

--[[
	Clears the aim (Esc, the pad's CancelAim): nothing to fire until the player aims again.
]]
function Module._clearAim()
	--[[ Checks ]]

	-- Check if it's the player's turn
	if not I.Match.IsMyTurn() or I.Match.GetPhase() ~= "Turn" then
		return
	end

	--[[ Clearing ]]

	dragInput = nil
	aimed = false
	power = 0
	Module._remember()
end

--%%%%%%%%%%%%%%%%%%%% Remember

--[[
	Keeps the aim for the snail the player plays now, so its next turn starts aimed the same way.
]]
function Module._remember()
	--[[ Saving ]]

	aims[I.Match.GetMyParticipantId()] = if aimed then Vector2.new(angle, power) else nil
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Every frame of the player's turn: moves the aim with the right stick, draws the power ring, the crosshair riding the
	power, the aimbot's whole path line, or else the preview's dots along the start of the path, and
	the readout over the crosshair,
	shows FIRE while the aim is locked and ready, and sends the aim to the other players every AIM_SEND_INTERVAL. A
	homing missile asks for its target first; once it's locked, its launch aims like an arced weapon's, with New target
	beside FIRE.
]]
function Module._step(deltaTime: number)
	--[[ Checks ]]

	-- Hide the aim between shots, while a shot sent waits for the server, and for a utility held
	local itemId: string = LoadoutBar.GetSelected()
	local mine: Model? = I.Snails.GetMine()
	-- A shot the server never took (refused) frees the aim again after FIRE_ANSWER_SECONDS
	if I.Match.GetPhase() ~= "Turn" or os.clock() - firedAt > _settings.FIRE_ANSWER_SECONDS then
		firedAngle = nil
	end
	if firedAngle or I.Match.GetPhase() ~= "Turn" or not mine or I.G_Arsenal.IsUtility(itemId) then
		Module._hideLook()
		elems["Fire"].Visible = false
		return
	end

	--[[ Local Variables ]]

	local aimKind: string = I.G_Arsenal.Get(itemId).Aim
	local ready: boolean = LoadoutBar.IsReady(itemId)
	local picking: boolean = aimKind == "Target" and target == nil

	--[[ Aiming ]]

	if not picking then
		Module._aimWithStick(mine, deltaTime)
	end

	--[[ Drawing ]]

	if aimKind == "Feet" then
		Module._hideLook()
	elseif picking then
		Module._drawTarget(mine)
	else
		Module._draw(mine, angle, if aimed then power else 0, nil, true)
		Module._drawReadout(mine, aimKind)
		Module._drawPrediction(mine, itemId)
		Module._drawPreview(mine, aimKind)
	end
	Module._drawTargetMark(if aimKind == "Target" then mine else nil)

	--[[ Fire ]]

	elems["Fire"].Visible = ready and dragInput == nil and Module._canFire(itemId)
	elems["Retarget"].Visible = aimKind == "Target" and target ~= nil

	--[[ Sending ]]

	if aimKind ~= "Feet" and not picking and os.clock() - lastSent >= _settings.AIM_SEND_INTERVAL then
		lastSent = os.clock()
		I.Network.UFire("Combat_Aim", angle, if aimed then power else 0)
	end
end

--%%%%%%%%%%%%%%%%%%%% Aim With Stick

--[[
	Moves the crosshair with the right stick's lean, like a drag: past STICK_DEADZONE, faster the further it leans (to
	STICK_AIM_SPEED of the power's length a second), never while CameraPan's button (LT) moves the camera, nor after
	it until the stick is back in the middle.
]]
function Module._aimWithStick(mine: Model, deltaTime: number)
	--[[ Local Variables ]]

	local lean: number = math.min(stick.Magnitude, 1)

	-- The stick moved the camera: it aims again once it's back in the middle
	if I.Console.IsHeld("CameraPan") then
		stickLocked = true
	elseif lean < _settings.STICK_DEADZONE then
		stickLocked = false
	end

	--[[ Checks ]]

	-- Check if the stick leans past its dead zone and isn't moving the camera
	if stickLocked or lean < _settings.STICK_DEADZONE or dragInput then
		return
	end

	--[[ Data ]]

	local scales = Module._getScales(mine) --- @type MatchHud_AimScales?
	if not scales then
		return
	end

	--[[ Aiming ]]

	local speed: number = ((lean - _settings.STICK_DEADZONE) / (1 - _settings.STICK_DEADZONE)) ^ _settings.STICK_CURVE * _settings.STICK_AIM_SPEED * scales.Length
	local from: Vector2 = Module._getCrosshairOffset(scales, if aimed then power else 0)
	Module._setFromOffset(scales, from + Vector2.new(stick.X, -stick.Y).Unit * speed * deltaTime)
	aimedThisTurn = true
	Module._remember()
end

--%%%%%%%%%%%%%%%%%%%% Draw

--[[
	Draws a snail's aim on the HUD's aim layer, in pixels over the snail: the crosshair along the aim, as far out as
	the power (from POWER_START, clear of the snail's ball, to POWER_LENGTH further at full), spinning, in the power's
	colour, or on `crosshairAt` when given (a homing missile's target), and the power wedge from POWER_START to the
	crosshair's ring in the power's colour; with `ring`, the power ring round the snail (the player's own aim), the crosshair's place at full
	power. Lengths are units, a stud at the match camera's starting distance, so the aim is the same on the screen at any
	zoom. The held weapon turns with the aim at once.
]]
function Module._draw(model: Model, aimAngle: number, aimPower: number, crosshairAt: Vector3?, ring: boolean?)
	--[[ Data ]]

	local scales = Module._getScales(model) --- @type MatchHud_AimScales?

	--[[ Checks ]]

	-- Check if the snail is still in play
	if not scales then
		Module._hideLook()
		return
	end

	--[[ Local Variables ]]

	local crosshair: Vector2 = scales.Origin + Module._getCrosshairOffset(scales, aimPower, aimAngle)
	if crosshairAt then
		local screenTarget: Vector3 = I.S.Workspace.CurrentCamera:WorldToScreenPoint(crosshairAt)
		crosshair = Vector2.new(screenTarget.X, screenTarget.Y) - elems["Aim"].AbsolutePosition
	end

	--[[ Weapon ]]

	-- The held weapon turns with this screen's aim at once
	I.Combat.SetAim(aimAngle)

	--[[ Ring ]]

	local reach: number = (scales.Base + scales.Length) * 2
	elems["PowerRing"].Position = UDim2.fromOffset(scales.Origin.X, scales.Origin.Y)
	elems["PowerRing"].Size = UDim2.fromOffset(reach, reach)
	elems["PowerRing"].Visible = ring == true

	--[[ Power Wedge ]]

	-- From where the power starts to the crosshair's ring, widening to POWER_WEDGE_SPREAD of its length at its end
	local direction: Vector2 = Vector2.new(math.cos(aimAngle), -math.sin(aimAngle))
	local wedgeFrom: number = scales.Base - (_settings.POWER_GAP + _settings.CROSSHAIR_SIZE / 2) * scales.Unit
	local wedgeLength: number = scales.Base + scales.Length * aimPower - _settings.CROSSHAIR_SIZE / 4 * scales.Unit - wedgeFrom
	local wedgeWidth: number = wedgeLength * _settings.POWER_WEDGE_SPREAD
	local wedgeMiddle: Vector2 = scales.Origin + direction * (wedgeFrom + wedgeLength / 2)
	elems["Wedge"].Position = UDim2.fromOffset(wedgeMiddle.X, wedgeMiddle.Y)
	elems["Wedge"].Size = UDim2.fromOffset(wedgeLength, wedgeWidth)
	elems["Wedge"].Rotation = math.deg(math.atan2(direction.Y, direction.X))
	elems["Wedge"].Visible = crosshairAt == nil and aimPower > 0
	elems["WedgeTop"].BackgroundColor3 = getPowerColor(aimPower)
	elems["WedgeBottom"].BackgroundColor3 = getPowerColor(aimPower)

	-- Each half is cut along its diagonal by its gradient's step, turned to the half's shape in pixels
	elems["WedgeTop"].UIGradient.Rotation = math.deg(math.atan2(wedgeLength, wedgeWidth / 2))
	elems["WedgeBottom"].UIGradient.Rotation = math.deg(math.atan2(-wedgeLength, wedgeWidth / 2))

	--[[ Crosshair ]]

	elems["Crosshair"].Position = UDim2.fromOffset(crosshair.X, crosshair.Y)
	elems["Crosshair"].Size = UDim2.fromOffset(_settings.CROSSHAIR_SIZE * scales.Unit, _settings.CROSSHAIR_SIZE * scales.Unit)
	elems["Crosshair"].Rotation = os.clock() * _settings.CROSSHAIR_SPIN % 360
	elems["Crosshair"].Visible = crosshairAt ~= nil or aimPower > 0

	-- The power's colour, as the wedge's
	local color: Color3 = getPowerColor(aimPower)
	if color ~= crosshairColor then
		crosshairColor = color
		elems["RingLine"].Color = color
		elems["ArmA"].BackgroundColor3 = color
		elems["ArmB"].BackgroundColor3 = color
	end
end

--%%%%%%%%%%%%%%%%%%%% Draw Target

--[[
	A homing missile in hand with no target yet: no aim drawn, and the readout over the snail asking for a target (a
	click, or a tap on touch).
]]
function Module._drawTarget(mine: Model)
	--[[ Drawing ]]

	Module._draw(mine, angle, 0)
	Module._hidePrediction(1)
	Module._hidePreview(1)

	--[[ Readout ]]

	local scales = Module._getScales(mine) --- @type MatchHud_AimScales?
	if not scales then
		return
	end
	local over: Vector2 = scales.Origin - Vector2.new(0, (scales.Base + scales.Length) * 0.6)
	elems["Readout"].Text = if I.Platform.Current == "Mobile" then _settings.TARGET_HINTS.TouchPick else _settings.TARGET_HINTS.Pick
	elems["Readout"].Position = UDim2.fromOffset(over.X, over.Y)
	elems["Readout"].Visible = true
end

--%%%%%%%%%%%%%%%%%%%% Draw Target Mark

--[[
	A homing missile's locked target: its lock-on mark (S_TargetMark) on its spot, TARGET_MARK_SIZE units across, its
	brackets turning and closing in as it's placed; hidden with no target, or with nil (another weapon in hand).
]]
function Module._drawTargetMark(mine: Model?)
	--[[ Data ]]

	local scales = Module._getScales(mine) --- @type MatchHud_AimScales?

	--[[ Checks ]]

	-- Check if a target is placed and the snail shows
	if not target or not scales then
		elems["TargetMark"].Visible = false
		return
	end

	--[[ Applying ]]

	local screen: Vector3 = I.S.Workspace.CurrentCamera:WorldToScreenPoint(target)
	local size: number = _settings.TARGET_MARK_SIZE * scales.Unit

	-- The brackets close in from TARGET_LOCK_SCALE as the target is placed, then breathe by TARGET_MARK_PULSE
	local locking: number = math.clamp((os.clock() - targetPlacedAt) / _settings.TARGET_LOCK_SECONDS, 0, 1)
	local closing: number = 1 + (_settings.TARGET_LOCK_SCALE - 1) * (1 - locking) ^ 3
	local pulse: number = 1 + _settings.TARGET_MARK_PULSE * math.sin(os.clock() * _settings.TARGET_MARK_PULSE_SPEED * 2 * math.pi)

	--[[ Applying ]]

	elems["TargetMark"].Position = UDim2.fromOffset(screen.X - elems["Aim"].AbsolutePosition.X, screen.Y - elems["Aim"].AbsolutePosition.Y)
	elems["TargetMark"].Size = UDim2.fromOffset(size, size)
	elems["TargetMark"].Visible = screen.Z > 0
	elems["TargetBrackets"].Size = UDim2.fromScale(closing * pulse, closing * pulse)
	elems["TargetBrackets"].Rotation = os.clock() * _settings.TARGET_BRACKET_SPIN % 90
end

--%%%%%%%%%%%%%%%%%%%% Draw Readout

--[[
	Writes the aim over its crosshair: the power and the angle up from level ("62% · 41°", for an arced weapon or a homing
	missile's launch), only the angle for a gun or a swing, which have no power; none with no aim.
]]
function Module._drawReadout(mine: Model, aimKind: string)
	--[[ Data ]]

	local scales = Module._getScales(mine) --- @type MatchHud_AimScales?

	--[[ Checks ]]

	-- Check if there's an aim to read
	if not scales or not aimed then
		elems["Readout"].Visible = false
		return
	end

	--[[ Local Variables ]]

	local crosshair: Vector2 = scales.Origin + Module._getCrosshairOffset(scales, power)
	local up: number = math.round(math.deg(math.asin(math.sin(angle))))

	--[[ Applying ]]

	elems["Readout"].Text = if aimKind == "Arc" or aimKind == "Target" then `{math.round(power * 100)}% · {up}°` else `{up}°`
	elems["Readout"].Position = UDim2.fromOffset(crosshair.X, crosshair.Y - _settings.CROSSHAIR_SIZE * scales.Unit * 0.6)
	elems["Readout"].Visible = true
end

--%%%%%%%%%%%%%%%%%%%% Hide Look

--[[
	Hides the crosshair, a homing missile's target mark, the power wedge, the ring, the readout, the prediction and the preview, and hands the held
	weapon back to the snail's replicated aim (or keeps it on a shot just sent).
]]
function Module._hideLook()
	--[[ Hiding ]]

	I.Combat.SetAim(firedAngle)

	elems["Crosshair"].Visible = false
	elems["TargetMark"].Visible = false
	elems["PowerRing"].Visible = false
	elems["Wedge"].Visible = false
	elems["Readout"].Visible = false
	Module._hidePrediction(1)
	Module._hidePreview(1)
end

--%%%%%%%%%%%%%%%%%%%% Draw Prediction

--[[
	For a player an admin gave the aimbot (the `Aimbot` Player attribute), draws where an arced weapon's shot would fly
	from the player's snail: the path at the power aimed, or faded at the power last fired with no aim, wind and all, to
	the first terrain or snail it meets. Everyone else, the tutorial too (the owner, 2026-11-25: "so player is not
	confused that he has it here and does not have it in the main game"), sees the preview's dots.
	shortcut: it ignores the shot's slowdown in water and its bounces, so it's exact to the first thing a shot touches
	out of liquid; follow Combat's Ballistics if a later step needs more.
]]
function Module._drawPrediction(model: Model, itemId: string)
	--[[ Checks ]]

	-- Check if it's the aimbot, and an arced weapon
	if not I.S.Players.LocalPlayer:GetAttribute("Aimbot") or I.G_Arsenal.Get(itemId).Aim ~= "Arc" or not model.PrimaryPart then
		Module._hidePrediction(1)
		return
	end

	--[[ Local Variables ]]

	local direction: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), 0)
	local position: Vector3 = model.PrimaryPart.Position + direction * (I.Settings["Snails"].ROOT_SIZE / 2 + I.Settings["Combat"].MUZZLE_GAP)
	local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(itemId, angle, if aimed then power else lastPower)
	local acceleration: Vector3 = Vector3.new(I.G_Combat.GetWindAcceleration(itemId, I.Match.GetFolder():GetAttribute("Wind") or 0), -I.S.Workspace.Gravity, 0)
	local transparency: number = if aimed then 0 else _settings.PREDICTION_IDLE_TRANSPARENCY
	local step: number = _settings.PREDICTION_STEP
	local shown: number = 0
	local sinceDot: number = _settings.PREDICTION_DOT_GAP
	predictionParams.FilterDescendantsInstances = { model, predictionEnd.Parent }

	--[[ Following ]]

	for _index: number = 1, math.ceil(_settings.PREDICTION_SECONDS / step) do
		local nextPosition: Vector3 = position + velocity * step + acceleration * (step * step / 2)
		local hit: RaycastResult? = I.S.Workspace:Raycast(position, nextPosition - position, predictionParams)
		local reached: Vector3 = if hit then hit.Position else nextPosition

		-- A dot every PREDICTION_DOT_GAP studs along the way
		sinceDot += (reached - position).Magnitude
		if sinceDot >= _settings.PREDICTION_DOT_GAP and shown < #predictionDots then
			sinceDot = 0
			shown += 1
			predictionDots[shown].Position = reached
			predictionDots[shown].Transparency = transparency
		end
		position = reached
		velocity += acceleration * step
		if hit then
			break
		end
	end

	--[[ Applying ]]

	predictionEnd.Position = position
	predictionEnd.Transparency = transparency
	Module._hidePrediction(shown + 1)
end

--%%%%%%%%%%%%%%%%%%%% Hide Prediction

--[[
	Hides the prediction's dots from `first` on, and its end when they're all hidden.
]]
function Module._hidePrediction(first: number)
	--[[ Hiding ]]

	for index: number = first, #predictionDots do
		predictionDots[index].Transparency = 1
	end
	if first == 1 then
		predictionEnd.Transparency = 1
	end
end

--%%%%%%%%%%%%%%%%%%%% Draw Preview

--[[
	Draws the start of an arced shot's path (a homing missile's launch too) from the player's snail, as the testers had
	it on 2026-11-24 (the owner, 2026-11-25: "it was perfect - so lets try to add those dots back"): PREVIEW_DOTS dots
	over PREVIEW_SHARE of a full-power shot's flight time, so they reach further with more power, without the wind (it
	helps, it doesn't aim), stopping at the first terrain or snail in the way, shrinking and fading along the way, all in
	the power's colour, the tutorial too. None for a gun, a swing or no aim, nor where the whole path shows (the aimbot).
]]
function Module._drawPreview(model: Model, aimKind: string)
	--[[ Checks ]]

	-- Check if it's an arced aim, and no whole path shows
	if not aimed or (aimKind ~= "Arc" and aimKind ~= "Target") or not model.PrimaryPart or I.S.Players.LocalPlayer:GetAttribute("Aimbot") then
		Module._hidePreview(1)
		return
	end

	--[[ Local Variables ]]

	local itemId: string = LoadoutBar.GetSelected()
	local camera: Camera = I.S.Workspace.CurrentCamera
	local scales = Module._getScales(model) --- @type MatchHud_AimScales
	local direction: Vector3 = Vector3.new(math.cos(angle), math.sin(angle), 0)
	local start: Vector3 = model.PrimaryPart.Position + direction * (I.Settings["Snails"].ROOT_SIZE / 2 + I.Settings["Combat"].MUZZLE_GAP)
	local velocity: Vector3 = I.G_Combat.GetLaunchVelocity(itemId, angle, power)
	local gravity: number = I.S.Workspace.Gravity

	-- A full-power shot's flight at 45°, which the preview shows a share of
	local fullSpeed: number = I.G_Combat.GetLaunchVelocity(itemId, math.rad(45), 1).Magnitude
	local shown: number = _settings.PREVIEW_SHARE * 2 * fullSpeed * math.sin(math.rad(45)) / gravity
	local count: number = #previewDots
	predictionParams.FilterDescendantsInstances = { model, predictionEnd.Parent }

	--[[ Drawing ]]

	local last: Vector3 = start
	local drawn: number = 0
	for index: number = 1, count do
		local t: number = shown * index / count
		local at: Vector3 = start + velocity * t + Vector3.new(0, -gravity, 0) * (t * t / 2)

		-- Stop at the first thing in the way
		if I.S.Workspace:Raycast(last, at - last, predictionParams) then
			break
		end
		last = at

		local screen: Vector3 = camera:WorldToScreenPoint(at)
		local along: number = index / count
		local size: number = (_settings.PREVIEW_DOT_SIZE[1] + (_settings.PREVIEW_DOT_SIZE[2] - _settings.PREVIEW_DOT_SIZE[1]) * along) * scales.Unit
		local dot: Frame = previewDots[index]
		dot.Position = UDim2.fromOffset(screen.X - elems["Aim"].AbsolutePosition.X, screen.Y - elems["Aim"].AbsolutePosition.Y)
		dot.Size = UDim2.fromOffset(size, size)
		dot.BackgroundColor3 = getPowerColor(power)
		dot.BackgroundTransparency = along * _settings.PREVIEW_FADE
		dot.UIStroke.Transparency = 0.25 + along * _settings.PREVIEW_FADE * 0.75
		dot.Visible = screen.Z > 0
		drawn = index
	end
	Module._hidePreview(drawn + 1)
end

--%%%%%%%%%%%%%%%%%%%% Hide Preview

--[[
	Hides the preview's dots from `first` on.
]]
function Module._hidePreview(first: number)
	--[[ Hiding ]]

	for index: number = first, #previewDots do
		previewDots[index].Visible = false
	end
end

--%%%%%%%%%%%%%%%%%%%% Fire

--[[
	FIRE, FIRE_KEYS or the pad's RT: sends the locked shot (Combat_Fire) with the angle, the power and a homing
	missile's target, ticks a phone or pad, plays the weapon's sound at once (the server plays it for everyone else),
	then hides the aim, the held weapon staying on the shot's angle until the shot is away, so nothing swings while the
	server answers. The aim stays kept for the snail's next turn.
]]
function Module._fire()
	--[[ Local Variables ]]

	local itemId: string = LoadoutBar.GetSelected()
	local mine: Model? = I.Snails.GetMine()

	--[[ Checks ]]

	-- Check if the player may shoot now, with a ready weapon aimed (or one placed at the feet, or a homing missile with its target)
	if firedAngle or dragInput or not mine or not I.Match.IsMyTurn() or I.Match.GetPhase() ~= "Turn" or not LoadoutBar.IsReady(itemId) or not Module._canFire(itemId) then
		return
	end

	--[[ Shot ]]

	local aimKind: string = I.G_Arsenal.Get(itemId).Aim
	local shotAngle: number = angle
	local shotPower: number = power

	-- A weapon fired at the feet goes the way the snail faces; guns and melee weapons need no power
	if aimKind == "Feet" then
		shotAngle = if mine:GetAttribute("Facing") == -1 then math.pi else 0
		shotPower = 0
	elseif aimKind == "Straight" or aimKind == "Melee" then
		shotPower = 1
	end

	--[[ Sending ]]

	I.Network.Fire("Combat_Fire", itemId, shotAngle, shotPower, if aimKind == "Target" then target else nil)
	lastPower = shotPower
	I.Haptic.PlayOnce("Combat_Fire")
	firedItem = itemId
	if mine.PrimaryPart then
		I.Sound.Play({
			Name = `Fire_{itemId}`,
			Location = mine.PrimaryPart.Position,
			SoundGroup = "SFX",
			RollOffMin = I.Settings["Combat"].SOUND_ROLLOFF_MIN,
			RollOffMax = I.Settings["Combat"].SOUND_ROLLOFF_MAX,
			PitchMin = 0.95,
			PitchMax = 1.05,
		})
	end

	-- Shooting ends an emote on this screen at once, before the server's word reaches every screen
	if mine:FindFirstChild("Skin") then
		I.SnailRig.StopEmote(mine:FindFirstChild("Skin"))
	end

	--[[ Clearing ]]

	firedAngle = shotAngle
	firedAt = os.clock()
	elems["Fire"].Visible = false
	Module._hideLook()
	target = nil
end

--%%%%%%%%%%%%%%%%%%%% Set Target

--[[
	Places a homing missile's target on a point of the arena's plane (Draw Target Mark shows it).
]]
function Module._setTarget(point: Vector3)
	--[[ Saving ]]

	target = point
	targetPlacedAt = os.clock()
end

--%%%%%%%%%%%%%%%%%%%% Clear Target

--[[
	New target (beside FIRE): lets go of a homing missile's target, so the next press places another. The launch's aim
	stays.
]]
function Module._clearTarget()
	--[[ Clearing ]]

	target = nil
	targetTouch = nil
end

--%%%%%%%%%%%%%%%%%%%% On My Turn

--[[
	Starts the player's turn aimed as their snail last was (AIM_START_POWER toward its nearest enemy on its first turn),
	and clears the drag, a picked target and FIRE when the turn starts or ends.
]]
function Module._onMyTurn(myTurn: boolean)
	--[[ Clearing ]]

	dragInput = nil
	targetTouch = nil
	aimedThisTurn = false
	Module._hideLook()
	target = nil
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

	local kept: Vector2? = aims[I.Match.GetMyParticipantId()]
	if kept then
		angle = kept.X
		power = kept.Y
	else
		angle = math.rad(if Module._getEnemySide() < 0 then 180 - _settings.AIM_START_ANGLE else _settings.AIM_START_ANGLE)
		power = _settings.AIM_START_POWER
	end
	aimed = true
	Module._remember()
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
	Draws the watched snail's crosshair and power wedge, eased toward its latest aim, until its aim stops arriving or the
	player's own turn starts.
]]
function Module._watchStep(deltaTime: number)
	--[[ Checks ]]

	-- Check if the watched snail still aims, with a weapon that has a crosshair
	local model: Model? = watched
	local itemId: string? = model and model:GetAttribute("HeldItem")
	local fresh: boolean = model ~= nil and model.Parent ~= nil and I.S.Workspace:GetServerTimeNow() - (model:GetAttribute("AimTime") or 0) <= _settings.AIM_SHOW_GRACE
	if stepConnection or not fresh or not itemId or I.G_Arsenal.IsUtility(itemId) or I.G_Arsenal.Get(itemId).Aim == "Feet" then
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

--%%%%%%%%%%%%%%%%%%%% Has Aimed This Turn

--[[
	**CLIENT** |
	Returns whether the player has aimed on their turn now (let go of a drag, or moved the stick): the tutorial shows
	"Drag to aim" until they have, then points at FIRE.
]]
--- @return boolean
function Module.HasAimedThisTurn()
	return aimedThisTurn
end

--%%%%%%%%%%%%%%%%%%%% Get Scales

--[[
	Returns how a snail's aim lies on the screen now: its middle on the aim layer (Origin), pixels in a unit (Unit: it
	grows and shrinks with the zoom, within AIM_ZOOM_SCALE of its size at the starting zoom), where
	the crosshair sits at no power (Base: POWER_START out, clear of its ball, further zoomed in) and the power's whole
	length (Length), in pixels; nil when the snail is out of play.
]]
--- @return MatchHud_AimScales?
function Module._getScales(model: Model?)
	--[[ Checks ]]

	-- Check if the snail is in play
	if not model or not model.PrimaryPart then
		return nil
	end

	--[[ Local Variables ]]

	local camera: Camera = I.S.Workspace.CurrentCamera
	local center: Vector3 = model.PrimaryPart.Position
	local screenCenter: Vector3 = camera:WorldToScreenPoint(center)

	-- Pixels in a stud at the snail now (more when zoomed in), and in a unit: a stud at the starting zoom, following the zoom within AIM_ZOOM_SCALE
	local tanHalf: number = math.tan(math.rad(camera.FieldOfView) / 2)
	local startDistance: number = I.Settings["MatchCamera"].DISTANCE
	local distance: number = (camera.CFrame.Position - center).Magnitude
	local stud: number = camera.ViewportSize.Y / (2 * distance * tanHalf)
	local zoomScale: number = math.clamp(startDistance / distance, _settings.AIM_ZOOM_SCALE[1], _settings.AIM_ZOOM_SCALE[2])
	local unit: number = camera.ViewportSize.Y / (2 * startDistance * tanHalf) * zoomScale
	local first: number = math.max(_settings.POWER_START * unit, (I.Settings["Snails"].ROOT_SIZE / 2 + I.Settings["Combat"].MUZZLE_GAP) * stud)

	--[[ Returning ]]

	--- @type MatchHud_AimScales
	local scales = {
		Origin = Vector2.new(screenCenter.X, screenCenter.Y) - elems["Aim"].AbsolutePosition,
		Unit = unit,
		Base = first + (_settings.POWER_GAP + _settings.CROSSHAIR_SIZE / 2) * unit,
		Length = _settings.POWER_LENGTH * unit,
	}
	return scales
end

--%%%%%%%%%%%%%%%%%%%% Get Crosshair Offset

--[[
	Returns where the crosshair sits from the snail's middle on the screen, in pixels (x right, y down), for a power and
	an angle (the player's aim's, unless given).
]]
--- @param scales MatchHud_AimScales
--- @return Vector2
function Module._getCrosshairOffset(scales, aimPower: number, aimAngle: number?)
	--[[ Local Variables ]]

	local way: number = aimAngle or angle

	--[[ Returning ]]

	return Vector2.new(math.cos(way), -math.sin(way)) * (scales.Base + scales.Length * aimPower)
end

--%%%%%%%%%%%%%%%%%%%% Can Fire

--[[
	Returns whether the held weapon has what it needs to fire: an aim locked (and a homing missile's target), or nothing
	for a weapon placed at the feet.
]]
--- @return boolean
function Module._canFire(itemId: string)
	--[[ Local Variables ]]

	local aimKind: string = I.G_Arsenal.Get(itemId).Aim

	--[[ Returning ]]

	if aimKind == "Feet" then
		return true
	elseif aimKind == "Target" then
		return target ~= nil and aimed
	end
	return aimed
end

--%%%%%%%%%%%%%%%%%%%% Get Enemy Side

--[[
	Returns which side of the player's snail its nearest enemy still in play is on: 1 to the right, -1 to the left (the
	way the snail faces when there's none).
]]
--- @return number
function Module._getEnemySide()
	--[[ Data ]]

	local mine: Model? = I.Snails.GetMine()
	local me: Configuration? = I.Match.GetParticipantInfo(I.Match.GetMyParticipantId())
	if not mine or not mine.PrimaryPart or not me then
		return 1
	end

	--[[ Searching ]]

	local nearest: number = math.huge
	local side: number = if mine:GetAttribute("Facing") == -1 then -1 else 1
	for _index: number, entry: Instance in ipairs(I.Match.GetFolder():FindFirstChild("Participants"):GetChildren()) do
		local model: Model? = I.Snails.Get(entry.Name)
		local enemy: boolean = entry:GetAttribute("Team") ~= me:GetAttribute("Team") and not entry:GetAttribute("Out")
		if enemy and model and model.PrimaryPart then
			local dx: number = model.PrimaryPart.Position.X - mine.PrimaryPart.Position.X
			if math.abs(dx) < nearest then
				nearest = math.abs(dx)
				side = if dx < 0 then -1 else 1
			end
		end
	end

	--[[ Returning ]]

	return side
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
