--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { [string]: Vector2 }
local HANDLE_EDGES = {
	S_ResizeTop = Vector2.new(0, -1),
	S_ResizeBottom = Vector2.new(0, 1),
	S_ResizeLeft = Vector2.new(-1, 0),
	S_ResizeRight = Vector2.new(1, 0),
	S_ResizeTopLeft = Vector2.new(-1, -1),
	S_ResizeTopRight = Vector2.new(1, -1),
	S_ResizeBottomLeft = Vector2.new(-1, 1),
	S_ResizeBottomRight = Vector2.new(1, 1),
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Input Position

--[[
	Returns an input's position on screen.
]]
--- @return Vector2
local function getInputPosition(input: InputObject)
	return Vector2.new(input.Position.X, input.Position.Y)
end

--%%%%%%%%%%%%%%%%%%%% Is Press Input

--[[
	Returns whether an input belongs to a window's followed press: the same touch, or the mouse while the press is a
	click.
]]
--- @param window AdminPanel_Window
--- @return boolean
local function isPressInput(window, input: InputObject, mouseType: Enum.UserInputType)
	--[[ Checks ]]

	-- Check if a press is followed
	if not window.PressInput then
		return false
	end

	--[[ Returning ]]

	return input == window.PressInput or (input.UserInputType == mouseType and window.PressInput.UserInputType == Enum.UserInputType.MouseButton1)
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

--- @class AdminPanel_Client_Window
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Bind

--[[
	Makes a panel a window: its `S_Header` drags it and its `ResizeHandles` resize it, never below `minSize`, with its
	`EdgeGlow` lit where a press would grab. Each panel keeps its own state, so several windows can be open together.
]]
function Module.Bind(panel: Frame, minSize: Vector2)
	--[[ Elements ]]

	local header: ImageButton = panel:FindFirstChild("S_Header", true)
	local edgeGlow: Frame = panel:FindFirstChild("EdgeGlow")

	--[[ State ]]

	--- @type AdminPanel_Window
	local window = {
		Panel = panel,
		Screen = panel:FindFirstAncestorWhichIsA("GuiBase2d"),
		MinSize = minSize,
		Segment = edgeGlow:FindFirstChild("Segment"),
		Corner = edgeGlow:FindFirstChild("Corner"),
		ResizeHandles = panel:FindFirstChild("ResizeHandles"),
		GlowLit = "",
		PressInput = nil,
		PressStart = Vector2.zero,
		PressMin = Vector2.zero,
		PressMax = Vector2.zero,
		PressEdges = Vector2.zero,
	}

	--[[ Drag ]]

	header.InputBegan:Connect(function(input: InputObject)
		Module._onPressBegan(window, input, Vector2.zero)
	end)

	--[[ Resize ]]

	for handleName: string, edges: Vector2 in pairs(HANDLE_EDGES) do
		local handle: ImageButton = panel:FindFirstChild(handleName, true)
		handle.InputBegan:Connect(function(input: InputObject)
			Module._onPressBegan(window, input, edges)
		end)
	end

	--[[ Connections ]]

	I.S.UserInputService.InputChanged:Connect(function(input: InputObject)
		Module._onPressMoved(window, input)
		Module._onPointerMoved(window, input)
	end)
	I.S.UserInputService.InputEnded:Connect(function(input: InputObject)
		Module._onPressEnded(window, input)
	end)
	window.Screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		Module._keepOnScreen(window)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Press Began

--[[
	Starts following a click or touch on the header (a drag, `edges` zero) or on a resize handle (the edges it moves).
	The first resize drops the aspect ratio the panel starts with, at the size it shows.
]]
--- @param window AdminPanel_Window
function Module._onPressBegan(window, input: InputObject, edges: Vector2)
	--[[ Checks ]]

	-- Skip anything but a click or a touch, and a second press while one is followed
	if (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) or window.PressInput then
		return
	end

	--[[ Saving ]]

	window.PressInput = input
	window.PressStart = getInputPosition(input)
	window.PressMin = window.Panel.AbsolutePosition
	window.PressMax = window.Panel.AbsolutePosition + window.Panel.AbsoluteSize
	window.PressEdges = edges

	--[[ Aspect Ratio ]]

	local aspect: UIAspectRatioConstraint? = window.Panel:FindFirstChildOfClass("UIAspectRatioConstraint")

	-- Free the panel's shape on its first resize, writing the size it shows first so it doesn't jump
	if edges ~= Vector2.zero and aspect then
		Module._place(window, window.PressMin, window.PressMax, true)
		aspect.Parent = nil
	end

	--[[ Glow ]]

	Module._setGlow(window, edges, window.PressStart)
end

--%%%%%%%%%%%%%%%%%%%% On Press Moved

--[[
	Moves the panel with the followed press, kept on screen, or moves the edges its handle holds, kept on screen and at
	least the window's smallest size.
]]
--- @param window AdminPanel_Window
function Module._onPressMoved(window, input: InputObject)
	--[[ Checks ]]

	-- Skip moves of anything but the followed press
	if not isPressInput(window, input, Enum.UserInputType.MouseMovement) then
		return
	end

	--[[ Local Variables ]]

	local delta: Vector2 = getInputPosition(input) - window.PressStart
	local min: Vector2
	local max: Vector2

	--[[ Moving ]]

	if window.PressEdges == Vector2.zero then
		min, max = Module._getDragRect(window, delta)
		Module._place(window, min, max, false)
	else
		min, max = Module._getResizeRect(window, delta)
		Module._place(window, min, max, true)
		Module._setGlow(window, window.PressEdges, getInputPosition(input))
	end
end

--%%%%%%%%%%%%%%%%%%%% On Press Ended

--[[
	Ends the followed press, and lights whatever edge the pointer is near now.
]]
--- @param window AdminPanel_Window
function Module._onPressEnded(window, input: InputObject)
	--[[ Checks ]]

	-- Skip the end of anything but the followed press
	if not isPressInput(window, input, Enum.UserInputType.MouseButton1) then
		return
	end

	--[[ Saving ]]

	window.PressInput = nil

	--[[ Glow ]]

	Module._glowAt(window, getInputPosition(input))
end

--%%%%%%%%%%%%%%%%%%%% On Pointer Moved

--[[
	Lights the edge the mouse is near while nothing is pressed (a resize keeps its own edges lit).
]]
--- @param window AdminPanel_Window
function Module._onPointerMoved(window, input: InputObject)
	--[[ Checks ]]

	-- Skip anything but the mouse moving with no press followed
	if input.UserInputType ~= Enum.UserInputType.MouseMovement or window.PressInput then
		return
	end

	--[[ Glow ]]

	Module._glowAt(window, getInputPosition(input))
end

--%%%%%%%%%%%%%%%%%%%% Glow At

--[[
	Lights the panel's edge or corner a point is near, where the panel can be resized (the handles show: Desktop); puts
	the glow out anywhere else.
]]
--- @param window AdminPanel_Window
function Module._glowAt(window, point: Vector2)
	--[[ Checks ]]

	-- Glow only where the handles show
	if not window.ResizeHandles.Visible then
		Module._setGlow(window, Vector2.zero, point)
		return
	end

	--[[ Glowing ]]

	Module._setGlow(window, Module._getNearEdges(window, point), point)
end

--%%%%%%%%%%%%%%%%%%%% Set Glow

--[[
	Lights the glow at `point` on the given edges, over the panel's border and as thick as it: on a corner, the ring as
	round as the panel's corners, turned to light only that corner's curve; on an edge, the short bar under the point,
	wholly on the edge's straight part. No edges puts it out. Only a change of lit part fades.
]]
--- @param window AdminPanel_Window
function Module._setGlow(window, edges: Vector2, point: Vector2)
	--[[ Local Variables ]]

	local panel: Frame = window.Panel
	local corner: UICorner = panel:FindFirstChildOfClass("UICorner")
	local border: UIStroke = panel:FindFirstChildOfClass("UIStroke")
	local lit: string = if edges == Vector2.zero then "" elseif edges.X ~= 0 and edges.Y ~= 0 then "Corner" else "Segment"
	local anchor: Vector2 = (edges + Vector2.one) / 2

	--[[ Corner ]]

	if lit == "Corner" then
		local ringCorner: UICorner = window.Corner:FindFirstChildOfClass("UICorner")
		local ring: UIStroke = window.Corner:FindFirstChildOfClass("UIStroke")
		local gradient: UIGradient = ring:FindFirstChildOfClass("UIGradient")
		ringCorner.CornerRadius = corner.CornerRadius
		ring.Thickness = border.Thickness
		window.Corner.Size = UDim2.fromOffset(corner.CornerRadius.Offset * 2, corner.CornerRadius.Offset * 2)
		window.Corner.AnchorPoint = anchor
		window.Corner.Position = UDim2.fromScale(anchor.X, anchor.Y)
		gradient.Rotation = math.deg(math.atan2(-edges.Y, -edges.X))
	end

	--[[ Segment ]]

	if lit == "Segment" then
		local gradient: UIGradient = window.Segment:FindFirstChildOfClass("UIGradient")
		local horizontal: boolean = edges.Y ~= 0
		local panelSize: Vector2 = panel.AbsoluteSize
		local edgeLength: number = if horizontal then panelSize.X else panelSize.Y
		local along: Vector2 = point - panel.AbsolutePosition

		-- Screen pixels per offset pixel, since a device scale may size the panel
		local zoom: number = if window.Corner.Size.X.Offset > 0 then window.Corner.AbsoluteSize.X / window.Corner.Size.X.Offset else 1

		-- The edge's straight part between its rounded corners: the bar fits in it
		local radius: number = corner.CornerRadius.Offset * zoom
		local straight: number = math.max(edgeLength - radius * 2, 0)
		local length: number = math.min(_settings.GLOW_SEGMENT_LENGTH * zoom, straight)
		local centre: number = math.clamp(if horizontal then along.X else along.Y, radius + length / 2, edgeLength - radius - length / 2)

		-- Lay it just outside the edge, across the top or bottom, or down the left or right
		if horizontal then
			window.Segment.AnchorPoint = Vector2.new(0.5, 1 - anchor.Y)
			window.Segment.Position = UDim2.fromScale(centre / panelSize.X, anchor.Y)
			window.Segment.Size = UDim2.fromOffset(length / zoom, border.Thickness)
			gradient.Rotation = 0
		else
			window.Segment.AnchorPoint = Vector2.new(1 - anchor.X, 0.5)
			window.Segment.Position = UDim2.fromScale(anchor.X, centre / panelSize.Y)
			window.Segment.Size = UDim2.fromOffset(border.Thickness, length / zoom)
			gradient.Rotation = 90
		end
	end

	--[[ Checks ]]

	-- Skip the fade when the same part stays lit
	if lit == window.GlowLit then
		return
	end

	--[[ Fading ]]

	window.GlowLit = lit

	local Segment_TweenGoal = { BackgroundTransparency = if lit == "Segment" then 0 else 1 }
	local Segment_Tween: Tween = I.S.TweenService:Create(window.Segment, _settings.GLOW_TWEEN, Segment_TweenGoal)
	Segment_Tween:Play()

	local Corner_TweenGoal = { Transparency = if lit == "Corner" then 0 else 1 }
	local Corner_Tween: Tween = I.S.TweenService:Create(window.Corner:FindFirstChildOfClass("UIStroke"), _settings.GLOW_TWEEN, Corner_TweenGoal)
	Corner_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Keep On Screen

--[[
	Pulls the panel back inside the screen after the screen changed size.
]]
--- @param window AdminPanel_Window
function Module._keepOnScreen(window)
	--[[ Checks ]]

	-- Skip while a press is moving it
	if window.PressInput then
		return
	end

	--[[ Local Variables ]]

	local min: Vector2
	local max: Vector2
	window.PressMin = window.Panel.AbsolutePosition
	window.PressMax = window.Panel.AbsolutePosition + window.Panel.AbsoluteSize
	min, max = Module._getDragRect(window, Vector2.zero)

	--[[ Moving ]]

	Module._place(window, min, max, false)
end

--%%%%%%%%%%%%%%%%%%%% Place

--[[
	Puts the panel's corners at two points on screen: its anchor point always, its size too after a resize, both as
	scale of the screen.
]]
--- @param window AdminPanel_Window
function Module._place(window, min: Vector2, max: Vector2, resize: boolean)
	--[[ Local Variables ]]

	local panel: Frame = window.Panel
	local screenPosition: Vector2 = window.Screen.AbsolutePosition
	local screenSize: Vector2 = window.Screen.AbsoluteSize
	local anchor: Vector2 = min + (max - min) * panel.AnchorPoint - screenPosition

	--[[ Moving ]]

	panel.Position = UDim2.fromScale(anchor.X / screenSize.X, anchor.Y / screenSize.Y)

	-- Size it only on a resize: a drag keeps whatever size it has, its device scale included
	if resize then
		panel.Size = UDim2.fromScale((max.X - min.X) / screenSize.X, (max.Y - min.Y) / screenSize.Y)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Near Edges

--[[
	Returns the panel's edges a point would resize: those of the resize handle under it, none away from every handle.
]]
--- @param window AdminPanel_Window
--- @return Vector2
function Module._getNearEdges(window, point: Vector2)
	--[[ Finding ]]

	for _index: number, handle: Instance in ipairs(window.ResizeHandles:GetChildren()) do
		--[[ Checks ]]

		-- Skip anything that isn't a handle
		if not handle:IsA("GuiButton") then
			continue
		end

		--[[ Local Variables ]]

		local min: Vector2 = handle.AbsolutePosition
		local max: Vector2 = handle.AbsolutePosition + handle.AbsoluteSize

		--[[ Returning ]]

		-- Return the handle's edges when the point is on it
		if point.X >= min.X and point.X <= max.X and point.Y >= min.Y and point.Y <= max.Y then
			return HANDLE_EDGES[handle.Name]
		end
	end

	--[[ Returning ]]

	return Vector2.zero
end

--%%%%%%%%%%%%%%%%%%%% Get Screen Bounds

--[[
	Returns the area on screen the panel may use: the screen less `SCREEN_MARGIN` on every side.
]]
--- @param window AdminPanel_Window
--- @return Vector2
--- @return Vector2
function Module._getScreenBounds(window)
	return window.Screen.AbsolutePosition + Vector2.one * _settings.SCREEN_MARGIN, window.Screen.AbsolutePosition + window.Screen.AbsoluteSize - Vector2.one * _settings.SCREEN_MARGIN
end

--%%%%%%%%%%%%%%%%%%%% Get Drag Rect

--[[
	Returns the panel's corners after the press moved by `delta`: the same size, moved, then pushed back inside the
	screen's bounds.
]]
--- @param window AdminPanel_Window
--- @return Vector2
--- @return Vector2
function Module._getDragRect(window, delta: Vector2)
	--[[ Local Variables ]]

	local boundsMin: Vector2
	local boundsMax: Vector2
	boundsMin, boundsMax = Module._getScreenBounds(window)
	local size: Vector2 = window.PressMax - window.PressMin
	local target: Vector2 = window.PressMin + delta

	--[[ Returning ]]

	local min: Vector2 = Vector2.new(math.max(boundsMin.X, math.min(target.X, boundsMax.X - size.X)), math.max(boundsMin.Y, math.min(target.Y, boundsMax.Y - size.Y)))
	return min, min + size
end

--%%%%%%%%%%%%%%%%%%%% Get Resize Rect

--[[
	Returns the panel's corners after the press moved its handle's edges by `delta`: each moved edge stays inside the
	screen's bounds and at least the smallest size from the opposite edge, which stays where it was.
]]
--- @param window AdminPanel_Window
--- @return Vector2
--- @return Vector2
function Module._getResizeRect(window, delta: Vector2)
	--[[ Local Variables ]]

	local boundsMin: Vector2
	local boundsMax: Vector2
	boundsMin, boundsMax = Module._getScreenBounds(window)
	local pressMin: Vector2 = window.PressMin
	local pressMax: Vector2 = window.PressMax
	local minSize: Vector2 = window.MinSize
	local left: number = pressMin.X
	local top: number = pressMin.Y
	local right: number = pressMax.X
	local bottom: number = pressMax.Y

	--[[ Moving ]]

	if window.PressEdges.X < 0 then
		left = math.max(boundsMin.X, math.min(pressMin.X + delta.X, pressMax.X - minSize.X))
	elseif window.PressEdges.X > 0 then
		right = math.min(boundsMax.X, math.max(pressMax.X + delta.X, pressMin.X + minSize.X))
	end

	if window.PressEdges.Y < 0 then
		top = math.max(boundsMin.Y, math.min(pressMin.Y + delta.Y, pressMax.Y - minSize.Y))
	elseif window.PressEdges.Y > 0 then
		bottom = math.min(boundsMax.Y, math.max(pressMax.Y + delta.Y, pressMin.Y + minSize.Y))
	end

	--[[ Returning ]]

	return Vector2.new(left, top), Vector2.new(right, bottom)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
