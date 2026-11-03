--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Platforms ]]

-- The platforms that each have a scale attribute (`Utils_<Platform>Scale`)
local PLATFORMS = { "Desktop", "Mobile", "Console", "VR" } --- @type { string }

--[[ Attributes ]]

-- The attribute the per-device scale is kept in on the UIScale, so ButtonScale and ButtonTransform rest on it
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

--- @class Utils_PlatformScale : Component
--- @field Instance GuiObject
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field Scales { [string]: number }
---
--- # Elements #
---
--- @field ScaleInstance UIScale
--- @field CreatedScaleInstance boolean
---
--- # Rest Pose #
---
--- @field DefaultScale number
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

	--[[ Setup ]]

	self:CreateScaleInstance()
	self:GetAttributes()
	self:Update()

	--[[ Connections ]]

	self:ConnectUpdates()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	--[[ Restoring ]]

	-- Skip an instance that never started
	if not self.ScaleInstance then
		return
	end

	-- Destroy only a UIScale this component created; give an adopted one its original scale back
	if self.CreatedScaleInstance then
		self.ScaleInstance:Destroy()
	else
		self.ScaleInstance:SetAttribute(BASE_SCALE_ATTRIBUTE, nil)
		self.ScaleInstance.Scale = self.DefaultScale
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Scale Instance

--[[
	Finds the element's UIScale or creates one, remembering which, and keeps its scale as the built scale.
]]
function Component:CreateScaleInstance()
	--[[ Finding ]]

	self.ScaleInstance = self.Instance:FindFirstChildOfClass("UIScale")
	self.CreatedScaleInstance = false

	-- Create one when the element has none
	if not self.ScaleInstance then
		self.ScaleInstance = Instance.new("UIScale")
		self.ScaleInstance.Parent = self.Instance
		self.CreatedScaleInstance = true
	end

	--[[ Rest Pose ]]

	self.DefaultScale = self.ScaleInstance:GetAttribute(BASE_SCALE_ATTRIBUTE) or self.ScaleInstance.Scale
end

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the scale of each platform; `0` keeps the built scale.
]]
function Component:GetAttributes()
	--[[ Reading ]]

	self.Scales = {}

	for _index: number, platform: string in ipairs(PLATFORMS) do
		local scale: number = self.Instance:GetAttribute(`Utils_{platform}Scale`) or 0

		self.Scales[platform] = if scale == 0 then self.DefaultScale else scale
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Updates

--[[
	Updates the scale when the platform changes, and applies a changed scale attribute at once.
]]
function Component:ConnectUpdates()
	--[[ Platform ]]

	table.insert(
		self.Connections,
		I.Topic.Subscribe("Platform_Changed", function()
			self:Update()
		end)
	)

	--[[ Attributes ]]

	for _index: number, platform: string in ipairs(PLATFORMS) do
		table.insert(
			self.Connections,
			self.Instance:GetAttributeChangedSignal(`Utils_{platform}Scale`):Connect(function()
				self:GetAttributes()
				self:Update()
			end)
		)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	Sets the scale of the current platform, and keeps it on the UIScale as the scale the button components rest on.
]]
function Component:Update()
	--[[ Local Variables ]]

	local scale: number = self.Scales[I.Platform.Current] or self.DefaultScale

	--[[ Applying ]]

	self.ScaleInstance:SetAttribute(BASE_SCALE_ATTRIBUTE, scale)
	self.ScaleInstance.Scale = scale
end

return Component
