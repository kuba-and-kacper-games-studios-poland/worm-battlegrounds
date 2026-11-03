--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService = I.S.RunService
local TweenService = I.S.TweenService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local GuiVisibility = require(_scripts:FindFirstChild("GuiVisibility")) --- @type Utils_GuiVisibility

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Defaults ]]

local DEFAULT_INTENSITY: number = 10
local DEFAULT_FADE_TIME: number = 0.5

-- How much one point of intensity moves (in scale) and turns (in degrees) the element
local OFFSET_DIVISOR: number = 700
local ROTATION_DIVISOR: number = 2

--[[ Shake Loop ]]

-- The shaking components the shared Heartbeat moves, and that Heartbeat while any shakes
local shakeEntries = {} --- @type { [Utils_UIShake]: boolean }
local loopConnection: RBXScriptConnection? = nil

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Random Offset

--[[
	Returns a random offset between `-intensity` and `intensity`.
]]
--- @return number
local function randomOffset(intensity: number)
	return (math.random() * 2 - 1) * intensity
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

--- @class Utils_UIShake : Component
--- @field Instance GuiObject
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field Intensity number
--- @field FadeTime number
---
--- # Rest Pose #
---
--- @field _originalPosition UDim2
--- @field _originalRotation number
---
--- # State #
---
--- @field GuiEnabled boolean
--- @field _shaking boolean
--- @field _fadingOut boolean
--- @field _fadeElapsed number
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
	self._shaking = false
	self._fadingOut = false
	self._fadeElapsed = 0

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

	self:RestoreTransform()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Start Loop

--[[
	Connects the shared Heartbeat that moves every shaking element, when it isn't running yet.
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
	Shakes every listed element one frame. Stops the loop once nothing shakes.
]]
function Component._stepLoop(deltaTime: number)
	--[[ Shaking ]]

	--- @param component Utils_UIShake
	for component, _shaking: boolean in pairs(shakeEntries) do
		-- Forget a component whose element is gone
		if not component.Instance.Parent or component._destroyed then
			shakeEntries[component] = nil
			continue
		end

		component:Step(deltaTime)
	end

	--[[ Stopping ]]

	-- Stop the loop once nothing shakes
	if next(shakeEntries) == nil and loopConnection then
		loopConnection:Disconnect()
		loopConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the shake's intensity and fade time.
]]
function Component:GetAttributes()
	--[[ Reading ]]

	self.Intensity = self.Instance:GetAttribute("Utils_ShakeIntensity") or DEFAULT_INTENSITY
	self.FadeTime = math.max(self.Instance:GetAttribute("Utils_ShakeFadeTime") or DEFAULT_FADE_TIME, 0)
end

--%%%%%%%%%%%%%%%%%%%% Connect Attributes

--[[
	Starts and stops the shake with `Utils_Shake`, and applies a changed intensity or fade time at once.
]]
function Component:ConnectAttributes()
	--[[ Start / Stop ]]

	table.insert(
		self.Connections,
		self.Instance:GetAttributeChangedSignal("Utils_Shake"):Connect(function()
			if self.Instance:GetAttribute("Utils_Shake") then
				self:StartShake()
			else
				self:StopShake()
			end
		end)
	)

	--[[ Tuning ]]

	table.insert(
		self.Connections,
		self.Instance:GetAttributeChangedSignal("Utils_ShakeIntensity"):Connect(function()
			self:GetAttributes()
		end)
	)
	table.insert(
		self.Connections,
		self.Instance:GetAttributeChangedSignal("Utils_ShakeFadeTime"):Connect(function()
			self:GetAttributes()
		end)
	)
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

--%%%%%%%%%%%%%%%%%%%% Update Gui State

--[[
	Rests the element while it is hidden, and starts the shake again once shown when `Utils_Shake` is still on.
]]
function Component:UpdateGuiState(guiEnabled: boolean)
	--[[ Checks ]]

	-- Skip when the state didn't change
	if guiEnabled == self.GuiEnabled then
		return
	end

	--[[ Applying ]]

	self.GuiEnabled = guiEnabled

	if not guiEnabled then
		self:RestoreTransform()
	elseif self.Instance:GetAttribute("Utils_Shake") then
		self:StartShake()
	end
end

--%%%%%%%%%%%%%%%%%%%% Start Shake

--[[
	Keeps the rest pose and lists the element in the shake loop; a shake fading out starts again at full strength.
]]
function Component:StartShake()
	--[[ Checks ]]

	-- Skip while hidden or already shaking at full strength
	if not self.GuiEnabled or (self._shaking and not self._fadingOut) then
		return
	end

	--[[ Rest Pose ]]

	-- Keep the rest pose only when the shake starts from rest
	if not self._shaking then
		self._originalPosition = self.Instance.Position
		self._originalRotation = self.Instance.Rotation
	end

	--[[ Registering ]]

	self._fadingOut = false
	self._fadeElapsed = 0
	self._shaking = true

	shakeEntries[self] = true
	Component._startLoop()
end

--%%%%%%%%%%%%%%%%%%%% Stop Shake

--[[
	Fades the shake out over `Utils_ShakeFadeTime`, then puts the element back at rest.
]]
function Component:StopShake()
	--[[ Checks ]]

	-- Skip when the element isn't shaking
	if not self._shaking then
		return
	end

	-- Stop at once without a fade time
	if self.FadeTime <= 0 then
		self:RestoreTransform()
		return
	end

	--[[ Fading ]]

	self._fadingOut = true
	self._fadeElapsed = 0
end

--%%%%%%%%%%%%%%%%%%%% Restore Transform

--[[
	Puts the element back at its rest pose and takes it off the shake loop.
]]
function Component:RestoreTransform()
	--[[ Applying ]]

	-- Restore only a shaken element that is still parented
	if self.Instance.Parent and self._shaking then
		self.Instance.Position = self._originalPosition
		self.Instance.Rotation = self._originalRotation
	end

	--[[ Removing ]]

	shakeEntries[self] = nil

	self._shaking = false
	self._fadingOut = false
	self._fadeElapsed = 0
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Moves and turns the element by a random offset for one frame, weaker as the fade out runs.
]]
function Component:Step(deltaTime: number)
	--[[ Checks ]]

	-- Rest an element that stopped shaking or hid
	if not self._shaking or not self.GuiEnabled then
		self:RestoreTransform()
		return
	end

	--[[ Calculating ]]

	local intensity: number = self.Intensity

	if self._fadingOut then
		self._fadeElapsed += deltaTime

		-- Rest once the fade out ends
		if self._fadeElapsed >= self.FadeTime then
			self:RestoreTransform()
			return
		end

		local alpha: number = TweenService:GetValue(self._fadeElapsed / self.FadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		intensity *= 1 - alpha
	end

	--[[ Applying ]]

	self.Instance.Position = self._originalPosition + UDim2.fromScale(randomOffset(intensity) / OFFSET_DIVISOR, randomOffset(intensity) / OFFSET_DIVISOR)
	self.Instance.Rotation = self._originalRotation + randomOffset(intensity) / ROTATION_DIVISOR
end

return Component
