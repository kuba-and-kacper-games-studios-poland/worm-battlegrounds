--[[
	Created By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Console"

--- @type Console_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Binds = require(script.Parent:FindFirstChild("Binds")) --- @type Console_Client_Binds

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ State ]]

--[[
	Whether the cursor runs, whether the player turned it off with View (the D-pad's selection drives instead), whether
	it was placed yet (it first shows in the screen's middle), where it points (in gui
	pixels, the space of AbsolutePosition), where it was last drawn, the element it points at, and its loop
]]
local running: boolean = false
local turnedOff: boolean = false
local placed: boolean = false
local position: Vector2 = Vector2.zero
local drawnAt: Vector2? = nil
local hovered: GuiObject? = nil
local stepConnection: RBXScriptConnection? = nil

--[[ Sticks ]]

-- The left and right sticks' leans while the cursor runs, and how far the left stick's speed-up has built (0 to 1)
local moveStick: Vector2 = Vector2.zero
local scrollStick: Vector2 = Vector2.zero
local boost: number = 0

--[[ Glide ]]

-- The element the cursor glides onto, and when the D-pad was last pressed (os.clock): it hops the selection, which the cursor follows
local glideTarget: GuiObject? = nil
local lastDPad: number = 0

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Middle

--[[
	Returns the middle of a gui element, in gui pixels.
]]
local function getMiddle(element: GuiObject): Vector2
	return element.AbsolutePosition + element.AbsoluteSize / 2
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

--- @class Console_Client_Cursor
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Building ]]

	Module._build()

	--[[ Connections ]]

	Module._createConnections()

	--[[ Starting ]]

	Module._refresh()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Builds the cursor's picture, hidden: its own ScreenGui over every gui and the whole screen, a full-screen root it
	sits in, and the cursor, a white ring with a dot in the middle, each edged dark, sized by the screen's height (the
	lines by Scale Look), and
	the empty look that stands in for Roblox's selection box while it runs.
]]
function Module._build()
	--[[ Gui ]]

	local gui: ScreenGui = I.Create("ScreenGui")({
		Name = _settings.CURSOR_GUI_NAME,
		DisplayOrder = _settings.CURSOR_DISPLAY_ORDER,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		Enabled = false,
		Parent = I.Env.PlayerGui,
	})
	local root: Frame = I.Create("Frame")({
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	local cursor: Frame = I.Create("Frame")({
		Name = "Cursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(_settings.CURSOR_SIZE, _settings.CURSOR_SIZE),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Parent = root,
	})

	--[[ Ring ]]

	-- The dark edge's ring lies under the white one, inset so its line shows either side of the white line
	local edge: Frame = I.Create("Frame")({
		Name = "Edge",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1,
		Parent = cursor,
	})
	I.Create("UICorner")({ CornerRadius = UDim.new(0.5, 0), Parent = edge })
	local edgeStroke: UIStroke = I.Create("UIStroke")({
		Color = _settings.CURSOR_EDGE_COLOR,
		Transparency = _settings.CURSOR_EDGE_TRANSPARENCY,
		Parent = edge,
	})

	local ring: Frame = I.Create("Frame")({
		Name = "Ring",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = cursor,
	})
	I.Create("UICorner")({ CornerRadius = UDim.new(0.5, 0), Parent = ring })
	local ringStroke: UIStroke = I.Create("UIStroke")({ Color = _settings.CURSOR_COLOR, Parent = ring })

	--[[ Dot ]]

	local dot: Frame = I.Create("Frame")({
		Name = "Dot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(_settings.CURSOR_DOT_SIZE, _settings.CURSOR_DOT_SIZE),
		BackgroundColor3 = _settings.CURSOR_COLOR,
		ZIndex = 3,
		Parent = cursor,
	})
	I.Create("UICorner")({ CornerRadius = UDim.new(0.5, 0), Parent = dot })
	local dotStroke: UIStroke = I.Create("UIStroke")({
		Color = _settings.CURSOR_EDGE_COLOR,
		Transparency = _settings.CURSOR_EDGE_TRANSPARENCY,
		Parent = dot,
	})

	--[[ Selection Look ]]

	-- Roblox draws this in place of its selection box while the cursor runs: nothing, as the button's own hover shows it
	local noSelection: Frame = I.Create("Frame")({
		Name = "NoSelection",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	})

	--[[ Saving ]]

	elems["Gui"] = gui
	elems["Root"] = root
	elems["Cursor"] = cursor
	elems["Edge"] = edge
	elems["EdgeStroke"] = edgeStroke
	elems["RingStroke"] = ringStroke
	elems["DotStroke"] = dotStroke
	elems["NoSelection"] = noSelection
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Starts or stops the cursor when the platform, the open window or the player's InMatch changes, follows the D-pad's
	presses (it hops the selection, which the cursor follows), keeps Roblox's virtual cursor off, and scales the
	cursor's lines with its size.
]]
function Module._createConnections()
	--[[ Running ]]

	I.Topic.Subscribe("Platform_Changed", function(_platform: string)
		Module._refresh()
	end)

	-- Once WidgetManager has shown or hidden the window
	I.Topic.Subscribe("WidgetManager_Opened", function(_widgetName: string)
		task.defer(Module._refresh)
	end)
	I.Topic.Subscribe("WidgetManager_Closed", function(_widgetName: string)
		task.defer(Module._refresh)
	end)
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refresh)

	--[[ D-pad ]]

	I.S.UserInputService.InputBegan:Connect(function(input: InputObject)
		if string.find(input.KeyCode.Name, "^DPad") then
			lastDPad = os.clock()
		end
	end)

	--[[ Roblox's Cursor ]]

	-- Roblox's own virtual cursor fights this one and the match's sticks, and its mouse input reads as a PC: keep it off
	I.S.GamepadService:GetPropertyChangedSignal("GamepadCursorEnabled"):Connect(Module._disableRobloxCursor)
	Module._disableRobloxCursor()

	--[[ Look ]]

	elems["Cursor"]:GetPropertyChangedSignal("AbsoluteSize"):Connect(Module._scaleLook)
	Module._scaleLook()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Toggle

--[[
	View, where the cursor may run: turns it off for the D-pad's selection, which starts on the button it pointed at, or
	back on over the selected button. What the player sees never jumps (the owner, 2026-11-26: "it doesn't snap anymore").
]]
function Module.Toggle()
	--[[ Local Variables ]]

	local selected: GuiObject? = I.S.GuiService.SelectedObject
	local pointed: GuiObject? = hovered

	--[[ Saving ]]

	turnedOff = not turnedOff

	-- Back on, it shows over the button the D-pad selected
	if not turnedOff and selected and I.Utils.IsGuiShown(selected) then
		position = getMiddle(selected)
		placed = true
	end

	--[[ Refreshing ]]

	Module._refresh()

	-- Off, the selection starts on the button the cursor pointed at
	if turnedOff and pointed and I.Utils.IsGuiShown(pointed) then
		I.S.GuiService.SelectedObject = pointed
	end
end

--%%%%%%%%%%%%%%%%%%%% Disable Roblox Cursor

--[[
	Turns Roblox's own gamepad virtual cursor off whenever it comes on (the player's Roblox setting, the Select button):
	this module's cursor does its job, and Roblox's left a dot in matches and made the pad read as a mouse.
]]
function Module._disableRobloxCursor()
	--[[ Checks ]]

	-- Skip while it's off
	if not I.S.GamepadService.GamepadCursorEnabled then
		return
	end

	--[[ Disabling ]]

	I.S.GamepadService:DisableGamepadCursor()
end

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Starts the cursor where it may run (Is Active) and stops it elsewhere: running, it shows, takes both sticks from the
	bindings under it, hides Roblox's selection box (the button under it shows its own hover) and moves every frame;
	stopped, it hides, lets them go, brings the box back for the D-pad and drops the selection it made.
]]
function Module._refresh()
	--[[ Local Variables ]]

	local active: boolean = Module.IsActive()

	--[[ Checks ]]

	-- Skip when it already runs or rests as it should
	if active == running then
		return
	end

	--[[ Starting ]]

	running = active
	elems["Gui"].Enabled = active
	I.Env.PlayerGui.SelectionImageObject = if active then elems["NoSelection"] else nil
	if active then
		Binds.Bind("Cursor", Module._onStick)
		Binds.Bind("Scroll", Module._onStick)
		stepConnection = I.S.RunService.RenderStepped:Connect(Module._step)
		return
	end

	--[[ Stopping ]]

	Binds.Unbind("Cursor")
	Binds.Unbind("Scroll")
	if stepConnection then
		stepConnection:Disconnect()
		stepConnection = nil
	end
	moveStick = Vector2.zero
	scrollStick = Vector2.zero
	boost = 0
	glideTarget = nil
	drawnAt = nil

	-- Drop the selection the cursor made, so no button stays picked under a mouse
	local pointed: GuiObject? = hovered
	hovered = nil
	if pointed and I.S.GuiService.SelectedObject == pointed then
		I.S.GuiService.SelectedObject = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% On Stick

