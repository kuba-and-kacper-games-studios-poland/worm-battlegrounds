--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService = I.S.RunService
local TweenService = I.S.TweenService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local ButtonPress = require(_scripts:FindFirstChild("ButtonPress")) --- @type Utils_ButtonPress
local GuiVisibility = require(_scripts:FindFirstChild("GuiVisibility")) --- @type Utils_GuiVisibility

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Defaults ]]

local HOVER_SCALE: number = 1.04
local CLICK_SCALE: number = 0.95
local DEFAULT_HOVER_SPEED: number = 1

-- The attribute PlatformScale keeps the per-device scale in, on the shared UIScale
local BASE_SCALE_ATTRIBUTE: string = "Utils_BaseScale"

--[[ Tweens ]]

local In_TweenInfo: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local Out_TweenInfo: TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

--[[ Position Loop ]]

-- The components whose position the shared Heartbeat moves, and that Heartbeat while any is listed
local positionEntries = {} --- @type { [Utils_ButtonTransform]: Utils_ButtonTransform_PositionEntry }
local loopConnection: RBXScriptConnection? = nil

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Float Position

--[[
	Returns where the idle float puts a component around `basePosition` right now.
]]
--- @param component Utils_ButtonTransform
--- @return UDim2
local function getFloatPosition(component, basePosition: UDim2)
	--[[ Calculating ]]

	local floatAlpha: number = (1 - math.cos(os.clock() * component.HoverSpeed * math.pi)) * 0.5

	--[[ Returning ]]

	return basePosition:Lerp(basePosition + component.HoverOffset, floatAlpha)
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

--- @class Utils_ButtonTransform : Component
--- @field Instance GuiObject
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Elements #
---
--- @field Button GuiButton
--- @field ScaleInstance UIScale?
--- @field CreatedScaleInstance boolean
---
--- # Switches #
---
--- @field EnableScale boolean
--- @field EnablePosition boolean
--- @field EnableRotation boolean
--- @field HoverEnabled boolean
--- @field HoverOnHover boolean
--- @field HoverOnClick boolean
---
--- # Transforms #
---
--- @field HoverScale number
--- @field ClickScale number
--- @field HoverPosition UDim2
--- @field ClickPosition UDim2
--- @field HoverRotation number
--- @field ClickRotation number
---
--- # Float #
---
--- @field HoverOffset UDim2
--- @field HoverSpeed number
---
--- # Rest Pose #
---
--- @field StartScale number
--- @field DefaultPosition UDim2
--- @field DefaultRotation number
---
--- # State #
---
--- @field ActiveState string
--- @field ActiveTweens { Tween }
--- @field GuiEnabled boolean
--- @field Hovered boolean
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Checks ]]

	-- Check if the instance is a GuiObject
	if not self.Instance:IsA("GuiObject") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a (GuiObject)! -`, self.Instance)
		return
	end

	--[[ Finding Button ]]

	local button: GuiButton? = if self.Instance:IsA("GuiButton") then self.Instance else self.Instance:FindFirstAncestorWhichIsA("GuiButton")

	-- Check if the object is a button or sits inside one
	if not button then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) has no (GuiButton) ancestor! -`, self.Instance)
		return
	end

	--[[ State ]]

	self.Button = button
	self.Hovered = false
	self.GuiEnabled = false
	self.ActiveState = "Default"
	self.ActiveTweens = {}
	self.CreatedScaleInstance = false

	--[[ Setup ]]

	self:GetAttributes()
	self:GetScaleInstance()

	--[[ Connections ]]

	self:ConnectInput()
	self:ConnectAttributes()
	self:ConnectGuiState()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	--[[ Checks ]]

	-- Skip an instance that never started
	if not self.Button then
		return
	end

	--[[ Restoring ]]

	self:StopPosition()
	self:CancelTweens()
	self:RestoreTransform()

	-- Remove a UIScale this component created
	if self.CreatedScaleInstance then
		self.ScaleInstance:Destroy()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Start Loop

