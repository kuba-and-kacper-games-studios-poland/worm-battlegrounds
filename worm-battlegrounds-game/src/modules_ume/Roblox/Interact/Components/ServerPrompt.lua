--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Interact"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Args = require(_scripts:FindFirstChild("Helpers"):FindFirstChild("Args")) --- @type Interact_Args

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

--- @class Interact_ServerPrompt : Component
--- @field Instance ProximityPrompt
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field ModuleName string
--- @field FunctionName string
--- @field Args { any }
--- @field DebounceDelay number
--- @field PassPlayer boolean
--- @field PassPlayerPos number
--- @field MaxDistance number
---
--- # State #
---
--- @field Cooldowns { [Player]: number }
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Type Check ]]

	-- Check if the instance is a ProximityPrompt
	if not self.Instance:IsA("ProximityPrompt") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a ProximityPrompt! -`, self.Instance)
		return
	end

	--[[ Attributes ]]

	self.ModuleName = self.Instance:GetAttribute("Interact_ModuleName")
	self.FunctionName = self.Instance:GetAttribute("Interact_Function")

	self.DebounceDelay = tonumber(self.Instance:GetAttribute("Interact_Delay")) or 0.25
	self.PassPlayer = self.Instance:GetAttribute("Interact_PassPlayer") or false
	self.PassPlayerPos = tonumber(self.Instance:GetAttribute("Interact_PassPlayerPos")) or 1
	self.MaxDistance = tonumber(self.Instance:GetAttribute("Interact_MaxDistance")) or 8

	--[[ Checks ]]

	-- Check if the module name is set
	if not self.ModuleName or self.ModuleName == "" then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is missing the (Interact_ModuleName) attribute! -`, self.Instance)
		return
	end

	-- Check if the function name is set
	if not self.FunctionName or self.FunctionName == "" then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is missing the (Interact_Function) attribute! -`, self.Instance)
		return
	end

	-- Check if the player position is at least 1
	if self.PassPlayerPos < 1 then
		warn(`[{_localName}::{script.Name}]: Attribute (Interact_PassPlayerPos) cannot be lower than (1)! -`, self.Instance)
		return
	end

	-- Check if the module exists on I
	if typeof(I[self.ModuleName]) ~= "table" then
		warn(`[{_localName}::{script.Name}]: Module (I.{self.ModuleName}) from (Interact_ModuleName) doesn't exist! -`, self.Instance)
		return
	end

	-- Check if the function exists on that module
	if typeof(I[self.ModuleName][self.FunctionName]) ~= "function" then
		warn(`[{_localName}::{script.Name}]: Function (I.{self.ModuleName}.{self.FunctionName}) from (Interact_Function) doesn't exist! -`, self.Instance)
		return
	end

	--[[ Function Arguments ]]

	self.Args = Args.Get(self.Instance)

	--[[ State ]]

	self.Cooldowns = {}

	--[[ Connections ]]

	table.insert(
		self.Connections,
		self.Instance.Triggered:Connect(function(player: Player)
			self:_onTriggered(player)
		end)
	)

	-- Drop a player's cooldown when they leave
	table.insert(
		self.Connections,
		Players.PlayerRemoving:Connect(function(player: Player)
			self.Cooldowns[player] = nil
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	-- Drop the per-player cooldowns
	self.Cooldowns = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Prompt Control

--%%%%%%%%%%%%%%%%%%%% On Triggered

--[[
	Calls the bound function for a player who triggered the prompt.
	The trigger counts only when the character is alive and in range, once per Interact_Delay per player.
]]
function Component:_onTriggered(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Checks ]]

	-- Check if the character is alive and in range
	if not self:_isInRange(player) then
		return
	end

	--[[ Cooldown ]]

	local now: number = os.clock()

	-- Check if the player's cooldown has passed
	if self.Cooldowns[player] and self.Cooldowns[player] > now then
		return
	end

	self.Cooldowns[player] = now + self.DebounceDelay

	--[[ Executing Function ]]

	if self.PassPlayer then
		I[self.ModuleName][self.FunctionName](table.unpack(Args.GetWithPlayer(self.Args, player, self.PassPlayerPos)))
	else
		I[self.ModuleName][self.FunctionName](table.unpack(self.Args))
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is In Range

--[[
	Returns whether the player's character is alive and within the prompt's MaxActivationDistance plus MaxDistance studs.
]]
--- @return boolean
function Component:_isInRange(player: Player)
	--[[ Data ]]

	local character: Model? = player.Character
	local humanoid: Humanoid? = character and character:FindFirstChildOfClass("Humanoid")
	local promptParent: Instance? = self.Instance.Parent

	--[[ Checks ]]

	-- Check if the character is alive and has a root part
	if not humanoid or humanoid.Health <= 0 or not humanoid.RootPart then
		return false
	end

	-- Check if the prompt is still in the world
	if not promptParent then
		return false
	end

	--[[ Finding ]]

	local promptPosition: Vector3

	if promptParent:IsA("Attachment") then
		promptPosition = promptParent.WorldPosition
	elseif promptParent:IsA("BasePart") then
		promptPosition = promptParent.Position
	elseif promptParent:IsA("Model") then
		promptPosition = promptParent:GetPivot().Position
	else
		-- Skip parents a prompt doesn't show on
		return false
	end

	--[[ Returning ]]

	return (humanoid.RootPart.Position - promptPosition).Magnitude <= self.Instance.MaxActivationDistance + self.MaxDistance
end

return Component
