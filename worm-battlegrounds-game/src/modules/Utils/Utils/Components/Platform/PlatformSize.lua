--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Platforms ]]

-- The platforms that each have a size attribute (`Utils_<Platform>Size`)
local PLATFORMS = { "Desktop", "Mobile", "Console", "VR" } --- @type { string }

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

--- @class Utils_PlatformSize : Component
--- @field Instance GuiObject
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field Sizes { [string]: UDim2 }
---
--- # Rest Pose #
---
--- @field DefaultSize UDim2
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

	self.DefaultSize = self.Instance.Size
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

	-- Give the element its built size back
	if self.DefaultSize then
		self.Instance.Size = self.DefaultSize
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the size of each platform; a zero UDim2 keeps the built size.
]]
function Component:GetAttributes()
	--[[ Reading ]]

	self.Sizes = {}

	for _index: number, platform: string in ipairs(PLATFORMS) do
		local size: UDim2 = self.Instance:GetAttribute(`Utils_{platform}Size`) or UDim2.new()

		self.Sizes[platform] = if size == UDim2.new() then self.DefaultSize else size
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Updates

--[[
	Updates the size when the platform changes, and applies a changed size attribute at once.
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
			self.Instance:GetAttributeChangedSignal(`Utils_{platform}Size`):Connect(function()
				self:GetAttributes()
				self:Update()
			end)
		)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	Sets the size of the current platform.
]]
function Component:Update()
	--[[ Applying ]]

	self.Instance.Size = self.Sizes[I.Platform.Current] or self.DefaultSize
end

return Component