--[[
	Connects the shared Heartbeat that moves every listed position, when it isn't running yet.
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
	Moves every listed position one frame: the eased transition to its state's position, with the idle float on top.
	Stops the loop once nothing is listed.
]]
function Component._stepLoop(deltaTime: number)
	--[[ Moving ]]

	--- @param component Utils_ButtonTransform
	--- @param entry Utils_ButtonTransform_PositionEntry
	for component, entry in pairs(positionEntries) do
		-- Forget a component whose button is gone
		if not component.Instance.Parent or component._destroyed then
			positionEntries[component] = nil
			continue
		end

		-- Skip a hidden button
		if not component.GuiEnabled then
			continue
		end

		--[[ Transition ]]

		if entry.TransitionElapsed < entry.TransitionDuration then
			entry.TransitionElapsed = math.min(entry.TransitionElapsed + deltaTime, entry.TransitionDuration)

			local alpha: number = TweenService:GetValue(entry.TransitionElapsed / entry.TransitionDuration, entry.EasingStyle, entry.EasingDirection)
			local targetPosition: UDim2 = if entry.ShouldHover then getFloatPosition(component, entry.TargetPosition) else entry.TargetPosition

			component.Instance.Position = entry.StartPosition:Lerp(targetPosition, alpha)
			continue
		end

		--[[ Float ]]

		if entry.ShouldHover then
			component.Instance.Position = getFloatPosition(component, entry.TargetPosition)
			continue
		end

		--[[ Settled ]]

		component.Instance.Position = entry.TargetPosition
		positionEntries[component] = nil
	end

	--[[ Stopping ]]

	-- Stop the loop once nothing moves
	if next(positionEntries) == nil and loopConnection then
		loopConnection:Disconnect()
		loopConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the transform switches and values and keeps the object's current position and rotation as its rest pose.
]]
function Component:GetAttributes()
	--[[ Switches ]]

	self.EnableScale = self.Instance:GetAttribute("Utils_ButtonTransform_EnableScale") ~= false
	self.EnablePosition = self.Instance:GetAttribute("Utils_ButtonTransform_EnablePosition") == true
	self.EnableRotation = self.Instance:GetAttribute("Utils_ButtonTransform_EnableRotation") == true
	self.HoverEnabled = self.Instance:GetAttribute("Utils_Hover") == true
	self.HoverOnHover = self.Instance:GetAttribute("Utils_HoverOnHover") ~= false
	self.HoverOnClick = self.Instance:GetAttribute("Utils_HoverOnClick") == true

	--[[ Transforms ]]

	self.HoverScale = self.Instance:GetAttribute("Utils_ButtonTransform_HoverScale") or HOVER_SCALE
	self.ClickScale = self.Instance:GetAttribute("Utils_ButtonTransform_ClickScale") or CLICK_SCALE
	self.HoverPosition = self.Instance:GetAttribute("Utils_ButtonTransform_HoverPosition") or UDim2.new()
	self.ClickPosition = self.Instance:GetAttribute("Utils_ButtonTransform_ClickPosition") or UDim2.new()
	self.HoverRotation = self.Instance:GetAttribute("Utils_ButtonTransform_HoverRotation") or 0
	self.ClickRotation = self.Instance:GetAttribute("Utils_ButtonTransform_ClickRotation") or 0

	--[[ Float ]]

	self.HoverOffset = self.Instance:GetAttribute("Utils_HoverOffset") or UDim2.new()
	self.HoverSpeed = self.Instance:GetAttribute("Utils_HoverSpeed") or DEFAULT_HOVER_SPEED

	-- Check if the float speed is positive
	if self.HoverSpeed <= 0 then
		warn(`[{_localName}::{script.Name}]: (Utils_HoverSpeed) must be greater than 0! -`, self.Instance)
		self.HoverSpeed = DEFAULT_HOVER_SPEED
	end

	--[[ Rest Pose ]]

	self.DefaultPosition = self.Instance.Position
	self.DefaultRotation = self.Instance.Rotation
end

--%%%%%%%%%%%%%%%%%%%% Get Scale Instance

--[[
	Finds the object's UIScale or creates one when scaling is on, remembering which, and keeps its starting scale.
]]
function Component:GetScaleInstance()
	--[[ Checks ]]

	-- Skip when scaling is off
	if not self.EnableScale then
		return
	end

	--[[ Finding ]]

	self.ScaleInstance = self.Instance:FindFirstChildOfClass("UIScale")

	-- Create one when the object has none
	if not self.ScaleInstance then
		self.ScaleInstance = Instance.new("UIScale")
		self.ScaleInstance.Parent = self.Instance
		self.CreatedScaleInstance = true
	end

	--[[ Rest Pose ]]

	self.StartScale = self.ScaleInstance.Scale
end

--%%%%%%%%%%%%%%%%%%%% Connect Input

