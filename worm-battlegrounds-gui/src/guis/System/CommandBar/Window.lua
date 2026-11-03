--[[
	Created By: 	Nari
]]

local _localName: string = "CommandBarWindow"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local TweenService: TweenService = game:GetService("TweenService")
local UserInputService: UserInputService = game:GetService("UserInputService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Drag And Resize ]]

-- Pixels kept between the panel and the screen's edges
local SCREEN_MARGIN: number = 8
-- The panel's edges each resize handle moves: -1 its left or top edge, 1 its right or bottom one
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

--[[ Panel ]]

-- The bound panel, the smallest size a resize leaves it, the frame or ScreenGui it is positioned in (its nearest
-- sized ancestor: the Gui tool's stage in a preview), and the connections made for it
local boundPanel: Frame? = nil
local minSize: Vector2 = Vector2.zero
local screen: GuiBase2d? = nil
local connections = {} --- @type { RBXScriptConnection }

--[[ Press ]]

-- The followed press, where it began, the panel's corners on screen then, and the edges it moves (none: a drag)
local pressInput: InputObject? = nil
local pressStart: Vector2 = Vector2.zero
local pressMin: Vector2 = Vector2.zero
local pressMax: Vector2 = Vector2.zero
local pressEdges: Vector2 = Vector2.zero

--[[ Edge Glow ]]

-- The glowing bar's longest length, and how fast the glow fades in and out (it is fully opaque while lit, as thick
-- as the panel's border). It lights wherever a resize handle is under the pointer
local SEGMENT_LENGTH: number = 60
local Glow_TweenInfo: TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

-- The glow's parts on the bound panel, the handles' frame (hidden on every device but Desktop), and which part is lit
local glowSegment: Frame? = nil
local glowCorner: Frame? = nil
local resizeHandles: Frame? = nil
local glowLit: string = ""

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
	Returns whether an input belongs to the followed press: the same touch, or the mouse while the press is a click.
]]
--- @return boolean
local function isPressInput(input: InputObject, mouseType: Enum.UserInputType)
	--[[ Checks ]]

	-- Check if a press is followed
	if not pressInput then
		return false
	end

	--[[ Returning ]]

	return input == pressInput or (input.UserInputType == mouseType and pressInput.UserInputType == Enum.UserInputType.MouseButton1)
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

--- @class UmeGui_Guis_System_CommandBar_Window
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Bind

