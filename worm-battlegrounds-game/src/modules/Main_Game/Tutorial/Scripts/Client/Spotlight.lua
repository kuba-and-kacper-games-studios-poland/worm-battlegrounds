--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
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

-- What the ring sits over: a gui element, a part (followed as it moves) or a spot in the world; nil shows only the hint
local target: (GuiObject | BasePart | Vector3)? = nil
local shownText: string = ""
local stepConnection: RBXScriptConnection?

-- The funnel steps already reported to the server this session (the Roblox onboarding funnel counts each once)
local reported = {} --- @type { [string]: boolean }

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
	elems["Arrow"] = moduleGui:FindFirstChild("U_Arrow", true) --- @type Frame
	elems["Hint"] = moduleGui:FindFirstChild("U_Hint", true) --- @type Frame
	elems["Text"] = elems["Hint"]:FindFirstChild("S_Text") --- @type TextLabel
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Shows a hint, and rings what to press with a red arrow pointing at it: a gui element, a part or a world spot (nil:
	the hint alone). Nothing else is darkened or blocked. A step (a name in FUNNEL_STEPS) is reported to the server the
	first time it shows, for the tutorial's funnel.
]]
function Module.Show(text: string, newTarget: (GuiObject | BasePart | Vector3)?, step: string?)
	--[[ Saving ]]

	target = newTarget

	--[[ Reporting ]]

	if step and not reported[step] and table.find(_settings.FUNNEL_STEPS, step) then
		reported[step] = true
		I.Network.Fire("Tutorial_Step", step)
	end

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
	Hides the hint, the ring and the arrow.
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
	Every frame while it shows: fits the ring over the target and pulses it, points the arrow at it from above (from
	under it when the ring is near the screen's top) bobbing toward it, and places the hint beside them (under the ring
	in the screen's top half, over it in the bottom half, past the arrow on its side).
]]
function Module._step()
	--[[ Local Variables ]]

	local screen: Vector2 = moduleGui.AbsoluteSize
	local hintSize: Vector2 = elems["Hint"].AbsoluteSize
	local corner: Vector2?
	local size: Vector2?
	corner, size = Module._getHole()

	--[[ Ring ]]

	elems["Spotlight"].Visible = corner ~= nil
	elems["Arrow"].Visible = corner ~= nil
	if not corner or not size then
		elems["Hint"].Position = UDim2.fromOffset(screen.X / 2, screen.Y * _settings.HINT_TOP)
		return
	end
	elems["Spotlight"].Position = UDim2.fromOffset(corner.X, corner.Y)
	elems["Spotlight"].Size = UDim2.fromOffset(size.X, size.Y)
	elems["Ring"].UIStroke.Transparency = 0.2 + 0.5 * (0.5 + 0.5 * math.sin(os.clock() * _settings.RING_PULSE_RATE))

	--[[ Arrow ]]

	local bottom: number = corner.Y + size.Y
	local centerX: number = corner.X + size.X / 2
	local flip: boolean = corner.Y + size.Y / 2 < screen.Y * _settings.ARROW_FLIP_SHARE
	local bob: number = _settings.ARROW_BOB * (0.5 + 0.5 * math.sin(os.clock() * _settings.ARROW_BOB_RATE))
	local arrowReach: number = _settings.ARROW_GAP + _settings.ARROW_BOB + elems["Arrow"].AbsoluteSize.Y

	-- Turned over, it hangs from its top edge, so its tip (rotated to the top) still sits at the anchor
	elems["Arrow"].AnchorPoint = if flip then Vector2.new(0.5, 0) else Vector2.new(0.5, 1)
	elems["Arrow"].Rotation = if flip then 180 else 0
	elems["Arrow"].Position = UDim2.fromOffset(centerX, if flip then bottom + _settings.ARROW_GAP + bob else corner.Y - _settings.ARROW_GAP - bob)

	--[[ Hint ]]

	local below: boolean = corner.Y + size.Y / 2 < screen.Y / 2
	local x: number = math.clamp(centerX, hintSize.X / 2 + _settings.HINT_EDGE, math.max(screen.X - hintSize.X / 2 - _settings.HINT_EDGE, hintSize.X / 2))
	local y: number = if below then bottom + _settings.HINT_GAP + (if flip then arrowReach else 0) else corner.Y - _settings.HINT_GAP - hintSize.Y - (if flip then 0 else arrowReach)
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
	Returns the ring's top-left corner and size on this gui, padded by HOLE_PADDING and at least HOLE_MIN wide and
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
