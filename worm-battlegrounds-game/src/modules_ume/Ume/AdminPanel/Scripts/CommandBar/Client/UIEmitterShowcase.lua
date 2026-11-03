--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constants

--[[ General ]]

local GUI_NAME: string = "AdminPanel_UIEmitterShowcase"
local PULSE_INTERVAL: number = 2.5

--[[ Layout ]]

local HEADER_HEIGHT: number = 48
local CARD_HEIGHT: number = 240
local CARD_PADDING: number = 12

--[[ Colors ]]

local WINDOW_COLOR: Color3 = Color3.fromRGB(22, 24, 30)
local CARD_COLOR: Color3 = Color3.fromRGB(32, 35, 44)
local STAGE_COLOR: Color3 = Color3.fromRGB(13, 14, 19)
local BUTTON_COLOR: Color3 = Color3.fromRGB(70, 92, 230)
local STROKE_COLOR: Color3 = Color3.fromRGB(60, 64, 78)
local TEXT_COLOR: Color3 = Color3.fromRGB(240, 242, 248)
local SUBTEXT_COLOR: Color3 = Color3.fromRGB(150, 156, 172)

--[[ Fade ]]

local FADE_OUT: NumberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.7, 0),
	NumberSequenceKeypoint.new(1, 1),
})

--[[ Tweens ]]

local Collect_TweenInfo: TweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local showcaseGui: ScreenGui? = nil

--[[ Session ]]

local emitters = {} --- @type { UIEmitter_Instance }
local pulseActions = {} --- @type { () -> () }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Add Corner

--[[
	Rounds the corners of a gui object.
]]
local function addCorner(parent: GuiObject, radius: number)
	--[[ Creating ]]

	I.Create("UICorner")({
		CornerRadius = UDim.new(0, radius),
		Parent = parent,
	})
end

--%%%%%%%%%%%%%%%%%%%% Fade Size

--[[
	Builds a pixel size curve that pops in, holds, then shrinks away.
]]
--- @return NumberSequence
local function fadeSize(size: number, envelope: number)
	--[[ Returning ]]

	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0, 0),
		NumberSequenceKeypoint.new(0.1, size, envelope),
		NumberSequenceKeypoint.new(0.75, size, envelope),
		NumberSequenceKeypoint.new(1, 0, 0),
	})
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

--- @class AdminPanel_CommandBar_Client_UIEmitterShowcase
local Module = {}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main

--%%%%%%%%%%%%%%%%%%%% Pulse Loop

--[[
	Re-fires every burst showcase on an interval while this gui session stays open.
]]
function Module._pulseLoop(session: ScreenGui)
	--[[ Looping ]]

	task.spawn(function()
		while showcaseGui == session do
			task.wait(PULSE_INTERVAL)

			-- Stop once the session was closed during the wait
			if showcaseGui ~= session then
				break
			end

			--[[ Pulsing ]]

			for _index: number, action: () -> () in ipairs(pulseActions) do
				action()
			end
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Window

--[[
	Creates the showcase ScreenGui with a header and a scrolling card grid.
]]
--- @return ScreenGui
--- @return ScrollingFrame
function Module._createWindow()
	--[[ Gui ]]

	local screenGui: ScreenGui = I.Create("ScreenGui")({
		Name = GUI_NAME,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1e5,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	--[[ Window ]]

	local window: Frame = I.Create("Frame")({
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.85, 0.85),
		BackgroundColor3 = WINDOW_COLOR,
		Parent = screenGui,
	})
	addCorner(window, 12)

	I.Create("UISizeConstraint")({
		MaxSize = Vector2.new(1100, 720),
		Parent = window,
	})
	I.Create("UIStroke")({
		Color = STROKE_COLOR,
		Thickness = 1,
		Parent = window,
	})

	--[[ Header ]]

	I.Create("TextLabel")({
		Name = "Title",
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(1, -80, 0, HEADER_HEIGHT),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "UIEmitter Showcase",
		TextColor3 = TEXT_COLOR,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = window,
	})

	local closeButton: TextButton = I.Create("TextButton")({
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0, HEADER_HEIGHT / 2),
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = CARD_COLOR,
		Font = Enum.Font.GothamBold,
		Text = "X",
		TextColor3 = TEXT_COLOR,
		TextSize = 16,
		Parent = window,
	})
	addCorner(closeButton, 8)

	closeButton.Activated:Connect(Module.Close)

	--[[ Grid ]]

	local grid: ScrollingFrame = I.Create("ScrollingFrame")({
		Name = "Grid",
		Position = UDim2.fromOffset(0, HEADER_HEIGHT),
		Size = UDim2.new(1, 0, 1, -HEADER_HEIGHT),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 6,
		Parent = window,
	})

	I.Create("UIPadding")({
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, CARD_PADDING),
		PaddingLeft = UDim.new(0, CARD_PADDING),
		PaddingRight = UDim.new(0, CARD_PADDING),
		Parent = grid,
	})
	I.Create("UIGridLayout")({
		CellSize = UDim2.new(0.25, -CARD_PADDING, 0, CARD_HEIGHT),
		CellPadding = UDim2.fromOffset(CARD_PADDING, CARD_PADDING),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = grid,
	})

	--[[ Returning ]]

	return screenGui, grid
