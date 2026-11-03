--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(script:FindFirstAncestor("Libs"):FindFirstChild("Runtime"))
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService: RunService = I.S.RunService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local GuiVisibility = require(_scripts:FindFirstChild("GuiVisibility")) --- @type UmeGui_Utils_GuiVisibility

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Shine ]]

-- How far the colours drift up and down, and how fast (cycles a second at speed 1)
local DRIFT_RANGE: number = 0.18
local DRIFT_RATE: number = 0.2

--[[
	A glint: how long it takes to cross the letters, how long until the next, how white it is, how far it leans from
	upright on screen (degrees) and how wide it is each side of its middle (a share of the text's height)
]]
local GLINT_TIME: number = 0.8
local GLINT_PERIOD: number = 2.6
local GLINT_STRENGTH: number = 0.85
local GLINT_LEAN: number = 25
local GLINT_HALF: number = 0.6

--[[ Loop ]]

-- The components the shared Heartbeat moves, and that Heartbeat while any runs
local entries = {} --- @type { [UmeGui_Utils_TextShine]: boolean }
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

--- @class UmeGui_Utils_TextShine : Component
--- @field Instance TextLabel
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field Drift boolean
--- @field Glint boolean
--- @field Speed number
---
--- # State #
---
--- @field _gradient UIGradient
--- @field _glintLabel TextLabel?
--- @field _glintGradient UIGradient?
--- @field _time number
--- @field _visible boolean
--- @field _rest { [string]: any }
local Component = {}
Component.__index = Component

-- Only the live copy in PlayerGui moves, never the templates in StarterGui or ReplicatedStorage
Component.IgnoreAncestors = { I.S.ReplicatedStorage, I.S.StarterGui }

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Checks ]]

	-- Check if the instance is a TextLabel with a UIGradient
	if not self.Instance:IsA("TextLabel") or not self.Instance:FindFirstChildOfClass("UIGradient") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a (TextLabel) with a (UIGradient)! -`, self.Instance)
		return
	end

	--[[ State ]]

	self._gradient = self.Instance:FindFirstChildOfClass("UIGradient")
	self._time = 0
	self._visible = false
	self._rest = { Color = self._gradient.Color, Offset = self._gradient.Offset }

	--[[ Connections ]]

	table.insert(
		self.Connections,
		self.Instance.AttributeChanged:Connect(function(attribute: string)
			if string.find(attribute, "^Utils_Shine") then
				self:Refresh()
			end
		end)
	)

	-- Move only while shown: hidden, it leaves the shared loop, which stops once nothing shown is left
	table.insert(
		self.Connections,
		GuiVisibility.Watch(self.Instance, function(shown: boolean)
			self._visible = shown
			self:Refresh()
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	--[[ Restoring ]]

	self._destroyed = true
	entries[self] = nil

	-- Skip a component that never started (not a TextLabel with a UIGradient)
	if not self._gradient then
		return
	end

	self._gradient.Color = self._rest.Color
	self._gradient.Offset = self._rest.Offset
	if self._glintLabel then
		self._glintLabel:Destroy()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Start Loop

--[[
	Connects the shared Heartbeat that moves every shine, when it isn't running yet.
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
	Moves every shine one frame. Drops components whose label is gone, and stops once none is left.
]]
function Component._stepLoop(deltaTime: number)
	--[[ Stepping ]]

	--- @param component UmeGui_Utils_TextShine
	for component, _running: boolean in pairs(entries) do
		-- Forget a component whose label is gone
		if not component.Instance.Parent or component._destroyed then
			entries[component] = nil
			continue
		end

		component:Step(deltaTime)
	end

	--[[ Stopping ]]

	-- Stop the loop once nothing runs
	if next(entries) == nil and loopConnection then
		loopConnection:Disconnect()
		loopConnection = nil
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Attributes

--[[
	Reads whether the colours drift (`Utils_ShineDrift`), whether a glint sweeps across (`Utils_ShineGlint`) and how fast
	(`Utils_ShineSpeed`), and gives the gradient the colours of `Utils_ShineColors` when it has them.
]]
function Component:GetAttributes()
	--[[ Reading ]]

	local colors: ColorSequence? = self.Instance:GetAttribute("Utils_ShineColors")
	self.Drift = self.Instance:GetAttribute("Utils_ShineDrift") == true
	self.Glint = self.Instance:GetAttribute("Utils_ShineGlint") == true
	self.Speed = self.Instance:GetAttribute("Utils_ShineSpeed") or 1

	--[[ Colours ]]

	-- Written once here, never every frame: the gradient keeps them while it moves
	if colors then
		self._gradient.Color = colors
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Reads the attributes again and joins the shared loop while the label shows with a drift or a glint on; with neither
	(a title's level without a shine) it leaves the loop and puts the gradient back where it rests.
]]
function Component:Refresh()
	--[[ Reading ]]

	self:GetAttributes()

	--[[ Running ]]

	local running: boolean = self._visible and (self.Drift or self.Glint)
	entries[self] = if running then true else nil

	-- Still: the gradient back at rest and no glint
	if not running then
		self._gradient.Offset = self._rest.Offset
		if self._glintLabel then
			self._glintLabel.Visible = false
		end
		return
	end

	--[[ Starting ]]

	Component._startLoop()
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Drifts the gradient's colours up and down, and once every period sends a glint (a white band) across the name's
	white copy.
]]
function Component:Step(deltaTime: number)
	--[[ Local Variables ]]

	self._time += deltaTime * self.Speed
	local time: number = self._time
	local cycle: number = time % GLINT_PERIOD
	local size: Vector2 = self.Instance.AbsoluteSize
	local bounds: Vector2 = self.Instance.TextBounds

	--[[ Drift ]]

	if self.Drift then
		self._gradient.Offset = Vector2.new(0, math.sin(time * math.pi * 2 * DRIFT_RATE) * DRIFT_RANGE)
	end

	--[[ Glint ]]

	local crossing: boolean = self.Glint and cycle < GLINT_TIME and size.X > 0 and bounds.X > 0

	-- Skip the overlay while no glint crosses
	if not crossing then
		if self._glintLabel then
			self._glintLabel.Visible = false
		end
		return
	end

	-- A glint starting across takes the label's text and font as they are now
	local glintLabel: TextLabel = self._glintLabel or self:_buildGlint()
	if not glintLabel.Visible then
		glintLabel.Text = self.Instance.Text
		glintLabel.FontFace = self.Instance.FontFace
		glintLabel.Visible = true
	end

	--[[
		A gradient's rotation is in the box's own shares, so a wide box flattens it: lean it by the box's shape instead,
		so the band leans GLINT_LEAN on screen however wide the label is
	]]
	local rotation: number = math.atan(math.tan(math.rad(GLINT_LEAN)) * size.Y / size.X)
	local spread: number = math.sin(rotation) * 0.5
	local textWidth: number = bounds.X / size.X
	local textStart: number = if self.Instance.TextXAlignment == Enum.TextXAlignment.Left then 0 elseif self.Instance.TextXAlignment == Enum.TextXAlignment.Right then 1 - textWidth else 0.5 - textWidth / 2
	local half: number = GLINT_HALF * bounds.Y / size.X

	-- The band only crosses the letters, from just before the first to just past the last, wherever they sit in the box
	local from: number = 0.5 + (textStart - 0.5) * math.cos(rotation) - spread - half
	local to: number = 0.5 + (textStart + textWidth - 0.5) * math.cos(rotation) + spread + half
	local glint: number = from + (to - from) * cycle / GLINT_TIME
	self._glintGradient.Rotation = math.deg(rotation)

	-- See-through but for a band around the glint, brightest at its middle
	local times = { 0, 1 } --- @type { number }
	for _index: number, at: number in ipairs({ glint - half, glint, glint + half }) do
		if at > 0.001 and at < 0.999 then
			table.insert(times, at)
		end
	end
	table.sort(times)

	local keypoints = {} --- @type { NumberSequenceKeypoint }
	for _index: number, at: number in ipairs(times) do
		local shine: number = math.max(0, 1 - math.abs(at - glint) / half) * GLINT_STRENGTH
		table.insert(keypoints, NumberSequenceKeypoint.new(at, 1 - shine))
	end
	self._glintGradient.Transparency = NumberSequence.new(keypoints)
end

--%%%%%%%%%%%%%%%%%%%% Build Glint

--[[
	Makes the glint's overlay the first time one crosses: a white copy of the text inside the label, without its outline
	or tags, so the name's own colours never change for it.
]]
--- @return TextLabel
function Component:_buildGlint()
	--[[ Building ]]

	local glintLabel: TextLabel = self.Instance:Clone()

	-- Only the size constraint stays: the copy must neither carry the outline nor start components of its own
	for _index: number, child: Instance in ipairs(glintLabel:GetChildren()) do
		if not child:IsA("UITextSizeConstraint") then
			child:Destroy()
		end
	end
	for _index: number, tag: string in ipairs(glintLabel:GetTags()) do
		glintLabel:RemoveTag(tag)
	end

	glintLabel.Name = "Glint"
	glintLabel.TextColor3 = Color3.new(1, 1, 1)
	glintLabel.TextTransparency = 0
	glintLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	glintLabel.Position = UDim2.fromScale(0.5, 0.5)
	glintLabel.Size = UDim2.fromScale(1, 1)
	glintLabel.Visible = false
	self._glintGradient = Instance.new("UIGradient")
	self._glintGradient.Parent = glintLabel
	glintLabel.Parent = self.Instance
	self._glintLabel = glintLabel

	--[[ Returning ]]

	return glintLabel
end

return Component
