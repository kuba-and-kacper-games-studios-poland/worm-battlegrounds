--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(script:FindFirstAncestor("Libs"):FindFirstChild("Runtime"))
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _data = script:FindFirstAncestor(_localName):FindFirstChild("Data")
local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

local animations = require(_data:FindFirstChild("ButtonScalePresets")) --- @type { [string]: UmeGui_Utils_ButtonScaleAnimation }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local ButtonPress = require(_scripts:FindFirstChild("ButtonPress")) --- @type UmeGui_Utils_ButtonPress
local GuiVisibility = require(_scripts:FindFirstChild("GuiVisibility")) --- @type UmeGui_Utils_GuiVisibility

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Defaults ]]

local HOVER_SCALE: number = 1.04
local CLICK_SCALE: number = 0.95
local DEFAULT_ANIMATION: string = "Default"

--[[ Attributes ]]

-- The attributes that apply live when changed
local LIVE_ATTRIBUTES = { "Utils_HoverScale", "Utils_ClickScale", "Utils_ScaleAnimation" } --- @type { string }

-- The attribute PlatformScale keeps the per-device scale in, on the shared UIScale
local BASE_SCALE_ATTRIBUTE: string = "Utils_BaseScale"

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

--- @class UmeGui_Utils_ButtonScale : Component
--- @field Instance ImageButton | TextButton
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field HoverScale number
--- @field ClickScale number
--- @field AnimationName string
--- @field Animation UmeGui_Utils_ButtonScaleAnimation
--- @field UsesRotation boolean
--- @field HoverRotation number
---
--- # Elements #
---
--- @field ScaleInstance UIScale
---
--- # Rest Pose #
---
--- @field StartScale number
--- @field DefaultScale number
--- @field DefaultRotation number
---
--- # State #
---
--- @field Shown boolean
--- @field Hovered boolean
--- @field PlayId number
--- @field ActiveTweens { Tween }
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Checks ]]

	-- Check if the instance is a button
	if not self.Instance:IsA("ImageButton") and not self.Instance:IsA("TextButton") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a (Button)! -`, self.Instance)
		return
	end

	--[[ State ]]

	self.Shown = false
	self.Hovered = false
	self.PlayId = 0
	self.ActiveTweens = {}

	--[[ Setup ]]

	self:GetScaleInstance()
	self:GetAttributes()

	--[[ Connections ]]

	self:ConnectInput()
	self:ConnectAttributes()
	self:ConnectVisibility()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	--[[ Resetting ]]

	-- Skip an instance that never started (not a button)
	if not self.ScaleInstance then
		return
	end

	self:ResetPose()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Scale Instance

--[[
	Finds the button's UIScale or creates one, and keeps its starting scale and rotation as the rest pose.
]]
function Component:GetScaleInstance()
	--[[ Finding ]]

	self.ScaleInstance = self.Instance:FindFirstChildOfClass("UIScale")

	-- Create one when the button has none
	if not self.ScaleInstance then
		self.ScaleInstance = Instance.new("UIScale")
		self.ScaleInstance.Scale = 1
		self.ScaleInstance.Parent = self.Instance
	end

	--[[ Rest Pose ]]

	self.StartScale = self.ScaleInstance.Scale
	self.DefaultScale = self:GetBaseScale()
	self.DefaultRotation = self.Instance.Rotation
end

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the hover and click scales and the animation, warning on an animation that isn't in ButtonScalePresets.
]]
function Component:GetAttributes()
	--[[ Scales ]]

	self.HoverScale = self.Instance:GetAttribute("Utils_HoverScale") or HOVER_SCALE
	self.ClickScale = self.Instance:GetAttribute("Utils_ClickScale") or CLICK_SCALE

	--[[ Animation ]]

	local animationName: string = self.Instance:GetAttribute("Utils_ScaleAnimation") or DEFAULT_ANIMATION

	-- Check if the animation exists
	if not animations[animationName] then
		warn(`[{_localName}::{script.Name}]: Animation ({animationName}) is missing - using {DEFAULT_ANIMATION}. -`, self.Instance)
		animationName = DEFAULT_ANIMATION
	end

	self.AnimationName = animationName
	self.Animation = animations[animationName]
	self.UsesRotation = self:IsRotating()
	self.HoverRotation = self:GetHoverRotation()
end

--%%%%%%%%%%%%%%%%%%%% Connect Input

--[[
	Plays the animation's phases on hover, on a click or touch, and while a key holds the button (Utils_ButtonKey).
]]
function Component:ConnectInput()
	--[[ Hover ]]

	table.insert(
		self.Connections,
		self.Instance.MouseEnter:Connect(function()
			self.Hovered = true
			self:PlayPhase("Hover")
		end)
	)
	table.insert(
		self.Connections,
		self.Instance.MouseLeave:Connect(function()
			self.Hovered = false
			self:PlayPhase("Leave")
		end)
	)

	--[[ Click ]]

	table.insert(
		self.Connections,
		self.Instance.InputBegan:Connect(function(input: InputObject)
			-- Skip anything but the start of an input
			if input.UserInputState ~= Enum.UserInputState.Begin then
				return
			end

			-- Skip anything but a click or a touch
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			self:PlayPhase("Press")
		end)
	)
	table.insert(
		self.Connections,
		self.Instance.InputEnded:Connect(function(input: InputObject)
			-- Skip anything but a click or a touch
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			self:PlayPhase("Release")
		end)
	)

	--[[ Keys ]]

	table.insert(
		self.Connections,
		ButtonPress.Connect(self.Instance, "Down", function()
			self:PlayPhase("Press")
		end)
	)
	table.insert(
		self.Connections,
		ButtonPress.Connect(self.Instance, "Up", function()
			self:PlayPhase("Release")
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Connect Attributes

--[[
	Applies a changed scale or animation attribute at once, and follows PlatformScale's per-device scale on the UIScale.
]]
function Component:ConnectAttributes()
	--[[ Button Attributes ]]

	for _index: number, attribute: string in ipairs(LIVE_ATTRIBUTES) do
		table.insert(
			self.Connections,
			self.Instance:GetAttributeChangedSignal(attribute):Connect(function()
				self:ApplyAttributes()
			end)
		)
	end

	--[[ Base Scale ]]

	table.insert(
		self.Connections,
		self.ScaleInstance:GetAttributeChangedSignal(BASE_SCALE_ATTRIBUTE):Connect(function()
			self.DefaultScale = self:GetBaseScale()
			self:ApplyAttributes()
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Connect Visibility

--[[
	Follows whether the button is shown, so a hidden button rests and shows again at rest.
]]
function Component:ConnectVisibility()
	--[[ Connections ]]

	table.insert(
		self.Connections,
		GuiVisibility.Watch(self.Instance, function(shown: boolean)
			self:SetShown(shown)
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play Phase

--[[
	Plays one phase of the animation, step after step, from the button's current pose. A newer phase, a reset or
	Destroy stops the steps still to come.
]]
--- @param phase UmeGui_Utils_ButtonScalePhase
function Component:PlayPhase(phase)
	--[[ Checks ]]

	-- Skip while the button is hidden
	if not self.Shown then
		return
	end

	--[[ Local Variables ]]

	local steps = self.Animation[phase] --- @type { UmeGui_Utils_ButtonScaleStep }
	local restScale: number = self:GetRestScale(phase)
	local restRotation: number = self:GetRestRotation(phase)

	self.PlayId += 1
	local playId: number = self.PlayId

	--[[ Playing ]]

	task.spawn(function()
		--- @param step UmeGui_Utils_ButtonScaleStep
		for _index: number, step in ipairs(steps) do
			-- Stop once a newer phase took over
			if self.PlayId ~= playId or self._destroyed then
				return
			end

			self:_playStep(step, restScale, restRotation)
			task.wait(step.Time)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Apply Attributes

--[[
	Re-reads the attributes and rests the button, then plays the hover again when it is still hovered.
]]
function Component:ApplyAttributes()
	--[[ Reading ]]

	self:ResetPose()
	self:GetAttributes()

	--[[ Playing ]]

	-- Show the new hover right away on a hovered button
	if self.Hovered then
		self:PlayPhase("Hover")
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Shown

--[[
	Rests the button when it hides, so it never shows again stuck hovered or pressed.
]]
function Component:SetShown(shown: boolean)
	--[[ Saving ]]

	self.Shown = shown

	--[[ Resetting ]]

	-- Rest the button once it is hidden
	if not shown then
		self.Hovered = false
		self:ResetPose()
	end
end

--%%%%%%%%%%%%%%%%%%%% Reset Pose

--[[
	Stops the running steps and puts the button back at its rest scale and rotation.
]]
function Component:ResetPose()
	--[[ Stopping ]]

	self.PlayId += 1

	for _index: number, tween: Tween in ipairs(self.ActiveTweens) do
		tween:Cancel()
	end

	table.clear(self.ActiveTweens)

	--[[ Applying ]]

	self.ScaleInstance.Scale = self.DefaultScale

	-- Turn the button back only when an animation turns it
	if self.UsesRotation then
		self.Instance.Rotation = self.DefaultRotation
	end
end

--%%%%%%%%%%%%%%%%%%%% Play Step

--[[
	Tweens the UIScale (and the rotation, for an animation that turns the button) to one step's goal, relative to the
	phase's rest scale and rest rotation.
]]
--- @param step UmeGui_Utils_ButtonScaleStep
function Component:_playStep(step, restScale: number, restRotation: number)
	--[[ Local Variables ]]

	local Step_TweenInfo: TweenInfo = TweenInfo.new(step.Time, step.EasingStyle, step.EasingDirection)

	table.clear(self.ActiveTweens)

	--[[ Scale ]]

	local Scale_TweenGoal = { Scale = restScale * step.Scale }
	local Scale_Tween: Tween = I.S.TweenService:Create(self.ScaleInstance, Step_TweenInfo, Scale_TweenGoal)
	Scale_Tween:Play()

	table.insert(self.ActiveTweens, Scale_Tween)

	--[[ Rotation ]]

	-- Skip the rotation for an animation that never turns the button
	if not self.UsesRotation then
		return
	end

	local Rotation_TweenGoal = { Rotation = self.DefaultRotation + restRotation + (step.Rotation or 0) }
	local Rotation_Tween: Tween = I.S.TweenService:Create(self.Instance, Step_TweenInfo, Rotation_TweenGoal)
	Rotation_Tween:Play()

	table.insert(self.ActiveTweens, Rotation_Tween)
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

--%%%%%%%%%%%%%%%%%%%% Get Rest Scale

--[[
	Returns the scale a phase settles on: hovered, pressed, or the base scale. A release settles hovered while the
	pointer is still over the button.
]]
--- @param phase UmeGui_Utils_ButtonScalePhase
--- @return number
function Component:GetRestScale(phase)
	--[[ Returning ]]

	if phase == "Hover" or (phase == "Release" and self.Hovered) then
		return self.DefaultScale * self.HoverScale
	end

	if phase == "Press" then
		return self.DefaultScale * self.ClickScale
	end

	return self.DefaultScale
end

--%%%%%%%%%%%%%%%%%%%% Get Rest Rotation

--[[
	Returns the degrees a phase's steps turn from: the hovered rotation for a release while the pointer is still over
	the button, so it lands back on its hover pose; 0 otherwise.
]]
--- @param phase UmeGui_Utils_ButtonScalePhase
--- @return number
function Component:GetRestRotation(phase)
	return if phase == "Release" and self.Hovered then self.HoverRotation else 0
end

--%%%%%%%%%%%%%%%%%%%% Get Hover Rotation

--[[
	Returns the rotation the hover pose rests at: its last step's, or 0.
]]
--- @return number
function Component:GetHoverRotation()
	--[[ Local Variables ]]

	local hoverSteps = self.Animation.Hover --- @type { UmeGui_Utils_ButtonScaleStep }
	local lastStep = hoverSteps[#hoverSteps] --- @type UmeGui_Utils_ButtonScaleStep?

	--[[ Returning ]]

	return if lastStep and lastStep.Rotation then lastStep.Rotation else 0
end

--%%%%%%%%%%%%%%%%%%%% Is Rotating

--[[
	Returns whether any step of the animation turns the button.
]]
--- @return boolean
function Component:IsRotating()
	--[[ Finding ]]

	--- @param steps { UmeGui_Utils_ButtonScaleStep }
	for _phase: string, steps in pairs(self.Animation) do
		--- @param step UmeGui_Utils_ButtonScaleStep
		for _index: number, step in ipairs(steps) do
			-- Stop at the first step with a rotation
			if step.Rotation ~= nil then
				return true
			end
		end
	end

	--[[ Returning ]]

	return false
end

return Component
