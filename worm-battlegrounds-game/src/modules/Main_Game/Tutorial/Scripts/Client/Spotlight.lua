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

-- What the arrow points at: a gui element, a part (followed as it moves) or a spot in the world
local target: (GuiObject | BasePart | Vector3)? = nil

--[[
	Where the hint goes: nil points the arrow from above (from below near the screen's top), "Below" points it up from
	under the target (a button with a title over it), "Left" points it right from beside the target with the hint left
	of it (a card in a column of cards), "Alone" shows the hint by itself under the target with no arrow or ring (the
	first drag, under the player's snail)
]]
local placing: ("Below" | "Left" | "Right" | "Beside" | "Alone")? = nil
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
	elems["Tip"] = elems["Hint"]:FindFirstChild("S_Tip") --- @type TextLabel
	elems["Swipe"] = moduleGui:FindFirstChild("U_Swipe", true) --- @type Frame
	elems["SwipeGlow"] = elems["Swipe"]:FindFirstChild("S_SwipeGlow") --- @type UIStroke
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Points the red arrow at a target (a gui element, a part or a world spot, the last with a soft ring round it) with a
	short hint beside it ("" for the arrow alone), from under it with "Below", from its left with "Left", from its right
	with "Right" (the tip alone on one line there, when the hint is ""), "Beside" as "Right" with no arrow, or with
	"Alone" the hint by itself under the target. A tip, when given, shows in smaller text under the hint (how to do it on
	the player's device). Nothing else is darkened or blocked. A step (a name in FUNNEL_STEPS) is reported to the server
	the first time it shows.
]]
function Module.Show(text: string, newTarget: GuiObject | BasePart | Vector3, step: string, place: ("Below" | "Left" | "Right" | "Beside" | "Alone")?, tip: string?)
	--[[ Saving ]]

	target = newTarget
	placing = place

	--[[ Reporting ]]

	if not reported[step] and table.find(_settings.FUNNEL_STEPS, step) then
		reported[step] = true
		I.Network.Fire("Tutorial_Step", step)
	end

	--[[ Applying ]]

	elems["Text"].Text = text
	elems["Tip"].Text = tip or ""
	elems["Tip"].Visible = tip ~= nil
	moduleGui.Enabled = true
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
	Every frame while it shows: rings a world spot and pulses the ring, points the arrow at the target from above (from
	under it when it's near the screen's top, or asked to) bobbing toward it, and places the hint past the arrow (over it in the
	screen's bottom half, under it in the top half), or under the target when the hint shows alone. Nothing shows while
	the target is off the screen.
]]
function Module._step()
	--[[ Local Variables ]]

	local screen: Vector2 = moduleGui.AbsoluteSize
	local hintSize: Vector2 = elems["Hint"].AbsoluteSize
	local world: boolean = typeof(target) == "Vector3" or (typeof(target) == "Instance" and target:IsA("BasePart"))
	local corner: Vector2?
	local size: Vector2?
	corner, size = Module._getHole(world)

	--[[ Visibility ]]

	elems["Spotlight"].Visible = corner ~= nil and world and placing ~= "Alone"
	elems["Arrow"].Visible = corner ~= nil and placing ~= "Alone" and placing ~= "Beside"
	elems["Hint"].Visible = corner ~= nil and (elems["Text"].Text ~= "" or elems["Tip"].Visible)
	elems["Swipe"].Visible = corner ~= nil and placing == "Alone"
	if not corner or not size then
		return
	end

	--[[ Ring ]]

	elems["Spotlight"].Position = UDim2.fromOffset(corner.X, corner.Y)
	elems["Spotlight"].Size = UDim2.fromOffset(size.X, size.Y)
	elems["Ring"].UIStroke.Transparency = 0.15 + 0.45 * (0.5 + 0.5 * math.sin(os.clock() * _settings.RING_PULSE_RATE))

	--[[ Alone ]]

	local bottom: number = corner.Y + size.Y
	local centerX: number = corner.X + size.X / 2
	local x: number = math.clamp(centerX, hintSize.X / 2 + _settings.HINT_EDGE, math.max(screen.X - hintSize.X / 2 - _settings.HINT_EDGE, hintSize.X / 2))
	if placing == "Alone" then
		local hintY: number = math.min(bottom + _settings.HINT_GAP, screen.Y - hintSize.Y - _settings.HINT_EDGE)
		elems["Hint"].Position = UDim2.fromOffset(x, hintY)
		Module._swipe(x, hintY + hintSize.Y)
		return
	end

	--[[ Left ]]

	local bob: number = _settings.ARROW_BOB * (0.5 + 0.5 * math.sin(os.clock() * _settings.ARROW_BOB_RATE))
	if placing == "Left" then
		-- Turned a quarter, the arrow points right; the hint ends just left of it
		local arrowLength: number = elems["Arrow"].AbsoluteSize.Y
		local arrowX: number = corner.X - _settings.ARROW_GAP - bob - arrowLength / 2
		local centerY: number = corner.Y + size.Y / 2
		elems["Arrow"].AnchorPoint = Vector2.new(0.5, 0.5)
		elems["Arrow"].Rotation = -90
		elems["Arrow"].Position = UDim2.fromOffset(arrowX, centerY)
		local textWidth: number = elems["Text"].TextBounds.X
		elems["Hint"].Position = UDim2.fromOffset(math.max(arrowX - arrowLength / 2 - _settings.HINT_GAP - textWidth / 2, hintSize.X / 2 + _settings.HINT_EDGE), centerY - hintSize.Y / 2)
		return
	end

	--[[ Right ]]

	if placing == "Right" or placing == "Beside" then
		-- Turned the other way, the arrow points left at the target; the line starts just right of it (of the target itself, Beside)
		local arrowLength: number = elems["Arrow"].AbsoluteSize.Y
		local arrowX: number = corner.X + size.X + _settings.ARROW_GAP + bob + arrowLength / 2
		local centerY: number = corner.Y + size.Y / 2
		elems["Arrow"].AnchorPoint = Vector2.new(0.5, 0.5)
		elems["Arrow"].Rotation = 90
		elems["Arrow"].Position = UDim2.fromOffset(arrowX, centerY)
		-- With no hint the tip is the line: the hint's frame sits so the tip under it centres on the target
		local tipOnly: boolean = elems["Text"].Text == ""
		local lineWidth: number = if tipOnly then elems["Tip"].TextBounds.X else elems["Text"].TextBounds.X
		local tipGap: number = elems["Tip"].AbsolutePosition.Y - (elems["Hint"].AbsolutePosition.Y + hintSize.Y)
		local hintY: number = if tipOnly then centerY - hintSize.Y - tipGap - elems["Tip"].AbsoluteSize.Y / 2 else centerY - hintSize.Y / 2
		local lineLeft: number = if placing == "Beside" then corner.X + size.X + _settings.ARROW_GAP * 2 else arrowX + arrowLength / 2 + _settings.HINT_GAP
		elems["Hint"].Position = UDim2.fromOffset(lineLeft + lineWidth / 2, hintY)
		return
	end

	--[[ Arrow ]]

	local flip: boolean = placing == "Below" or corner.Y + size.Y / 2 < screen.Y * _settings.ARROW_FLIP_SHARE
	local arrowReach: number = _settings.ARROW_GAP + _settings.ARROW_BOB + elems["Arrow"].AbsoluteSize.Y

	-- Turned over, it hangs from its top edge, so its tip (rotated to the top) still sits at the anchor
	elems["Arrow"].AnchorPoint = if flip then Vector2.new(0.5, 0) else Vector2.new(0.5, 1)
	elems["Arrow"].Rotation = if flip then 180 else 0
	elems["Arrow"].Position = UDim2.fromOffset(centerX, if flip then bottom + _settings.ARROW_GAP + bob else corner.Y - _settings.ARROW_GAP - bob)

	--[[ Hint ]]

	-- A tip under the hint needs its room on the screen too
	local tipRoom: number = if elems["Tip"].Visible then elems["Tip"].AbsoluteSize.Y + _settings.HINT_GAP else 0
	local y: number = if flip then bottom + arrowReach + _settings.HINT_GAP else corner.Y - arrowReach - _settings.HINT_GAP - hintSize.Y - tipRoom
	elems["Hint"].Position = UDim2.fromOffset(x, math.clamp(y, _settings.HINT_EDGE, math.max(screen.Y - hintSize.Y - tipRoom - _settings.HINT_EDGE, 0)))
