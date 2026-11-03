--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local UserInputService = I.S.UserInputService
local TweenService = I.S.TweenService
local TextService = I.S.TextService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Create Progress Bar Gradient

--[[
	Creates side of the progressBar and return the UIGradient to control it.
]]
--- @return UIGradient
local function createProgressBarGradient(parent: Frame, leftSide: boolean, radialFillImage: string)
	--[[ Creating Container ]]

	local frame: Frame = Instance.new("Frame")
	frame.Name = leftSide and "LeftContainer" or "RightContainer"
	frame.Size = UDim2.fromScale(0.5, 1)
	frame.Position = UDim2.fromScale(leftSide and 0 or 0.5, 0)
	frame.BackgroundTransparency = 1
	frame.ClipsDescendants = true
	frame.Parent = parent

	--[[ Creating Image ]]

	local image: ImageLabel = Instance.new("ImageLabel")
	frame.Name = "ProgressImage"
	image.BackgroundTransparency = 1
	image.Size = UDim2.fromScale(2, 1)
	image.Position = UDim2.fromScale(leftSide and 0 or -1, 0)
	image.Image = radialFillImage
	image.Parent = frame

	--[[ Creating Gradient ]]

	local gradient: UIGradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.4999, 0),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
	gradient.Rotation = leftSide and 180 or 0
	gradient.Parent = image

	--[[ Returning ]]

	return gradient
end

--%%%%%%%%%%%%%%%%%%%% Create Circular Progress Bar

--[[
	Creates circular progress bar and returns its container.
]]
--- @return Frame
--- @return RBXScriptConnection
local function createCircularProgressBar(radialFillImage: string)
	--[[ Creating Container ]]

	local bar: Frame = Instance.new("Frame")
	bar.Name = "CircularProgressBar"
	bar.Size = UDim2.fromOffset(58, 58)
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.Position = UDim2.fromScale(0.5, 0.5)
	bar.BackgroundTransparency = 1

	--[[ Creating ProgressBar Sides ]]

	local gradient1: UIGradient = createProgressBarGradient(bar, true, radialFillImage)
	local gradient2: UIGradient = createProgressBarGradient(bar, false, radialFillImage)

	--[[ Creating Progress Value ]]

	local progress: NumberValue = Instance.new("NumberValue")
	progress.Name = "Progress"
	progress.Parent = bar
	local circleBarChangedConnection: RBXScriptConnection = progress.Changed:Connect(function(value)
		local angle: number = math.clamp(value * 360, 0, 360)
		gradient1.Rotation = math.clamp(angle, 180, 360)
		gradient2.Rotation = math.clamp(angle, 0, 180)
	end)

	--[[ Returning ]]

	return bar, circleBarChangedConnection
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Prompt

--- @type Interact_PromptStyle
local data = {}

--%%%%%%%%%%%%%%%%%%%% Create Prompt

