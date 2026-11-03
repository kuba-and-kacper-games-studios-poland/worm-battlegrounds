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

--- @class Utils_UITextSizeConstraint : Component
--- @field Instance UITextSizeConstraint
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field Sizes { [string]: NumberRange }
---
--- # Rest Pose #
---
--- @field DefaultSize NumberRange
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Checks ]]

	-- Check if the instance is a UITextSizeConstraint
	if not self.Instance:IsA("UITextSizeConstraint") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a (UITextSizeConstraint)! -`, self.Instance)
		return
	end

	--[[ Setup ]]

	self.DefaultSize = NumberRange.new(self.Instance.MinTextSize, self.Instance.MaxTextSize)
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

	-- Give the constraint its built size back
	if self.DefaultSize then
		self.Instance.MinTextSize = self.DefaultSize.Min
		self.Instance.MaxTextSize = self.DefaultSize.Max
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the text size range of each platform, clamped to 1 to 100. A `0, 0` range, or a value that isn't a
	NumberRange (which warns), keeps the built size.
]]
function Component:GetAttributes()
	--[[ Reading ]]

	self.Sizes = {}

	for _index: number, platform: string in ipairs(PLATFORMS) do
		local value: any = self.Instance:GetAttribute(`Utils_{platform}Size`)

		-- Keep the built size when none is set
		if value == nil then
			self.Sizes[platform] = self.DefaultSize
			continue
		end

		-- Check if the value is a NumberRange
		if typeof(value) ~= "NumberRange" then
			warn(`[{_localName}::{script.Name}]: (Utils_{platform}Size) must be a NumberRange, not a ({typeof(value)})! -`, self.Instance)
			self.Sizes[platform] = self.DefaultSize
			continue
		end

		-- Keep the built size for a 0, 0 range
		if value.Min == 0 and value.Max == 0 then
			self.Sizes[platform] = self.DefaultSize
			continue
		end

		--[[ Clamping ]]

		local maxTextSize: number = math.clamp(value.Max, 1, 100)
		local minTextSize: number = math.min(math.clamp(value.Min, 1, 100), maxTextSize)

		self.Sizes[platform] = NumberRange.new(minTextSize, maxTextSize)
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
	Sets the text size range of the current platform.
]]
function Component:Update()
	--[[ Applying ]]

	local size: NumberRange = self.Sizes[I.Platform.Current] or self.DefaultSize

	self.Instance.MinTextSize = size.Min
	self.Instance.MaxTextSize = size.Max
end

return Component
