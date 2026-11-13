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
local focusVelocity: Vector3 = Vector3.zero
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

-- The height the view had when the shot it follows took off: the shot rides up the screen before the view rises with it
local shotFloor: number = 0

-- The view's goal last frame: a glide to the next snail zooms out by how far it still has to go
local lastGoal: Vector3 = Vector3.zero

-- A blast's push in: the share of the zoom, and until when it eases back (os.clock)
local kick: number = 0
local kickUntil: number = 0

--[[ Hand ]]

-- Where the player moved the view by hand, which it stays on instead of following until MANUAL_HOLD after their last move (os.clock)
local manualPoint: Vector3? = nil
local manualUntil: number = 0

-- Until when a new turn's glide to its snail ignores the player's hand (os.clock): it ends once the view gets there
local turnGlideUntil: number = 0

--[[ Zoom ]]

-- How far from the plane the player wants the camera, and how far it is now (easing toward it)
local zoomGoal: number = _settings.DISTANCE
local zoom: number = _settings.DISTANCE

--[[ Input ]]

local dragging: boolean = false
local lastMouse: Vector2 = Vector2.zero
local windowFocused: boolean = true
local stickPan: Vector2 = Vector2.zero

-- The fingers on the arena (not on a gui), with where each was last
local touches = {} --- @type { [InputObject]: Vector2 }

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
	Wires the pan inputs (dragging with the right mouse button, a finger on touch, LT with the right stick, and whether
	the window has focus for the edge pan) and the zoom inputs (the mouse wheel, two fingers pinching, the D-pad held up
	or down). The pad's buttons are the Console module's (Aim, CameraPan, ZoomIn, ZoomOut).
]]
function Module._createConnections()
	--[[ Window ]]

	I.S.UserInputService.WindowFocused:Connect(function()
		windowFocused = true
	end)
	I.S.UserInputService.WindowFocusReleased:Connect(function()
		windowFocused = false
	end)

	--[[ Presses ]]

	-- Roblox's own camera script claims the right button, so its presses arrive as processed: take them anyway
	I.S.UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			dragging = true
			lastMouse = Vector2.new(input.Position.X, input.Position.Y)
		elseif input.UserInputType == Enum.UserInputType.Touch and not processed then
			touches[input] = Vector2.new(input.Position.X, input.Position.Y)
		end
	end)

	I.S.UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			dragging = false
		elseif input.UserInputType == Enum.UserInputType.Touch then
			touches[input] = nil
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
		elseif touches[input] then
			Module._onTouchMoved(input)
		elseif I.Console.IsAction("Aim", input.KeyCode) then
			stickPan = Vector2.new(input.Position.X, input.Position.Y)
		end
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
	snail; where the player moved it by hand instead, while they hold the pan and until MANUAL_HOLD after their last
	move or the next turn. Nothing changes until a
	map is loaded, or while the player is in the Studio map's lobby, which gets Roblox's camera back.
]]
function Module._update(deltaTime: number)
	--[[ Checks ]]

	-- Check if the player is in the match
	if not I.S.Players.LocalPlayer:GetAttribute("InMatch") then
		if focus then
			focus = nil
			blastHeld = false
			manualPoint = nil
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
		focusVelocity = Vector3.zero
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

		-- A new shot keeps the height the view had at its take-off, until it rides up to the screen's top
		if target and target:IsA("BasePart") and focus then
			shotFloor = focus.Y
		end
	end

	-- LT with the right stick pans (the Console module's CameraPan and Aim), and so does the mouse at the screen's left or right edge
	if stickPan.Magnitude >= _settings.STICK_DEADZONE and I.Console.IsHeld("CameraPan") then
		Module._addPan(Vector3.new(stickPan.X, stickPan.Y, 0) * _settings.STICK_PAN_SPEED * deltaTime)
	end
	-- A mouse left at the edge once the view can't go further that way isn't a move, or it would hold the view there forever
	local edge: number = Module._getEdgePan(camera)
	local stuck: boolean = focus ~= nil and math.abs(Module._getClamped(focus + Vector3.xAxis * edge, bounds, camera, _settings.CEILING_EXTRA).X - Module._getClamped(focus, bounds, camera, _settings.CEILING_EXTRA).X) < 0.5
	if edge ~= 0 and not stuck then
		Module._addPan(Vector3.xAxis * edge * _settings.EDGE_PAN_SPEED * deltaTime)
	end

	-- The player's own turn, before the shot, follows their snail: a hand move then is the leashed pan
	if manualPoint and Module._isAiming() then
		manualPoint = nil
	end

	-- A held D-pad up or down zooms in or out
	if padZoom ~= 0 then
		Module._zoomTo(zoomGoal * (1 + padZoom * _settings.PAD_ZOOM_RATE * deltaTime))
	end

	-- A shot in flight the view follows, not one the player moved it away from
	local shot: boolean = target ~= nil and target:IsA("BasePart") and not holding and not (manualPoint and os.clock() < manualUntil)

	-- The zoom breathes with the action: out so a high shot and the map under it fit, out a little on the glide to the next snail, in a moment at a blast
	local breath: number = 1
	if target and shot then
		local fit: number = (target:GetPivot().Position.Y - shotFloor) / _settings.SHOT_TOP / math.tan(math.rad(camera.FieldOfView / 2))
		breath = math.clamp(fit / zoomGoal, 1, _settings.SHOT_ZOOM_OUT)
	elseif focus and os.clock() < travelUntil then
		breath = 1 + _settings.TRAVEL_ZOOM_OUT * math.min((lastGoal - focus).Magnitude / _settings.TRAVEL_ZOOM_DISTANCE, 1)
	end
	breath *= 1 - kick * math.clamp((kickUntil - os.clock()) / _settings.BLAST_KICK_SECONDS, 0, 1)

	-- Ease the zoom first, so the bounds clamp the view at its new size; a knockout's punch-in closes in, and breathing out stops at ZOOM_MAX
	local wantedZoom: number = if punching then zoomGoal * _settings.PUNCH_ZOOM else math.min(zoomGoal * breath, math.max(zoomGoal, _settings.ZOOM_MAX))
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

	-- A shot, or a snail a blow sent flying, moves the view only once it leaves the middle of the screen, so bounces don't shake it
	local center: Vector3 = if punching
		then punchPoint
		elseif chased then Module._getDeadZoned(blastPoint, camera)
		elseif holding then blastPoint
		elseif target and target:IsA("BasePart") then Module._getDeadZoned(target.Position + lead, camera)
		elseif target then target:GetPivot().Position
		else bounds.Position

	-- A shot rides up to SHOT_TOP of the half screen over the middle before the view rises with it, so the map stays in view under it
	if target and shot then
		center = Vector3.new(center.X, math.min(center.Y, math.max(shotFloor, target:GetPivot().Position.Y - Module._getHalfHeight() * _settings.SHOT_TOP)), center.Z)
	end

	-- The view may rise CEILING_EXTRA over the map's top, so a snail up there is centred; a shot in flight is followed up any height
	local ceiling: number = if shot then math.huge else _settings.CEILING_EXTRA

	-- Where the view sits with no pan: the pan is only what the player moved from there, never the bounds' own push
	local base: Vector3 = Module._getClamped(center, bounds, camera, ceiling)

	-- On the player's own turn the pan goes anywhere in the arena, and eases back to their snail while it moves
	if not holding and target and target:IsA("Model") and I.Match.IsMyTurn() and target.PrimaryPart.AssemblyLinearVelocity.Magnitude >= _settings.RECENTER_MOVE_SPEED then
		pan *= math.exp(-_settings.RECENTER_SPEED * deltaTime)
	end

	local goal: Vector3 = Module._getClamped(base + pan, bounds, camera, ceiling)
	pan = Vector3.new(goal.X - base.X, goal.Y - base.Y, 0)

	-- A view moved by hand stays while the player holds the pan, and MANUAL_HOLD after their last move; then it glides back
	if manualPoint and (dragging or next(touches) ~= nil or I.Console.IsHeld("CameraPan")) then
		manualUntil = math.max(manualUntil, os.clock() + _settings.MANUAL_HOLD)
	end
	local manual: boolean = false
	if manualPoint and os.clock() < manualUntil then
		goal = Module._getClamped(manualPoint, bounds, camera, _settings.CEILING_EXTRA)
		manualPoint = goal
		manual = true
	elseif manualPoint then
		manualPoint = nil
		pan = Vector3.zero
		travelUntil = os.clock() + _settings.TRAVEL_MAX
	end

	-- Taking the camera sets the FOV buff's base, so an open widget's FOV change still adds to it
	if not focus then
		I.Buff.Set("FOV", "Standard", _settings.FOV)
	end
	local speed: number = if manual then _settings.MANUAL_SPEED elseif os.clock() < travelUntil then _settings.TRAVEL_SPEED elseif shot then _settings.SHOT_FOLLOW_SPEED else _settings.FOLLOW_SPEED

	-- A damped spring eases each move in and out, never faster than MAX_SPEED (scaled with the zoom); a hand move and a shot it must keep up with aren't held back
	local maxSpeed: number = if manual or shot then math.huge else _settings.MAX_SPEED * zoom / _settings.DISTANCE
	if focus then
		focus, focusVelocity = Module._getDamped(focus, goal, focusVelocity, 1 / speed, maxSpeed, deltaTime)
	else
		focus = goal
		focusVelocity = Vector3.zero
	end
	if focus and (focus - goal).Magnitude < _settings.TRAVEL_DONE then
		travelUntil = 0

		-- The hand is free again once the view reached the snail whose turn it is
		if target and target:IsA("Model") and target:GetAttribute("Active") then
			turnGlideUntil = 0
		end
	end
	lastGoal = goal

	--[[ Applying ]]

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.lookAt(focus + Vector3.zAxis * zoom, focus)
end

--%%%%%%%%%%%%%%%%%%%% On Explosion

--[[
	Keeps the camera on a blast until the next turn starts, and for at least BLAST_HOLD seconds (BIG_BLAST_HOLD for a big
	one), when it follows shots, so the player sees what the shot did and the camera moves once, to the next snail. The
	view pushes in a moment at the blast (BLAST_KICK, BIG_BLAST_KICK).
]]
function Module._onExplosion(position: Vector3, radius: number, _itemId: string, _shiny: boolean)
	--[[ Checks ]]

	-- Skip when the camera doesn't follow shots, so it never jumps to a blast
	if not I.PlayerSettings.Get("CameraFollowsShot") then
		return
	end

	--[[ Holding ]]

	local big: boolean = radius >= _settings.BIG_BLAST_RADIUS
	Module._hold(position, if big then _settings.BIG_BLAST_HOLD else _settings.BLAST_HOLD)
	kick = if big then _settings.BIG_BLAST_KICK else _settings.BLAST_KICK
	kickUntil = os.clock() + _settings.BLAST_KICK_SECONDS
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
	Every turn, the first too, starts on the snail whose turn it is: the camera leaves the last blast and wherever the
	player moved it by hand, and glides over, ignoring their hand until it gets there.
]]
function Module._onTurnStarted(_activeId: string)
	--[[ Saving ]]

	blastHeld = false
	blastUntil = 0
	manualPoint = nil
	pan = Vector3.zero
	travelUntil = os.clock() + _settings.TRAVEL_MAX
	turnGlideUntil = travelUntil
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

	--[[ Moving ]]

	Module._addPan(Vector3.new(-pixels.X, pixels.Y, 0) * studsPerPixel)