end

--%%%%%%%%%%%%%%%%%%%% Swipe

--[[
	Slides the touch point under the hint (its middle x, its bottom y): it fades in, sweeps SWIPE_DISTANCE right and
	SWIPE_RISE up as a drag would, and fades out, every SWIPE_SECONDS; lengths are design pixels, scaled as the hint is.
]]
function Module._swipe(x: number, hintBottom: number)
	--[[ Local Variables ]]

	local scale: number = elems["Hint"].AbsoluteSize.Y / elems["Hint"].Size.Y.Offset
	local cycle: number = (os.clock() % _settings.SWIPE_SECONDS) / _settings.SWIPE_SECONDS
	local along: number = 1 - (1 - math.clamp(cycle / 0.7, 0, 1)) ^ 2
	local fade: number = if cycle < 0.15 then 1 - cycle / 0.15 elseif cycle > 0.7 then (cycle - 0.7) / 0.3 else 0

	--[[ Applying ]]

	elems["Swipe"].Position = UDim2.fromOffset(x + (along - 0.5) * _settings.SWIPE_DISTANCE * scale, hintBottom + (_settings.SWIPE_GAP - along * _settings.SWIPE_RISE) * scale)
	elems["Swipe"].BackgroundTransparency = 0.2 + 0.8 * fade
	elems["SwipeGlow"].Transparency = 0.7 + 0.3 * fade
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Hole

--[[
	Returns the target's top-left corner and size on this gui: a gui element's box HOLE_PADDING pixels bigger on each
	side, or a world spot's WORLD_HOLE_RADIUS studs round it and at least HOLE_MIN pixels across; nil while there's no
	target or it isn't on the screen (a hidden gui element, a spot behind the camera).
]]
--- @return Vector2?
--- @return Vector2?
function Module._getHole(world: boolean)
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
		-- A left-aligned title is pointed at where its words end, not its box's
		if target:IsA("TextLabel") and target.TextXAlignment == Enum.TextXAlignment.Left then
			center = Vector2.new(target.AbsolutePosition.X + target.TextBounds.X / 2 - moduleGui.AbsolutePosition.X, center.Y)
			extent = Vector2.new(target.TextBounds.X, extent.Y)
		end
	elseif world and target ~= nil then
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
		extent = Vector2.new(radius * 2, radius * 2):Max(Vector2.one * _settings.HOLE_MIN)
	else
		return nil, nil
	end

	--[[ Returning ]]

	local size: Vector2 = if world then extent else extent + Vector2.one * _settings.HOLE_PADDING * 2
	return center - size / 2, size
end

return Module