end

--%%%%%%%%%%%%%%%%%%%% Create Card

--[[
	Creates one showcase card with a title, a description, a clipped stage, and an action button.
]]
--- @return Frame
--- @return TextButton
function Module._createCard(grid: ScrollingFrame, order: number, title: string, description: string)
	--[[ Card ]]

	local card: Frame = I.Create("Frame")({
		Name = title,
		LayoutOrder = order,
		BackgroundColor3 = CARD_COLOR,
		Parent = grid,
	})
	addCorner(card, 10)

	--[[ Texts ]]

	I.Create("TextLabel")({
		Name = "Title",
		Position = UDim2.fromOffset(10, 8),
		Size = UDim2.new(1, -20, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = TEXT_COLOR,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})
	I.Create("TextLabel")({
		Name = "Description",
		Position = UDim2.fromOffset(10, 28),
		Size = UDim2.new(1, -20, 0, 28),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = description,
		TextColor3 = SUBTEXT_COLOR,
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = card,
	})

	--[[ Stage ]]

	local stage: Frame = I.Create("Frame")({
		Name = "Stage",
		Position = UDim2.fromOffset(10, 60),
		Size = UDim2.new(1, -20, 1, -104),
		BackgroundColor3 = STAGE_COLOR,
		ClipsDescendants = true,
		Parent = card,
	})
	addCorner(stage, 8)

	--[[ Button ]]

	local button: TextButton = I.Create("TextButton")({
		Name = "Action",
		Position = UDim2.new(0, 10, 1, -36),
		Size = UDim2.new(1, -20, 0, 28),
		BackgroundColor3 = BUTTON_COLOR,
		Font = Enum.Font.GothamBold,
		TextColor3 = TEXT_COLOR,
		TextSize = 13,
		Parent = card,
	})
	addCorner(button, 6)

	--[[ Returning ]]

	return stage, button
end

--%%%%%%%%%%%%%%%%%%%% Populate Cards

--[[
	Creates every showcase card and wires its emitters.
]]
function Module._populateCards(grid: ScrollingFrame)
	--[[ Showcases ]]

	local showcases = {
		{ "Confetti Burst", "Layered emitters, random spin, gravity and drag.", Module._showConfetti },
		{ "Fountain", "Continuous Rate with a narrow spread and gravity arc.", Module._showFountain },
		{ "Snowfall", "Rectangle emission area, warm start and horizontal shake.", Module._showSnowfall },
		{ "Embers", "Color and size curves with envelopes, vertical-lock shake.", Module._showEmbers },
		{ "Orbit", "Particles circle the stage center with scaled radii.", Module._showOrbit },
		{ "Collect", "Attraction to a GuiObject with an arrive callback.", Module._showCollect },
		{ "Shockwave", "Circle shape with streaks facing their movement.", Module._showShockwave },
		{ "Live Config", "Writes Rate and Color on a playing emitter.", Module._showLiveConfig },
	}

	--[[ Populating ]]

	for order: number, showcase in ipairs(showcases) do
		local stage: Frame, button: TextButton = Module._createCard(grid, order, showcase[1], showcase[2])
		showcase[3](stage, button)
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Toggle

--[[
	Opens the showcase gui, or closes it when it is already open.
]]
--- @return boolean
function Module.Toggle()
	--[[ Checks ]]

	-- Check if the showcase is already open
	if showcaseGui then
		Module.Close()
		return false
	end

	--[[ Opening ]]

	Module.Open()

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Open

--[[
	Builds the showcase gui, starts every showcase, and begins the burst pulse loop.
]]
function Module.Open()
	--[[ Checks ]]

	-- Check if the showcase is already open
	if showcaseGui then
		return
	end

	--[[ Creating ]]

	local screenGui: ScreenGui, grid: ScrollingFrame = Module._createWindow()
	showcaseGui = screenGui

	-- Parent first so stages have an AbsoluteSize before the first spawn
	screenGui.Parent = I.Env.PlayerGui

	Module._populateCards(grid)

	--[[ Pulsing ]]

	Module._pulseLoop(screenGui)
end

--%%%%%%%%%%%%%%%%%%%% Close

--[[
	Destroys every showcase emitter and the showcase gui.
]]
function Module.Close()
	--[[ Checks ]]

	-- Check if the showcase is open
	if not showcaseGui then
		return
	end

	--[[ Cleanup ]]

	for _index: number, emitter in ipairs(emitters) do
		emitter:Destroy()
	end

	showcaseGui:Destroy()

	--[[ Resetting ]]

	showcaseGui = nil
	emitters = {}
	pulseActions = {}
end

--%%%%%%%%%%%%%%%%%%%% Create Emitter

--[[
	Creates an emitter and tracks it so Close can destroy it.
]]
--- @param params UIEmitter_Params
--- @return UIEmitter_Instance
function Module._createEmitter(params)
	--[[ Creating ]]

	local emitter = I.UIEmitter.new(params) --- @type UIEmitter_Instance
	table.insert(emitters, emitter)

	--[[ Returning ]]

	return emitter
end

--%%%%%%%%%%%%%%%%%%%% Show Confetti

--[[
	Bursts four layered single-color emitters so the confetti mixes colors.
]]
function Module._showConfetti(stage: Frame, button: TextButton)
	--[[ Local Variables ]]

	local colors = {
		Color3.fromRGB(255, 92, 160),
		Color3.fromRGB(255, 214, 80),
		Color3.fromRGB(80, 220, 255),
		Color3.fromRGB(140, 255, 120),
	} --- @type { Color3 }
	local layers = {} --- @type { UIEmitter_Instance }

	--[[ Emitters ]]

	for _index: number, color: Color3 in ipairs(colors) do
		table.insert(
			layers,
			Module._createEmitter({
				Parent = stage,
				Rate = 0,
				EmitterPosition = UDim2.fromScale(0.5, 0.9),
				Lifetime = NumberRange.new(1.4, 2.2),
				Velocity = NumberRange.new(160, 300),
				Direction = Vector2.new(0, -1),
				SpreadAngle = 55,
				Gravity = Vector2.new(0, 380),
				Drag = 1.5,
				Rotation = NumberRange.new(0, 360),
				RotationSpeed = NumberRange.new(-540, 540),
				SizeSpace = "Offset",
				Size = 9,
				AspectRatio = 0.5,
				Color = color,
				Transparency = FADE_OUT,
			})
		)
	end

	--[[ Action ]]

	--%%%%%%%%%%%%%%%%%%%% Burst

	--[[
		Emits one burst from every confetti layer.
	]]
	local function burst()
		--[[ Emitting ]]

		for _index: number, layer in ipairs(layers) do
			layer:Emit(10)
		end
	end

	button.Text = "Burst"
	button.Activated:Connect(burst)
	table.insert(pulseActions, burst)

	burst()
end

--%%%%%%%%%%%%%%%%%%%% Show Fountain

--[[
	Streams a continuous water fountain that the button pauses and resumes.
]]
function Module._showFountain(stage: Frame, button: TextButton)
	--[[ Emitter ]]

	local emitter = Module._createEmitter({
		Parent = stage,
		Rate = 45,
		EmitterPosition = UDim2.fromScale(0.5, 1),
		Lifetime = NumberRange.new(1, 1.3),
		Velocity = NumberRange.new(190, 250),
		Direction = Vector2.new(0, -1),
		SpreadAngle = 16,
		Gravity = Vector2.new(0, 480),
		SizeSpace = "Offset",
		Size = NumberSequence.new(7, 3),
		Color = ColorSequence.new(Color3.fromRGB(190, 240, 255), Color3.fromRGB(40, 110, 255)),
		Transparency = FADE_OUT,
	})

	--[[ Action ]]

	local playing: boolean = true

	button.Text = "Pause"
	button.Activated:Connect(function()
		playing = not playing

		if playing then
			emitter:Play()
		else
			emitter:Stop()
		end

		button.Text = if playing then "Pause" else "Play"
	end)

	--[[ Playing ]]

	emitter:Play()
end

--%%%%%%%%%%%%%%%%%%%% Show Snowfall

--[[
	Drifts snow from a strip along the top, warm-started so the stage is already full.
]]
function Module._showSnowfall(stage: Frame, button: TextButton)
	--[[ Emitter ]]

	local emitter = Module._createEmitter({
		Parent = stage,
		Rate = 14,
		EmitterPosition = UDim2.fromScale(0.5, 0),
		EmissionShape = "Rectangle",
		EmissionArea = Vector2.new(1, 0.05),
		Lifetime = NumberRange.new(4, 6),
		Velocity = NumberRange.new(20, 40),
		Direction = Vector2.new(0, 1),
		ShakeSpeed = NumberRange.new(10, 25),
		ShakeLockVertical = false,
		InitialParticles = 30,
		InitialAgeProgress = NumberRange.new(0, 0.9),
		SizeSpace = "Offset",
		Size = NumberRange.new(3, 7),
		Transparency = NumberRange.new(0, 0.5),
	})

	--[[ Action ]]

	button.Text = "Clear"
	button.Activated:Connect(function()
		emitter:Clear()
	end)

	--[[ Playing ]]

	emitter:Play()
end

--%%%%%%%%%%%%%%%%%%%% Show Embers

--[[
	Rises flickering embers whose color, size, and transparency follow lifetime curves.
]]
function Module._showEmbers(stage: Frame, button: TextButton)
	--[[ Emitter ]]

	local emitter = Module._createEmitter({
		Parent = stage,
		Rate = 22,
		EmitterPosition = UDim2.fromScale(0.5, 1),
		EmissionShape = "Rectangle",
		EmissionArea = Vector2.new(0.4, 0),
		Lifetime = NumberRange.new(1.2, 2),
		Velocity = NumberRange.new(50, 90),
		Direction = Vector2.new(0, -1),
		ShakeSpeed = NumberRange.new(15, 35),
		ShakeDirectionChanges = NumberRange.new(3, 6),
		SizeSpace = "Offset",
		Size = fadeSize(7, 3),
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 245, 180)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 150, 40)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 30, 20)),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2, 0.2),
			NumberSequenceKeypoint.new(1, 1, 0),
		}),
	})

	--[[ Action ]]

	button.Text = "Flare"
	button.Activated:Connect(function()
		emitter:Emit(30)
	end)

	--[[ Playing ]]

	emitter:Play()
