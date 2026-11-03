--[[
    Created By:     Nari
]]

-- --- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local GuiVisibility = require(_scripts:FindFirstChild("GuiVisibility")) --- @type Utils_GuiVisibility

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Defaults ]]

local DEFAULT_ROW_AMOUNT: number = 10

-- The attributes that apply live when changed
local LIVE_ATTRIBUTES = { "Utils_RowAmount", "Utils_XScale", "Utils_YScale" } --- @type { string }

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

--- @class Utils_UIGrid : Component
--- @field Instance UIGridLayout
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field RowAmount number
--- @field XScale number
--- @field YScale number
---
--- # State #
---
--- @field ParentSizeConnection RBXScriptConnection?
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Checks ]]

	-- Check if the instance is a UIGridLayout
	if not self.Instance:IsA("UIGridLayout") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a (UIGridLayout)! -`, self.Instance)
		return
	end

	--[[ Setup ]]

	self:GetAttributes()

	--[[ Connections ]]

	self:ConnectAttributes()
	self:ConnectParent()
	self:ConnectVisibility()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	--[[ Disconnecting ]]

	-- Stop following the parent's size
	if self.ParentSizeConnection then
		self.ParentSizeConnection:Disconnect()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the cells per row and the cell size multipliers, warning on a row amount that isn't above 0.
]]
function Component:GetAttributes()
	--[[ Reading ]]

	self.RowAmount = self.Instance:GetAttribute("Utils_RowAmount") or DEFAULT_ROW_AMOUNT
	self.XScale = self.Instance:GetAttribute("Utils_XScale") or 1
	self.YScale = self.Instance:GetAttribute("Utils_YScale") or 1

	--[[ Checks ]]

	-- Check if the row amount is a number above 0
	if type(self.RowAmount) ~= "number" or self.RowAmount <= 0 then
		warn(`[{_localName}::{script.Name}]: (Utils_RowAmount) must be greater than 0, not ({self.RowAmount})! -`, self.Instance)
		self.RowAmount = DEFAULT_ROW_AMOUNT
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Attributes

--[[
	Resizes the cells when a size attribute changes, or when `Utils_Update` is set to true (it turns itself off).
]]
function Component:ConnectAttributes()
	--[[ Size Attributes ]]

	for _index: number, attribute: string in ipairs(LIVE_ATTRIBUTES) do
		table.insert(
			self.Connections,
			self.Instance:GetAttributeChangedSignal(attribute):Connect(function()
				self:GetAttributes()
				self:UpdateGridSize()
			end)
		)
	end

	--[[ Update Request ]]

	table.insert(
		self.Connections,
		self.Instance:GetAttributeChangedSignal("Utils_Update"):Connect(function()
			-- Skip the reset back to false
			if not self.Instance:GetAttribute("Utils_Update") then
				return
			end

			self.Instance:SetAttribute("Utils_Update", false)
			self:UpdateGridSize()
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Connect Parent

--[[
	Follows the parent's width (the inner width of a ScrollingFrame), moving to the new parent when the layout moves.
]]
function Component:ConnectParent()
	--[[ Connections ]]

	table.insert(
		self.Connections,
		self.Instance:GetPropertyChangedSignal("Parent"):Connect(function()
			self:_connectParentSize()
			self:UpdateGridSize()
		end)
	)

	self:_connectParentSize()
	self:UpdateGridSize()
end

--%%%%%%%%%%%%%%%%%%%% Connect Visibility

--[[
	Resizes the cells each time the layout's gui shows, since a hidden parent may have changed size meanwhile.
]]
function Component:ConnectVisibility()
	--[[ Connections ]]

	table.insert(
		self.Connections,
		GuiVisibility.Watch(self.Instance, function(shown: boolean)
			-- Resize once shown again
			if shown then
				self:UpdateGridSize()
			end
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Connect Parent Size

--[[
	Replaces the listener on the parent's size with one on the current parent.
]]
function Component:_connectParentSize()
	--[[ Disconnecting ]]

	if self.ParentSizeConnection then
		self.ParentSizeConnection:Disconnect()
		self.ParentSizeConnection = nil
	end

	--[[ Checks ]]

	local parent: Instance? = self.Instance.Parent

	-- Skip a layout without a gui parent
	if not parent or not parent:IsA("GuiObject") then
		return
	end

	--[[ Connections ]]

	local sizeProperty: string = if parent:IsA("ScrollingFrame") then "AbsoluteWindowSize" else "AbsoluteSize"

	self.ParentSizeConnection = parent:GetPropertyChangedSignal(sizeProperty):Connect(function()
		self:UpdateGridSize()
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update Grid Size

--[[
	Sizes the cells so `RowAmount` of them fit across the parent's width (the inner width for a ScrollingFrame),
	less its horizontal UIPadding.
]]
function Component:UpdateGridSize()
	--[[ Checks ]]

	local parent: Instance? = self.Instance.Parent

	-- Skip a layout without a gui parent
	if not parent or not parent:IsA("GuiObject") then
		return
	end

	--[[ Calculating ]]

	local padding: UIPadding? = parent:FindFirstChildOfClass("UIPadding")
	local paddingLeftRight: number = if padding then padding.PaddingLeft.Offset + padding.PaddingRight.Offset else 0

	local parentWidth: number = if parent:IsA("ScrollingFrame") then parent.AbsoluteWindowSize.X else parent.AbsoluteSize.X
	local cellSize: number = (parentWidth - paddingLeftRight) / self.RowAmount

	--[[ Applying ]]

	self.Instance.CellSize = UDim2.fromOffset(cellSize * self.XScale, cellSize * self.YScale)
end

return Component
