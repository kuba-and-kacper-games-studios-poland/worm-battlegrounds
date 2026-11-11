--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchCamera"

--- @type MatchCamera_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Folders ]]

local arenaFolder: Instance
local snailsFolder: Instance
local combatFolder: Instance

--[[ View ]]

local focus: Vector3? = nil
local pan: Vector3 = Vector3.zero
local followed: PVInstance? = nil

-- The last blast the camera stays on, until when (os.clock), and whether it stays there until the next turn starts
local blastPoint: Vector3 = Vector3.zero
local blastUntil: number = 0
local blastHeld: boolean = false

-- The snail a blow sent flying (or that fell), which the camera follows while it holds after a shot
local chased: Model? = nil

-- Until when the camera glides over to a new snail, or to where bullets landed, slower than it follows (os.clock)
local travelUntil: number = 0

--[[ Feel ]]

-- Until when a hit stop holds the view, and a knockout's punch-in stays on its snail (os.clock)
local frozenUntil: number = 0
local punchUntil: number = 0
local punchPoint: Vector3 = Vector3.zero

-- The shot the camera leads, where it was last frame, and its smoothed velocity
local ledShot: PVInstance? = nil
local ledFrom: Vector3 = Vector3.zero
local ledVelocity: Vector3 = Vector3.zero

--[[ Zoom ]]

-- How far from the plane the player wants the camera, and how far it is now (easing toward it)
local zoomGoal: number = _settings.DISTANCE
local zoom: number = _settings.DISTANCE

--[[ Input ]]

local dragging: boolean = false
local lastMouse: Vector2 = Vector2.zero
local windowFocused: boolean = true
local stickPan: Vector2 = Vector2.zero
local lastTouchPan: Vector2 = Vector2.zero
local pinchStart: number = _settings.DISTANCE

-- Which way the D-pad zooms while held: -1 in, 1 out, 0 not
local padZoom: number = 0

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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.MatchCamera = {

		--[[ Control ]]

		Freeze = Module.Freeze,
		PunchIn = Module.PunchIn,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	arenaFolder = I.Dirs.UmeWorkspace:WaitForChild("Arena")
	snailsFolder = I.Dirs.UmeWorkspace:WaitForChild("Snails")
	combatFolder = I.Dirs.UmeWorkspace:WaitForChild("Combat")
	Module._createConnections()
	I.Network.Fired("Combat_Explosion", Module._onExplosion)
	I.Network.Fired("Combat_Tracer", Module._onTracer)
	I.Topic.Subscribe("Match_TurnStarted", Module._onTurnStarted)

	-- Before CameraShake's step (Camera + 1), so Combat's blast shakes land on top of the view
	I.S.RunService:BindToRenderStep(_localName, Enum.RenderPriority.Camera.Value, Module._update)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Wires the pan inputs (dragging with the right mouse button, two fingers on touch, LT with the right stick, and
	whether the window has focus for the edge pan) and the zoom inputs (the mouse wheel, a pinch, the D-pad held up or
	down). The pad's buttons are the Console module's (Aim, CameraPan, ZoomIn, ZoomOut).
]]
function Module._createConnections()
	--[[ Window ]]

	I.S.UserInputService.WindowFocused:Connect(function()
		windowFocused = true
	end)
	I.S.UserInputService.WindowFocusReleased:Connect(function()
		windowFocused = false
	end)

	--[[ Mouse ]]

	-- Roblox's own camera script claims the right button, so its presses arrive as processed: take them anyway
	I.S.UserInputService.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			dragging = true
			lastMouse = Vector2.new(input.Position.X, input.Position.Y)
		end
	end)

	I.S.UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			dragging = false
		elseif I.Console.IsAction("Aim", input.KeyCode) then
			stickPan = Vector2.zero
		end
	end)

	--[[ Moves ]]

	-- A free mouse reports no Delta, so drags are measured from its positions; the wheel zooms unless a gui scrolls
	I.S.UserInputService.InputChanged:Connect(function(input: InputObject, processed: boolean)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			if not processed then
				Module._zoomTo(zoomGoal * (1 - input.Position.Z * _settings.ZOOM_STEP))
			end
		elseif dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mouse: Vector2 = Vector2.new(input.Position.X, input.Position.Y)
			Module._panBy(mouse - lastMouse)
			lastMouse = mouse
		elseif I.Console.IsAction("Aim", input.KeyCode) then
			stickPan = Vector2.new(input.Position.X, input.Position.Y)
		end
	end)

	--[[ Touch ]]

	I.S.UserInputService.TouchPan:Connect(function(touches: { Vector2 }, translation: Vector2, _velocity: Vector2, state: Enum.UserInputState)
		if #touches < 2 then
			return
		end
		if state == Enum.UserInputState.Begin then
			lastTouchPan = Vector2.zero
		end
		Module._panBy(translation - lastTouchPan)
		lastTouchPan = translation
	end)

	-- Spreading two fingers zooms in, pinching them zooms out
	I.S.UserInputService.TouchPinch:Connect(function(_touches: { Vector2 }, scale: number, _velocity: number, state: Enum.UserInputState, processed: boolean)
		if processed or scale <= 0 then
			return
		end
		if state == Enum.UserInputState.Begin then
			pinchStart = zoomGoal
		end
		Module._zoomTo(pinchStart / scale)
	end)

	--[[ Pad ]]

	I.Console.Bind("ZoomIn", Module._onPadZoom)
	I.Console.Bind("ZoomOut", Module._onPadZoom)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Freeze