--[[
	The cursor's sticks (the Console module's Cursor and Scroll): keeps each one's lean, and sinks it, so nothing under
	the cursor walks, turns the camera or moves Roblox's selection with them.
]]
--- @return Enum.ContextActionResult
function Module._onStick(action: string, state: Enum.UserInputState, input: InputObject)
	--[[ Saving ]]

	-- A stick let go, or taken by another binding, rests
	local lean: Vector2 = if state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then Vector2.zero else Vector2.new(input.Position.X, input.Position.Y)
	if action == "Cursor" then
		moveStick = lean
	else
		scrollStick = lean
	end

	--[[ Returning ]]

	return Enum.ContextActionResult.Sink
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Every frame while it runs: the D-pad's hop glides the cursor onto the button it selected, else the left stick moves
	it, faster the further it leans and the longer it's held near full lean, slower over a button; let go, it stays
	where it is. The button it points at becomes the selection,
	so A presses it as Roblox's selection does, and the right stick scrolls the list under it.
]]
function Module._step(deltaTime: number)
	--[[ Local Variables ]]

	local root: Frame = elems["Root"]
	local screenMin: Vector2 = root.AbsolutePosition
	local screenSize: Vector2 = root.AbsoluteSize
	local height: number = screenSize.Y
	local selected: GuiObject? = I.S.GuiService.SelectedObject
	local lean: number = math.min(moveStick.Magnitude, 1)
	local leaning: boolean = lean >= _settings.CURSOR_DEADZONE

	-- The first time it shows, it starts in the screen's middle
	if not placed then
		placed = true
		position = screenMin + screenSize / 2
	end

	--[[ Following ]]

	-- The D-pad hopped the selection to another button: the cursor glides after it (never onto a list it selected)
	if selected and selected ~= hovered and selected:IsA("GuiButton") and os.clock() - lastDPad <= _settings.CURSOR_DPAD_FOLLOW then
		glideTarget = selected
	end

	-- The stick takes over from the D-pad's glide, and an element that went away ends it
	if glideTarget and (leaning or not I.Utils.IsGuiShown(glideTarget)) then
		glideTarget = nil
	end

	--[[ Moving ]]

	-- Held near full lean the stick speeds the cursor up, and the speed-up fades fast once it eases off
	if lean >= _settings.CURSOR_BOOST_LEAN then
		boost = math.min(boost + deltaTime / _settings.CURSOR_BOOST_TIME, 1)
	elseif leaning then
		boost = math.max(boost - 3 * deltaTime / _settings.CURSOR_BOOST_TIME, 0)
	else
		boost = 0
	end

	local before: Vector2 = position
	if glideTarget then
		position += (getMiddle(glideTarget) - position) * (1 - math.exp(-_settings.CURSOR_GLIDE * deltaTime))
	elseif leaning then
		local share: number = (lean - _settings.CURSOR_DEADZONE) / (1 - _settings.CURSOR_DEADZONE)
		local speed: number = _settings.CURSOR_SPEED[1] + (_settings.CURSOR_SPEED[2] - _settings.CURSOR_SPEED[1]) * share ^ _settings.CURSOR_CURVE
		speed *= (1 + (_settings.CURSOR_BOOST - 1) * boost) * height
		if hovered then
			speed *= _settings.CURSOR_BUTTON_SLOW
		end
		position += Vector2.new(moveStick.X, -moveStick.Y).Unit * speed * deltaTime
	end
	position = Vector2.new(math.clamp(position.X, screenMin.X, screenMin.X + screenSize.X), math.clamp(position.Y, screenMin.Y, screenMin.Y + screenSize.Y))

	-- A glide ends once it barely moves: it arrived, or its element is past the screen's edge
	if glideTarget and (position - before).Magnitude < 0.5 then
		glideTarget = nil
	end

	--[[ Pointing ]]

	local pointed: GuiObject?
	local scroller: ScrollingFrame?
	pointed, scroller = Module._getPointed()
	hovered = glideTarget or pointed

	--[[ Selecting ]]

	-- The element it points at is the selection, so A presses it and B backs out as with Roblox's selection
	if I.S.GuiService.SelectedObject ~= hovered then
		I.S.GuiService.SelectedObject = hovered
	end

	--[[ Scrolling ]]

	if scroller then
		Module._scroll(scroller, deltaTime, height)
	end

	--[[ Drawing ]]

	local at: Vector2 = position - screenMin
	if at ~= drawnAt then
		drawnAt = at
		elems["Cursor"].Position = UDim2.fromOffset(at.X, at.Y)
	end