end

--%%%%%%%%%%%%%%%%%%%% Add Pan

--[[
	Moves the view by hand some studs: on the player's own turn before the shot, the pan from their snail; else the
	view leaves what it follows and stays where the player puts it, until MANUAL_HOLD after their last move. Nothing
	moves while a new turn's glide takes the view to its snail.
]]
function Module._addPan(move: Vector3)
	--[[ Checks ]]

	-- Check if the camera is in a match yet, and not gliding to a new turn's snail
	if not focus or os.clock() < turnGlideUntil then
		return
	end

	--[[ Saving ]]

	if Module._isAiming() then
		pan += move
		return
	end
	manualPoint = (manualPoint or focus) + move
	manualUntil = os.clock() + _settings.MANUAL_HOLD
end

--%%%%%%%%%%%%%%%%%%%% On Touch Moved

--[[
	A finger on the arena moved: one finger drags the view (unless it points the aim on the player's turn), two drag it
	by their middle and zoom as they spread or pinch.
]]
function Module._onTouchMoved(input: InputObject)
	--[[ Local Variables ]]

	local last: Vector2 = touches[input]
	local position: Vector2 = Vector2.new(input.Position.X, input.Position.Y)
	local other: Vector2? = nil
	local count: number = 0
	for touch: InputObject, at: Vector2 in pairs(touches) do
		count += 1
		if touch ~= input then
			other = at
		end
	end
	touches[input] = position

	--[[ Moving ]]

	-- One finger drags, unless it points the aim
	if count == 1 then
		if not Module._isAiming() then
			Module._panBy(position - last)
		end
		return
	end

	-- Two fingers drag by their middle, which moves half as far as one of them, and zoom by how their distance changed
	Module._panBy((position - last) / 2)
	local before: number = (last - other).Magnitude
	local after: number = (position - other).Magnitude
	if before > 0 and after > 0 then
		Module._zoomTo(zoomGoal * before / after)
	end
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

	--[[ Checks ]]

	-- Check if the mouse is inside the window (it reads -1, -1 once it leaves)
	if mouse.X < 0 or mouse.Y < 0 or mouse.X > camera.ViewportSize.X or mouse.Y > camera.ViewportSize.Y then
		return 0
	end

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
	Returns a snail in play moving faster than CHASE_SPEED (a blow sent it flying, or it fell): the one the camera
	already chases while it still does, else the fastest; nil when none does.
]]
--- @return Model?
function Module._getFlyingSnail()
	--[[ Checks ]]

	-- Keep the snail it chases while that one still flies (a knocked-out snail's anchored ball keeps its last speed: never chased)
	if chased and chased.Parent == snailsFolder and chased:GetAttribute("Alive") and chased.PrimaryPart and chased.PrimaryPart.AssemblyLinearVelocity.Magnitude >= _settings.CHASE_SPEED then
		return chased
	end

	--[[ Finding ]]

	local fastest: Model? = nil
	local fastestSpeed: number = _settings.CHASE_SPEED
	for _index: number, model: Instance in ipairs(snailsFolder:GetChildren()) do
		if model:IsA("Model") and model:GetAttribute("Alive") and model.PrimaryPart and model.PrimaryPart.AssemblyLinearVelocity.Magnitude >= fastestSpeed then
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
	`ceiling` studs, their sides widened by SIDE_EXTRA of half the view's width, so a snail at the map's edge can sit
	mid-screen), on the bounds' plane; along an axis where the view is wider than that, the bounds' middle.
]]
--- @return Vector3
function Module._getClamped(point: Vector3, bounds: BasePart, camera: Camera, ceiling: number)
	--[[ Local Variables ]]

	local halfHeight: number = Module._getHalfHeight()
	local halfWidth: number = halfHeight * camera.ViewportSize.X / camera.ViewportSize.Y
	local side: Vector3 = Vector3.xAxis * halfWidth * _settings.SIDE_EXTRA
	local low: Vector3 = bounds.Position - bounds.Size / 2 - side
	local high: Vector3 = bounds.Position + bounds.Size / 2 + side

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

