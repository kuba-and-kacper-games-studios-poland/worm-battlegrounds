--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService = I.S.RunService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local GuiVisibility = require(_scripts:FindFirstChild("GuiVisibility")) --- @type Utils_GuiVisibility

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Defaults ]]

local DEFAULT_HOVER_SPEED: number = 1

-- The attributes that apply live when changed
local LIVE_ATTRIBUTES = { "Utils_HoverOffset", "Utils_HoverSpeed" } --- @type { string }

--[[ Hover Loop ]]

-- The floating components the shared Heartbeat moves, and that Heartbeat while any floats
local hoverEntries = {} --- @type { [Utils_UIHover]: boolean }
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

--- @class Utils_UIHover : Component
--- @field Instance GuiObject
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field HoverOffset UDim2
--- @field HoverSpeed number
---
--- # Rest Pose #
---
--- @field DefaultPosition UDim2
---
--- # State #
---
--- @field GuiEnabled boolean
--- @field HoverPhaseOffset number
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Checks ]]

	-- Check if the instance is a GuiObject
	if not self.Instance:IsA("GuiObject") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a (GuiObject)! -`, self.Instance)
		return
	end

	--[[ State ]]

	self.GuiEnabled = false
	self.DefaultPosition = self.Instance.Position
	self.HoverPhaseOffset = 0

	--[[ Setup ]]

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

	--[[ Restoring ]]

	self:StopHover()

	-- Put the element back at rest while it is still parented
	if self.Instance.Parent and self.DefaultPosition then
		self.Instance.Position = self.DefaultPosition
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Start Loop

--[[
	Connects the shared Heartbeat that moves every floating element, when it isn't running yet.
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
	Moves every floating element along its float one frame. Stops the loop once nothing floats.
]]
function Component._stepLoop(_deltaTime: number)
	--[[ Moving ]]

	--- @param component Utils_UIHover
	for component, _floating: boolean in pairs(hoverEntries) do
		-- Forget a component whose element is gone
		if not component.Instance.Parent or component._destroyed then
			hoverEntries[component] = nil
			continue
		end

		local hoverAlpha: number = (1 - math.cos(component:GetHoverPhase() * math.pi)) * 0.5
		component.Instance.Position = component.DefaultPosition:Lerp(component.DefaultPosition + component.HoverOffset, hoverAlpha)
	end

	--[[ Stopping ]]

	-- Stop the loop once nothing floats
	if next(hoverEntries) == nil and loopConnection then
		loopConnection:Disconnect()
		loopConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the float's offset and speed.
]]
function Component:GetAttributes()
	--[[ Reading ]]

	self.HoverOffset = self.Instance:GetAttribute("Utils_HoverOffset") or UDim2.new()
	self.HoverSpeed = self.Instance:GetAttribute("Utils_HoverSpeed") or DEFAULT_HOVER_SPEED

	--[[ Checks ]]

	-- Check if the speed isn't negative
	if self.HoverSpeed < 0 then
		warn(`[{_localName}::{script.Name}]: (Utils_HoverSpeed) must not be negative! -`, self.Instance)
		self.HoverSpeed = DEFAULT_HOVER_SPEED
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Attributes

--[[
	Applies a changed offset or speed at once.
]]
function Component:ConnectAttributes()
	--[[ Connections ]]

	for _index: number, attribute: string in ipairs(LIVE_ATTRIBUTES) do
		table.insert(
			self.Connections,
			self.Instance:GetAttributeChangedSignal(attribute):Connect(function()
				self:ApplyAttributes()
			end)
		)
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Gui State

--[[
	Follows whether the element and its gui ancestors are shown.
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

--%%%%%%%%%%%%%%%%%%%% Apply Attributes

--[[
	Re-reads the float attributes without jumping the float, and pauses it in place at speed 0.
]]
function Component:ApplyAttributes()
	--[[ Reading ]]

	local phase: number = self:GetHoverPhase()
	self:GetAttributes()

	--[[ Phase ]]

	-- Continue from the current phase at the new speed
	self.HoverPhaseOffset = phase - os.clock() * self.HoverSpeed

	--[[ Applying ]]

	if self.HoverSpeed == 0 then
		self:StopHover()
	else
		self:StartHover()
	end
end

--%%%%%%%%%%%%%%%%%%%% Update Gui State

--[[
	Starts the float once the element shows and stops it, back at rest, once it hides.
]]
function Component:UpdateGuiState(guiEnabled: boolean)
	--[[ Checks ]]

	-- Skip when the state didn't change
	if guiEnabled == self.GuiEnabled then
		return
	end

	--[[ Applying ]]

	self.GuiEnabled = guiEnabled

	-- Start floating once shown
	if guiEnabled then
		self:StartHover()
		return
	end

	--[[ Resetting ]]

	self:StopHover()

	-- Put the element back at rest while it is still parented
	if self.Instance.Parent then
		self.Instance.Position = self.DefaultPosition
	end
end

--%%%%%%%%%%%%%%%%%%%% Start Hover

--[[
	Lists the element in the float loop while it is shown and its speed isn't 0.
]]
function Component:StartHover()
	--[[ Checks ]]

	-- Skip while hidden or paused
	if not self.GuiEnabled or self.HoverSpeed == 0 then
		return
	end

	--[[ Registering ]]

	hoverEntries[self] = true
	Component._startLoop()
end

--%%%%%%%%%%%%%%%%%%%% Stop Hover

--[[
	Takes the element off the float loop, where it stands.
]]
function Component:StopHover()
	--[[ Removing ]]

	hoverEntries[self] = nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Hover Phase

--[[
	Returns the float's phase from the clock, the speed and the offset kept across speed changes.
]]
--- @return number
function Component:GetHoverPhase()
	return os.clock() * self.HoverSpeed + self.HoverPhaseOffset
end

return Component
