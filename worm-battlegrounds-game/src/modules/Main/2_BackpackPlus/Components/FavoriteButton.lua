--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "BackpackPlus"

--- @type BackpackPlus_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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

--- @class BackpackPlus_FavoriteButton : Component
--- @field Instance GuiButton
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Elements #
---
--- @field Background GuiObject
--- @field BackgroundGradient UIGradient
--- @field DefaultGradientColor ColorSequence
--- @field DefaultGradientTransparency NumberSequence
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
	if not self.BackgroundGradient then
		return
	end

	self:CreateConnections()

	--[[ Initial Update ]]

	self:UpdateDisplay(I.BackpackPlus.IsFavoriteMode())
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements.
]]
function Component:GetElements()
	self.Background = self.Instance:FindFirstChild("S_Background", true) --- @type GuiObject
	self.BackgroundGradient = self.Background and self.Background:FindFirstChild("UIGradient", true) --- @type UIGradient?

	if self.BackgroundGradient then
		self.DefaultGradientColor = self.BackgroundGradient.Color
		self.DefaultGradientTransparency = self.BackgroundGradient.Transparency
	end
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Creates connections for favorite mode input and updates.
]]
function Component:CreateConnections()
	--[[ Interact Connection ]]

	table.insert(
		self.Connections,
		self.Instance.MouseButton1Click:Connect(function()
			I.BackpackPlus.ToggleFavoriteMode()
		end)
	)

	--[[ Favorite Mode Connection ]]

	table.insert(
		self.Connections,
		I.Topic.Subscribe("BackpackPlus_FavoriteModeChanged", function(isActive: boolean)
			self:UpdateDisplay(isActive)
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update Display

--[[
	Updates favorite button gradient based on favorite mode.
]]
function Component:UpdateDisplay(isActive: boolean)
	--[[ Updating ]]

	if isActive then
		self.BackgroundGradient.Color = I.Gradient.GetColor(_settings.FAVORITE_GRADIENT_NAME)
		self.BackgroundGradient.Transparency = NumberSequence.new(0)
	else
		self.BackgroundGradient.Color = self.DefaultGradientColor
		self.BackgroundGradient.Transparency = self.DefaultGradientTransparency
	end
end

return Component
