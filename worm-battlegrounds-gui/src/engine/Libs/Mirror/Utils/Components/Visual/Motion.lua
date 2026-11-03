--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(script:FindFirstAncestor("Libs"):FindFirstChild("Runtime"))
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService = I.S.RunService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local GuiVisibility = require(_scripts:FindFirstChild("GuiVisibility")) --- @type UmeGui_Utils_GuiVisibility

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Kinds ]]

-- What each kind moves, and the class it must sit on
--- @type { [string]: string }
local KIND_CLASSES = {
	Spin = "UIGradient",
	Sweep = "UIGradient",
	Glint = "UIGradient",
	Breathe = "UIGradient",
	Pulse = "UIScale",
	Twinkle = "GuiObject",
	Turn = "ViewportFrame",
	Float = "ViewportFrame",
	Rotate = "GuiObject",
	-- A UIStroke's Color, a text's TextColor3 or a GuiObject's BackgroundColor3: all are Instances, the kind tells
	-- them apart
	Hue = "Instance",
	Travel = "GuiObject",
	Drift = "GuiObject",
	Flash = "GuiObject",
	Flipbook = "ImageLabel",
}

-- Each kind's Utils_MotionAmount when the attribute is missing
--- @type { [string]: number }
local DEFAULT_AMOUNTS = {
	Spin = 60,
	Sweep = 1,
	Glint = 0.85,
	Breathe = 0.15,
	Pulse = 0.06,
	Twinkle = 1,
	Turn = 40,
	Float = 40,
	Rotate = 12,
	Hue = 0.25,
	Travel = 0,
	Flash = 1,
	Flipbook = 4,
}

-- Each kind's Utils_MotionPath when the attribute is missing: a trip down its parent, a sway 8 px to each side
--- @type { [string]: UDim2 }
local DEFAULT_PATHS = {
	Travel = UDim2.fromScale(0, 1),
	Drift = UDim2.fromOffset(8, 0),
}

--[[ Timing ]]

-- A sweep or glint crosses in CROSS_TIME seconds once every PERIOD; pulses, breaths and twinkles repeat every PERIOD
local PERIOD: number = 2.6
local CROSS_TIME: number = 0.7
-- A glint's half width along its gradient
local GLINT_WIDTH: number = 0.14
-- How far a floating model bobs up and down, as a share of its height
local FLOAT_BOB: number = 0.05
-- How strong a cycling colour's hue is, as an RGB light's: saturated, at full brightness
local HUE_SATURATION: number = 0.9
-- The share of a travelling element's trip it takes to fade in, and again to fade out, so its jump back never shows
local TRAVEL_FADE: number = 0.15
-- A flipbook's frames a second, at speed 1
local FLIPBOOK_FPS: number = 4

--[[
	A flash at the start of each PERIOD, in seconds of it: a dim flicker until FLASH_FLICKER, dark until FLASH_STRIKE,
	then the full flash fading out until FLASH_OUT, as lightning strikes
]]
local FLASH_FLICKER: number = 0.06
local FLASH_STRIKE: number = 0.14
local FLASH_OUT: number = 0.6
local FLASH_FLICKER_SHOWN: number = 0.6

--[[ Loop ]]

-- The components the shared Heartbeat moves, and that Heartbeat while any runs
local entries = {} --- @type { [UmeGui_Utils_Motion]: boolean }
local loopConnection: RBXScriptConnection? = nil

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Sample Sequence

