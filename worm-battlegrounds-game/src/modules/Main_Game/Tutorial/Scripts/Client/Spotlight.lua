--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Tutorial"

--- @type Tutorial_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance }

--[[ General ]]

local moduleGui: ScreenGui

--[[ State ]]

--[[
	What the hole sits over: a gui element, a part (followed as it moves), a spot in the world or an area of the screen
	(in AbsolutePosition's space); nil shows only the hint
]]
local target: (GuiObject | BasePart | Vector3 | Rect)? = nil
local shownText: string = ""
local stepConnection: RBXScriptConnection?

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

--- @class Tutorial_Client_Spotlight
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Elements ]]

	moduleGui = I.UserInterface.UI[_settings.HINT_GUI_NAME]
	elems["Spotlight"] = moduleGui:FindFirstChild("U_Spotlight", true) --- @type Frame
	elems["Ring"] = elems["Spotlight"]:FindFirstChild("S_Ring") --- @type Frame
	elems["Blockers"] = moduleGui:FindFirstChild("U_Blockers", true) --- @type Folder
	elems["Hint"] = moduleGui:FindFirstChild("U_Hint", true) --- @type Frame
	elems["Text"] = elems["Hint"]:FindFirstChild("S_Text") --- @type TextLabel
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Shows a hint, and blacks out the screen around what to press: a gui element, a part, a world spot or a screen
	area (nil: the hint alone). Presses outside the hole are blocked while it shows.
]]
function Module.Show(text: string, newTarget: (GuiObject | BasePart | Vector3 | Rect)?)
	--[[ Saving ]]

	target = newTarget

	--[[ Text ]]

	if text ~= shownText then
		shownText = text
		elems["Text"].Text = text
		task.spawn(Module._fitText, text)
	end

	--[[ Applying ]]

	moduleGui.Enabled = true
	elems["Hint"].Visible = true
	if not stepConnection then
		stepConnection = I.S.RunService.RenderStepped:Connect(Module._step)
	end
end

--%%%%%%%%%%%%%%%%%%%% Hide

--[[
	Hides the hint and the spotlight.
]]
function Module.Hide()
	--[[ Applying ]]

	target = nil
	moduleGui.Enabled = false
	if stepConnection then
		stepConnection:Disconnect()
		stepConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Every frame while it shows: fits the hole over the target, the blockers around it, and the hint beside it (under
	the hole in the screen's top half, over it in the bottom half), and pulses the hole's ring.
]]
function Module._step()
	--[[ Local Variables ]]

	local screen: Vector2 = moduleGui.AbsoluteSize
	local hintSize: Vector2 = elems["Hint"].AbsoluteSize
	local corner: Vector2?
	local size: Vector2?
	corner, size = Module._getHole()

	--[[ Hole ]]

	elems["Spotlight"].Visible = corner ~= nil
	for _index: number, blocker: Frame in ipairs(elems["Blockers"]:GetChildren()) do
		blocker.Visible = corner ~= nil
	end
	if not corner or not size then
		elems["Hint"].Position = UDim2.fromOffset(screen.X / 2, screen.Y * _settings.HINT_TOP)
		return
	end
	elems["Spotlight"].Position = UDim2.fromOffset(corner.X, corner.Y)
	elems["Spotlight"].Size = UDim2.fromOffset(size.X, size.Y)
	elems["Ring"].UIStroke.Transparency = 0.2 + 0.5 * (0.5 + 0.5 * math.sin(os.clock() * _settings.RING_PULSE_RATE))

	--[[ Blockers ]]

	local bottom: number = corner.Y + size.Y
	local right: number = corner.X + size.X
	elems["Blockers"].Top.Position = UDim2.fromOffset(0, 0)
	elems["Blockers"].Top.Size = UDim2.fromOffset(screen.X, corner.Y)
	elems["Blockers"].Bottom.Position = UDim2.fromOffset(0, bottom)
	elems["Blockers"].Bottom.Size = UDim2.fromOffset(screen.X, screen.Y - bottom)
	elems["Blockers"].Left.Position = UDim2.fromOffset(0, corner.Y)
	elems["Blockers"].Left.Size = UDim2.fromOffset(corner.X, size.Y)
	elems["Blockers"].Right.Position = UDim2.fromOffset(right, corner.Y)
	elems["Blockers"].Right.Size = UDim2.fromOffset(screen.X - right, size.Y)

	--[[ Hint ]]

	local below: boolean = corner.Y + size.Y / 2 < screen.Y / 2
	local x: number = math.clamp(corner.X + size.X / 2, hintSize.X / 2 + _settings.HINT_EDGE, math.max(screen.X - hintSize.X / 2 - _settings.HINT_EDGE, hintSize.X / 2))
	local y: number = if below then bottom + _settings.HINT_GAP else corner.Y - _settings.HINT_GAP - hintSize.Y
	elems["Hint"].Position = UDim2.fromOffset(x, math.clamp(y, _settings.HINT_EDGE, math.max(screen.Y - hintSize.Y - _settings.HINT_EDGE, 0)))
