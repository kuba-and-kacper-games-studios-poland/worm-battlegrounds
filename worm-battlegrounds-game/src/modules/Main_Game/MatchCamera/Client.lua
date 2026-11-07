--[[
	Created By: 	Nari
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

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	arenaFolder = I.Dirs.UmeWorkspace:WaitForChild("Arena")
	snailsFolder = I.Dirs.UmeWorkspace:WaitForChild("Snails")
	combatFolder = I.Dirs.UmeWorkspace:WaitForChild("Combat")
	Module._createConnections()

	-- Before CameraShake's step (Camera + 1), so Combat's blast shakes land on top of the view
	I.S.RunService:BindToRenderStep(_localName, Enum.RenderPriority.Camera.Value, Module._update)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Wires the pan inputs (dragging with the right mouse button, two fingers on touch, LT with the right stick, and
	whether the window has focus for the edge pan) and the zoom inputs (the mouse wheel, a pinch).
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
		elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
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
		elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
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
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	Points the camera along -Z at what it follows (the active snail, else the local player's snail, else the arena's
	middle), plus the player's pan, kept inside the arena's bounds. Nothing changes until a map is loaded, or while
	the player is in the Studio map's lobby, which gets Roblox's camera back.
]]
function Module._update(deltaTime: number)
	--[[ Checks ]]

	-- Check if the player is in the match
	if not I.S.Players.LocalPlayer:GetAttribute("InMatch") then
		if focus then
			focus = nil
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

	-- A new snail to follow drops the pan
	if target ~= followed then
		followed = target
		pan = Vector3.zero
	end

	-- LT with the right stick pans, and so does the mouse at the screen's left or right edge
	if stickPan.Magnitude >= _settings.STICK_DEADZONE and I.S.UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonL2) then
		pan += Vector3.new(stickPan.X, stickPan.Y, 0) * _settings.STICK_PAN_SPEED * deltaTime
	end
	pan += Vector3.xAxis * Module._getEdgePan(camera) * _settings.EDGE_PAN_SPEED * deltaTime

	-- Ease the zoom first, so the bounds clamp the view at its new size
	zoom += (zoomGoal - zoom) * (1 - math.exp(-_settings.ZOOM_SPEED * deltaTime))

	local center: Vector3 = if target then target:GetPivot().Position else bounds.Position
	local goal: Vector3 = Module._getClamped(center + pan, bounds, camera)
	pan = goal - Vector3.new(center.X, center.Y, goal.Z)

	-- Taking the camera sets the FOV buff's base, so an open widget's FOV change still adds to it
	if not focus then
		I.Buff.Set("FOV", "Standard", _settings.FOV)
	end
	focus = if focus then focus:Lerp(goal, 1 - math.exp(-_settings.FOLLOW_SPEED * deltaTime)) else goal

	--[[ Applying ]]

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.lookAt(focus + Vector3.zAxis * zoom, focus)
end

--%%%%%%%%%%%%%%%%%%%% Zoom To

--[[
	Sets how far from the plane the player wants the camera, kept between ZOOM_MIN and ZOOM_MAX.
]]
function Module._zoomTo(distance: number)
	--[[ Saving ]]

	zoomGoal = math.clamp(distance, _settings.ZOOM_MIN, _settings.ZOOM_MAX)
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
	Returns what the camera follows: a shot in flight (the first part with the Projectile attribute) when
	the player's CameraFollowsShot setting is on, else the snail whose turn it is (its Active attribute), else the local player's.
]]
--- @return PVInstance?
function Module._getTarget()
	--[[ Shots ]]

	if I.PlayerSettings.Get("CameraFollowsShot") then
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

	--[[ Returning ]]

	local mine: Model? = I.Snails.GetMine()
	return if mine and mine.PrimaryPart then mine else nil
end

--%%%%%%%%%%%%%%%%%%%% Get Clamped

--[[
	Returns a point moved just enough that the view centered on it stays inside the bounds, on the bounds' plane;
	along an axis where the view is wider than the bounds, the bounds' middle.
]]
--- @return Vector3
function Module._getClamped(point: Vector3, bounds: BasePart, camera: Camera)
	--[[ Local Variables ]]

	local halfHeight: number = Module._getHalfHeight()
	local halfWidth: number = halfHeight * camera.ViewportSize.X / camera.ViewportSize.Y
	local low: Vector3 = bounds.Position - bounds.Size / 2
	local high: Vector3 = bounds.Position + bounds.Size / 2
	local x: number = bounds.Position.X
	local y: number = bounds.Position.Y

	--[[ Clamping ]]

	if high.X - low.X > halfWidth * 2 then
		x = math.clamp(point.X, low.X + halfWidth, high.X - halfWidth)
	end
	if high.Y - low.Y > halfHeight * 2 then
		y = math.clamp(point.Y, low.Y + halfHeight, high.Y - halfHeight)
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
