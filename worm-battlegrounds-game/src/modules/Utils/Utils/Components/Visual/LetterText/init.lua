--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Utils"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService: RunService = I.S.RunService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local GuiVisibility = require(_scripts:FindFirstChild("GuiVisibility")) --- @type Utils_GuiVisibility
local Motes = require(script:FindFirstChild("Motes")) --- @type Utils_LetterText_Motes

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Defaults ]]

local DEFAULT_INTENSITY: number = 1
local DEFAULT_SPEED: number = 1

--[[ Effects ]]

--[[
	How far a wave lifts a letter, how high a bounce jumps, how far a shake throws it and turns it, how much a pulse
	grows it and how far a sway turns it, at intensity 1 (design px, degrees and scale)
]]
local WAVE_HEIGHT: number = 3
local BOUNCE_HEIGHT: number = 6
local SHAKE_OFFSET: number = 1.5
local SHAKE_ROTATION: number = 5
local SHAKE_INTERVAL: number = 0.05
local PULSE_GROWTH: number = 0.22
local SWAY_ROTATION: number = 8

-- How often a flickering letter flashes white (a chance per step) and for how long
local FLICKER_CHANCE: number = 0.03
local FLICKER_TIME: number = 0.08

-- A halo: the glow's outline width and how its see-through breathes (from, range)
local HALO_THICKNESS: number = 6
local HALO_TRANSPARENCY: number = 0.55
local HALO_BREATH: number = 0.3

-- An echo: how far it sits behind its letter (design px) and how fast it catches up (per second)
local ECHO_OFFSET: number = 2
local ECHO_FOLLOW: number = 10

-- Sparkles: how many at once round the word, their size (design px) and how long one lives (seconds, from, range)
local SPARKLE_COUNT: number = 7
local SPARKLE_SIZE: number = 16
local SPARKLE_LIFE: number = 0.55
local SPARKLE_LIFE_RANGE: number = 0.4

--[[
	How far a float bobs a letter, an orbit circles it, a drip sags it and a stomp lifts the word (design px), how much
	a grow swells the letters, and how hard a landing stomp shakes the word
]]
local FLOAT_HEIGHT: number = 4
local ORBIT_RADIUS: number = 2.5
local DRIP_DEPTH: number = 5
local STOMP_HEIGHT: number = 7
local STOMP_SHAKE: number = 2.5
local GROW_SCALE: number = 0.25

-- A glitch: how often a letter jumps aside (a chance per step), for how long and how far (design px)
local GLITCH_CHANCE: number = 0.01
local GLITCH_TIME: number = 0.12
local GLITCH_OFFSET: number = 4

-- A strike: the pause between flashes (seconds, from, range), how long one flickers and how far it jolts the letters
local STRIKE_GAP: number = 1.6
local STRIKE_GAP_RANGE: number = 1.6
local STRIKE_TIME: number = 0.3
local STRIKE_SHAKE: number = 2

--[[
	How see-through a fade makes a letter at its faintest, how wide a shimmer's or shade's band is (a share of the
	word) and how dark a shade gets
]]
local FADE_DEPTH: number = 0.75
local SHIMMER_WIDTH: number = 0.18
local SHADE_DEPTH: number = 0.65

--[[
	Inside a clipping ScrollingFrame a turned letter isn't drawn, so there the letters sit in a CanvasGroup this much
	bigger than the label on every side (design px), for what moves outside the word
]]
local CANVAS_MARGIN: number = 24

--[[ Channels ]]

--[[
	The effects that move, turn, grow or colour the letters every step: a word whose effects use none of a channel gets
	that value once, when its letters are placed, and the step never writes it
]]
--- @type { [string]: { string } }
local CHANNELS = {
	Move = { "Wave", "Bounce", "Shake", "Float", "Orbit", "Drip", "Stomp", "Strike", "Glitch" },
	Turn = { "Shake", "Sway" },
	Grow = { "Pulse", "Grow", "Stomp" },
	Color = { "Gradient", "Rainbow", "Flicker", "Shimmer", "Shade", "Glitch", "Strike", "Swap" },
}

--[[ Loop ]]

-- The shortest time between two steps, so a fast screen moves the letters about 60 times a second at most
local STEP_TIME: number = 1 / 75

-- The components the shared Heartbeat moves, that Heartbeat while any runs, and the time since its last step
local entries = {} --- @type { [Utils_LetterText]: boolean }
local loopConnection: RBXScriptConnection? = nil
local pendingTime: number = 0

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Sample