--[[
	Returns a colour sequence's colour at `alpha` (0 to 1), between the keypoints around it.
]]
--- @return Color3
local function sampleSequence(sequence: ColorSequence, alpha: number)
	--[[ Local Variables ]]

	local keypoints = sequence.Keypoints --- @type { ColorSequenceKeypoint }

	--[[ Finding ]]

	for index: number = 1, #keypoints - 1 do
		local from: ColorSequenceKeypoint = keypoints[index]
		local to: ColorSequenceKeypoint = keypoints[index + 1]
		if alpha <= to.Time then
			return from.Value:Lerp(to.Value, (alpha - from.Time) / math.max(to.Time - from.Time, 1e-4))
		end
	end

	--[[ Returning ]]

	return keypoints[#keypoints].Value
end

--%%%%%%%%%%%%%%%%%%%% Scale UDim2

--[[
	Returns a UDim2 with its scales and offsets multiplied by `by`.
]]
--- @return UDim2
local function scaleUDim2(value: UDim2, by: number)
	return UDim2.new(value.X.Scale * by, value.X.Offset * by, value.Y.Scale * by, value.Y.Offset * by)
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

--- @class UmeGui_Utils_Motion : Component
--- @field Instance Instance
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field Kind string
--- @field Speed number
--- @field Amount number
--- @field Phase number
--- @field Path UDim2
---
--- # State #
---
--- @field _time number
--- @field _rest { [any]: any }
---
--- # Float #
---
--- @field _floatModel Model?
--- @field _floatPivot CFrame
--- @field _floatCentre Vector3
--- @field _floatHeight number
local Component = {}
Component.__index = Component

-- Only the live copy in PlayerGui moves, never the templates in StarterGui or ReplicatedStorage
Component.IgnoreAncestors = { I.S.ReplicatedStorage, I.S.StarterGui }

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Setup ]]

	self:GetAttributes()

	--[[ Checks ]]

	-- Check if the kind is known and sits on its class
	local class: string? = KIND_CLASSES[self.Kind]
	if not class or not self.Instance:IsA(class) then
		warn(`[{_localName}::{script.Name}]: Motion ({self.Kind}) needs a ({class or "known kind"}), not ({self.Instance.ClassName})! -`, self.Instance)
		return
	end

	--[[ State ]]

	self._time = 0
	self:_saveRest()

	--[[ Connections ]]

	table.insert(
		self.Connections,
		self.Instance.AttributeChanged:Connect(function(attribute: string)
			if string.find(attribute, "^Utils_Motion") then
				self:GetAttributes()
			end
		end)
	)

	-- Move only while shown: hidden, it leaves the shared loop, which stops once nothing shown is left
	table.insert(
		self.Connections,
		GuiVisibility.Watch(self.Instance, function(shown: boolean)
			entries[self] = if shown then true else nil
			if shown then
				Component._startLoop()
			end
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	--[[ Restoring ]]

	self._destroyed = true
	entries[self] = nil
	self:_restore()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Start Loop

--[[
	Connects the shared Heartbeat that moves every motion, when it isn't running yet.
]]
function Component._startLoop()
	--[[ Checks ]]

	-- Skip when the loop already runs
	if loopConnection then
		return
	end

	--[[ Connections ]]

	loopConnection = RunService.Heartbeat:Connect(Component._stepLoop)
end

--%%%%%%%%%%%%%%%%%%%% Step Loop

--[[
	Moves every motion one frame. Drops components whose instance is gone, and stops once none is left.
]]
function Component._stepLoop(deltaTime: number)
	--[[ Stepping ]]

	--- @param component UmeGui_Utils_Motion
	for component, _running: boolean in pairs(entries) do
		-- Forget a component whose instance is gone
		if not component.Instance.Parent or component._destroyed then
			entries[component] = nil
			continue
		end

		component:Step(deltaTime)
	end

	--[[ Stopping ]]

	-- Stop the loop once nothing runs
	if next(entries) == nil and loopConnection then
		loopConnection:Disconnect()
		loopConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the kind (`Utils_MotionKind`), how fast (`Utils_MotionSpeed`, 1), how much (`Utils_MotionAmount`, the kind's
	default), how far into its cycle it starts (`Utils_MotionPhase` in seconds, else a random point, so neighbours
	don't move in step) and the way a moving element goes (`Utils_MotionPath`, the kind's default).
]]
function Component:GetAttributes()
	--[[ Reading ]]

	self.Kind = self.Instance:GetAttribute("Utils_MotionKind") or ""
	self.Speed = self.Instance:GetAttribute("Utils_MotionSpeed") or 1
	self.Amount = self.Instance:GetAttribute("Utils_MotionAmount") or DEFAULT_AMOUNTS[self.Kind] or 0
	self.Phase = self.Instance:GetAttribute("Utils_MotionPhase") or self.Phase or math.random() * PERIOD
	self.Path = self.Instance:GetAttribute("Utils_MotionPath") or DEFAULT_PATHS[self.Kind] or UDim2.new()
end

--%%%%%%%%%%%%%%%%%%%% Save Rest

