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

-- How the player aims now: "Drag" (mouse or finger), "Pad" (right stick and RT), or nil
local mode: string? = nil
local pressPosition: Vector2 = Vector2.zero
local angle: number = math.rad(45)
local power: number = 0.5
local padStart: number = 0
local target: Vector3? = nil
local lastSent: number = 0
local stepConnection: RBXScriptConnection?

-- The item the player last fired, so a click while it rolls blows up a black hole grenade
local firedItem: string? = nil

--[[ Others' Aim ]]

-- The worm whose aim line this player watches (the active one, while its aim keeps arriving), and the aim drawn
local watched: Model? = nil
local watchedAngle: number = 0
local watchedPower: number = 0
local watchConnection: RBXScriptConnection?

--[[ Look ]]

local dots = {} --- @type { Part }
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

	elems["Power"] = gui:FindFirstChild("U_Power") --- @type Frame
	elems["PowerFill"] = elems["Power"]:FindFirstChild("Fill", true) --- @type Frame
	elems["PowerStatus"] = elems["Power"]:FindFirstChild("Status", true) --- @type TextLabel
	elems["Angle"] = elems["Power"]:FindFirstChild("S_Angle", true) --- @type TextLabel

	--[[ Building ]]

	local combatFolder: Instance = I.Dirs.UmeWorkspace:WaitForChild("Combat")
	for index: number = 1, _settings.AIM_LINE_DOTS do
		dots[index] = I.Create("Part")({
			Name = "AimDot",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * _settings.AIM_DOT_SIZE,
			Color = _settings.AIM_DOT_COLOR,
			Material = Enum.Material.Neon,
			Anchored = true,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			Transparency = 1,
			Parent = combatFolder,
		})
	end
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
	elems["Power"].Visible = false

	--[[ Connections ]]

	I.S.UserInputService.InputBegan:Connect(Module._onInputBegan)
	I.S.UserInputService.InputChanged:Connect(Module._onInputChanged)
	I.S.UserInputService.InputEnded:Connect(Module._onInputEnded)
	I.Topic.Subscribe("Match_MyTurn", Module._onMyTurn)

	-- Every worm's aim (players' and bots'), to draw its line for this player too
	local wormsFolder: Instance = I.Dirs.UmeWorkspace:WaitForChild("Worms")
	wormsFolder.ChildAdded:Connect(Module._watchWorm)
	for _index: number, model: Instance in ipairs(wormsFolder:GetChildren()) do
		Module._watchWorm(model)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Input Began

--[[
	Starts aiming on a press (mouse, finger or RT), cancels on right click, Esc or B, fires a Feet weapon at once,
	picks a homing missile's target with the first tap, and blows up a rolling black hole grenade.
]]
function Module._onInputBegan(input: InputObject, processed: boolean)
	--[[ Local Variables ]]

	local press: boolean = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch

	--[[ Cancelling ]]

	if input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
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

	-- Check if the player may aim now
	if mode or not I.Match.IsMyTurn() or I.Match.GetPhase() ~= "Turn" then
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

	Module._stopWatching()
	mode = if press then "Drag" else "Pad"
	pressPosition = Vector2.new(input.Position.X, input.Position.Y)
	padStart = os.clock()
	elems["Power"].Visible = true
	stepConnection = I.S.RunService.RenderStepped:Connect(Module._step)
end

--%%%%%%%%%%%%%%%%%%%% On Input Changed

--[[
	Follows the drag (its direction is the angle, its length the power) or the right stick's direction.
]]
function Module._onInputChanged(input: InputObject, _processed: boolean)
	--[[ Dragging ]]

	if mode == "Drag" and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local drag: Vector2 = Vector2.new(input.Position.X, input.Position.Y) - pressPosition
		if drag.Magnitude >= _settings.MIN_DRAG then
			angle = math.atan2(-drag.Y, drag.X)
			power = math.clamp((drag.Magnitude - _settings.MIN_DRAG) / (_settings.MAX_DRAG - _settings.MIN_DRAG), 0, 1)
		end
		return
	end

	--[[ Stick ]]

	-- LT with the right stick pans the camera instead
	if input.KeyCode == Enum.KeyCode.Thumbstick2 and input.Position.Magnitude >= _settings.STICK_DEADZONE and not I.S.UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonL2) then
		angle = math.atan2(input.Position.Y, input.Position.X)
	end
end

--%%%%%%%%%%%%%%%%%%%% On Input Ended

--[[
	Fires on release: the mouse or finger after a long enough drag (a short one cancels), or RT.
]]
function Module._onInputEnded(input: InputObject, _processed: boolean)
	--[[ Dragging ]]

	if mode == "Drag" and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		local drag: Vector2 = Vector2.new(input.Position.X, input.Position.Y) - pressPosition
		if drag.Magnitude < _settings.MIN_DRAG then
			Module._cancel()
		else
			Module._fire()
		end
		return
	end

	--[[ Pad ]]

	if mode == "Pad" and input.KeyCode == Enum.KeyCode.ButtonR2 then
		Module._fire()
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	While the player aims: runs the pad's power bar up and down, shows the power and angle, draws the aim line
	(without wind), and sends the aim to the other players every AIM_SEND_INTERVAL.
]]
function Module._step()
	--[[ Checks ]]

	-- Stop when the turn moved on
	if not I.Match.IsMyTurn() or I.Match.GetPhase() ~= "Turn" then
		Module._cancel()
		return
	end

	--[[ Power ]]

	if mode == "Pad" then
		local sweep: number = ((os.clock() - padStart) * _settings.PAD_POWER_SPEED) % 1
		power = 1 - math.abs(sweep * 2 - 1)
	end

	--[[ Panel ]]

	elems["PowerFill"].Size = UDim2.fromScale(power, 1)
	elems["PowerStatus"].Text = `{math.round(power * 100)}%`
	elems["Angle"].Text = `Angle {math.round(math.deg(math.asin(math.sin(angle))))}°`

	--[[ Aim Line ]]

	Module._drawLine(I.Worms.GetMine(), LoadoutBar.GetSelected(), angle, power)

	--[[ Sending ]]

	if os.clock() - lastSent >= _settings.AIM_SEND_INTERVAL then
		lastSent = os.clock()
		I.Network.UFire("Combat_Aim", angle, power)
	end