--[[
	Returns the colour at `alpha` (0 to 1) along a colour sequence's keypoints, between the keypoints around it. It
	takes the keypoints read once, since every read of `ColorSequence.Keypoints` makes a new table.
]]
--- @param keypoints { ColorSequenceKeypoint }
--- @return Color3
local function sample(keypoints, alpha: number)
	--[[ Finding ]]

	for index: number = 1, #keypoints - 1 do
		local from: ColorSequenceKeypoint = keypoints[index]
		local to: ColorSequenceKeypoint = keypoints[index + 1]
		if alpha <= to.Time then
			return from.Value:Lerp(to.Value, (alpha - from.Time) / math.max(to.Time - from.Time, 1e-4))
		end
	end

	--[[ Returning ]]

	return keypoints[#keypoints].Value
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

--- @class Utils_LetterText : Component
--- @field Instance TextLabel
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Attributes #
---
--- @field Effects { [string]: boolean }
--- @field Intensity number
--- @field Speed number
--- @field Spacing number
--- @field Keypoints { ColorSequenceKeypoint }?
--- @field Uses { [string]: boolean }
---
--- # Letters #
---
--- @field _guideFrame Frame?
--- @field _letterFrame GuiObject?
--- @field _letters { Utils_LetterTextLetter }
--- @field _sparkles { Utils_LetterTextSparkle }
--- @field _motes { Utils_LetterTextMote }
--- @field _rest { [string]: any }?
---
--- # Place #
---
--- @field _placed boolean
--- @field _textSize number
--- @field _textLeft number
--- @field _textRight number
--- @field _textTop number
--- @field _textHeight number
--- @field _clip ScrollingFrame?
--- @field _billboard BillboardGui?
---
--- # State #
---
--- @field _key string
--- @field _visible boolean
--- @field _queued boolean
--- @field _time number
--- @field _shakeTime number
--- @field _strikeWait number
--- @field _strikeTime number
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

	-- Check if the instance is a TextLabel
	if not self.Instance:IsA("TextLabel") then
		warn(`[{_localName}::{script.Name}]: Instance ({self.Instance}) is not a (TextLabel)! -`, self.Instance)
		return
	end

	--[[ State ]]

	self._letters = {}
	self._sparkles = {}
	self._motes = {}
	self._placed = false
	self._textSize = 0
	self._key = ""
	self._visible = false
	self._queued = false
	self._time = 0
	self._shakeTime = 0
	self._strikeWait = STRIKE_GAP
	self._strikeTime = 0

	--[[ Connections ]]

	self:_connectChanges()

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
	self:_clear()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Start Loop

--[[
	Connects the shared Heartbeat that moves every component's letters, when it isn't running yet.
]]
function Component._startLoop()
	--[[ Checks ]]

	-- Skip when the loop already runs
	if loopConnection then
		return
	end

	--[[ Connections ]]

	pendingTime = 0
	loopConnection = RunService.Heartbeat:Connect(Component._stepLoop)
end

--%%%%%%%%%%%%%%%%%%%% Step Loop

--[[
	Moves every shown component's letters one step, at most every STEP_TIME, skipping those nobody can see now (scrolled
	out of their list, or on a billboard out of reach or off screen). Drops components whose label is gone, and stops
	once none is left.
]]
function Component._stepLoop(deltaTime: number)
	--[[ Pacing ]]

	pendingTime += deltaTime

	-- Skip frames that come sooner than STEP_TIME after the last step
	if pendingTime < STEP_TIME then
		return
	end

	local step: number = pendingTime
	local camera: Camera = I.Env.Camera
	pendingTime = 0

	--[[ Stepping ]]

	--- @param component Utils_LetterText
	for component, _running: boolean in pairs(entries) do
		-- Forget a component whose label is gone
		if not component.Instance.Parent or component._destroyed then
			entries[component] = nil
			continue
		end

		-- Skip a label nobody can see this frame
		if component:IsCulled(camera) then
			continue
		end

		component:Step(step)
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
	Reads the effects (`Utils_LetterEffects`, comma separated: the motions Wave, Bounce, Shake, Pulse, Sway, Float, Orbit,
	Drip, Grow, Stomp, Glitch, Strike; the colour ones Gradient, Rainbow, Flicker, OutlineCycle, Shimmer, Shade, Swap,
	Fade; and the extras Halo, Echo, Sparkle and the motes Embers, Drops, Flakes, Comets, Rings, Gems), their intensity
	and speed, the room between the letters (`Utils_LetterSpacing`, design px) and the colours (`Utils_LetterColors`).
]]
function Component:GetAttributes()
	--[[ Local Variables ]]

	local colors: ColorSequence? = self.Instance:GetAttribute("Utils_LetterColors")

	--[[ Reading ]]

	self.Effects = {}
	for _index: number, effect: string in ipairs(string.split(self.Instance:GetAttribute("Utils_LetterEffects") or "", ",")) do
		local name: string = string.gsub(effect, "%s", "")
		if name ~= "" then
			self.Effects[name] = true
		end
	end
	self.Intensity = self.Instance:GetAttribute("Utils_LetterIntensity") or DEFAULT_INTENSITY
	self.Speed = self.Instance:GetAttribute("Utils_LetterSpeed") or DEFAULT_SPEED
	self.Spacing = self.Instance:GetAttribute("Utils_LetterSpacing") or 0
	self.Keypoints = if colors then colors.Keypoints else nil

	--[[ Channels ]]

	self.Uses = {}
	for channel: string, effects: { string } in pairs(CHANNELS) do
		for _index: number, effect: string in ipairs(effects) do
			if self.Effects[effect] then
				self.Uses[channel] = true
				break
			end
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Changes

