--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "BackpackPlus"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Motion Settings ]]

-- Swing
local SWING_Y_AMPLITUDE: number = 7.5
local SWING_SPEED: number = 4

-- Scale Targets
local SCALE_NORMAL: number = 1
local SCALE_HOVER: number = 1.075
local SCALE_PRESSED: number = 0.88

-- Scale Spring
local SCALE_SPRING_STIFFNESS: number = 220
local SCALE_SPRING_DAMPING: number = 14
local SCALE_RELEASE_VELOCITY: number = 8

-- Scale Timing
local SCALE_QUICK_HOVER_DURATION: number = 0.15
local SCALE_SETTLE_EPSILON: number = 0.001
local SCALE_MIN: number = 0.001
local SCALE_MAX_DELTA: number = 1 / 30

--[[ Motion Instances ]]

--- @type { [Frame]: BackpackPlus_Slot_ViewportMotion }
local activeMotions = {}

local swingProgress: number = 0
local swingHeartbeat: RBXScriptConnection? = nil

--[[ Visibility ]]

local backpackGui: ScreenGui
local itemsContainer: Frame

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Target Scale

--[[
	Returns the interactive scale target for a viewport motion component.
]]
--- @param motion BackpackPlus_Slot_ViewportMotion
--- @return number
local function getTargetScale(motion)
	if motion.IsPressed then
		return SCALE_PRESSED
	end

	if motion.IsHovered then
		return SCALE_HOVER
	end

	return SCALE_NORMAL
end

--%%%%%%%%%%%%%%%%%%%% Ensure Swing Heartbeat

--[[
	Starts the shared Y-swing heartbeat when the first motion component is active.
]]
local function ensureSwingHeartbeat()
	--[[ Checks ]]

	-- Heartbeat already active
	if swingHeartbeat then
		return
	end

	--[[ Elements ]]

	backpackGui = I.UserInterface.UI["BackpackPlus"]
	itemsContainer = backpackGui:FindFirstChild("U_Backpack", true):FindFirstChild("S_ItemsContainer", true)

	--[[ Animation Loop ]]

	swingHeartbeat = I.S.RunService.Heartbeat:Connect(function(deltaTime: number)
		swingProgress += deltaTime

		--[[ Updating Global Rotation ]]

		local ySwingRadians: number = math.sin(swingProgress * SWING_SPEED) * math.rad(SWING_Y_AMPLITUDE)
		local isBackpackOpen: boolean = I.BackpackPlus.GetState()

		--[[ Updating All Saved Slots ]]

		--- @param motion BackpackPlus_Slot_ViewportMotion
		for _, motion in pairs(activeMotions) do
			--[[ Checks ]]

			-- Clear if slot is destroyed/invalid
			if motion._destroyed or not motion.Model or not motion.Model.Parent then
				activeMotions[motion.Instance] = nil
				continue
			end

			-- Skipping Slots that are not on screen (gui disabled, Slot hidden, or in the closed backpack)
			if not backpackGui.Enabled or not motion.Instance.Visible or (not isBackpackOpen and motion.Instance.Parent == itemsContainer) then
				continue
			end

			--[[ Updating Scale ]]

			-- Skipping settled spring
			if math.abs(motion.TargetScale - motion.Scale) > SCALE_SETTLE_EPSILON or math.abs(motion.ScaleVelocity) > SCALE_SETTLE_EPSILON then
				-- Stepping spring
				local springDeltaTime: number = math.min(deltaTime, SCALE_MAX_DELTA)
				local scaleAccel: number = (motion.TargetScale - motion.Scale) * SCALE_SPRING_STIFFNESS - motion.ScaleVelocity * SCALE_SPRING_DAMPING
				motion.ScaleVelocity += scaleAccel * springDeltaTime
				motion.Scale = math.max(motion.Scale + motion.ScaleVelocity * springDeltaTime, SCALE_MIN)

				-- Snapping settled spring
				if math.abs(motion.TargetScale - motion.Scale) <= SCALE_SETTLE_EPSILON and math.abs(motion.ScaleVelocity) <= SCALE_SETTLE_EPSILON then
					motion.Scale = motion.TargetScale
					motion.ScaleVelocity = 0
				end

				-- Applying scale
				motion.Model:ScaleTo(math.max(motion.DefaultScale * motion.Scale, SCALE_MIN))
			end

			-- Applying swing rotation
			motion.Model:PivotTo(CFrame.new(motion.PivotPosition) * motion.BaseRotation * CFrame.Angles(0, ySwingRadians, 0))
		end

		--[[ Cleanup ]]

		if next(activeMotions) == nil then
			if swingHeartbeat then
				swingHeartbeat:Disconnect()
				swingHeartbeat = nil
			end
		end
	end)
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