--- @return () -> ()
function data.CreatePrompt(prompt: ProximityPrompt, inputType: Enum.ProximityPromptInputType, gui: ScreenGui)
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Variables

	--[[ Mappings ]]

	-- The images and key texts named by the prompt's Interact_Mappings (Default when empty)
	--- @type Interact_Mapping
	local mappings = I.Interact.GetMappings(prompt:GetAttribute("Interact_Mappings"))

	--[[ Tweens ]]

	local tweensForButtonHoldBegin = {}
	local tweensForButtonHoldEnd = {}
	local tweensForFadeOut = {}
	local tweensForFadeIn = {}

	--[[ TweenInfos ]]

	local tweenInfoInFullDuration: TweenInfo = TweenInfo.new(prompt.HoldDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tweenInfoOutHalfSecond: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfoFast: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local BILLBOARD_SCALE = 1.5
	local INNER_SCALE = 1 / BILLBOARD_SCALE
	local APPEAR_SCALE = 0.4
	local HEIGHT_SCALE = 1.5

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Getting Gui

	--[[ Gui ]]

	local promptUI: BillboardGui = Instance.new("BillboardGui")
	promptUI.Name = "Prompt"
	promptUI.AlwaysOnTop = true
	promptUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	--[[ Top Container ]]

	local topContainer: CanvasGroup = Instance.new("CanvasGroup")
	topContainer.Name = "TopContainer"
	topContainer.Size = UDim2.fromScale(1, 1)
	topContainer.BackgroundTransparency = 1
	topContainer.GroupTransparency = 1
	topContainer.BorderSizePixel = 0
	topContainer.Parent = promptUI

	table.insert(tweensForFadeIn, TweenService:Create(topContainer, tweenInfoFast, { GroupTransparency = 0 }))
	table.insert(tweensForFadeOut, TweenService:Create(topContainer, tweenInfoFast, { GroupTransparency = 1 }))

	--[[ Scaled Container ]]

	local scaledContainer: Frame = Instance.new("Frame")
	scaledContainer.Name = "ScaledContainer"
	scaledContainer.Size = UDim2.fromScale(1, 1)
	scaledContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	scaledContainer.Position = UDim2.fromScale(0.5, 0.5)
	scaledContainer.BackgroundTransparency = 1
	scaledContainer.BorderSizePixel = 0
	scaledContainer.Parent = topContainer

	local scaledContainerAspect: UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	scaledContainerAspect.AspectType = Enum.AspectType.FitWithinMaxSize
	scaledContainerAspect.Parent = scaledContainer

	local containerScale: UIScale = Instance.new("UIScale")
	containerScale.Scale = APPEAR_SCALE
	containerScale.Parent = scaledContainer

	--[[ Background ]]

	local background: Frame = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.fromScale(1, 0.85)
	background.AnchorPoint = Vector2.new(0.5, 0.5)
	background.Position = UDim2.fromScale(0.5, 0.5)
	background.BackgroundTransparency = 1
	background.BackgroundColor3 = Color3.new(0, 0, 0)
	background.BorderSizePixel = 0
	background.ZIndex = 0
	background.Parent = scaledContainer

	local backgroundShadow: UIShadow = Instance.new("UIShadow")
	backgroundShadow.Color = Color3.new(0, 0, 0)
	backgroundShadow.Transparency = 1
	backgroundShadow.BlurRadius = UDim.new(0.7, 0)
	backgroundShadow.Parent = background

	local backgroundCorner: UICorner = Instance.new("UICorner")
	backgroundCorner.CornerRadius = UDim.new(1, 0)
	backgroundCorner.Parent = background

	--[[ Container ]]

	local container: Frame = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.fromScale(1, 1)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.fromScale(0.5, 0.5)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Parent = scaledContainer

	table.insert(tweensForFadeIn, TweenService:Create(containerScale, tweenInfoFast, { Scale = INNER_SCALE }))
	table.insert(tweensForFadeOut, TweenService:Create(containerScale, tweenInfoFast, { Scale = APPEAR_SCALE }))
	table.insert(tweensForFadeIn, TweenService:Create(backgroundShadow, tweenInfoFast, { Transparency = 0.3 }))
	table.insert(tweensForFadeOut, TweenService:Create(backgroundShadow, tweenInfoFast, { Transparency = 1 }))

	--[[ Input Frame ]]

	local inputFrame: Frame = Instance.new("Frame")
	inputFrame.Name = "InputFrame"
	inputFrame.Size = UDim2.fromScale(1, 1)
	inputFrame.BackgroundTransparency = 1
	inputFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
	inputFrame.ZIndex = 2
	inputFrame.Parent = container

	--[[ Resizable Input Frame ]]

	local resizeableInputFrame: Frame = Instance.new("Frame")
	resizeableInputFrame.Name = "ResizableInputFrame"
	resizeableInputFrame.Size = UDim2.fromScale(1, 1)
	resizeableInputFrame.Position = UDim2.fromScale(0.5, 0.5)
	resizeableInputFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	resizeableInputFrame.BackgroundTransparency = 1
	resizeableInputFrame.Parent = inputFrame

	local inputFrameScaler: UIScale = Instance.new("UIScale")
	inputFrameScaler.Parent = resizeableInputFrame

	local inputFrameScaleFactor: number = inputType == Enum.ProximityPromptInputType.Touch and 1.6 or 1.33

	table.insert(tweensForButtonHoldBegin, TweenService:Create(inputFrameScaler, tweenInfoFast, { Scale = inputFrameScaleFactor }))
	table.insert(tweensForButtonHoldEnd, TweenService:Create(inputFrameScaler, tweenInfoFast, { Scale = 1 }))

	--[[ Action Text ]]

	local actionText: TextLabel = Instance.new("TextLabel")
	actionText.Name = "ActionText"
	actionText.Size = UDim2.fromScale(1, 1)
	actionText.Font = Enum.Font.GothamBold
	actionText.TextSize = 19 * BILLBOARD_SCALE
	actionText.BackgroundTransparency = 1
	actionText.TextTransparency = 0
	actionText.TextColor3 = Color3.new(1, 1, 1)
	actionText.TextXAlignment = Enum.TextXAlignment.Left
	actionText.Parent = container

	local actionTextStroke: UIStroke = Instance.new("UIStroke")
	actionTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	actionTextStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
	actionTextStroke.Thickness = 0.1
	actionTextStroke.Parent = actionText

	--[[ Object Text ]]

	local objectText: TextLabel = Instance.new("TextLabel")
	objectText.Name = "ObjectText"
	objectText.Size = UDim2.fromScale(1, 1)
	objectText.Font = Enum.Font.GothamBlack
	objectText.TextSize = 14 * BILLBOARD_SCALE
	objectText.BackgroundTransparency = 1
	objectText.TextTransparency = 0
	objectText.TextColor3 = Color3.fromRGB(200, 200, 200)
	objectText.TextXAlignment = Enum.TextXAlignment.Left
	objectText.Parent = container

	local objectTextStroke: UIStroke = Instance.new("UIStroke")
	objectTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	objectTextStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
	objectTextStroke.Thickness = 0.1
	objectTextStroke.Parent = objectText

	--[[ Interact Button ]]

	local interactButton: TextButton
	if inputType == Enum.ProximityPromptInputType.Touch or prompt.ClickablePrompt then
		interactButton = Instance.new("TextButton")
		interactButton.Name = "InteractButton"
		interactButton.BackgroundTransparency = 1
		interactButton.TextTransparency = 1
		interactButton.Size = UDim2.fromScale(1, 1)
		interactButton.Parent = promptUI
	end

	--[[ Round Background Frame ]]

	local roundBackgroundFrame: Frame = Instance.new("Frame")
	roundBackgroundFrame.Name = "RoundFrame"
	roundBackgroundFrame.Size = UDim2.fromOffset(48 * BILLBOARD_SCALE, 48 * BILLBOARD_SCALE)
	roundBackgroundFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	roundBackgroundFrame.Position = UDim2.fromScale(0.5, 0.5)
	roundBackgroundFrame.BackgroundTransparency = 0.25
	roundBackgroundFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	roundBackgroundFrame.Parent = resizeableInputFrame

	local roundedFrameCorner: UICorner = Instance.new("UICorner")
	roundedFrameCorner.CornerRadius = UDim.new(0.5, 0)
	roundedFrameCorner.Parent = roundBackgroundFrame

	--[[ Interact Icon/Text ]]

	if inputType == Enum.ProximityPromptInputType.Gamepad then
		--
		--%%%%%%%%%%%%%%%%%%%% Gamepad Input

		-- The pad's own image (PlayStation or Xbox) for the prompt's key
		local gamepadImage: string? = I.Interact.GetGamepadImage(mappings, prompt.GamepadKeyCode)

		if gamepadImage then
			-- Element
			local icon: ImageLabel = Instance.new("ImageLabel")
			icon.Name = "ButtonImage"
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Size = UDim2.fromOffset(24 * BILLBOARD_SCALE, 24 * BILLBOARD_SCALE)
			icon.Position = UDim2.fromScale(0.5, 0.5)
			icon.BackgroundTransparency = 1
			icon.ImageTransparency = 0
			icon.Image = gamepadImage
			icon.Parent = resizeableInputFrame
		end
	elseif inputType == Enum.ProximityPromptInputType.Touch then
		--
		--%%%%%%%%%%%%%%%%%%%% Mobile Input

		-- Element
		local buttonImage: ImageLabel = Instance.new("ImageLabel")
		buttonImage.Name = "ButtonImage"
		buttonImage.BackgroundTransparency = 1
		buttonImage.ImageTransparency = 0
		buttonImage.Size = UDim2.fromOffset(25 * BILLBOARD_SCALE, 31 * BILLBOARD_SCALE)
		buttonImage.AnchorPoint = Vector2.new(0.5, 0.5)
		buttonImage.Position = UDim2.fromScale(0.5, 0.5)
		buttonImage.Image = mappings.TouchTapImage
		buttonImage.Parent = resizeableInputFrame
	else
		--
		--%%%%%%%%%%%%%%%%%%%% Keyboard Input

		--[[ Key Border ]]

		-- Element
		local buttonImage: ImageLabel = Instance.new("ImageLabel")
		buttonImage.Name = "ButtonImage"
		buttonImage.BackgroundTransparency = 1
		buttonImage.ImageTransparency = 0
		buttonImage.Size = UDim2.fromOffset(28 * BILLBOARD_SCALE, 30 * BILLBOARD_SCALE)
		buttonImage.AnchorPoint = Vector2.new(0.5, 0.5)
		buttonImage.Position = UDim2.fromScale(0.5, 0.5)
		buttonImage.Image = mappings.KeyCapImage
		buttonImage.Parent = resizeableInputFrame

		--[[ Getting Key Text/Icon ]]

		local buttonTextString: string = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)
		local buttonTextImage: string = mappings.KeyboardButtonImage[prompt.KeyboardKeyCode]

		-- Getting custom image for current KeyCode
		if buttonTextImage == nil then
			buttonTextImage = mappings.KeyboardButtonIconMapping[buttonTextString]
		end

		-- Getting string for custom KeyCode type
		if buttonTextImage == nil then
			local keyCodeMappedText: string = mappings.KeyCodeToTextMapping[prompt.KeyboardKeyCode]
			if keyCodeMappedText then
				buttonTextString = keyCodeMappedText
			end
		end

		--[[ Updating Display ]]

		if buttonTextImage then
			-- Element
			local icon: ImageLabel = Instance.new("ImageLabel")
			icon.Name = "ButtonImage"
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Size = UDim2.fromOffset(36 * BILLBOARD_SCALE, 36 * BILLBOARD_SCALE)
			icon.Position = UDim2.fromScale(0.5, 0.5)
			icon.BackgroundTransparency = 1
			icon.ImageTransparency = 0
			icon.Image = buttonTextImage
			icon.Parent = resizeableInputFrame
		elseif buttonTextString ~= nil and buttonTextString ~= "" then
			-- Element
			local buttonText: TextLabel = Instance.new("TextLabel")
			buttonText.Name = "ButtonText"
			buttonText.Position = UDim2.fromOffset(0, -1 * BILLBOARD_SCALE)
			buttonText.Size = UDim2.fromScale(1, 1)
			buttonText.Font = Enum.Font.GothamMedium
			buttonText.TextSize = 14 * BILLBOARD_SCALE
			if string.len(buttonTextString) > 2 then
				buttonText.TextSize = 12 * BILLBOARD_SCALE
			end
			buttonText.BackgroundTransparency = 1
			buttonText.TextTransparency = 0
			buttonText.TextColor3 = Color3.new(1, 1, 1)
			buttonText.TextXAlignment = Enum.TextXAlignment.Center
			buttonText.Text = buttonTextString
			buttonText.Parent = resizeableInputFrame
		else
			error(`ProximityPrompt ({prompt.Name}) has an unsupported keycode for rendering UI: ({prompt.KeyboardKeyCode})`)
		end
	end

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Tweens

	-- Creating variables for circular progress bar
	local circleBar: Frame?, circleBarChangedConnection: RBXScriptConnection?

	-- Holding Progress Animation
	if prompt.HoldDuration > 0 then
		circleBar, circleBarChangedConnection = createCircularProgressBar(mappings.RadialFillImage)
		circleBar.Size = UDim2.fromOffset(58 * BILLBOARD_SCALE, 58 * BILLBOARD_SCALE)
		circleBar.Parent = resizeableInputFrame
		table.insert(tweensForButtonHoldBegin, TweenService:Create(circleBar.Progress, tweenInfoInFullDuration, { Value = 1 }))
		table.insert(tweensForButtonHoldEnd, TweenService:Create(circleBar.Progress, tweenInfoOutHalfSecond, { Value = 0 }))
	end

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Connections

	local inputBeganConnection: RBXScriptConnection?
	local inputEndedConnection: RBXScriptConnection?

	local holdBeganTweenConnection: RBXScriptConnection?
	local holdEndedTweenConnection: RBXScriptConnection?
	local triggeredTweenConnection: RBXScriptConnection
	local triggerEndedTweenConnection: RBXScriptConnection

	local changedConnection: RBXScriptConnection
	local enabledConnection: RBXScriptConnection

	--[[ Touch -> Input ]]

	if inputType == Enum.ProximityPromptInputType.Touch or prompt.ClickablePrompt then
		local buttonDown = false
		inputBeganConnection = interactButton.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and input.UserInputState ~= Enum.UserInputState.Change then
				prompt:InputHoldBegin()
				buttonDown = true
			end
		end)
		inputEndedConnection = interactButton.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				if buttonDown then
					buttonDown = false
					prompt:InputHoldEnd()
				end
			end
		end)
		promptUI.Active = true
	end

	--[[ Tween Connections ]]

	-- Holding Tweens
	if prompt.HoldDuration > 0 then
		holdBeganTweenConnection = prompt.PromptButtonHoldBegan:Connect(function()
			for _, tween in ipairs(tweensForButtonHoldBegin) do
				tween:Play()
			end
		end)
		holdEndedTweenConnection = prompt.PromptButtonHoldEnded:Connect(function()
			for _, tween in ipairs(tweensForButtonHoldEnd) do
				tween:Play()
			end
		end)
	end

	-- Triggered Tweens
	triggeredTweenConnection = prompt.Triggered:Connect(function()
		for _, tween in ipairs(tweensForFadeOut) do
			tween:Play()
		end
	end)
	triggerEndedTweenConnection = prompt.TriggerEnded:Connect(function()
		for _, tween in ipairs(tweensForFadeIn) do
			tween:Play()
		end
	end)

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Dynamic Update

	local function updateUIFromPrompt()
		--[[ Local Variables ]]

		local actionTextSize: Vector2 = TextService:GetTextSize(prompt.ActionText, 19 * BILLBOARD_SCALE, Enum.Font.GothamBold, Vector2.new(1000, 1000))
		local objectTextSize: Vector2 = TextService:GetTextSize(prompt.ObjectText, 14 * BILLBOARD_SCALE, Enum.Font.GothamBlack, Vector2.new(1000, 1000))
		local promptHeight = 72 * BILLBOARD_SCALE
		local promptWidth = 72 * BILLBOARD_SCALE
		local textPaddingLeft = 72 * BILLBOARD_SCALE

		--[[ Calculating Prompt Size/Offsets ]]

		local maxTextWidth: number = math.max(actionTextSize.X, objectTextSize.X)
		if (prompt.ActionText ~= nil and prompt.ActionText ~= "") or (prompt.ObjectText ~= nil and prompt.ObjectText ~= "") then
			promptWidth = maxTextWidth + textPaddingLeft + 24 * BILLBOARD_SCALE
		end

		local actionTextYOffset = 0
		if prompt.ObjectText ~= nil and prompt.ObjectText ~= "" then
			actionTextYOffset = 9 * BILLBOARD_SCALE
		end

		--[[ Updating Displayed Texts ]]

		actionText.Text = prompt.ActionText
		actionText.AutoLocalize = prompt.AutoLocalize
		actionText.RootLocalizationTable = prompt.RootLocalizationTable
		actionText.Position = UDim2.new(0.5, textPaddingLeft - promptWidth / 2, 0, actionTextYOffset)

		objectText.Text = prompt.ObjectText
		objectText.AutoLocalize = prompt.AutoLocalize
		objectText.RootLocalizationTable = prompt.RootLocalizationTable
		objectText.Position = UDim2.new(0.5, textPaddingLeft - promptWidth / 2, 0, -10 * BILLBOARD_SCALE)

		--[[ Updating Size ]]

		promptUI.Size = UDim2.fromOffset(promptWidth, promptHeight * HEIGHT_SCALE)
		promptUI.SizeOffset = Vector2.new(prompt.UIOffset.X / promptUI.Size.Width.Offset, prompt.UIOffset.Y / promptUI.Size.Height.Offset)
		scaledContainerAspect.AspectRatio = promptWidth / promptHeight
	end

	changedConnection = prompt.Changed:Connect(updateUIFromPrompt)
	updateUIFromPrompt()

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

	--[[ Displaying Prompt ]]

	promptUI.Adornee = prompt.Parent
	promptUI.Parent = gui

	for _, tween in ipairs(tweensForFadeIn) do
		tween:Play()
	end

	--[[ Cleanup Function ]]

	local cleanedUp = false
	local function cleanup()
		if cleanedUp then
			return
		end
		cleanedUp = true

		-- Disconnecting Input
		if inputBeganConnection then
			inputBeganConnection:Disconnect()
		end
		if inputEndedConnection then
			inputEndedConnection:Disconnect()
		end

		-- Disconnecting Hold Tweens
		if holdBeganTweenConnection then
			holdBeganTweenConnection:Disconnect()
		end
		if holdEndedTweenConnection then
			holdEndedTweenConnection:Disconnect()
		end

		-- Disconnecting Circular Progress Bar Changed Connection
		if circleBarChangedConnection then
			circleBarChangedConnection:Disconnect()
		end

		-- Disconnecting Triggered Tweens
		triggeredTweenConnection:Disconnect()
		triggerEndedTweenConnection:Disconnect()

		-- Disconnecting Changed
		changedConnection:Disconnect()

		-- Disconnecting Enabled
		if enabledConnection then
			enabledConnection:Disconnect()
		end

		-- Fade Out Tweens
		promptUI.Enabled = true
		for _, tween in ipairs(tweensForFadeIn) do
			tween:Cancel()
		end
		for _, tween in ipairs(tweensForFadeOut) do
			tween:Play()
		end

		-- Destroying Prompt
		task.wait(0.2)
		promptUI.Parent = nil
	end

	enabledConnection = prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not prompt.Enabled then
			cleanup()
		end
	end)

	--[[ Returning ]]

	return cleanup
end

return data
