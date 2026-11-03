--[[
    Created By:     Nari 
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Interact"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type { [string]: Interact_PromptStyle }
local promptStyles = {}
for _, styleModule: ModuleScript in ipairs(I.Dirs.GlobalData.Interact.PromptStyles:GetDescendants()) do
	if styleModule:IsA("ModuleScript") and not promptStyles[styleModule.Name] then
		promptStyles[styleModule.Name] = require(styleModule)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Screen Gui

--[[
	Returns `ScreenGui` used for storing Proximity Prompts.
]]
--- @return ScreenGui
local function getScreenGui()
	local screenGui: ScreenGui = I.Env.PlayerGui:FindFirstChild("ProximityPrompts")

	if screenGui == nil then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "ProximityPrompts"
		screenGui.ResetOnSpawn = false
		screenGui.Parent = I.Env.PlayerGui
	end

	return screenGui
end

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

--- @class Interact_Prompt : Component
--- @field Instance ProximityPrompt
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field Style string
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Checks ]]

	if not self.Instance:IsA("ProximityPrompt") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a ProximityPrompt! -`, self.Instance)
		return
	end

	if self.Instance.Style == Enum.ProximityPromptStyle.Default then
		warn(`[{_localName}::{script.Name}]: (ProximityPromptStyle) is set to Default! -`, self.Instance)
		return
	end

	--[[ Attributes ]]

	self.Style = self.Instance:GetAttribute("Interact_Style")
	if not self.Style or not promptStyles[self.Style] then
		warn(`[{_localName}::{script.Name}]: ({self.Style}) is not a valid Prompt Style! -`, self.Instance)
		self.Style = "Default"
	end
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Shown

--[[
	Executes when the `self.Instance` is shown.
]]
function Component:Shown(inputType: Enum.ProximityPromptInputType)
	-- Return if no style is set
	if not self.Style then
		return
	end

	--[[ Showing ]]

	--- @type function
	local cleanupFunction = promptStyles[self.Style or "Default"].CreatePrompt(self.Instance, inputType, getScreenGui())

	self.Instance.PromptHidden:Once(cleanupFunction)
end

return Component
