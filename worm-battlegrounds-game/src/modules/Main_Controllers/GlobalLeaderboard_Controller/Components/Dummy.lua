--[[
	Created By: 	Nari
]]

--- @type Ume
-- local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "GlobalLeaderboard_Controller"

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

--- @class GlobalLeaderboard_Controller_Dummy : Component
--- @field Instance Instance
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field AnimationId number
---
--- # Animation #
---
--- @field Anim Animation
--- @field AnimTrack AnimationTrack
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
	self:AddAnimation()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	if self.AnimTrack then
		self.AnimTrack:Stop()
		self.AnimTrack:Destroy()
	end

	if self.Anim then
		self.Anim:Destroy()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Getting and storing key attributes.
]]
function Component:GetAttributes()
	--[[ Attributes ]]

	self.AnimationId = self.Instance:GetAttribute("GLC_Client_AnimationId")
	if not self.AnimationId or self.AnimationId == 0 then
		self.AnimationId = 782841498
	end
end

--%%%%%%%%%%%%%%%%%%%% Add Animation

--[[
	Creates and loads animation for the dummy.
]]
function Component:AddAnimation()
	--[[ Getting Animator ]]

	local humanoid: Humanoid = self.Instance:FindFirstChildOfClass("Humanoid")
	local animator: Animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end

	--[[ Creating Animation ]]

	self.Anim = Instance.new("Animation")
	self.Anim.AnimationId = `rbxassetid://{self.AnimationId}`
	self.Anim.Parent = animator

	self.AnimTrack = animator:LoadAnimation(self.Anim)
	self.AnimTrack.Looped = true
	self.AnimTrack.Priority = Enum.AnimationPriority.Core
	self.AnimTrack:Play()
end

return Component