end

--%%%%%%%%%%%%%%%%%%%% Show Orbit

--[[
	Circles particles around the stage center with lifetime-shrinking radii.
]]
function Module._showOrbit(stage: Frame, button: TextButton)
	--[[ Emitter ]]

	local emitter = Module._createEmitter({
		Parent = stage,
		Rate = 12,
		Lifetime = NumberRange.new(2, 3),
		OrbitSpeed = NumberRange.new(1.5, 3.5),
		OrbitRadiusScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.85, 0.1),
			NumberSequenceKeypoint.new(1, 0.15, 0.05),
		}),
		SizeSpace = "Offset",
		Size = fadeSize(6, 2),
		Color = ColorSequence.new(Color3.fromRGB(180, 120, 255), Color3.fromRGB(90, 220, 255)),
		Transparency = FADE_OUT,
	})

	--[[ Action ]]

	button.Text = "Burst"
	button.Activated:Connect(function()
		emitter:Emit(20)
	end)

	--[[ Playing ]]

	emitter:Play()
end

--%%%%%%%%%%%%%%%%%%%% Show Collect

--[[
	Bursts coins that home in on a target, which pulses and counts each arrival.
]]
function Module._showCollect(stage: Frame, button: TextButton)
	--[[ Target ]]

	local target: Frame = I.Create("Frame")({
		Name = "Target",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.82, 0.3),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Color3.fromRGB(255, 200, 60),
		ZIndex = 2,
		Parent = stage,
	})
	addCorner(target, 15)

	local counter: TextLabel = I.Create("TextLabel")({
		Name = "Counter",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.82, 0, 0.3, 18),
		Size = UDim2.fromOffset(60, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "0",
		TextColor3 = TEXT_COLOR,
		TextSize = 13,
		Parent = stage,
	})

	--[[ Emitter ]]

	local collected: number = 0

	local emitter = Module._createEmitter({
		Parent = stage,
		Rate = 0,
		EmitterPosition = UDim2.fromScale(0.25, 0.7),
		Lifetime = 3,
		Velocity = NumberRange.new(80, 180),
		SpreadAngle = 180,
		Drag = 2,
		AttractTo = target,
		AttractAfter = NumberRange.new(0.3, 0.6),
		AttractStrength = 2500,
		AttractMaxSpeed = 500,
		AttractArriveRadius = 10,
		AttractDestroyOnArrive = true,
		AttractOnArrive = function()
			collected += 1
			counter.Text = tostring(collected)

			local Collect_TweenGoal = { Size = UDim2.fromOffset(38, 38) }
			local Collect_Tween: Tween = I.S.TweenService:Create(target, Collect_TweenInfo, Collect_TweenGoal)
			Collect_Tween:Play()
		end,
		SizeSpace = "Offset",
		Size = 8,
		Color = Color3.fromRGB(255, 220, 90),
	})

	--[[ Action ]]

	--%%%%%%%%%%%%%%%%%%%% Collect

	--[[
		Emits a burst of coins toward the target.
	]]
	local function collect()
		--[[ Emitting ]]

		emitter:Emit(12)
	end

	button.Text = "Collect"
	button.Activated:Connect(collect)
	table.insert(pulseActions, collect)

	collect()