end

--%%%%%%%%%%%%%%%%%%%% Scroll

--[[
	Scrolls a list with the right stick: pushed up it shows what's above, pushed right what's to the right, up to
	SCROLL_SPEED screen heights a second on the screen, only the ways the list scrolls and within its canvas.
]]
function Module._scroll(frame: ScrollingFrame, deltaTime: number, height: number)
	--[[ Local Variables ]]

	local lean: number = math.min(scrollStick.Magnitude, 1)

	--[[ Checks ]]

	-- Check if the stick leans past its dead zone
	if lean < _settings.SCROLL_DEADZONE then
		return
	end

	--[[ Calculating ]]

	-- The canvas is in the list's own pixels, which its UIScales grow on the screen
	local scale: number = Module._getScale(frame)
	local share: number = (lean - _settings.SCROLL_DEADZONE) / (1 - _settings.SCROLL_DEADZONE)
	local move: Vector2 = Vector2.new(scrollStick.X, -scrollStick.Y).Unit * share * _settings.SCROLL_SPEED * height * deltaTime / scale
	local room: Vector2 = (frame.AbsoluteCanvasSize - frame.AbsoluteWindowSize):Max(Vector2.zero) / scale
	local canvas: Vector2 = frame.CanvasPosition
	local direction: Enum.ScrollingDirection = frame.ScrollingDirection

	--[[ Scrolling ]]

	frame.CanvasPosition = Vector2.new(
		if direction ~= Enum.ScrollingDirection.Y then math.clamp(canvas.X + move.X, 0, room.X) else canvas.X,
		if direction ~= Enum.ScrollingDirection.X then math.clamp(canvas.Y + move.Y, 0, room.Y) else canvas.Y
	)
