--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Rarity"

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

--- @class Rarity_Gradient : Component
--- @field Instance UIGradient
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field Rarity string
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Type Check ]]

	if not self.Instance:IsA("UIGradient") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a (UIGradient)! -`, self.Instance)
		return
	end

	--[[ Connecting ]]

	table.insert(
		self.Connections,
		self.Instance:GetAttributeChangedSignal("Rarity_Rarity"):Connect(function()
			self:Apply()
		end)
	)

	--[[ Applying ]]

	self:Apply()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	self.Instance:RemoveTag("Utils_UIGradientMove")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Applies rarity color, rotation, and the scroll (`Utils_UIGradientMove`) from the `Rarity_Rarity` attribute.
	The scroll stays tagged and stops at speed 0, so a change of rarity never brings the old colors back.
]]
function Component:Apply()
	--[[ Data ]]

	local rarity: string? = self.Instance:GetAttribute("Rarity_Rarity")
	if typeof(rarity) ~= "string" or rarity == "" then
		rarity = "Common"
	end

	self.Rarity = rarity

	--[[ Applying ]]

	--- @type Gradient_GradientTable
	local stored = I.Gradient.Get(`Rarity_{rarity}`)
	self.Instance.Color = stored.Color
	self.Instance.Offset = stored.Offset
	self.Instance.Transparency = stored.Transparency

	local rotation: number? = I.Rarity.GetGradientRotation(rarity)
	self.Instance.Rotation = if typeof(rotation) == "number" then rotation else 0

	--[[ Scrolling ]]

	-- Without a speed the scroll uses its default
	self.Instance:SetAttribute("Utils_SourceColor", stored.Color)
	self.Instance:SetAttribute("Utils_MoveSpeed", if I.Rarity.GetAddGradientMove(rarity) then nil else 0)
	self.Instance:AddTag("Utils_UIGradientMove")
end

return Component