end

--%%%%%%%%%%%%%%%%%%%% Fit Text

--[[
	Sizes the hint's text box to its lines at their design size, and the panel to the text, since scaled text can't
	size itself under the panel's screen scale.
]]
function Module._fitText(text: string)
	--[[ Local Variables ]]

	local label: TextLabel = elems["Text"]
	local params: GetTextBoundsParams = Instance.new("GetTextBoundsParams")
	params.Text = text
	params.Font = label.FontFace
	params.Size = _settings.HINT_TEXT_SIZE
	params.Width = elems["Hint"].Size.X.Offset + label.Size.X.Offset
	params.RichText = true

	--[[ Measuring ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(I.S.TextService.GetTextBoundsAsync, I.S.TextService, params)
	if not success or text ~= shownText then
		return
	end

	--[[ Applying ]]

	local height: number = math.ceil(result.Y)
	label.Size = UDim2.new(label.Size.X.Scale, label.Size.X.Offset, 0, height)
	elems["Hint"].Size = UDim2.fromOffset(elems["Hint"].Size.X.Offset, label.Position.Y.Offset + height + _settings.HINT_BOTTOM_PADDING)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Hole

--[[
	Returns the hole's top-left corner and size on this gui, padded by HOLE_PADDING and at least HOLE_MIN wide and
	tall, or nil while there's no target or it isn't on the screen (a hidden gui element, a spot behind the camera).
]]
--- @return Vector2?
--- @return Vector2?
function Module._getHole()
	--[[ Local Variables ]]

	local center: Vector2
	local extent: Vector2

	--[[ Measuring ]]

	if typeof(target) == "Instance" and target:IsA("GuiObject") then
		-- Check if the element shows
		if not I.Utils.IsGuiShown(target) then
			return nil, nil
		end
		-- Every gui's AbsolutePosition counts from under the top bar, as this gui's own does
		center = target.AbsolutePosition + target.AbsoluteSize / 2 - moduleGui.AbsolutePosition
		extent = target.AbsoluteSize
	elseif typeof(target) == "Rect" then
		center = (target.Min + target.Max) / 2 - moduleGui.AbsolutePosition
		extent = target.Max - target.Min
	elseif target ~= nil then
		local camera: Camera = I.S.Workspace.CurrentCamera
		local position: Vector3 = if typeof(target) == "Vector3" then target else target.Position
		local point: Vector3
		local onScreen: boolean
		-- Screen points count from under the top bar, as gui positions do
		point, onScreen = camera:WorldToScreenPoint(position)
		-- Check if the spot is in front of the camera
		if not onScreen then
			return nil, nil
		end
		local edge: Vector3 = camera:WorldToScreenPoint(position + camera.CFrame.RightVector * _settings.WORLD_HOLE_RADIUS)
		local radius: number = (Vector2.new(edge.X, edge.Y) - Vector2.new(point.X, point.Y)).Magnitude
		center = Vector2.new(point.X, point.Y) - moduleGui.AbsolutePosition
		extent = Vector2.new(radius * 2, radius * 2)
	else
		return nil, nil
	end

	--[[ Returning ]]

	local size: Vector2 = (extent + Vector2.one * _settings.HOLE_PADDING * 2):Max(Vector2.one * _settings.HOLE_MIN)
	return center - size / 2, size
end

return Module