--[[
	Plays the hover, click and default states from the button's hover, a click or touch, and its key (Utils_ButtonKey).
]]
function Component:ConnectInput()
	--[[ Hover ]]

	table.insert(
		self.Connections,
		self.Button.MouseEnter:Connect(function()
			self.Hovered = true
			self:PlayState("Hover")
		end)
	)
	table.insert(
		self.Connections,
		self.Button.MouseLeave:Connect(function()
			self.Hovered = false
			self:PlayState("Default")
		end)
	)

	--[[ Click ]]

	table.insert(
		self.Connections,
		self.Button.InputBegan:Connect(function(input: InputObject)
			-- Skip anything but the start of an input
			if input.UserInputState ~= Enum.UserInputState.Begin then
				return
			end

			-- Skip anything but a click or a touch
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			self:PlayState("Click")
		end)
	)
	table.insert(
		self.Connections,
		self.Button.InputEnded:Connect(function(input: InputObject)
			-- Skip anything but a click or a touch
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			self:PlayState(if self.Hovered then "Hover" else "Default")
		end)
	)

	--[[ Keys ]]

	table.insert(
		self.Connections,
		ButtonPress.Connect(self.Button, "Down", function()
			self:PlayState("Click")
		end)
	)
	table.insert(
		self.Connections,
		ButtonPress.Connect(self.Button, "Up", function()
			self:PlayState(if self.Hovered then "Hover" else "Default")
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Connect Attributes

--[[
	Applies a changed transform or float attribute at once, and follows PlatformScale's per-device scale on the UIScale.
]]
function Component:ConnectAttributes()
	--[[ Object Attributes ]]

	table.insert(
		self.Connections,
		self.Instance.AttributeChanged:Connect(function(attribute: string)
			-- Skip attributes this component doesn't read
			if not attribute:match("^Utils_ButtonTransform_") and not attribute:match("^Utils_Hover") then
				return
			end

			self:ApplyAttributes()
		end)
	)

	--[[ Base Scale ]]

	-- Skip when scaling is off
	if not self.ScaleInstance then
		return
	end

	table.insert(
		self.Connections,
		self.ScaleInstance:GetAttributeChangedSignal(BASE_SCALE_ATTRIBUTE):Connect(function()
			self:PlayState(self.ActiveState)
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Connect Gui State

--[[
	Follows whether the object and its gui ancestors are shown.
]]
function Component:ConnectGuiState()
	--[[ Connections ]]

	table.insert(
		self.Connections,
		GuiVisibility.Watch(self.Instance, function(guiEnabled: boolean)
			self:UpdateGuiState(guiEnabled)
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play State

--[[
	Tweens the enabled scale and rotation to a state (`Default`, `Hover`, `Click`) and moves its position and float.
]]
function Component:PlayState(state: string)
	--[[ Checks ]]

	-- Skip while the object is hidden
	if not self.GuiEnabled then
		return
	end

	--[[ Local Variables ]]

	local State_TweenInfo: TweenInfo = if state == "Default" then Out_TweenInfo else In_TweenInfo
	local floatOn: boolean = self.HoverEnabled or (state == "Hover" and self.HoverOnHover) or (state == "Click" and self.HoverOnClick)
	local shouldFloat: boolean = floatOn and self.HoverOffset ~= UDim2.new()

	self.ActiveState = state

	--[[ Position ]]

	self:UpdatePositionState(state, shouldFloat, State_TweenInfo)

	--[[ Tweens ]]

	self:CancelTweens()

	-- Turn the object when rotation is on
	if self.EnableRotation then
		local Rotation_TweenGoal = { Rotation = self.DefaultRotation + self:GetStateRotation(state) }
		local Rotation_Tween: Tween = TweenService:Create(self.Instance, State_TweenInfo, Rotation_TweenGoal)
		Rotation_Tween:Play()

		table.insert(self.ActiveTweens, Rotation_Tween)
	end

	-- Scale the object when scaling is on
	if self.EnableScale and self.ScaleInstance then
		local Scale_TweenGoal = { Scale = self:GetBaseScale() * self:GetStateScale(state) }
		local Scale_Tween: Tween = TweenService:Create(self.ScaleInstance, State_TweenInfo, Scale_TweenGoal)
		Scale_Tween:Play()

		table.insert(self.ActiveTweens, Scale_Tween)
	end
end

--%%%%%%%%%%%%%%%%%%%% Apply Attributes

--[[
	Puts the object back at rest, re-reads the attributes and plays the current state with them.
]]
function Component:ApplyAttributes()
	--[[ Resetting ]]

	self:StopPosition()
	self:CancelTweens()
	self:RestoreTransform()

	--[[ Reading ]]

	self:GetAttributes()

	-- Find or create the UIScale once scaling is turned on
	if not self.ScaleInstance then
		self:GetScaleInstance()
	end

	--[[ Playing ]]

	self:PlayState(self.ActiveState)
end

--%%%%%%%%%%%%%%%%%%%% Update Gui State

--[[
	Rests the object while it or one of its gui ancestors is hidden, and plays the default state once shown.
]]
function Component:UpdateGuiState(guiEnabled: boolean)
	--[[ Checks ]]

	-- Skip when the state didn't change
	if guiEnabled == self.GuiEnabled then
		return
	end

	--[[ Applying ]]

	self.GuiEnabled = guiEnabled

	-- Play the default state once shown
	if guiEnabled then
		self:PlayState("Default")
		return
	end

	--[[ Resetting ]]

	self.Hovered = false
	self.ActiveState = "Default"
	self:StopPosition()
	self:CancelTweens()
	self:RestoreTransform()
end

--%%%%%%%%%%%%%%%%%%%% Update Position State

--[[
	Lists the object in the position loop to ease to the state's position and float there, or takes it off.
]]
function Component:UpdatePositionState(state: string, shouldFloat: boolean, stateTweenInfo: TweenInfo)
	--[[ Checks ]]

	-- Skip when the object neither moves nor floats
	if not self.EnablePosition and not shouldFloat and not positionEntries[self] then
		return
	end

	--[[ Saving ]]

	positionEntries[self] = {
		State = state,
		StartPosition = self.Instance.Position,
		TargetPosition = self:GetStatePosition(state),
		TransitionElapsed = 0,
		TransitionDuration = stateTweenInfo.Time,
		EasingStyle = stateTweenInfo.EasingStyle,
		EasingDirection = stateTweenInfo.EasingDirection,
		ShouldHover = shouldFloat,
	}

	--[[ Starting ]]

	Component._startLoop()
end

--%%%%%%%%%%%%%%%%%%%% Stop Position

--[[
	Takes the object off the position loop.
]]
function Component:StopPosition()
	--[[ Removing ]]

	positionEntries[self] = nil
end

--%%%%%%%%%%%%%%%%%%%% Cancel Tweens

--[[
	Cancels the running scale and rotation tweens.
]]
function Component:CancelTweens()
	--[[ Cancelling ]]

	for _index: number, tween: Tween in ipairs(self.ActiveTweens) do
		tween:Cancel()
	end

	table.clear(self.ActiveTweens)
end

--%%%%%%%%%%%%%%%%%%%% Restore Transform

--[[
	Puts the enabled transforms back at the rest pose.
]]
function Component:RestoreTransform()
	--[[ Checks ]]

	-- Skip an object that left the game
	if not self.Instance.Parent then
		return
	end

	--[[ Applying ]]

	if self.EnablePosition then
		self.Instance.Position = self.DefaultPosition
	end

	if self.EnableRotation then
		self.Instance.Rotation = self.DefaultRotation
	end

	if self.ScaleInstance then
		self.ScaleInstance.Scale = self:GetBaseScale()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Base Scale

--[[
	Returns the UIScale's resting scale: PlatformScale's per-device scale when it set one, else the scale it started at.
]]
--- @return number
function Component:GetBaseScale()
	return self.ScaleInstance:GetAttribute(BASE_SCALE_ATTRIBUTE) or self.StartScale
end

--%%%%%%%%%%%%%%%%%%%% Get State Scale

--[[
	Returns the scale multiplier of a state.
]]
--- @return number
function Component:GetStateScale(state: string)
	--[[ Returning ]]

	if state == "Hover" then
		return self.HoverScale
	end

	if state == "Click" then
		return self.ClickScale
	end

	return 1
end

--%%%%%%%%%%%%%%%%%%%% Get State Position

--[[
	Returns a state's position: the rest position plus that state's offset when position transforms are on.
]]
--- @return UDim2
function Component:GetStatePosition(state: string)
	--[[ Checks ]]

	-- Stay at the rest position when position transforms are off
	if not self.EnablePosition then
		return self.DefaultPosition
	end

	--[[ Returning ]]

	if state == "Hover" then
		return self.DefaultPosition + self.HoverPosition
	end

	if state == "Click" then
		return self.DefaultPosition + self.ClickPosition
	end

	return self.DefaultPosition
end

--%%%%%%%%%%%%%%%%%%%% Get State Rotation

--[[
	Returns the degrees a state adds to the rest rotation.
]]
--- @return number
function Component:GetStateRotation(state: string)
	--[[ Returning ]]

	if state == "Hover" then
		return self.HoverRotation
	end

	if state == "Click" then
		return self.ClickRotation
	end

	return 0
end

return Component