--- @class BackpackPlus_Slot_ViewportMotion : Component
--- @field Instance Frame
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Elements #
---
--- @field SlotButton ImageButton
--- @field ItemWorldModel WorldModel
---
--- # Model #
---
--- @field Model Model?
--- @field PivotPosition Vector3
--- @field BaseRotation CFrame
--- @field DefaultScale number
---
--- # Interaction #
---
--- @field IsHovered boolean
--- @field IsPressed boolean
--- @field HoverStartedAt number?
---
--- # Scale #
---
--- @field Scale number
--- @field ScaleVelocity number
--- @field TargetScale number
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Initialization ]]

	self:GetElements()

	--[[ Properties ]]

	self.IsHovered = false
	self.IsPressed = false
	self.HoverStartedAt = nil
	self.Scale = SCALE_NORMAL
	self.ScaleVelocity = 0
	self.TargetScale = SCALE_NORMAL

	--[[ Connections ]]

	self:CreateConnections()

	--[[ Starting ]]

	local displayModel: Instance? = self.ItemWorldModel:FindFirstChild("UnitDisplayModel")

	-- Binding the display model when it already exists
	if displayModel and displayModel:IsA("Model") then
		self:BindModel(displayModel)
	end
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	--[[ Removing From Active ]]

	if activeMotions[self.Instance] then
		activeMotions[self.Instance] = nil
	end

	-- Disconnecting global update if no models are assigned
	if next(activeMotions) == nil and swingHeartbeat then
		swingHeartbeat:Disconnect()
		swingHeartbeat = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements.
]]
function Component:GetElements()
	self.SlotButton = self.Instance:FindFirstChild("S_SlotButton", true) --- @type ImageButton
	self.ItemWorldModel = self.Instance:FindFirstChild("S_ItemWorldModel", true) --- @type WorldModel
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Connects slot button hover / press to per-instance scale targets, and binds the display model when it is added or rebuilt.
]]
function Component:CreateConnections()
	--[[ Display Model ]]

	-- Binding a display model added after Init
	table.insert(
		self.Connections,
		self.ItemWorldModel.ChildAdded:Connect(function(child: Instance)
			-- Ignoring other children
			if child.Name ~= "UnitDisplayModel" or not child:IsA("Model") then
				return
			end

			self:BindModel(child)
		end)
	)

	-- Unbinding a removed display model
	table.insert(
		self.Connections,
		self.ItemWorldModel.ChildRemoved:Connect(function(child: Instance)
			-- Ignoring children that aren't the bound model
			if child ~= self.Model then
				return
			end

			self.Model = nil
			activeMotions[self.Instance] = nil
		end)
	)

	--[[ Hover ]]

	-- Begin
	table.insert(
		self.Connections,
		self.SlotButton.MouseEnter:Connect(function()
			--[[ Updating ]]

			self.IsHovered = true
			self.TargetScale = getTargetScale(self)
			self.HoverStartedAt = os.clock()
		end)
	)

	-- End
	table.insert(
		self.Connections,
		self.SlotButton.MouseLeave:Connect(function()
			--[[ Clearing ]]

			self.IsHovered = false
			self.IsPressed = false

			--[[ Updating ]]

			local targetScale: number = getTargetScale(self)
			local hoverStartedAt: number? = self.HoverStartedAt
			self.HoverStartedAt = nil
			self.TargetScale = targetScale

			--[[ Snapping ]]

			-- Snapping a quick hover back on the bound model
			if self.Model and hoverStartedAt and os.clock() - hoverStartedAt <= SCALE_QUICK_HOVER_DURATION then
				self.Scale = targetScale
				self.ScaleVelocity = 0
				self.Model:ScaleTo(math.max(self.DefaultScale * targetScale, SCALE_MIN))
			end
		end)
	)

	--[[ Input ]]

	-- Begin
	table.insert(
		self.Connections,
		self.SlotButton.InputBegan:Connect(function(input: InputObject)
			--[[ Checks ]]

			-- Ignoring non-begin input
			if input.UserInputState ~= Enum.UserInputState.Begin then
				return
			end

			-- Ignoring non-press input
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			--[[ Pressing ]]

			self.IsPressed = true
			self.TargetScale = getTargetScale(self)
		end)
	)

	-- End
	table.insert(
		self.Connections,
		self.SlotButton.InputEnded:Connect(function(input: InputObject)
			--[[ Checks ]]

			-- Ignoring non-press input
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			--[[ Releasing ]]

			self.IsPressed = false
			self.TargetScale = getTargetScale(self)
			self.ScaleVelocity = math.max(self.ScaleVelocity, SCALE_RELEASE_VELOCITY)
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Bind Model

--[[
	Caches pivot / scale baselines for the viewport display model and starts animating it.
]]
function Component:BindModel(model: Model)
	--[[ Caching ]]

	local modelPivot: CFrame = model:GetPivot()

	self.Model = model
	self.PivotPosition = modelPivot.Position
	self.BaseRotation = modelPivot.Rotation
	self.DefaultScale = math.max(model:GetScale(), SCALE_MIN)

	--[[ Resetting ]]

	self.Scale = SCALE_NORMAL
	self.ScaleVelocity = 0
	self.TargetScale = getTargetScale(self)

	--[[ Starting ]]

	activeMotions[self.Instance] = self
	ensureSwingHeartbeat()
end

return Component