--[[
	Makes a panel a window: its S_Header drags it and its ResizeHandles resize it, never below `size`, with its
	EdgeGlow lit where a press would grab. Binds one panel at a time: binding another lets go of the last, and a panel
	lets go once it leaves the place. Binding the bound panel again only updates its smallest size.
]]
function Module.Bind(root: Frame, size: Vector2)
	--[[ Saving ]]

	minSize = size

	--[[ Checks ]]

	-- Skip a panel that is already bound
	if root == boundPanel then
		return
	end

	--[[ Cleaning ]]

	Module._unbind()

	--[[ Elements ]]

	local header: ImageButton = root:FindFirstChild("S_Header", true)
	local edgeGlow: Frame = root:FindFirstChild("EdgeGlow")
	glowSegment = edgeGlow:FindFirstChild("Segment")
	glowCorner = edgeGlow:FindFirstChild("Corner")
	glowLit = ""
	resizeHandles = root:FindFirstChild("ResizeHandles")
	boundPanel = root
	screen = root:FindFirstAncestorWhichIsA("GuiBase2d")

	--[[ Drag ]]

	table.insert(
		connections,
		header.InputBegan:Connect(function(input: InputObject)
			Module._onPressBegan(input, Vector2.zero)
		end)
	)

	--[[ Resize ]]

	for handleName: string, edges: Vector2 in pairs(HANDLE_EDGES) do
		local handle: ImageButton = root:FindFirstChild(handleName, true)
		table.insert(
			connections,
			handle.InputBegan:Connect(function(input: InputObject)
				Module._onPressBegan(input, edges)
			end)
		)
	end

	--[[ Connections ]]

	table.insert(connections, UserInputService.InputChanged:Connect(Module._onPressMoved))
	table.insert(connections, UserInputService.InputChanged:Connect(Module._onPointerMoved))
	table.insert(connections, UserInputService.InputEnded:Connect(Module._onPressEnded))
	table.insert(connections, screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(Module._keepOnScreen))
	table.insert(
		connections,
		root.AncestryChanged:Connect(function()
			-- Let go once the panel leaves the place: a rebuild, or a live reload that loads a new copy of this module
			if not root:IsDescendantOf(game) then
				Module._unbind()
			end
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Unbind

--[[
	Disconnects the bound view's connections and forgets its panel and press.
]]
function Module._unbind()
	--[[ Cleaning ]]

	for _index: number, connection: RBXScriptConnection in ipairs(connections) do
		connection:Disconnect()
	end
	table.clear(connections)

	--[[ Saving ]]

	boundPanel = nil
	screen = nil
	glowSegment = nil
	glowCorner = nil
	resizeHandles = nil
	pressInput = nil
end

--%%%%%%%%%%%%%%%%%%%% On Press Began

--[[
	Starts following a click or touch on the header (a drag, `edges` zero) or on a resize handle (the edges it moves).
	A resize sizes the panel by the pointer from then on, so it drops the aspect ratio the panel starts with.
]]
function Module._onPressBegan(input: InputObject, edges: Vector2)
	--[[ Checks ]]

	-- Skip anything but a click or a touch, and a second press while one is followed
	if (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) or pressInput then
		return
	end

	--[[ Saving ]]

	pressInput = input
	pressStart = getInputPosition(input)
	pressMin = boundPanel.AbsolutePosition
	pressMax = boundPanel.AbsolutePosition + boundPanel.AbsoluteSize
	pressEdges = edges

	--[[ Aspect Ratio ]]

	local aspect: UIAspectRatioConstraint? = boundPanel:FindFirstChildOfClass("UIAspectRatioConstraint")

	-- Free the panel's shape on its first resize, at the size it shows now: its Size alone is the unconstrained
	-- scale, so writing the shown size first keeps it from jumping when the constraint goes
	if edges ~= Vector2.zero and aspect then
		Module._place(pressMin, pressMax, true)
		aspect.Parent = nil
	end

	--[[ Glow ]]

	-- A resize keeps its edges lit under the pointer until it ends; a drag puts the glow out
	Module._setGlow(edges, pressStart)
end

--%%%%%%%%%%%%%%%%%%%% On Press Moved

--[[
	Moves the panel with the followed press, kept on screen, or moves the edges its handle holds, kept on screen and
	at least minSize.
]]
function Module._onPressMoved(input: InputObject)
	--[[ Checks ]]

	-- Skip moves of anything but the followed press
	if not isPressInput(input, Enum.UserInputType.MouseMovement) then
		return
	end

	--[[ Local Variables ]]

	local delta: Vector2 = getInputPosition(input) - pressStart
	local min: Vector2
	local max: Vector2

	--[[ Moving ]]

	if pressEdges == Vector2.zero then
		min, max = Module._getDragRect(delta)
		Module._place(min, max, false)
	else
		min, max = Module._getResizeRect(delta)
		Module._place(min, max, true)
		Module._setGlow(pressEdges, getInputPosition(input))
	end
end

--%%%%%%%%%%%%%%%%%%%% On Press Ended

--[[
	Ends the followed press, and lights whatever edge the pointer is near now.
]]
function Module._onPressEnded(input: InputObject)
	--[[ Checks ]]

	-- Skip the end of anything but the followed press
	if not isPressInput(input, Enum.UserInputType.MouseButton1) then
		return
	end

	--[[ Saving ]]

	pressInput = nil

	--[[ Glow ]]

	Module._glowAt(getInputPosition(input))
end

--%%%%%%%%%%%%%%%%%%%% On Pointer Moved

--[[
	Lights the edge the mouse is near while nothing is pressed (a resize keeps its own edges lit).
]]
function Module._onPointerMoved(input: InputObject)
	--[[ Checks ]]

	-- Skip anything but the mouse moving with no press followed
	if input.UserInputType ~= Enum.UserInputType.MouseMovement or pressInput then
		return
	end

	--[[ Glow ]]

	Module._glowAt(getInputPosition(input))
end

--%%%%%%%%%%%%%%%%%%%% Glow At

--[[
	Lights the panel's edge or corner a point is near, where the panel can be resized (the handles show: Desktop);
	puts the glow out anywhere else.
]]
function Module._glowAt(point: Vector2)
	--[[ Checks ]]

	-- Glow only where the handles show
	if not resizeHandles.Visible then
		Module._setGlow(Vector2.zero, point)
		return
	end

	--[[ Glowing ]]

	Module._setGlow(Module._getNearEdges(point), point)
end

--%%%%%%%%%%%%%%%%%%%% Set Glow

--[[
	Lights the glow at `point` on the given edges, over the panel's border and as thick as it: on a corner, the ring as
	round as the panel's corners, its gradient turned to light only that corner's curve; on an edge, the short bar laid
	along it under the point, wholly on the edge's straight part so it never runs onto a rounded corner. No edges puts
	the glow out. Only a change of lit part fades; the bar follows the point at once.
]]
function Module._setGlow(edges: Vector2, point: Vector2)
	--[[ Local Variables ]]

	local corner: UICorner = boundPanel:FindFirstChildOfClass("UICorner")
	local border: UIStroke = boundPanel:FindFirstChildOfClass("UIStroke")
	local lit: string = if edges == Vector2.zero then "" elseif edges.X ~= 0 and edges.Y ~= 0 then "Corner" else "Segment"
	local anchor: Vector2 = (edges + Vector2.one) / 2

	--[[ Corner ]]

	if lit == "Corner" then
		local ringCorner: UICorner = glowCorner:FindFirstChildOfClass("UICorner")
		local ring: UIStroke = glowCorner:FindFirstChildOfClass("UIStroke")
		local gradient: UIGradient = ring:FindFirstChildOfClass("UIGradient")
		ringCorner.CornerRadius = corner.CornerRadius
		ring.Thickness = border.Thickness
		glowCorner.Size = UDim2.fromOffset(corner.CornerRadius.Offset * 2, corner.CornerRadius.Offset * 2)
		glowCorner.AnchorPoint = anchor
		glowCorner.Position = UDim2.fromScale(anchor.X, anchor.Y)
		gradient.Rotation = math.deg(math.atan2(-edges.Y, -edges.X))
	end

	--[[ Segment ]]

	if lit == "Segment" then
		local gradient: UIGradient = glowSegment:FindFirstChildOfClass("UIGradient")
		local horizontal: boolean = edges.Y ~= 0
		local panelSize: Vector2 = boundPanel.AbsoluteSize
		local edgeLength: number = if horizontal then panelSize.X else panelSize.Y
		local along: Vector2 = point - boundPanel.AbsolutePosition

		-- How many screen pixels one of the glow's offset pixels takes, since the Gui tool may zoom the preview
		local zoom: number = if glowCorner.Size.X.Offset > 0 then glowCorner.AbsoluteSize.X / glowCorner.Size.X.Offset else 1

		-- The edge's straight part, between its two rounded corners: the bar fits in it, shorter when the edge is short
		local radius: number = corner.CornerRadius.Offset * zoom
		local straight: number = math.max(edgeLength - radius * 2, 0)
		local length: number = math.min(SEGMENT_LENGTH * zoom, straight)
		local centre: number = math.clamp(if horizontal then along.X else along.Y, radius + length / 2, edgeLength - radius - length / 2)

		-- Lay it just outside the edge, on the panel's own outline: across the top or bottom, or down the left or right
		if horizontal then
			glowSegment.AnchorPoint = Vector2.new(0.5, 1 - anchor.Y)
			glowSegment.Position = UDim2.fromScale(centre / panelSize.X, anchor.Y)
			glowSegment.Size = UDim2.fromOffset(length / zoom, border.Thickness)
			gradient.Rotation = 0
		else
			glowSegment.AnchorPoint = Vector2.new(1 - anchor.X, 0.5)
			glowSegment.Position = UDim2.fromScale(anchor.X, centre / panelSize.Y)
			glowSegment.Size = UDim2.fromOffset(border.Thickness, length / zoom)
			gradient.Rotation = 90
		end
	end

	--[[ Checks ]]

	-- Skip the fade when the same part stays lit
	if lit == glowLit then
		return
	end

	--[[ Fading ]]

	glowLit = lit

	local Segment_TweenGoal = { BackgroundTransparency = if lit == "Segment" then 0 else 1 }
	local Segment_Tween: Tween = TweenService:Create(glowSegment, Glow_TweenInfo, Segment_TweenGoal)
	Segment_Tween:Play()

	local Corner_TweenGoal = { Transparency = if lit == "Corner" then 0 else 1 }
	local Corner_Tween: Tween = TweenService:Create(glowCorner:FindFirstChildOfClass("UIStroke"), Glow_TweenInfo, Corner_TweenGoal)
	Corner_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Keep On Screen

--[[
	Pulls the panel back inside the screen after the screen changed size.
]]
function Module._keepOnScreen()
	--[[ Checks ]]

	-- Check if a view is bound and no press is moving it
	if not boundPanel or pressInput then
		return
	end

	--[[ Local Variables ]]

	local min: Vector2
	local max: Vector2
	pressMin = boundPanel.AbsolutePosition
	pressMax = boundPanel.AbsolutePosition + boundPanel.AbsoluteSize
	min, max = Module._getDragRect(Vector2.zero)

	--[[ Moving ]]

	Module._place(min, max, false)
end

--%%%%%%%%%%%%%%%%%%%% Place

--[[
	Puts the panel's corners at two points on screen: its anchor point always, its size too after a resize. Both are
	written as scale of the screen, so they hold however the Gui tool zooms the preview.
]]
function Module._place(min: Vector2, max: Vector2, resize: boolean)
	--[[ Local Variables ]]

	local screenPosition: Vector2 = screen.AbsolutePosition
	local screenSize: Vector2 = screen.AbsoluteSize
	local anchor: Vector2 = min + (max - min) * boundPanel.AnchorPoint - screenPosition

	--[[ Moving ]]

	boundPanel.Position = UDim2.fromScale(anchor.X / screenSize.X, anchor.Y / screenSize.Y)

	-- Size it only on a resize: a drag keeps whatever size it has, its device scale included
	if resize then
		boundPanel.Size = UDim2.fromScale((max.X - min.X) / screenSize.X, (max.Y - min.Y) / screenSize.Y)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Near Edges

--[[
	Returns the panel's edges a point would resize: those of the resize handle under it (-1 left or top, 1 right or
	bottom, both for a corner), none away from every handle. So the glow shows exactly where a press grabs.
]]
--- @return Vector2
function Module._getNearEdges(point: Vector2)
	--[[ Finding ]]

	for _index: number, handle: Instance in ipairs(resizeHandles:GetChildren()) do
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
	Returns the area on screen the panel may use: the screen less SCREEN_MARGIN on every side.
]]
--- @return Vector2
--- @return Vector2
function Module._getScreenBounds()
	return screen.AbsolutePosition + Vector2.one * SCREEN_MARGIN, screen.AbsolutePosition + screen.AbsoluteSize - Vector2.one * SCREEN_MARGIN
