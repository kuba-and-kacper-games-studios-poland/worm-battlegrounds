--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Limited"

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

--- @class Limited_Slot : Component
--- @field Instance TextLabel
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field LimitedId string
--- @field CustomFormat string
---
--- # Elements #
---
--- @field GlobalDir Folder
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
	if not self.LimitedId then
		return
	end

	self:GetElements()
	if not self.GlobalDir then
		return
	end

	self:CreateConnections()

	--[[ Initial Update ]]

	self:UpdateDisplay()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Getting and storing key attributes.
]]
function Component:GetAttributes()
	--[[ Checks ]]

	local limitedId = self.Instance:GetAttribute("Limited_Id")
	if typeof(limitedId) ~= "string" or #limitedId == 0 then
		warn(`[{_localName}::{script.Name}]: ({self.Instance.Name}) is missing a valid (Limited_Id) attribute! -`, self.Instance)
		return
	end

	--[[ Saving ]]

	self.LimitedId = limitedId
	self.CustomFormat = self.Instance:GetAttribute("Limited_CustomFormat")
	if self.CustomFormat == "" then
		self.CustomFormat = nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements.
]]
function Component:GetElements()
	--[[ Checks ]]

	if not self.Instance:IsA("TextLabel") then
		warn(`[{_localName}::{script.Name}]: ({self.Instance.Name}) is not a TextLabel! -`, self.Instance)
		return
	end

	--[[ Replicator ]]

	self.GlobalDir = I.Dirs.Storage:WaitForChild(_localName, 30)
	if not self.GlobalDir then
		warn(`[{_localName}::{script.Name}]: ({self.Instance.Name}) could not find global replicator folder!`)
		return
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Creates connections for limited stock updates.
]]
function Component:CreateConnections()
	--[[ Sold Updated ]]

	table.insert(
		self.Connections,
		self.GlobalDir:GetAttributeChangedSignal(`{self.LimitedId}_Sold`):Connect(function()
			self:UpdateDisplay()
		end)
	)

	--[[ Max Updated ]]

	table.insert(
		self.Connections,
		self.GlobalDir:GetAttributeChangedSignal(`{self.LimitedId}_Max`):Connect(function()
			self:UpdateDisplay()
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update Display

--[[
	Updates the limited display on self.Instance.
	`CustomFormat` is a `string.format` pattern taking two `%s` values: amount left, then total.
]]
function Component:UpdateDisplay()
	--[[ Values ]]

	local sold: number = tonumber(self.GlobalDir:GetAttribute(`{self.LimitedId}_Sold`)) or 0
	local max: number = tonumber(self.GlobalDir:GetAttribute(`{self.LimitedId}_Max`)) or 0
	local left: number = math.max(0, max - sold)

	--[[ Formatting ]]

	local leftFormatted: string = I.BN.FormatWithSeparator(left, ",")
	local maxFormatted: string = I.BN.FormatWithSeparator(max, ",")

	--[[ Updating Display ]]

	if self.CustomFormat then
		self.Instance.Text = string.format(self.CustomFormat, leftFormatted, maxFormatted)
	else
		self.Instance.Text = `{leftFormatted}/{maxFormatted}`
	end
end

return Component