--[[
	Builds the letters again (once, on the next resumption point) when the text, the font or an attribute changes, and
	resizes them when the label's size changes.
]]
function Component:_connectChanges()
	--[[ Text ]]

	for _index: number, property: string in ipairs({ "Text", "FontFace" }) do
		table.insert(
			self.Connections,
			self.Instance:GetPropertyChangedSignal(property):Connect(function()
				self:_queueRefresh()
			end)
		)
	end

	--[[ Size ]]

	table.insert(
		self.Connections,
		self.Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			self:_resize()
		end)
	)

	--[[ Attributes ]]

	table.insert(
		self.Connections,
		self.Instance.AttributeChanged:Connect(function(attribute: string)
			if string.find(attribute, "^Utils_Letter") then
				self:_queueRefresh()
			end
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh

--[[
	Reads the attributes and builds the letters when what they show changed. Without effects (a title's level without
	split letters) it gives the label its own text back and leaves the loop; hidden, it leaves the loop and builds once
	it shows again.
]]
function Component:Refresh()
	--[[ Reading ]]

	self:GetAttributes()

	--[[ Off ]]

	-- No effects: the label's own text, nothing to move
	if next(self.Effects) == nil then
		entries[self] = nil
		self._key = ""
		self:_clear()
		return
	end

	-- Hidden: still, until it shows
	if not self._visible then
		entries[self] = nil
		return
	end

	--[[ Building ]]

	-- Only when something the letters show changed: setting a title's look again leaves them as they are
	local key: string = table.concat({
		self.Instance:GetAttribute("Utils_LetterEffects"),
		tostring(self.Intensity),
		tostring(self.Speed),
		tostring(self.Spacing),
		tostring(self.Instance:GetAttribute("Utils_LetterColors")),
		self.Instance.Text,
		tostring(self.Instance.FontFace),
	}, "|")
	if key ~= self._key then
		self._key = key
		self:_build()
	end

	--[[ Running ]]

	entries[self] = true
	Component._startLoop()
end

--%%%%%%%%%%%%%%%%%%%% Step

--[[
	Moves, turns, grows and colours every letter by the effects for this step, from where it was placed, writing only
	the channels the effects use; then the sparkles and motes.
]]
function Component:Step(deltaTime: number)
	--[[ Placing ]]

	-- Skip until the letters have a place (the label laid out, its guides measured)
	if not self._placed and not self:_place() then
		return
	end

	--[[ Local Variables ]]

	local effects = self.Effects --- @type { [string]: boolean }
	local uses = self.Uses --- @type { [string]: boolean }
	local keypoints = self.Keypoints --- @type { ColorSequenceKeypoint }?
	local intensity: number = self.Intensity
	local white: Color3 = Color3.new(1, 1, 1)
	local time: number = self._time + deltaTime * self.Speed
	self._time = time
	self._shakeTime += deltaTime

	-- A new shake target every interval
	local reshake: boolean = self._shakeTime >= SHAKE_INTERVAL
	if reshake then
		self._shakeTime = 0
	end

	--[[ Word ]]

	-- A stomp lifts the whole word slowly, slams it down and shakes it as it lands
	local stompY: number = 0
	local stompShake: number = 0
	if effects.Stomp then
		local beat: number = (time * 0.7) % 1
		if beat < 0.75 then
			stompY = -math.sin(beat / 0.75 * math.pi / 2) * STOMP_HEIGHT * intensity
		elseif beat < 0.8 then
			stompY = -(1 - (beat - 0.75) / 0.05) * STOMP_HEIGHT * intensity
		else
			stompShake = (1 - (beat - 0.8) / 0.2) * intensity
		end
	end

	-- A strike flickers every letter white now and then, as lightning does
	local struck: boolean = false
	if effects.Strike then
		self._strikeWait -= deltaTime
		if self._strikeWait <= 0 then
			self._strikeWait = STRIKE_GAP + math.random() * STRIKE_GAP_RANGE
			self._strikeTime = STRIKE_TIME
		end
		if self._strikeTime > 0 then
			self._strikeTime -= deltaTime
			struck = math.floor(self._strikeTime * 30) % 2 == 0
		end
	end

	-- Where a shimmer's light band and a shade's dark band cross the word, each pausing past its end
	local shimmerAt: number = (time * 0.6) % 1.6 - 0.3
	local shadeAt: number = (time * 0.6 + 0.8) % 1.6 - 0.3

	--[[ Letters ]]

	--- @param letter Utils_LetterTextLetter
	for index: number, letter in ipairs(self._letters) do
		--[[ Motion ]]

		local along: number = letter.Along
		local offsetX: number = 0
		local offsetY: number = 0
		local rotation: number = 0
		local scale: number = 1

		if effects.Wave then
			offsetY += math.sin(time * 3 - index * 0.6) * WAVE_HEIGHT * intensity
		end
		if effects.Bounce then
			offsetY -= math.abs(math.sin(time * 3 - index * 0.45)) * BOUNCE_HEIGHT * intensity
		end
		if effects.Shake then
			if reshake then
				letter.ShakeX = (math.random() * 2 - 1) * SHAKE_OFFSET * intensity
				letter.ShakeY = (math.random() * 2 - 1) * SHAKE_OFFSET * intensity
				letter.ShakeR = (math.random() * 2 - 1) * SHAKE_ROTATION * intensity
			end
			offsetX += letter.ShakeX
			offsetY += letter.ShakeY
			rotation += letter.ShakeR
		end
		if effects.Pulse then
			scale += math.max(0, math.sin(time * 4 - index * 0.5)) ^ 4 * PULSE_GROWTH * intensity
		end
		if effects.Sway then
			rotation += math.sin(time * 2 - index * 0.4) * SWAY_ROTATION * intensity
		end
		if effects.Float then
			offsetX += math.cos(time * 0.9 + index * 2.3) * FLOAT_HEIGHT * 0.3 * intensity
			offsetY += math.sin(time * (1.3 + index % 3 * 0.4) + index * 1.7) * FLOAT_HEIGHT * intensity
		end
		if effects.Orbit then
			offsetX += math.cos(time * 2.4 - index * 0.8) * ORBIT_RADIUS * intensity
			offsetY += math.sin(time * 2.4 - index * 0.8) * ORBIT_RADIUS * intensity
		end
		if effects.Drip then
			-- Each letter sags slowly on its own beat, then springs back up
			local beat: number = (time * 0.45 + index * 0.37) % 1
			offsetY += (if beat < 0.85 then (beat / 0.85) ^ 2 else 1 - (beat - 0.85) / 0.15) * DRIP_DEPTH * intensity
		end
		if effects.Grow then
			scale += (math.sin(time * 2 - index * 0.5) + 1) / 2 * GROW_SCALE * intensity
		end
		if effects.Stomp then
			offsetX += (math.random() * 2 - 1) * STOMP_SHAKE * stompShake
			offsetY += stompY + (math.random() * 2 - 1) * STOMP_SHAKE * stompShake
			scale += stompShake * 0.1
		end
		if struck then
			offsetX += (math.random() * 2 - 1) * STRIKE_SHAKE * intensity
			offsetY += (math.random() * 2 - 1) * STRIKE_SHAKE * intensity
		end

		-- A glitching letter now and then jumps aside in another of the colours for a moment
		if effects.Glitch then
			if letter.GlitchTime <= 0 and math.random() < GLITCH_CHANCE * intensity then
				letter.GlitchTime = GLITCH_TIME
				letter.GlitchX = (if math.random() < 0.5 then -1 else 1) * GLITCH_OFFSET * intensity
				letter.GlitchColor = if keypoints then sample(keypoints, math.random()) else white
			end
			if letter.GlitchTime > 0 then
				letter.GlitchTime -= deltaTime
				offsetX += letter.GlitchX
			end
		end

		--[[ Colour ]]

		local color: Color3 = letter.Color
		if effects.Gradient and keypoints then
			color = sample(keypoints, (math.sin(time * 1.5 - index * 0.5) + 1) / 2)
		end
		if effects.Rainbow then
			color = Color3.fromHSV((time * 0.3 + index * 0.07) % 1, 0.55, 1)
		end
		if effects.Flicker then
			if letter.Flash <= 0 and math.random() < FLICKER_CHANCE * intensity then
				letter.Flash = FLICKER_TIME
			end
			if letter.Flash > 0 then
				letter.Flash -= deltaTime
				color = white
			end
		end
		if effects.Shimmer then
			color = color:Lerp(white, math.max(0, 1 - math.abs(along - shimmerAt) / SHIMMER_WIDTH) * 0.85)
		end
		if effects.Shade then
			color = color:Lerp(Color3.new(0, 0, 0), math.max(0, 1 - math.abs(along - shadeAt) / SHIMMER_WIDTH) * SHADE_DEPTH)
		end
		if letter.GlitchTime > 0 then
			color = letter.GlitchColor
		end
		if struck then
			color = white
		end

		-- A swap trades the letter's colour and its outline's in turn, every other letter at a time
		local stroke: UIStroke? = letter.Stroke
		if effects.Swap and stroke then
			local dark: Color3 = self._rest.StrokeColor
			local swapped: boolean = (index + math.floor(time * 1.5)) % 2 == 0
			stroke.Color = if swapped then color else dark
			color = if swapped then dark else color
		end

		-- A fade lets the letters thin out in turn, outline and all
		if effects.Fade then
			local faded: number = (math.sin(time * 2 - index * 0.7) + 1) / 2 * FADE_DEPTH * intensity
			letter.Label.TextTransparency = faded
			if stroke then
				stroke.Transparency = faded
			end
		end

		-- The outline flows through the colours, a step behind the letter before it
		if effects.OutlineCycle and keypoints and stroke then
			stroke.Color = sample(keypoints, (math.sin(time * 2 + index * 0.7) + 1) / 2):Lerp(Color3.new(0, 0, 0), 0.35)
		end

		--[[ Applying ]]

		local position: UDim2 = UDim2.new(letter.X, offsetX, letter.Y, offsetY)
		if uses.Move then
			letter.Label.Position = position
		end
		if uses.Turn then
			letter.Label.Rotation = rotation
		end
		if uses.Grow then
			letter.Scale.Scale = scale
		end
		if uses.Color then
			letter.Label.TextColor3 = color
		end

		--[[ Halo ]]

		-- A breathing glow behind the letter, following it
		local halo: TextLabel? = letter.Halo
		if halo then
			letter.HaloStroke.Transparency = HALO_TRANSPARENCY + (math.sin(time * 3 + index * 0.5) + 1) / 2 * HALO_BREATH
			if uses.Move then
				halo.Position = position
			end
			if uses.Turn then
				halo.Rotation = rotation
			end
			if uses.Grow then
				letter.HaloScale.Scale = scale * 1.05
			end
			if uses.Color then
				halo.TextColor3 = color
				letter.HaloStroke.Color = color
			end
		end

		--[[ Echo ]]

		-- A ghost trailing the letter's motion; a still word's echo was set where it rests when placed
		local echo: TextLabel? = letter.Echo
		if echo then
			if uses.Move then
				echo.Position = echo.Position:Lerp(position + UDim2.fromOffset(ECHO_OFFSET, ECHO_OFFSET), math.min(1, deltaTime * ECHO_FOLLOW))
			end
			if uses.Turn then
				echo.Rotation = rotation
			end
			if uses.Grow then
				letter.EchoScale.Scale = scale
			end
			if uses.Color and not keypoints then
				echo.TextColor3 = color
			end
		end
	end

	--[[ Sparkles ]]

	--- @param sparkle Utils_LetterTextSparkle
	for _index: number, sparkle in ipairs(self._sparkles) do
		-- Wait out the pause before the next star
		if sparkle.Delay > 0 then
			sparkle.Delay -= deltaTime
			continue
		end

		sparkle.Life += deltaTime

		-- A star that lived its life is born again somewhere else round the word, in one of the colours
		if sparkle.Life >= sparkle.Duration then
			local tint: Color3 = if keypoints then sample(keypoints, math.random()) else white
			sparkle.Life = 0
			sparkle.Duration = SPARKLE_LIFE + math.random() * SPARKLE_LIFE_RANGE
			sparkle.Delay = math.random() * 0.3
			sparkle.Holder.Position = UDim2.fromScale(self._textLeft + math.random() * (self._textRight - self._textLeft), self._textTop + (math.random() * 1.3 - 0.15) * self._textHeight)
			for _barIndex: number, bar: Frame in ipairs(sparkle.Bars) do
				bar.BackgroundColor3 = tint
			end
			sparkle.Scale.Scale = 0
			continue
		end

		local alpha: number = sparkle.Life / sparkle.Duration
		sparkle.Scale.Scale = math.sin(alpha * math.pi) * intensity
		sparkle.Holder.Rotation = alpha * 90
	end

	--[[ Motes ]]

	if #self._motes > 0 then
		Motes.Step(self, deltaTime, sample)
	end
end

--%%%%%%%%%%%%%%%%%%%% Queue Refresh

--[[
	Refreshes once, on the next resumption point, however many changes come together: a title's look sets its font and
	four attributes in a row, and builds the letters once for all of them.
]]
function Component:_queueRefresh()
	--[[ Checks ]]

	-- Skip when a refresh is already waiting
	if self._queued then
		return
	end

	--[[ Queueing ]]

	self._queued = true
	task.defer(function()
		self._queued = false
		if not self._destroyed then
			self:Refresh()
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Build

--[[
	Makes one unseen guide and one seen letter per character of the label's text, at the size its scaled text shows, with
	each letter's halo and echo, the sparkles and the motes the effects name, and hides the label's own text and outline
	(the letters carry them). The letters wait for their place until the guides are measured.
]]
function Component:_build()
	--[[ Clearing ]]

	self:_clear()

	--[[ Local Variables ]]

	local label: TextLabel = self.Instance
	local stroke: UIStroke? = label:FindFirstChildOfClass("UIStroke")
	local keypoints = self.Keypoints --- @type { ColorSequenceKeypoint }?
	local textSize: number = self:GetTextSize()
	local count: number = utf8.len(label.ContentText) or 0
	self._textSize = textSize
	self._clip = label:FindFirstAncestorWhichIsA("ScrollingFrame")
	self._billboard = label:FindFirstAncestorWhichIsA("BillboardGui")
	self._rest = {
		TextTransparency = label.TextTransparency,
		StrokeEnabled = if stroke then stroke.Enabled else nil,
		StrokeColor = if stroke then stroke.Color else Color3.new(0, 0, 0),
	}

	--[[ Frames ]]

	-- The guides: the text laid out letter by letter, unseen, where each letter belongs
	local guideFrame: Frame = Instance.new("Frame")
	guideFrame.Name = "LetterGuides"
	guideFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	guideFrame.BackgroundTransparency = 1
	guideFrame.Position = UDim2.fromScale(0.5, 0.5)
	guideFrame.Size = UDim2.fromScale(1, 1)
	local layout: UIListLayout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = if label.TextXAlignment == Enum.TextXAlignment.Left
		then Enum.HorizontalAlignment.Left
		elseif label.TextXAlignment == Enum.TextXAlignment.Right then Enum.HorizontalAlignment.Right
		else Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, self.Spacing)
	layout.Parent = guideFrame

	-- The guides' measured widths place the letters again (the connection goes with the frame)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self._placed = false
	end)

	-- The letters seen, moved from their guides by the effects (in a clipping ScrollingFrame inside a CanvasGroup,
	-- where turned letters are drawn)
	local letterFrame: GuiObject = Instance.new(if self._clip then "CanvasGroup" else "Frame")
	letterFrame.Name = "Letters"
	letterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	letterFrame.BackgroundTransparency = 1
	letterFrame.Position = UDim2.fromScale(0.5, 0.5)
	letterFrame.Size = if self._clip then UDim2.new(1, CANVAS_MARGIN * 2, 1, CANVAS_MARGIN * 2) else UDim2.fromScale(1, 1)
	self._guideFrame = guideFrame
	self._letterFrame = letterFrame

	--[[ Letters ]]

	local index: number = 0
	for _first: number, code: number in utf8.codes(label.ContentText) do
		index += 1
		local character: string = utf8.char(code)
		local along: number = if count > 1 then (index - 1) / (count - 1) else 0
		local color: Color3 = if keypoints then sample(keypoints, along) else label.TextColor3

		local guide: TextLabel = Instance.new("TextLabel")
		guide.Name = `Guide{index}`
		guide.AutomaticSize = Enum.AutomaticSize.X
		guide.BackgroundTransparency = 1
		guide.FontFace = label.FontFace
		guide.LayoutOrder = index
		guide.Size = UDim2.fromScale(0, 1)
		guide.Text = character
		guide.TextSize = textSize
		guide.TextTransparency = 1
		guide.Parent = guideFrame

		local letterLabel: TextLabel = Instance.new("TextLabel")
		letterLabel.Name = `Letter{index}`
		letterLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		letterLabel.BackgroundTransparency = 1
		letterLabel.FontFace = label.FontFace
		letterLabel.Text = character
		letterLabel.TextColor3 = color
		letterLabel.TextSize = textSize
		letterLabel.ZIndex = 3
		letterLabel.Parent = letterFrame
		local letterScale: UIScale = Instance.new("UIScale")
		letterScale.Parent = letterLabel

		-- Each letter keeps the label's outline
		local letterStroke: UIStroke? = nil
		if stroke then
			letterStroke = Instance.new("UIStroke")
			letterStroke.Color = stroke.Color
			letterStroke.LineJoinMode = stroke.LineJoinMode
			letterStroke.Thickness = stroke.Thickness
			letterStroke.Transparency = stroke.Transparency
			letterStroke.Parent = letterLabel
		end

		--- @type Utils_LetterTextLetter
		local letter = {
			Label = letterLabel,
			Scale = letterScale,
			Stroke = letterStroke,
			Guide = guide,
			X = 0,
			Y = 0,
			Along = along,
			Color = color,
			ShakeX = 0,
			ShakeY = 0,
			ShakeR = 0,
			Flash = 0,
			GlitchTime = 0,
			GlitchX = 0,
			GlitchColor = color,
		}

		-- A halo (a breathing glow) and an echo (a trailing ghost) go behind the letter
		if self.Effects.Halo then
			letter.Halo = Instance.new("TextLabel")
			letter.Halo.Name = `Halo{index}`
			letter.Halo.AnchorPoint = Vector2.new(0.5, 0.5)
			letter.Halo.BackgroundTransparency = 1
			letter.Halo.FontFace = label.FontFace
			letter.Halo.Text = character
			letter.Halo.TextColor3 = color
			letter.Halo.TextSize = textSize
			letter.Halo.TextTransparency = 1
			letter.Halo.ZIndex = 1
			letter.Halo.Parent = letterFrame
			letter.HaloScale = Instance.new("UIScale")
			letter.HaloScale.Scale = 1.05
			letter.HaloScale.Parent = letter.Halo
			letter.HaloStroke = Instance.new("UIStroke")
			letter.HaloStroke.Color = color
			letter.HaloStroke.LineJoinMode = Enum.LineJoinMode.Round
			letter.HaloStroke.Thickness = HALO_THICKNESS
			letter.HaloStroke.Parent = letter.Halo
		end
		if self.Effects.Echo then
			letter.Echo = Instance.new("TextLabel")
			letter.Echo.Name = `Echo{index}`
			letter.Echo.AnchorPoint = Vector2.new(0.5, 0.5)
			letter.Echo.BackgroundTransparency = 1
			letter.Echo.FontFace = label.FontFace
			letter.Echo.Text = character
			letter.Echo.TextColor3 = if keypoints then sample(keypoints, 1 - along) else color
			letter.Echo.TextSize = textSize
			letter.Echo.TextTransparency = 0.55
			letter.Echo.ZIndex = 2
			letter.Echo.Parent = letterFrame
			letter.EchoScale = Instance.new("UIScale")
			letter.EchoScale.Parent = letter.Echo
		end

		table.insert(self._letters, letter)
	end

	--[[ Sparkles ]]

	-- Pixel stars round the word: a cross of two bars with a white heart, each living a moment, then born elsewhere
	if self.Effects.Sparkle then
		for sparkleIndex: number = 1, SPARKLE_COUNT do
			local holder: Frame = Instance.new("Frame")
			holder.Name = `Sparkle{sparkleIndex}`
			holder.AnchorPoint = Vector2.new(0.5, 0.5)
			holder.BackgroundTransparency = 1
			holder.Size = UDim2.fromOffset(SPARKLE_SIZE, SPARKLE_SIZE)
			holder.ZIndex = 4
			holder.Parent = letterFrame
			local scale: UIScale = Instance.new("UIScale")
			scale.Scale = 0
			scale.Parent = holder
			local bars = {} --- @type { Frame }
			for barIndex: number, size: UDim2 in ipairs({ UDim2.fromScale(1, 0.25), UDim2.fromScale(0.25, 1), UDim2.fromScale(0.25, 0.25) }) do
				local bar: Frame = Instance.new("Frame")
				bar.Name = if barIndex == 3 then "Heart" else "Bar"
				bar.AnchorPoint = Vector2.new(0.5, 0.5)
				bar.BackgroundColor3 = Color3.new(1, 1, 1)
				bar.BorderSizePixel = 0
				bar.Position = UDim2.fromScale(0.5, 0.5)
				bar.Size = size
				bar.ZIndex = if barIndex == 3 then 5 else 4
				bar.Parent = holder
				if barIndex < 3 then
					table.insert(bars, bar)
				end
			end
			table.insert(self._sparkles, { Holder = holder, Scale = scale, Bars = bars, Life = 0, Duration = 0, Delay = math.random() * 0.8 })
		end
	end

	--[[ Motes ]]

	Motes.Build(self)

	--[[ Showing ]]

	-- Parented last, each in one go
	guideFrame.Parent = label
	letterFrame.Parent = label
	label.TextTransparency = 1
	if stroke then
		stroke.Enabled = false
	end
end

--%%%%%%%%%%%%%%%%%%%% Clear

--[[
	Removes the letters, sparkles and motes, and gives the label back its own text and outline.
]]
function Component:_clear()
	--[[ Removing ]]

	if self._guideFrame then
		self._guideFrame:Destroy()
		self._guideFrame = nil
	end
	if self._letterFrame then
		self._letterFrame:Destroy()
		self._letterFrame = nil
	end
	table.clear(self._letters)
	table.clear(self._sparkles)
	table.clear(self._motes)
	self._placed = false

	--[[ Restoring ]]

	-- Skip a label whose text was never hidden
	if not self._rest then
		return
	end

	local stroke: UIStroke? = self.Instance:FindFirstChildOfClass("UIStroke")
	self.Instance.TextTransparency = self._rest.TextTransparency
	if stroke and self._rest.StrokeEnabled ~= nil then
		stroke.Enabled = self._rest.StrokeEnabled
	end
	self._rest = nil
end

--%%%%%%%%%%%%%%%%%%%% Resize

--[[
	Gives the letters the text size the label's scaled text shows now and places them again: a scale tween or the
	screen changes the label's size, and letters built anew would show nowhere until their guides are measured.
]]
function Component:_resize()
	--[[ Checks ]]

	-- Skip a label without letters
	if not self._guideFrame then
		return
	end

	--[[ Placing ]]

	self._placed = false

	--[[ Resizing ]]

	local textSize: number = self:GetTextSize()

	-- Skip when the text keeps its size (a UIScale above it grows the letters with it)
	if textSize == self._textSize then
		return
	end

	self._textSize = textSize

	--- @param letter Utils_LetterTextLetter
	for _index: number, letter in ipairs(self._letters) do
		letter.Guide.TextSize = textSize
		letter.Label.TextSize = textSize
		if letter.Halo then
			letter.Halo.TextSize = textSize
		end
		if letter.Echo then
			letter.Echo.TextSize = textSize
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Place

--[[
	Reads where each guide sits in the letters' frame (by scale, so the label's UIScales hold) and puts its letter there
	at its size, once per layout change instead of every step. Also keeps where the text runs, for the sparkles.
	Returns false while the label or its guides aren't laid out yet.
]]
--- @return boolean
function Component:_place()
	--[[ Local Variables ]]

	local letterFrame: GuiObject = self._letterFrame
	local framePosition: Vector2 = letterFrame.AbsolutePosition
	local frameSize: Vector2 = letterFrame.AbsoluteSize

	--[[ Checks ]]

	-- Check if the label and its guides are laid out
	if frameSize.X < 1 or frameSize.Y < 1 or self._guideFrame:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.X < 1 then
		return false
	end

	--[[ Placing ]]

	--- @param letter Utils_LetterTextLetter
	for _index: number, letter in ipairs(self._letters) do
		local guidePosition: Vector2 = letter.Guide.AbsolutePosition
		local guideSize: Vector2 = letter.Guide.AbsoluteSize
		local size: UDim2 = UDim2.fromScale(guideSize.X / frameSize.X, guideSize.Y / frameSize.Y)
		letter.X = (guidePosition.X + guideSize.X / 2 - framePosition.X) / frameSize.X
		letter.Y = (guidePosition.Y + guideSize.Y / 2 - framePosition.Y) / frameSize.Y
		letter.Width = size.X.Scale
		letter.Height = size.Y.Scale
		letter.Label.Size = size

		-- Every letter starts on its guide (a still word's stays there), its echo just behind it
		local rest: UDim2 = UDim2.fromScale(letter.X, letter.Y)
		letter.Label.Position = rest
		if letter.Halo then
			letter.Halo.Size = size
			letter.Halo.Position = rest
		end
		if letter.Echo then
			letter.Echo.Size = size
			letter.Echo.Position = rest + UDim2.fromOffset(ECHO_OFFSET, ECHO_OFFSET)
		end
	end

	--[[ Text ]]

	-- Where the text runs, so stars are born round the word and not over the label's empty space
	local first = self._letters[1] --- @type Utils_LetterTextLetter?
	local last = self._letters[#self._letters] --- @type Utils_LetterTextLetter?
	self._textLeft = if first then first.X - first.Width / 2 else 0
	self._textRight = if last then last.X + last.Width / 2 else 1
	self._textTop = (self.Instance.AbsolutePosition.Y - framePosition.Y) / frameSize.Y
	self._textHeight = self.Instance.AbsoluteSize.Y / frameSize.Y

	--[[ Returning ]]

	self._placed = true
	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Get Text Size

--[[
	Returns the label's text height in its own (unscaled) units: its shown text bounds over the screen's scale of the
	label.
]]
--- @return number
function Component:GetTextSize()
	--[[ Local Variables ]]

	local label: TextLabel = self.Instance
	local screenScale: number = if label.Size.Y.Offset > 0 then label.AbsoluteSize.Y / label.Size.Y.Offset else 1

	--[[ Returning ]]

	return math.max(1, math.floor(label.TextBounds.Y / math.max(screenScale, 1e-3) + 0.5))
end

--%%%%%%%%%%%%%%%%%%%% Is Culled

--[[
	Returns whether nobody can see the label this frame though it is shown: scrolled out of its list's window, or on a
	billboard farther than its MaxDistance, behind the camera or off the screen's sides.
]]
--- @return boolean
function Component:IsCulled(camera: Camera)
	--[[ List ]]

	-- Out of its list's window
	if self._clip then
		local position: Vector2 = self.Instance.AbsolutePosition
		local size: Vector2 = self.Instance.AbsoluteSize
		local windowPosition: Vector2 = self._clip.AbsolutePosition
		local windowSize: Vector2 = self._clip.AbsoluteSize
		if position.X > windowPosition.X + windowSize.X or position.X + size.X < windowPosition.X or position.Y > windowPosition.Y + windowSize.Y or position.Y + size.Y < windowPosition.Y then
			return true
		end
	end

	--[[ World ]]

	-- Skip labels on screen guis
	if not self._billboard then
		return false
	end

	local anchor: Instance? = self._billboard.Adornee or self._billboard.Parent
	local worldPosition: Vector3? = if anchor and anchor:IsA("Attachment") then anchor.WorldPosition elseif anchor and anchor:IsA("BasePart") then anchor.Position else nil

	-- Skip a billboard whose place can't be read (on a model)
	if not worldPosition then
		return false
	end

	-- Out of the billboard's reach
	if (worldPosition - camera.CFrame.Position).Magnitude > self._billboard.MaxDistance then
		return true
	end

	-- Behind the camera, or off the screen by more than the label's width
	local point: Vector3 = camera:WorldToViewportPoint(worldPosition)
	local viewport: Vector2 = camera.ViewportSize
	local margin: number = self.Instance.AbsoluteSize.X

	--[[ Returning ]]

	return point.Z < 0 or point.X < -margin or point.X > viewport.X + margin or point.Y < -margin or point.Y > viewport.Y + margin
end

return Component