end

--%%%%%%%%%%%%%%%%%%%% Get Drag Rect

--[[
	Returns the panel's corners after the press moved by `delta`: the same size, moved, then pushed back inside the
	screen's bounds.
]]
--- @return Vector2
--- @return Vector2
function Module._getDragRect(delta: Vector2)
	--[[ Local Variables ]]

	local boundsMin: Vector2
	local boundsMax: Vector2
	boundsMin, boundsMax = Module._getScreenBounds()
	local size: Vector2 = pressMax - pressMin
	local target: Vector2 = pressMin + delta

	--[[ Returning ]]

	local min: Vector2 = Vector2.new(math.max(boundsMin.X, math.min(target.X, boundsMax.X - size.X)), math.max(boundsMin.Y, math.min(target.Y, boundsMax.Y - size.Y)))
	return min, min + size
end

--%%%%%%%%%%%%%%%%%%%% Get Resize Rect

--[[
	Returns the panel's corners after the press moved its handle's edges by `delta`: each moved edge stays inside the
	screen's bounds and at least minSize from the opposite edge, which stays where it was.
]]
--- @return Vector2
--- @return Vector2
function Module._getResizeRect(delta: Vector2)
	--[[ Local Variables ]]

	local boundsMin: Vector2
	local boundsMax: Vector2
	boundsMin, boundsMax = Module._getScreenBounds()
	local left: number = pressMin.X
	local top: number = pressMin.Y
	local right: number = pressMax.X
	local bottom: number = pressMax.Y

	--[[ Moving ]]

	if pressEdges.X < 0 then
		left = math.max(boundsMin.X, math.min(pressMin.X + delta.X, pressMax.X - minSize.X))
	elseif pressEdges.X > 0 then
		right = math.min(boundsMax.X, math.max(pressMax.X + delta.X, pressMin.X + minSize.X))
	end

	if pressEdges.Y < 0 then
		top = math.max(boundsMin.Y, math.min(pressMin.Y + delta.Y, pressMax.Y - minSize.Y))
	elseif pressEdges.Y > 0 then
		bottom = math.min(boundsMax.Y, math.max(pressMax.Y + delta.Y, pressMin.Y + minSize.Y))
	end

	--[[ Returning ]]

	return Vector2.new(left, top), Vector2.new(right, bottom)
end

return Module
