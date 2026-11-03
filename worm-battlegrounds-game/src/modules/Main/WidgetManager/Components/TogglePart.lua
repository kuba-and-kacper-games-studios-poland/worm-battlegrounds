--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "WidgetManager"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local insideCounts = {} --- @type { [string]: number }
local pendingOpens = {} --- @type { [string]: boolean }
local zoneOpened = {} --- @type { [string]: boolean }

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

--- @class WidgetManager_TogglePart : Component
--- @field Instance BasePart
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field WidgetName string
---
--- # Elements #
---
--- @field Region BasePart
---
--- # State #
---
--- @field IsInside boolean
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Initialization ]]

	self:GetAttributes()
	if not self.WidgetName then
		return
	end

	self:GetElements()
	if not self.Region then
		return
	end

	--[[ State ]]

	self.IsInside = false

	self:CreateConnections()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	--[[ Zone ]]

	-- Count this zone out when it goes away with the player inside
	if self.IsInside then
		self:SetInside(false)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Getting and storing the widget name attribute.
]]
function Component:GetAttributes()
	--[[ Getting ]]

	local widgetName = self.Instance:GetAttribute("WidgetManager_WidgetName")
	if typeof(widgetName) ~= "string" or widgetName == "" then
		warn(`[{_localName}::{script.Name}]: ({widgetName}) is not a valid WidgetName! -`, self.Instance)
		return
	end

	--[[ Saving ]]

	self.WidgetName = widgetName
end

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing the toggle region.
]]
function Component:GetElements()
	--[[ Checks ]]

	if not self.Instance:IsA("BasePart") then
		warn(`[{_localName}::{script.Name}]: ({self.Instance.Name}) is not a BasePart! -`, self.Instance)
		return
	end

	--[[ Saving ]]

	self.Region = self.Instance
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Creates the connection that opens and closes the widget in the region.
]]
function Component:CreateConnections()
	table.insert(
		self.Connections,
		I.DoEvery.Get(0.15):Connect(function()
			--[[ Checks ]]

			-- Skip a destroyed component
			if self._destroyed then
				return
			end

			--[[ Getting Player Position ]]

			local character: Model? = I.Env.LocalPlayer.Character

			-- Skip while the player has no character
			if not character then
				return
			end

			local playerPos: Vector3 = character:GetPivot().Position

			--[[ Counting ]]

			local isPlayerIn: boolean = I.World.IsPointInRegion(playerPos, self.Region.CFrame, self.Region.Size)

			-- Count the zone in or out when the player crosses its edge
			if isPlayerIn ~= self.IsInside then
				self:SetInside(isPlayerIn)
			end

			--[[ Opening ]]

			-- Skip unless a zone holds the player and the widget still has to open
			if not self.IsInside or not pendingOpens[self.WidgetName] then
				return
			end

			local current: ScreenGui? = I.WidgetManager.GetCurrent()

			-- Leave a widget the player already opened to them
			if current and current.Name == self.WidgetName then
				pendingOpens[self.WidgetName] = nil
				return
			end

			-- Keep trying until the widget opens
			if I.WidgetManager.Open(self.WidgetName) then
				pendingOpens[self.WidgetName] = nil
				zoneOpened[self.WidgetName] = true
			end
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Inside

--[[
	Counts this zone in or out of the zones of its widget, which every TogglePart shares.
	The first zone entered opens the widget; the last one left closes it when a zone opened it.
]]
function Component:SetInside(isInside: boolean)
	--[[ Counting ]]

	local count: number = (insideCounts[self.WidgetName] or 0) + (if isInside then 1 else -1)
	insideCounts[self.WidgetName] = if count > 0 then count else nil
	self.IsInside = isInside

	--[[ Opening ]]

	-- Open the widget on the first zone entered
	if isInside and count == 1 then
		pendingOpens[self.WidgetName] = true
	end

	--[[ Closing ]]

	-- Skip unless the player left the last zone of this widget
	if isInside or count > 0 then
		return
	end

	pendingOpens[self.WidgetName] = nil

	-- Close only a widget a zone opened
	if zoneOpened[self.WidgetName] then
		zoneOpened[self.WidgetName] = nil
		I.WidgetManager.Close(self.WidgetName)
	end
end

return Component
