--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "BackpackPlus"

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

--- @class BackpackPlus_FilterButton : Component
--- @field Instance GuiObject
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field FilterCategory string?
---
--- # Elements #
---
--- @field Background GuiObject
--- @field BackgroundGradient UIGradient
--- @field DefaultGradientColor ColorSequence
--- @field SelectedOutline GuiObject?
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
	if not self.FilterCategory then
		return
	end

	self:GetElements()
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
	--[[ Attributes ]]

	local filterCategory = self.Instance:GetAttribute("BackpackPlus_FilterCategory")
	if typeof(filterCategory) ~= "string" then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is missing a valid FilterCategory! -`, self.Instance)
		return
	end

	self.FilterCategory = filterCategory
end

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements.
]]
function Component:GetElements()
	self.Background = self.Instance:FindFirstChild("S_Background", true) --- @type GuiObject
	self.BackgroundGradient = self.Background:FindFirstChild("UIGradient", true) --- @type UIGradient
	self.DefaultGradientColor = self.BackgroundGradient.Color

	-- A button with a Selected outline inside (a theme's pixel button) shows its pick with it
	self.SelectedOutline = self.Instance:FindFirstChild("Selected", true) --- @type GuiObject?
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Creates connections for filter input and updates.
]]
function Component:CreateConnections()
	--[[ Interact Connection ]]

	table.insert(
		self.Connections,
		self.Instance.MouseButton1Click:Connect(function()
			if self.FilterCategory == "" then
				I.BackpackPlus.ClearFilter("Category")
			else
				I.BackpackPlus.SetFilter("Category", self.FilterCategory)
			end
		end)
	)

	--[[ Filter Updated Connection ]]

	table.insert(
		self.Connections,
		I.Topic.Subscribe("BackpackPlus_FilterSet", function(filterName: string, filterValue: string?)
			if filterName == "Category" then
				self:UpdateDisplay(filterValue)
			end
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update Display

--[[
	Updates filter button gradient based on the active Category filter, and shows a pixel button's outline on the
	picked one.
]]
function Component:UpdateDisplay(filterValue: string?)
	--[[ Getting State ]]

	local isSelected: boolean = self.FilterCategory == (filterValue or "")

	--[[ Updating ]]

	if isSelected then
		self.BackgroundGradient.Color = ColorSequence.new(Color3.fromRGB(60, 60, 60))
	else
		self.BackgroundGradient.Color = self.DefaultGradientColor
	end

	-- Check if the button has the pixel outline
	if self.SelectedOutline then
		self.SelectedOutline.Visible = isSelected
	end
end

return Component