end

--%%%%%%%%%%%%%%%%%%%% Scale Look

--[[
	Sets the cursor's lines from its size on the screen: the ring's CURSOR_RING_WIDTH of it, the dark edge
	CURSOR_EDGE_WIDTH of that either side of the ring and round the dot.
]]
function Module._scaleLook()
	--[[ Local Variables ]]

	local size: number = elems["Cursor"].AbsoluteSize.Y
	local ringWidth: number = math.max(size * _settings.CURSOR_RING_WIDTH, 1)
	local edgeWidth: number = math.max(ringWidth * _settings.CURSOR_EDGE_WIDTH, 1)

	--[[ Applying ]]

	elems["RingStroke"].Thickness = ringWidth
	elems["Edge"].Size = UDim2.new(1, -2 * edgeWidth, 1, -2 * edgeWidth)
	elems["EdgeStroke"].Thickness = ringWidth + 2 * edgeWidth
	elems["DotStroke"].Thickness = edgeWidth
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Hovered

--[[
	Returns the element the cursor points at (the selection it keeps), or nil over nothing or while it doesn't run.
]]
--- @return GuiObject?
function Module.GetHovered()
	return hovered
end

--%%%%%%%%%%%%%%%%%%%% Is Active

--[[
	Returns whether the cursor runs now: where it may (Is Allowed), unless the player turned it off with View.
]]
--- @return boolean
function Module.IsActive()
	return Module.IsAllowed() and not turnedOff
end

--%%%%%%%%%%%%%%%%%%%% Is Allowed

