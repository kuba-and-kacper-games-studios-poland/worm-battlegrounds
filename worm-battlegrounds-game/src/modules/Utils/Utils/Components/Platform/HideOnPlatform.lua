--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local HideReasons = require(_scripts:FindFirstChild("HideReasons")) --- @type Utils_HideReasons

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Platforms ]]

-- The platforms that each have a visibility attribute (`Utils_<Platform>Visibility`)
local PLATFORMS = { "Desktop", "Mobile", "Console", "VR" } --- @type { string }

-- The hide reason this component holds in HideReasons
local HIDE_REASON: string = "Utils_HideOnPlatform"

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

--- @class Utils_HideOnPlatform : Component
--- @field Instance Instance
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field VisibilityStates { [string]: boolean }
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Setup ]]

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

	--[[ Forget Hide Reason ]]

	HideReasons.Clear(self.Instance, HIDE_REASON)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads whether the instance shows on each platform; a missing attribute shows it.
]]
function Component:GetAttributes()
	--[[ Reading ]]

	self.VisibilityStates = {}

	for _index: number, platform: string in ipairs(PLATFORMS) do
		self.VisibilityStates[platform] = self.Instance:GetAttribute(`Utils_{platform}Visibility`) ~= false
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Updates

--[[
	Updates the visibility when the platform changes, and applies a changed visibility attribute at once.
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
			self.Instance:GetAttributeChangedSignal(`Utils_{platform}Visibility`):Connect(function()
				self:GetAttributes()
				self:Update()
			end)
		)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update

--[[
	Hides or shows the instance for the current platform; another component's hide still keeps it hidden.
]]
function Component:Update()
	--[[ Applying ]]

	HideReasons.SetHidden(self.Instance, HIDE_REASON, self.VisibilityStates[I.Platform.Current] ~= true)
end

return Component