end

--%%%%%%%%%%%%%%%%%%%% Show Shockwave

--[[
	Bursts streaks outward from a ring, each rotated to face its movement.
]]
function Module._showShockwave(stage: Frame, button: TextButton)
	--[[ Emitter ]]

	local emitter = Module._createEmitter({
		Parent = stage,
		Rate = 0,
		EmissionShape = "Circle",
		EmissionArea = 0.15,
		Lifetime = NumberRange.new(0.5, 0.8),
		Velocity = NumberRange.new(160, 260),
		SpreadAngle = 180,
		Drag = 3,
		FaceMovementDirection = true,
		SizeSpace = "Offset",
		Size = NumberSequence.new(18, 4),
		AspectRatio = 5,
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(120, 200, 255)),
		Transparency = NumberSequence.new(0, 1),
	})

	--[[ Action ]]

	--%%%%%%%%%%%%%%%%%%%% Pulse

	--[[
		Emits one ring of streaks.
	]]
	local function pulse()
		--[[ Emitting ]]

		emitter:Emit(32)
	end

	button.Text = "Pulse"
	button.Activated:Connect(pulse)
	table.insert(pulseActions, pulse)

	pulse()
end

--%%%%%%%%%%%%%%%%%%%% Show Live Config

--[[
	Cycles Rate and Color on a playing emitter through its validated config proxy.
]]
function Module._showLiveConfig(stage: Frame, button: TextButton)
	--[[ Local Variables ]]

	local steps = {
		{ Rate = 5, Color = Color3.fromRGB(90, 160, 255) },
		{ Rate = 25, Color = Color3.fromRGB(120, 255, 150) },
		{ Rate = 80, Color = Color3.fromRGB(255, 110, 180) },
	}
	local stepIndex: number = 1

	--[[ Emitter ]]

	local emitter = Module._createEmitter({
		Parent = stage,
		Rate = steps[1].Rate,
		EmitterPosition = UDim2.fromScale(0.5, 0.5),
		Lifetime = NumberRange.new(0.8, 1.4),
		Velocity = NumberRange.new(40, 110),
		SpreadAngle = 180,
		SizeSpace = "Offset",
		Size = fadeSize(6, 2),
		Color = steps[1].Color,
		Transparency = FADE_OUT,
	})

	--[[ Action ]]

	button.Text = `Rate {steps[1].Rate} | Next`
	button.Activated:Connect(function()
		stepIndex = stepIndex % #steps + 1

		local step = steps[stepIndex]
		emitter.Rate = step.Rate
		emitter.Color = step.Color

		button.Text = `Rate {step.Rate} | Next`
	end)

	--[[ Playing ]]

	emitter:Play()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