--[[
	Returns whether the cursor may run now: on Console (a pad was used last; a mouse or touch ends it), in the lobby, and
	in a match only while a window is open, so it never takes the sticks from aiming and walking.
]]
--- @return boolean
function Module.IsAllowed()
	--[[ Local Variables ]]

	local inMatch: boolean = I.Config.PlaceLoader.MapId == _settings.MATCH_MAP_ID or I.S.Players.LocalPlayer:GetAttribute("InMatch") == true

	--[[ Returning ]]

	return I.Platform.Current == "Console" and (not inMatch or I.WidgetManager.GetCurrent() ~= nil)
end

--%%%%%%%%%%%%%%%%%%%% Get Pointed

--[[
	Returns the frontmost button under the cursor a pad may press (Is Pointable), and the frontmost list under it that
	can scroll. With a window open only the window and what's drawn over it count, as the selection stays in it.
]]
--- @return GuiObject?
--- @return ScrollingFrame?
function Module._getPointed()
	--[[ Local Variables ]]

	local widget: ScreenGui? = I.WidgetManager.GetCurrent()
	local button: GuiObject? = nil
	local scroller: ScrollingFrame? = nil

	--[[ Finding ]]

	for _index: number, object: GuiObject in ipairs(I.Env.PlayerGui:GetGuiObjectsAtPosition(position.X, position.Y)) do
		-- Skip the cursor itself, and what an open window covers
		local layer: ScreenGui? = object:FindFirstAncestorWhichIsA("ScreenGui")
		if not layer or layer == elems["Gui"] or (widget and layer ~= widget and layer.DisplayOrder <= widget.DisplayOrder) then
			continue
		end

		if not button and object:IsA("GuiButton") and Module._isPointable(object) then
			button = object
		elseif not scroller and object:IsA("ScrollingFrame") and Module._canScroll(object) then
			scroller = object
		end

		-- Stop once both are found
		if button and scroller then
			break
		end
	end

	--[[ Returning ]]

	return button, scroller
end

--%%%%%%%%%%%%%%%%%%%% Get Scale

--[[
	Returns how much the UIScales on a gui element and above it grow it on the screen.
]]
--- @return number
function Module._getScale(element: GuiObject)
	--[[ Local Variables ]]

	local scale: number = 1
	local current: Instance? = element

	--[[ Finding ]]

	while current and current:IsA("GuiObject") do
		local uiScale: UIScale? = current:FindFirstChildWhichIsA("UIScale")
		if uiScale then
			scale *= uiScale.Scale
		end
		current = current.Parent
	end

	--[[ Returning ]]

	return math.max(scale, 1e-3)
end

--%%%%%%%%%%%%%%%%%%%% Is Pointable

--[[
	Returns whether the cursor may select a button: selectable, taking input, shown, and with the cursor inside every
	frame that clips it (a list scrolled past it doesn't count).
]]
--- @return boolean
function Module._isPointable(button: GuiButton)
	--[[ Checks ]]

	-- Check if a pad may select it and it takes input
	if not button.Selectable or not button.Interactable or not I.Utils.IsGuiShown(button) then
		return false
	end

	--[[ Checking ]]

	local parent: Instance? = button.Parent
	while parent and parent:IsA("GuiObject") do
		if parent.ClipsDescendants and not Module._isUnder(parent) then
			return false
		end
		parent = parent.Parent
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Is Under

--[[
	Returns whether the cursor is over a gui element's box.
]]
--- @return boolean
function Module._isUnder(element: GuiObject)
	--[[ Local Variables ]]

	local low: Vector2 = element.AbsolutePosition
	local high: Vector2 = low + element.AbsoluteSize

	--[[ Returning ]]

	return position.X >= low.X and position.X <= high.X and position.Y >= low.Y and position.Y <= high.Y
end

--%%%%%%%%%%%%%%%%%%%% Can Scroll

--[[
	Returns whether a list scrolls: scrolling on, with more canvas than window along a way it scrolls.
]]
--- @return boolean
function Module._canScroll(frame: ScrollingFrame)
	--[[ Local Variables ]]

	local room: Vector2 = frame.AbsoluteCanvasSize - frame.AbsoluteWindowSize
	local direction: Enum.ScrollingDirection = frame.ScrollingDirection

	--[[ Returning ]]

	return frame.ScrollingEnabled and ((direction ~= Enum.ScrollingDirection.Y and room.X > 1) or (direction ~= Enum.ScrollingDirection.X and room.Y > 1))
end

return Module
