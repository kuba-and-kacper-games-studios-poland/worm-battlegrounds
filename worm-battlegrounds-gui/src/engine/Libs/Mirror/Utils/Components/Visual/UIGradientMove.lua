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

local DEFAULT_MOVE_SPEED: number = 1

--[[ Move Loop ]]

-- The scrolling components the shared Heartbeat moves, and that Heartbeat while any scrolls
local gradientMoveEntries = {} --- @type { [UmeGui_Utils_UIGradientMove]: boolean }
local loopConnection: RBXScriptConnection? = nil

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Mod 1

--[[
	Returns `x` wrapped into `[0, 1)`.
]]
--- @return number
local function mod1(x: number)
	return x - math.floor(x)
end

--%%%%%%%%%%%%%%%%%%%% Offset Color Sequence

--[[
	Returns the sequence with its keypoints shifted by `scrollOffset` and wrapped into `[0, 1]`, the seam at 0 and 1
	closed with a blended color.
]]
--- @return ColorSequence
local function offsetColorSequence(original: ColorSequence, scrollOffset: number)
	--[[ Shifting ]]

	local keypoints = {} --- @type { ColorSequenceKeypoint }

	for _index: number, keypoint: ColorSequenceKeypoint in ipairs(original.Keypoints) do
		table.insert(keypoints, ColorSequenceKeypoint.new(mod1(keypoint.Time + scrollOffset), keypoint.Value))
	end

	--[[ Sorting ]]

	table.sort(keypoints, function(a: ColorSequenceKeypoint, b: ColorSequenceKeypoint)
		return a.Time < b.Time
	end)

	--[[ Calculating ]]

	local firstKeypoint: ColorSequenceKeypoint = keypoints[1]
	local lastKeypoint: ColorSequenceKeypoint = keypoints[#keypoints]

	local diff: number = 1 - lastKeypoint.Time
	local diff2: number = firstKeypoint.Time
	local diffTotal: number = diff + diff2
	local t: number = 0

	-- Blend the seam only when the keypoints leave a gap at the ends
	if diffTotal > 0 then
		t = diff2 / diffTotal
	end

	--[[ Closing Seam ]]

	-- Add a keypoint at 0 when none sits there
	if firstKeypoint.Time ~= 0 then
		table.insert(keypoints, 1, ColorSequenceKeypoint.new(0, firstKeypoint.Value:Lerp(lastKeypoint.Value, t)))
	end

	-- Add a keypoint at 1 when none sits there
	if lastKeypoint.Time ~= 1 then
		table.insert(keypoints, ColorSequenceKeypoint.new(1, firstKeypoint.Value:Lerp(lastKeypoint.Value, t)))
	end

	--[[ Returning ]]

	return ColorSequence.new(keypoints)
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

--- @class UmeGui_Utils_UIGradientMove : Component
--- @field Instance UIGradient
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field Speed number
---
--- # Colors #
---
--- @field SourceColor ColorSequence
--- @field _sourceSequence ColorSequence
---
--- # State #
---
--- @field Offset number
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

	-- Check if the instance is a UIGradient
	if not self.Instance:IsA("UIGradient") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a (UIGradient)! -`, self.Instance)
		return
	end

	--[[ State ]]

	self.Offset = 0
	self.GuiEnabled = false

	--[[ Setup ]]

	self:GetAttributes()
	self:BuildBaseSequence()

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

	self:StopMove()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Start Loop

--[[
	Connects the shared Heartbeat that scrolls every moving gradient, when it isn't running yet.
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
	Scrolls every listed gradient one frame. Stops the loop once nothing scrolls.
]]
function Component._stepLoop(deltaTime: number)
	--[[ Scrolling ]]

	--- @param component UmeGui_Utils_UIGradientMove
	for component, _moving: boolean in pairs(gradientMoveEntries) do
		-- Forget a component whose gradient is gone
		if not component.Instance.Parent or component._destroyed then
			gradientMoveEntries[component] = nil
			continue
		end

		component:Step(deltaTime)
	end

	--[[ Stopping ]]

	-- Stop the loop once nothing scrolls
	if next(gradientMoveEntries) == nil and loopConnection then
		loopConnection:Disconnect()
		loopConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads the scroll speed.
]]
function Component:GetAttributes()
	--[[ Reading ]]

	self.Speed = self.Instance:GetAttribute("Utils_MoveSpeed") or DEFAULT_MOVE_SPEED
end

--%%%%%%%%%%%%%%%%%%%% Build Base Sequence

--[[
	Builds the looping sequence from the gradient's authored colors, saved once in `Utils_SourceColor` so clones and
	rebinds start from the same colors. The stops are squeezed into `[0, (N-1)/N]` and the first color repeats at 1.
]]
function Component:BuildBaseSequence()
	--[[ Data ]]

	local savedColor: any = self.Instance:GetAttribute("Utils_SourceColor")

	-- Save the authored gradient on the first bind
	if typeof(savedColor) ~= "ColorSequence" then
		savedColor = self.Instance.Color
		self.Instance:SetAttribute("Utils_SourceColor", savedColor)
	end

	self.SourceColor = savedColor

	--[[ Local Variables ]]

	local sourceKeypoints = self.SourceColor.Keypoints --- @type { ColorSequenceKeypoint }
	local sourceCount: number = #sourceKeypoints

	--[[ Checks ]]

	-- Loop a single stop as one flat color
	if sourceCount <= 1 then
		self._sourceSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, sourceKeypoints[1].Value),
			ColorSequenceKeypoint.new(1, sourceKeypoints[1].Value),
		})
		return
	end

	--[[ Building ]]

	local seamEnd: number = (sourceCount - 1) / sourceCount
	local keypoints = {} --- @type { ColorSequenceKeypoint }

	for _index: number, keypoint: ColorSequenceKeypoint in ipairs(sourceKeypoints) do
		table.insert(keypoints, ColorSequenceKeypoint.new(keypoint.Time * seamEnd, keypoint.Value))
	end

	table.insert(keypoints, ColorSequenceKeypoint.new(1, sourceKeypoints[1].Value))

	--[[ Saving ]]

	self._sourceSequence = ColorSequence.new(keypoints)
end

--%%%%%%%%%%%%%%%%%%%% Connect Attributes

--[[
	Applies a changed scroll speed at once, stopping at speed 0, and new authored colors (`Utils_SourceColor`), so a
	script that recolors the gradient never gets the old colors back.
]]
function Component:ConnectAttributes()
	--[[ Connections ]]

	table.insert(
		self.Connections,
		self.Instance:GetAttributeChangedSignal("Utils_MoveSpeed"):Connect(function()
			self:GetAttributes()

			-- Stop at speed 0
			if self.Speed == 0 then
				self:StopMove()
			else
				self:StartMove()
			end
		end)
	)

	table.insert(
		self.Connections,
		self.Instance:GetAttributeChangedSignal("Utils_SourceColor"):Connect(function()
			self:BuildBaseSequence()

			-- Show the new colors now: scrolled while moving, as authored otherwise
			if gradientMoveEntries[self] then
				self.Instance.Color = offsetColorSequence(self._sourceSequence, self.Offset)
			else
				self.Instance.Color = self.SourceColor
			end
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Connect Gui State

--[[
	Follows whether the gradient's gui ancestors are shown.
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
	Scrolls while the gradient is shown and puts its authored colors back while it is hidden.
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
		self:StartMove()
	else
		self:StopMove()
	end
end

--%%%%%%%%%%%%%%%%%%%% Start Move

--[[
	Lists the gradient in the scroll loop while it is shown and its speed isn't 0, and shows the current scroll at once.
]]
function Component:StartMove()
	--[[ Checks ]]

	-- Skip while hidden or at speed 0
	if not self.GuiEnabled or self.Speed == 0 then
		return
	end

	--[[ Registering ]]

	gradientMoveEntries[self] = true
	Component._startLoop()

	--[[ Applying ]]

	self.Instance.Color = offsetColorSequence(self._sourceSequence, self.Offset)
end

--%%%%%%%%%%%%%%%%%%%% Stop Move

--[[
	Takes the gradient off the scroll loop and puts its authored colors back.
]]
function Component:StopMove()
	--[[ Removing ]]

	gradientMoveEntries[self] = nil

	--[[ Restoring ]]

	-- Skip when the authored colors were never read
	if not self.SourceColor then
		return
	end

	self.Instance.Color = self.SourceColor
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Moves the scroll on by one frame and shows the shifted colors.
]]
function Component:Step(deltaTime: number)
	--[[ Calculating ]]

	self.Offset = mod1(self.Offset + self.Speed * deltaTime)

	--[[ Applying ]]

	self.Instance.Color = offsetColorSequence(self._sourceSequence, self.Offset)
end

return Component