end

--%%%%%%%%%%%%%%%%%%%% Draw Line

--[[
	Places the aim line's dots along the first part of a worm's shot path: an arc for thrown and launched weapons,
	a straight line for guns and melee weapons.
]]
function Module._drawLine(model: Model?, itemId: string, aimAngle: number, aimPower: number)
	--[[ Checks ]]

	-- Check if the worm is still in play
	if not model or not model.PrimaryPart then
		return
	end

	--[[ Local Variables ]]

	local row = I.G_Arsenal.Get(itemId) --- @type Arsenal_WeaponData
	local direction: Vector3 = Vector3.new(math.cos(aimAngle), math.sin(aimAngle), 0)
	local origin: Vector3 = model.PrimaryPart.Position + direction * (I.Settings["Worms"].ROOT_SIZE / 2 + I.Settings["Combat"].MUZZLE_GAP)
	local points = {} --- @type { Vector3 }

	--[[ Calculating ]]

	if row.Aim == "Arc" or row.Aim == "Target" then
		local step: number = _settings.AIM_LINE_SECONDS / _settings.AIM_LINE_DOTS
		points = I.G_Combat.PredictArc(origin, I.G_Combat.GetLaunchVelocity(itemId, aimAngle, aimPower), 0, _settings.AIM_LINE_SECONDS, step)
	else
		local reach: number = row.Range or row.Reach or 20
		for index: number = 1, _settings.AIM_LINE_DOTS do
			points[index] = origin + direction * reach * (index / _settings.AIM_LINE_DOTS)
		end
	end

	--[[ Placing ]]

	for index: number, dot: Part in ipairs(dots) do
		local point: Vector3? = points[index + 1] or points[index]
		dot.Transparency = if point then 0.2 else 1
		if point then
			dot.Position = point
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Fire