--[[
	Keeps the values the kind moves, to give them back when it stops: a gradient's rotation, offset and colours, a
	scale, a turned object's rotation, a cycling colour, a moving element's position, a flipbook's frame, and the
	background transparency of a fading frame (twinkling, travelling or flashing) and its frames.
]]
function Component:_saveRest()
	--[[ Saving ]]

	self._rest = {}
	if self.Instance:IsA("UIGradient") then
		self._rest.Rotation = self.Instance.Rotation
		self._rest.Offset = self.Instance.Offset
		self._rest.Color = self.Instance.Color
	elseif self.Instance:IsA("UIScale") then
		self._rest.Scale = self.Instance.Scale
	elseif self.Kind == "Rotate" then
		self._rest.Rotation = self.Instance.Rotation
	elseif self.Kind == "Hue" then
		local instance: any = self.Instance
		local property: string = Component._getHueProperty(instance)
		self._rest[property] = instance[property]
	elseif self.Kind == "Travel" or self.Kind == "Drift" then
		self._rest.Position = self.Instance.Position
	elseif self.Kind == "Flipbook" then
		self._rest.ImageRectOffset = self.Instance.ImageRectOffset
	end

	--[[ Fading ]]

	-- Kinds that fade keep each shown frame's background transparency, keyed by the frame
	if self.Kind == "Twinkle" or self.Kind == "Travel" or self.Kind == "Flash" then
		for _index: number, frame: Instance in ipairs({ self.Instance, unpack(self.Instance:GetDescendants()) }) do
			if frame:IsA("GuiObject") and frame.BackgroundTransparency < 1 then
				self._rest[frame] = frame.BackgroundTransparency
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Moves the instance one frame by its kind: Spin turns a gradient (Amount degrees a second), Sweep slides a gradient
	across and off again (a light band), Glint runs a white band through a gradient's colours (Amount how white), Breathe
	moves a gradient up and down (Amount of its height), Pulse grows and shrinks a scale (by Amount), Twinkle fades a
	frame and its frames out and in, Turn spins the model in a viewport (Amount degrees a second), Float spins it the same
	way while it bobs gently up and down (FLOAT_BOB of its height), as a dropped item does, and Rotate turns a gui object
	(Amount degrees a second; inside a scrolling page it shows only within a CanvasGroup), Hue runs a stroke's, a
	text's or a frame's colour through every hue, as an RGB light (Amount turns a second), Travel moves a gui object
	along its Path once every PERIOD, swaying Amount px aside and fading in and out at the ends, then starts over (a
	falling drop, a rising ember), Drift moves it back and forth along its Path, Flash lights a frame and its frames
	as lightning at the start of every PERIOD (Amount how bright), and Flipbook plays an image's frames, laid side by
	side at its ImageRectSize, Amount of them, FLIPBOOK_FPS a second.
]]
function Component:Step(deltaTime: number)
	--[[ Local Variables ]]

	self._time += deltaTime * self.Speed
	local time: number = self._time + self.Phase
	local wave: number = math.sin(time * math.pi * 2 / PERIOD)
	local cycle: number = time % PERIOD
	local instance: any = self.Instance

	--[[ Moving ]]

	if self.Kind == "Spin" or self.Kind == "Rotate" then
		instance.Rotation = (self._rest.Rotation + time * self.Amount) % 360
	elseif self.Kind == "Sweep" then
		instance.Offset = Vector2.new(if cycle < CROSS_TIME then -1 + 2 * cycle / CROSS_TIME else -1, 0) * self.Amount
	elseif self.Kind == "Glint" then
		instance.Color = Component._getGlinted(self._rest.Color, if cycle < CROSS_TIME then -GLINT_WIDTH + (1 + GLINT_WIDTH * 2) * cycle / CROSS_TIME else nil, self.Amount)
	elseif self.Kind == "Breathe" then
		instance.Offset = self._rest.Offset + Vector2.new(0, wave * self.Amount)
	elseif self.Kind == "Pulse" then
		instance.Scale = self._rest.Scale * (1 + wave * self.Amount)
	elseif self.Kind == "Twinkle" then
		-- Shown for the top of each wave, gone in between
		self:_fade(math.clamp(wave * 2 - 0.4, 0, 1) * self.Amount)
	elseif self.Kind == "Travel" then
		local progress: number = cycle / PERIOD
		instance.Position = self._rest.Position + scaleUDim2(self.Path, progress) + UDim2.fromOffset(math.sin(progress * math.pi * 2) * self.Amount, 0)
		self:_fade(math.clamp(math.min(progress, 1 - progress) / TRAVEL_FADE, 0, 1))
	elseif self.Kind == "Drift" then
		instance.Position = self._rest.Position + scaleUDim2(self.Path, wave)
	elseif self.Kind == "Flash" then
		self:_fade(Component._getFlash(cycle) * self.Amount)
	elseif self.Kind == "Flipbook" then
		local frame: number = math.floor(time * FLIPBOOK_FPS) % math.max(self.Amount, 1)
		instance.ImageRectOffset = Vector2.new(frame * instance.ImageRectSize.X, self._rest.ImageRectOffset.Y)
	elseif self.Kind == "Turn" then
		local model: Model? = instance:FindFirstChildOfClass("Model")
		if model then
			local box: CFrame = model:GetBoundingBox()
			local axis: Vector3 = Vector3.new(box.X, 0, box.Z)
			model:PivotTo(CFrame.new(axis) * CFrame.Angles(0, math.rad(self.Amount * deltaTime * self.Speed), 0) * CFrame.new(-axis) * model:GetPivot())
		end
	elseif self.Kind == "Hue" then
		instance[Component._getHueProperty(instance)] = Color3.fromHSV((time * self.Amount) % 1, HUE_SATURATION, 1)
	elseif self.Kind == "Float" then
		local model: Model? = instance:FindFirstChildOfClass("Model")
		if model then
			-- Keep where a new model rests, to float it around that
			if model ~= self._floatModel then
				local box: CFrame
				local size: Vector3
				box, size = model:GetBoundingBox()
				self._floatModel = model
				self._floatPivot = model:GetPivot()
				self._floatCentre = box.Position
				self._floatHeight = size.Y
			end
			local lift: Vector3 = Vector3.new(0, wave * self._floatHeight * FLOAT_BOB, 0)
			model:PivotTo(CFrame.new(self._floatCentre + lift) * CFrame.Angles(0, math.rad(time * self.Amount), 0) * CFrame.new(-self._floatCentre) * self._floatPivot)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Restore

