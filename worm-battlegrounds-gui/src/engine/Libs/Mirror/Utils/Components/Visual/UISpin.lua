--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(script:FindFirstAncestor("Libs"):FindFirstChild("Runtime"))
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService = I.S.RunService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local GuiVisibility = require(_scripts:FindFirstChild("GuiVisibility")) --- @type UmeGui_Utils_GuiVisibility

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Defaults ]]

local DEFAULT_SPIN_SPEED: number = 1

-- Degrees turned per second at speed 1
local DEGREES_PER_SPEED: number = 6

--[[ Spin Loop ]]

-- The spinning components the shared Heartbeat turns, and that Heartbeat while any spins
local spinEntries = {} --- @type { [UmeGui_Utils_UISpin]: boolean }
local loopConnection: RBXScriptConnection? = nil

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

--- @class UmeGui_Utils_UISpin : Component
--- @field Instance GuiObject | UIGradient
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field Speed number
---
--- # State #
---
--- @field GuiEnabled boolean
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Checks ]]

	-- Check if the instance has a Rotation to spin
	if not self.Instance:IsA("GuiObject") and not self.Instance:IsA("UIGradient") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a (GuiObject) or (UIGradient)! -`, self.Instance)
		return
	end

	--[[ Setup ]]

	self.GuiEnabled = false
	self:GetAttributes()

	--[[ Connections ]]

	self:ConnectAttributes()
	self:ConnectGuiState()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	--[[ Stopping ]]

	self:StopSpin()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Start Loop

--[[
	Connects the shared Heartbeat that turns every spinning instance, when it isn't running yet.
]]
function Component._startLoop()
	--[[ Checks ]]

	-- Skip when the loop already runs
	if loopConnection then
		return
	end

	--[[ Connections ]]

	loopConnection = RunService.Heartbeat:Connect(Component._stepLoop)
end

--%%%%%%%%%%%%%%%%%%%% Step Loop

--[[
	Turns every spinning instance one frame. Stops the loop once nothing spins.
]]
function Component._stepLoop(deltaTime: number)
	--[[ Spinning ]]

	--- @param component UmeGui_Utils_UISpin
	for component, _spinning: boolean in pairs(spinEntries) do
		-- Forget a component whose instance is gone
		if not component.Instance.Parent or component._destroyed then
			spinEntries[component] = nil
			continue
		end

		component.Instance.Rotation += component.Speed * DEGREES_PER_SPEED * deltaTime
	end

	--[[ Stopping ]]

	-- Stop the loop once nothing spins
	if next(spinEntries) == nil and loopConnection then
		loopConnection:Disconnect()
		loopConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the spin speed.
]]
function Component:GetAttributes()
	--[[ Reading ]]

	self.Speed = self.Instance:GetAttribute("Utils_SpinSpeed") or DEFAULT_SPIN_SPEED
end

--%%%%%%%%%%%%%%%%%%%% Connect Attributes

--[[
	Applies a changed spin speed at once, pausing in place at speed 0.
]]
function Component:ConnectAttributes()
	--[[ Connections ]]

	table.insert(
		self.Connections,
		self.Instance:GetAttributeChangedSignal("Utils_SpinSpeed"):Connect(function()
			self:GetAttributes()

			-- Pause in place at speed 0
			if self.Speed == 0 then
				self:StopSpin()
			else
				self:StartSpin()
			end
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Connect Gui State

--[[
	Follows whether the instance and its gui ancestors are shown.
]]
function Component:ConnectGuiState()
	--[[ Connections ]]

	table.insert(
		self.Connections,
		GuiVisibility.Watch(self.Instance, function(guiEnabled: boolean)
			self:UpdateGuiState(guiEnabled)
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Update Gui State

--[[
	Spins while the instance is shown and pauses while it is hidden.
]]
function Component:UpdateGuiState(guiEnabled: boolean)
	--[[ Checks ]]

	-- Skip when the state didn't change
	if guiEnabled == self.GuiEnabled then
		return
	end

	--[[ Applying ]]

	self.GuiEnabled = guiEnabled

	if guiEnabled then
		self:StartSpin()
	else
		self:StopSpin()
	end
end

--%%%%%%%%%%%%%%%%%%%% Start Spin

--[[
	Lists the instance in the spin loop while it is shown and its speed isn't 0.
]]
function Component:StartSpin()
	--[[ Checks ]]

	-- Skip while hidden or paused
	if not self.GuiEnabled or self.Speed == 0 then
		return
	end

	--[[ Registering ]]

	spinEntries[self] = true
	Component._startLoop()
end

--%%%%%%%%%%%%%%%%%%%% Stop Spin

--[[
	Takes the instance off the spin loop, at its current rotation.
]]
function Component:StopSpin()
	--[[ Removing ]]

	spinEntries[self] = nil
end

return Component