--[[
	**CLIENT** |
	Holds the view still for a hit stop of some seconds.
]]
function Module.Freeze(seconds: number)
	--[[ Saving ]]

	frozenUntil = math.max(frozenUntil, os.clock() + seconds)
end

--%%%%%%%%%%%%%%%%%%%% Punch In

--[[
	**CLIENT** |
	Pushes the camera in on a knockout blow: it moves to the point and closes in to PUNCH_ZOOM of the player's zoom for
	PUNCH_SECONDS, then goes back to what it followed.
]]
function Module.PunchIn(point: Vector3)
	--[[ Saving ]]

	punchPoint = point
	punchUntil = os.clock() + _settings.PUNCH_SECONDS
end

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	Points the camera along -Z at what it follows (a blast it stays on, or a snail a blow sent flying, else the target,
	else the arena's middle), plus the player's pan, kept inside the arena's bounds, gliding when it moves on to a new
	snail. Nothing changes until a map is loaded, or while the player is in the Studio map's lobby, which gets Roblox's
	camera back.
]]
function Module._update(deltaTime: number)
	--[[ Checks ]]

	-- Check if the player is in the match
	if not I.S.Players.LocalPlayer:GetAttribute("InMatch") then
		if focus then
			focus = nil
			blastHeld = false
			I.S.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		end
		return
	end

	--[[ Data ]]

	local markers: Instance? = arenaFolder:FindFirstChild("Markers")
	local bounds: Instance? = markers and markers:FindFirstChild("Bounds")
	if not bounds or not bounds:IsA("BasePart") then
		return
	end

	--[[ Local Variables ]]

	local camera: Camera = I.S.Workspace.CurrentCamera
	local target: PVInstance? = Module._getTarget()
	local punching: boolean = os.clock() < punchUntil

	-- A hit stop holds the view where it is
	if focus and os.clock() < frozenUntil then
		camera.CFrame = CFrame.lookAt(focus + Vector3.zAxis * zoom, focus)
		return
	end

	-- A followed shot gone without a blast here (it sank, or this screen's copy landed before the server's blast) holds where it ended
	if followed and followed:IsA("BasePart") and followed.Parent ~= combatFolder then
		followed = nil
		Module._hold(if blastHeld then blastPoint else ledFrom, _settings.BLAST_HOLD)
	end

	-- After a blast, stay on it until the next turn starts (and at least its hold), unless another shot flies
	local holding: boolean = (blastHeld or os.clock() < blastUntil) and not (target and target:GetAttribute("Projectile"))

	-- While it holds, a snail the blow sent flying (or that fell) is followed until it comes to rest
	chased = if holding then Module._getFlyingSnail() else nil
	if chased then
		blastPoint = chased:GetPivot().Position
		blastUntil = math.max(blastUntil, os.clock() + _settings.CHASE_HOLD)
		travelUntil = 0
	end

	-- A new snail to follow drops the pan, and the camera glides over to it
	if not holding and target ~= followed then
		followed = target
		pan = Vector3.zero
		travelUntil = if target and target:IsA("Model") then os.clock() + _settings.TRAVEL_MAX else 0
	end

	-- LT with the right stick pans (the Console module's CameraPan and Aim), and so does the mouse at the screen's left or right edge
	if stickPan.Magnitude >= _settings.STICK_DEADZONE and I.Console.IsHeld("CameraPan") then
		pan += Vector3.new(stickPan.X, stickPan.Y, 0) * _settings.STICK_PAN_SPEED * deltaTime
	end
	pan += Vector3.xAxis * Module._getEdgePan(camera) * _settings.EDGE_PAN_SPEED * deltaTime

	-- A held D-pad up or down zooms in or out
	if padZoom ~= 0 then
		Module._zoomTo(zoomGoal * (1 + padZoom * _settings.PAD_ZOOM_RATE * deltaTime))
	end

	-- Ease the zoom first, so the bounds clamp the view at its new size; a knockout's punch-in closes in
	local wantedZoom: number = if punching then zoomGoal * _settings.PUNCH_ZOOM else zoomGoal
	zoom += (wantedZoom - zoom) * (1 - math.exp(-_settings.ZOOM_SPEED * deltaTime))

	-- A flying shot is led a little along its flight, so where it lands comes into view sooner
	local lead: Vector3 = Vector3.zero
	if not holding and target and target:IsA("BasePart") then
		local position: Vector3 = target.Position
		if target == ledShot and deltaTime > 0 then
			ledVelocity = ledVelocity:Lerp((position - ledFrom) / deltaTime, 1 - math.exp(-_settings.LEAD_SMOOTH * deltaTime))
		else
			ledVelocity = Vector3.zero
		end
		ledShot = target
		ledFrom = position
		lead = ledVelocity * _settings.LEAD_SECONDS
		lead = if lead.Magnitude > _settings.LEAD_MAX then lead.Unit * _settings.LEAD_MAX else lead
	else
		ledShot = nil
	end

	local center: Vector3 = if punching then punchPoint elseif holding then blastPoint elseif target then target:GetPivot().Position + lead else bounds.Position
	-- The view may rise CEILING_EXTRA over the map's top, so a snail up there is centred; a shot in flight is followed up any height
	local ceiling: number = if target and target:IsA("BasePart") and not holding then math.huge else _settings.CEILING_EXTRA

	-- Where the view sits with no pan: the pan is only what the player moved from there, never the bounds' own push
	local base: Vector3 = Module._getClamped(center, bounds, camera, ceiling)

	-- On the player's own turn their snail stays in view: the pan eases back while it moves, and never leaves it off screen
	if not holding and target and target:IsA("Model") and I.Match.IsMyTurn() then
		local leashHeight: number = Module._getHalfHeight() * _settings.LEASH
		local leashWidth: number = leashHeight * camera.ViewportSize.X / camera.ViewportSize.Y
		if target.PrimaryPart.AssemblyLinearVelocity.Magnitude >= _settings.RECENTER_MOVE_SPEED then
			pan *= math.exp(-_settings.RECENTER_SPEED * deltaTime)
		end
		local offset: Vector3 = base + pan - center
		local leashed: Vector3 = Vector3.new(math.clamp(offset.X, -leashWidth, leashWidth), math.clamp(offset.Y, -leashHeight, leashHeight), 0)
		pan = Vector3.new(center.X + leashed.X - base.X, center.Y + leashed.Y - base.Y, 0)
	end

	local goal: Vector3 = Module._getClamped(base + pan, bounds, camera, ceiling)
	pan = Vector3.new(goal.X - base.X, goal.Y - base.Y, 0)

	-- Taking the camera sets the FOV buff's base, so an open widget's FOV change still adds to it
	if not focus then
		I.Buff.Set("FOV", "Standard", _settings.FOV)
	end
	local speed: number = if os.clock() < travelUntil then _settings.TRAVEL_SPEED else _settings.FOLLOW_SPEED
	focus = if focus then focus:Lerp(goal, 1 - math.exp(-speed * deltaTime)) else goal
	if focus and (focus - goal).Magnitude < _settings.TRAVEL_DONE then
		travelUntil = 0
	end

	--[[ Applying ]]

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.lookAt(focus + Vector3.zAxis * zoom, focus)
end

--%%%%%%%%%%%%%%%%%%%% On Explosion

--[[
	Keeps the camera on a blast until the next turn starts, and for at least BLAST_HOLD seconds (BIG_BLAST_HOLD for a big
	one), when it follows shots, so the player sees what the shot did and the camera moves once, to the next snail.
]]
function Module._onExplosion(position: Vector3, radius: number, _itemId: string, _shiny: boolean)
	--[[ Checks ]]

	-- Skip when the camera doesn't follow shots, so it never jumps to a blast
	if not I.PlayerSettings.Get("CameraFollowsShot") then
		return
	end

	--[[ Holding ]]

	Module._hold(position, if radius >= _settings.BIG_BLAST_RADIUS then _settings.BIG_BLAST_HOLD else _settings.BLAST_HOLD)
end

--%%%%%%%%%%%%%%%%%%%% On Tracer

--[[
	Takes the camera to where a gun's bullets (or a swing) landed, when it follows shots: bullets are too fast to follow,
	so it glides to the middle of their hits and stays there like a blast until the next turn starts.
]]
--- @param hits { Vector3 }
function Module._onTracer(_itemId: string, _from: Vector3, hits)
	--[[ Checks ]]

	-- Skip when the camera doesn't follow shots, or nothing landed
	if not I.PlayerSettings.Get("CameraFollowsShot") or #hits == 0 then
		return
	end

	--[[ Local Variables ]]

	local sum: Vector3 = Vector3.zero
	for _index: number, point: Vector3 in ipairs(hits) do
		sum += point
	end

	--[[ Holding ]]

	Module._hold(sum / #hits, _settings.BLAST_HOLD)
	travelUntil = os.clock() + _settings.TRAVEL_MAX
end

--%%%%%%%%%%%%%%%%%%%% On Turn Started

--[[
	A new turn lets the camera go from the last blast once its hold is over, on to the snail whose turn it is.
]]
function Module._onTurnStarted(_activeId: string)
	--[[ Saving ]]

	blastHeld = false
end

--%%%%%%%%%%%%%%%%%%%% Hold

--[[
	Keeps the camera on a point until the next turn starts, and for at least some seconds.
]]
function Module._hold(point: Vector3, seconds: number)
	--[[ Saving ]]

	blastPoint = point
	blastUntil = math.max(blastUntil, os.clock() + seconds)
	blastHeld = true
end

--%%%%%%%%%%%%%%%%%%%% Zoom To

--[[
	Sets how far from the plane the player wants the camera, kept between ZOOM_MIN and ZOOM_MAX.
]]
function Module._zoomTo(distance: number)
	--[[ Saving ]]

	zoomGoal = math.clamp(distance, _settings.ZOOM_MIN, _settings.ZOOM_MAX)
end

--%%%%%%%%%%%%%%%%%%%% On Pad Zoom

--[[
	D-pad up or down held (the Console module's ZoomIn and ZoomOut): zooms that way every frame until it's let go. Leaves
	the D-pad to a gui selection, which it moves.
]]
--- @return Enum.ContextActionResult
function Module._onPadZoom(action: string, state: Enum.UserInputState, _input: InputObject)
	--[[ Checks ]]

	-- Pass the D-pad on while a gui is selected
	if I.S.GuiService.SelectedObject then
		padZoom = 0
		return Enum.ContextActionResult.Pass
	end

	--[[ Saving ]]

	padZoom = if state ~= Enum.UserInputState.Begin then 0 elseif action == "ZoomIn" then -1 else 1

	--[[ Returning ]]

	return Enum.ContextActionResult.Sink
end

--%%%%%%%%%%%%%%%%%%%% Pan By

--[[
	Moves the view the way a drag of some pixels moves the arena under the pointer.
]]
function Module._panBy(pixels: Vector2)
	--[[ Local Variables ]]

	local camera: Camera = I.S.Workspace.CurrentCamera
	local studsPerPixel: number = 2 * Module._getHalfHeight() / camera.ViewportSize.Y

	--[[ Saving ]]

	pan += Vector3.new(-pixels.X, pixels.Y, 0) * studsPerPixel
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Edge Pan

--[[
	Returns which way the mouse at the screen's edge pans: -1 at the left edge, 1 at the right, 0 elsewhere, or with no
	mouse or no focus. Only the sides pan: Roblox's buttons sit along the top and the loadout bar along the bottom.
]]
--- @return number
function Module._getEdgePan(camera: Camera)
	--[[ Checks ]]

	-- Check if a mouse points into the focused window, not dragging the view or holding an aim (left button)
	local holding: boolean = I.S.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
	if not windowFocused or dragging or holding or not I.S.UserInputService.MouseEnabled then
		return 0
	end

	--[[ Local Variables ]]

	local mouse: Vector2 = I.S.UserInputService:GetMouseLocation()
	local margin: number = _settings.EDGE_PAN_MARGIN * camera.ViewportSize.Y

	--[[ Returning ]]

	return if mouse.X <= margin then -1 elseif mouse.X >= camera.ViewportSize.X - margin then 1 else 0
end

--%%%%%%%%%%%%%%%%%%%% Get Target

--[[
	Returns what the camera follows: a shot in flight when the player's CameraFollowsShot setting is on (the one it
	already follows while it flies, else the first part with the Projectile attribute), else the snail whose turn it is
	(its Active attribute), else between turns the snail it followed last, else the local player's.
]]
--- @return PVInstance?
function Module._getTarget()
	--[[ Shots ]]

	if I.PlayerSettings.Get("CameraFollowsShot") then
		-- Staying on one shot, so it doesn't hop between a cluster bomb's bomblets
		if followed and followed.Parent == combatFolder then
			return followed
		end
		for _index: number, part: Instance in ipairs(combatFolder:GetChildren()) do
			if part:IsA("BasePart") and part:GetAttribute("Projectile") then
				return part
			end
		end
	end

	--[[ Snails ]]

	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		if model:IsA("Model") and model:GetAttribute("Active") and model.PrimaryPart then
			return model
		end
	end

	-- Between turns, the snail it followed, so it doesn't swing over to the player's own and back
	if followed and followed:IsA("Model") and followed.Parent == snailsFolder and followed.PrimaryPart then
		return followed
	end

	--[[ Returning ]]

	local mine: Model? = I.Snails.GetMine()
	return if mine and mine.PrimaryPart then mine else nil
end

--%%%%%%%%%%%%%%%%%%%% Get Flying Snail

--[[
	Returns a snail moving faster than CHASE_SPEED (a blow sent it flying, or it fell): the one the camera already
	chases while it still does, else the fastest; nil when none does.
]]
--- @return Model?
function Module._getFlyingSnail()
	--[[ Checks ]]

	-- Keep the snail it chases while that one still flies
	if chased and chased.Parent == snailsFolder and chased.PrimaryPart and chased.PrimaryPart.AssemblyLinearVelocity.Magnitude >= _settings.CHASE_SPEED then
		return chased
	end

	--[[ Finding ]]

	local fastest: Model? = nil
	local fastestSpeed: number = _settings.CHASE_SPEED
	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		if model:IsA("Model") and model.PrimaryPart and model.PrimaryPart.AssemblyLinearVelocity.Magnitude >= fastestSpeed then
			fastest = model
			fastestSpeed = model.PrimaryPart.AssemblyLinearVelocity.Magnitude
		end
	end

	--[[ Returning ]]

	return fastest
end

--%%%%%%%%%%%%%%%%%%%% Get Clamped

--[[
	Returns a point moved just enough that the view centered on it stays inside the bounds (their top raised by
	`ceiling` studs), on the bounds' plane; along an axis where the view is wider than the bounds, the bounds' middle.
]]
--- @return Vector3
function Module._getClamped(point: Vector3, bounds: BasePart, camera: Camera, ceiling: number)
	--[[ Local Variables ]]

	local halfHeight: number = Module._getHalfHeight()
	local halfWidth: number = halfHeight * camera.ViewportSize.X / camera.ViewportSize.Y
	local low: Vector3 = bounds.Position - bounds.Size / 2
	local high: Vector3 = bounds.Position + bounds.Size / 2

	-- The top on its own, since an endless ceiling (math.huge) times the other axes' zeros would be NaN
	local top: number = high.Y + ceiling
	local x: number = bounds.Position.X
	local y: number = bounds.Position.Y

	--[[ Clamping ]]

	if high.X - low.X > halfWidth * 2 then
		x = math.clamp(point.X, low.X + halfWidth, high.X - halfWidth)
	end
	if top - low.Y > halfHeight * 2 then
		y = math.clamp(point.Y, low.Y + halfHeight, top - halfHeight)
	end

	--[[ Returning ]]

	return Vector3.new(x, y, bounds.Position.Z)
end

--%%%%%%%%%%%%%%%%%%%% Get Half Height

--[[
	Returns half the height of the view on the plane at the current zoom, in studs.
]]
--- @return number
function Module._getHalfHeight()
	return zoom * math.tan(math.rad(I.S.Workspace.CurrentCamera.FieldOfView / 2))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