--[[
	Gives the instance back the values it had before it moved. A turned or floating model stays where it is.
]]
function Component:_restore()
	--[[ Restoring ]]

	local instance: any = self.Instance
	for key: any, value: any in pairs(self._rest or {}) do
		if typeof(key) == "Instance" then
			key.BackgroundTransparency = value
		else
			instance[key] = value
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Fade

--[[
	Shows the frames a fading kind keeps at `shown` (0 gone, 1 as they rest).
]]
function Component:_fade(shown: number)
	--[[ Fading ]]

	for key: any, transparency: any in pairs(self._rest) do
		if typeof(key) == "Instance" then
			key.BackgroundTransparency = 1 - (1 - transparency) * shown
		end
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Hue Property

--[[
	Returns the colour a Hue cycles on an instance: a stroke's Color, a text's TextColor3, else a frame's
	BackgroundColor3.
]]
--- @return string
function Component._getHueProperty(instance: Instance)
	return if instance:IsA("UIStroke") then "Color" elseif instance:IsA("TextLabel") then "TextColor3" else "BackgroundColor3"
end

--%%%%%%%%%%%%%%%%%%%% Get Flash

--[[
	Returns how shown a flash is `cycle` seconds into its PERIOD: a dim flicker, a short dark, then the strike fading
	out, and dark for the rest.
]]
--- @return number
function Component._getFlash(cycle: number)
	--[[ Returning ]]

	if cycle < FLASH_FLICKER then
		return FLASH_FLICKER_SHOWN
	elseif cycle < FLASH_STRIKE then
		return 0
	end

	return math.max(0, 1 - (cycle - FLASH_STRIKE) / (FLASH_OUT - FLASH_STRIKE))
end

--%%%%%%%%%%%%%%%%%%%% Get Glinted

--[[
	Returns a colour sequence with a white band centred at `glint` (0 to 1 along it, nil for none), `strength` white at
	its middle.
]]
--- @return ColorSequence
function Component._getGlinted(colors: ColorSequence, glint: number?, strength: number)
	--[[ Checks ]]

	-- Without a glint crossing, the plain colours
	if not glint then
		return colors
	end

	--[[ Local Variables ]]

	local times = { 0, 1 } --- @type { number }
	local keypoints = {} --- @type { ColorSequenceKeypoint }

	--[[ Building ]]

	for _index: number, at: number in ipairs({ glint - GLINT_WIDTH, glint, glint + GLINT_WIDTH }) do
		if at > 0.001 and at < 0.999 then
			table.insert(times, at)
		end
	end
	table.sort(times)

	for _index: number, at: number in ipairs(times) do
		local shine: number = math.max(0, 1 - math.abs(at - glint) / GLINT_WIDTH) * strength
		table.insert(keypoints, ColorSequenceKeypoint.new(at, sampleSequence(colors, at):Lerp(Color3.new(1, 1, 1), shine)))
	end

	--[[ Returning ]]

	return ColorSequence.new(keypoints)
end

return Component