--[[
	Sends the shot (Combat_Fire) with the angle, power and a homing missile's target, ticks a phone or pad, then clears
	the aim.
]]
function Module._fire()
	--[[ Local Variables ]]

	local itemId: string = LoadoutBar.GetSelected()
	local mine: Model? = I.Worms.GetMine()

	-- A weapon fired at the feet goes the way the worm faces
	if I.G_Arsenal.Get(itemId).Aim == "Feet" then
		angle = if mine and mine:GetAttribute("Facing") == -1 then math.pi else 0
		power = 0
	end

	--[[ Sending ]]

	I.Network.Fire("Combat_Fire", itemId, angle, power, target)
	I.Haptic.PlayOnce("Combat_Fire")
	firedItem = itemId

	--[[ Clearing ]]

	Module._cancel()
	target = nil
	targetMarker.Transparency = 1
end

--%%%%%%%%%%%%%%%%%%%% Cancel

--[[
	Stops aiming without firing: hides the power panel and the aim line. A homing missile's target stays picked.
]]
function Module._cancel()
	--[[ Saving ]]

	mode = nil
	if stepConnection then
		stepConnection:Disconnect()
		stepConnection = nil
	end

	--[[ Hiding ]]

	elems["Power"].Visible = false
	for _index: number, dot: Part in ipairs(dots) do
		dot.Transparency = 1
	end
end

--%%%%%%%%%%%%%%%%%%%% On My Turn

--[[
	Clears the aim and a picked target whenever the player's turn starts or ends.
]]
function Module._onMyTurn(myTurn: boolean)
	--[[ Clearing ]]

	Module._cancel()
	target = nil
	targetMarker.Transparency = 1
	if myTurn then
		firedItem = nil
	end
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
	Another worm aims: starts drawing its aim line for this player. This player's own worm draws its line as they aim.
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
	Draws the watched worm's aim line, eased toward its latest aim, until its aim stops arriving or the player aims.
]]
function Module._watchStep(deltaTime: number)
	--[[ Checks ]]

	-- Check if the watched worm still aims, with a weapon that has a line
	local model: Model? = watched
	local itemId: string? = model and model:GetAttribute("HeldItem")
	local fresh: boolean = model ~= nil and model.Parent ~= nil and I.S.Workspace:GetServerTimeNow() - (model:GetAttribute("AimTime") or 0) <= _settings.AIM_SHOW_GRACE
	if mode or not fresh or not itemId or I.G_Arsenal.Get(itemId).Aim == "Feet" then
		Module._stopWatching()
		return
	end

	--[[ Easing ]]

	local alpha: number = 1 - math.exp(-_settings.AIM_SMOOTHING * deltaTime)
	local turn: number = ((model:GetAttribute("AimAngle") - watchedAngle + math.pi) % (2 * math.pi)) - math.pi
	watchedAngle += turn * alpha
	watchedPower += (model:GetAttribute("AimPower") - watchedPower) * alpha

	--[[ Drawing ]]

	Module._drawLine(model, itemId, watchedAngle, watchedPower)
end

--%%%%%%%%%%%%%%%%%%%% Stop Watching

--[[
	Stops drawing another worm's aim line and hides it.
]]
function Module._stopWatching()
	--[[ Checks ]]

	-- Check if a line is being watched
	if not watchConnection then
		return
	end

	--[[ Saving ]]

	watchConnection:Disconnect()
	watchConnection = nil
	watched = nil

	--[[ Hiding ]]

	for _index: number, dot: Part in ipairs(dots) do
		dot.Transparency = 1
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

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