--%%%%%%%%%%%%%%%%%%%% Get Damped

--[[
	Returns a point moved one frame toward a goal on a critically damped spring that settles in about `smoothTime`
	seconds, never faster than `maxSpeed` studs a second, and its new velocity (Unity's SmoothDamp).
]]
--- @return Vector3
--- @return Vector3
function Module._getDamped(current: Vector3, goal: Vector3, velocity: Vector3, smoothTime: number, maxSpeed: number, deltaTime: number)
	--[[ Local Variables ]]

	local omega: number = 2 / math.max(smoothTime, 0.0001)
	local x: number = omega * deltaTime
	local decay: number = 1 / (1 + x + 0.48 * x * x + 0.235 * x * x * x)
	local change: Vector3 = current - goal

	-- The spring pulls at most as hard as reaching maxSpeed would
	local maxChange: number = maxSpeed * smoothTime
	if change.Magnitude > maxChange then
		change = change.Unit * maxChange
	end
	local pull: Vector3 = (velocity + omega * change) * deltaTime

	--[[ Returning ]]

	return current - change + (change + pull) * decay, (velocity - omega * pull) * decay
end

--%%%%%%%%%%%%%%%%%%%% Get Dead Zoned

--[[
	Returns where the view should center to keep a point inside the middle of the screen (DEAD_ZONE of the view's half
	size around where it looks now): where it looks while the point is inside, else moved just enough to bring it back.
]]
--- @return Vector3
function Module._getDeadZoned(point: Vector3, camera: Camera)
	--[[ Checks ]]

	-- Check if the camera looks somewhere yet
	if not focus then
		return point
	end

	--[[ Local Variables ]]

	local halfHeight: number = Module._getHalfHeight() * _settings.DEAD_ZONE
	local halfWidth: number = halfHeight * camera.ViewportSize.X / camera.ViewportSize.Y
	local offset: Vector3 = point - focus

	--[[ Returning ]]

	return focus + Vector3.new(offset.X - math.clamp(offset.X, -halfWidth, halfWidth), offset.Y - math.clamp(offset.Y, -halfHeight, halfHeight), 0)
end

--%%%%%%%%%%%%%%%%%%%% Is Aiming

--[[
	Returns whether it's the player's own turn before their shot, when the camera stays with their snail.
]]
--- @return boolean
function Module._isAiming()
	return I.Match.IsMyTurn() and I.Match.GetPhase() == "Turn"
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
