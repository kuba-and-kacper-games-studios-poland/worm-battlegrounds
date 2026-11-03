--[[
    Created By:     Nari 
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Interact"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local Players = I.S.Players
local HttpService = I.S.HttpService

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

--- @class Interact_Area : Component
--- @field Instance BasePart
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field ModuleName string
--- @field FunctionName string
--- @field Args table
--- @field DebounceDelay number
--- @field PassPlayer boolean
--- @field PassPlayerPos number
--- @field MaxDistance number
---
--- # State #
---
--- @field UUID string
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

	-- Check if the instance is a part
	if not self.Instance:IsA("BasePart") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a BasePart! -`, self.Instance)
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
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is missing the (Interact_ModuleName) attribute ! -`, self.Instance)
		return
	end

	-- Check if the function name is set
	if not self.FunctionName or self.FunctionName == "" then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is missing the (Interact_Function) attribute ! -`, self.Instance)
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

	--[[ Generating UId ]]

	self.UUID = tostring(HttpService:GenerateGUID(false))

	--[[ Connect Touched ]]

	if I.Env.IsServer then
		self:ServerSetup()
	elseif I.Env.IsClient then
		self:ClientSetup()
	end
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

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Area Control

--%%%%%%%%%%%%%%%%%%%% Client Setup

--[[
	Client setup for when the area is being touched.
]]
function Component:ClientSetup()
	--[[ Creating Connection ]]

	local touchedConnection: RBXScriptConnection = self.Instance.Touched:Connect(function(touched: BasePart)
		--[[ Checks ]]

		local character: Model = touched.Parent
		local playerCharacter: Model = I.Env.LocalPlayer.Character
		if not playerCharacter or character ~= playerCharacter then
			return
		end

		if I.Debounce.Run(self.UUID, self.DebounceDelay) then
			return
		end

		--[[ Executing Function ]]

		I[self.ModuleName][self.FunctionName](table.unpack(self.Args))
	end)

	--[[ Saving Connection ]]

	table.insert(self.Connections, touchedConnection)
end

--%%%%%%%%%%%%%%%%%%%% Server Setup

--[[
	Server setup for when the area is being touched.
	A touch counts only when the character is alive and at the part, once per Interact_Delay per player.
]]
function Component:ServerSetup()
	--[[ State ]]

	self.Cooldowns = {}

	--[[ Creating Connections ]]

	local touchedConnection: RBXScriptConnection = self.Instance.Touched:Connect(function(touched: BasePart)
		--[[ Checks ]]

		local character: Model = touched.Parent
		local player: Player = Players:GetPlayerFromCharacter(character)

		-- Check if a valid player touched the area
		if not player or not I.Player.Valid(player) then
			return
		end

		-- Check if the character is alive and at the area
		if not self:_isAtArea(character) then
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
	end)

	-- Drop a player's cooldown when they leave
	local playerRemovingConnection: RBXScriptConnection = Players.PlayerRemoving:Connect(function(player: Player)
		self.Cooldowns[player] = nil
	end)

	--[[ Saving Connections ]]

	table.insert(self.Connections, touchedConnection)
	table.insert(self.Connections, playerRemovingConnection)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is At Area

--[[
	Returns whether the character is alive and its root part is inside the part's box, widened by MaxDistance studs.
]]
--- @return boolean
function Component:_isAtArea(character: Model)
	--[[ Data ]]

	local humanoid: Humanoid? = character:FindFirstChildOfClass("Humanoid")

	--[[ Checks ]]

	-- Check if the character is alive and has a root part
	if not humanoid or humanoid.Health <= 0 or not humanoid.RootPart then
		return false
	end

	--[[ Calculating ]]

	local localPosition: Vector3 = self.Instance.CFrame:PointToObjectSpace(humanoid.RootPart.Position)
	local halfSize: Vector3 = self.Instance.Size / 2 + Vector3.one * self.MaxDistance

	--[[ Returning ]]

	return math.abs(localPosition.X) <= halfSize.X and math.abs(localPosition.Y) <= halfSize.Y and math.abs(localPosition.Z) <= halfSize.Z
end

return Component
