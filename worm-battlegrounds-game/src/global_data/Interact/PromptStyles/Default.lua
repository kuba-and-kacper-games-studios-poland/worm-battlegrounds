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
	local tweenInfoQuick: TweenInfo = TweenInfo.new(0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Getting Gui

	--[[ Gui ]]

	local promptUI: BillboardGui = Instance.new("BillboardGui")
	promptUI.Name = "Prompt"
	promptUI.AlwaysOnTop = true
	promptUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	--[[ Container ]]

	local container: Frame = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.fromScale(0.5, 1)
	container.BackgroundTransparency = 1
	container.BackgroundColor3 = Color3.new(0.07, 0.07, 0.07)
	container.Parent = promptUI

	local roundedCorner: UICorner = Instance.new("UICorner")
	roundedCorner.Parent = container

	table.insert(tweensForButtonHoldBegin, TweenService:Create(container, tweenInfoFast, { Size = UDim2.fromScale(0.5, 1), BackgroundTransparency = 1 }))
	table.insert(tweensForButtonHoldEnd, TweenService:Create(container, tweenInfoFast, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0.2 }))
	table.insert(tweensForFadeOut, TweenService:Create(container, tweenInfoFast, { Size = UDim2.fromScale(0.5, 1), BackgroundTransparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(container, tweenInfoFast, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0.2 }))

	--[[ Input Frame ]]

	local inputFrame: Frame = Instance.new("Frame")
	inputFrame.Name = "InputFrame"
	inputFrame.Size = UDim2.fromScale(1, 1)
	inputFrame.BackgroundTransparency = 1
	inputFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
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
	actionText.Font = Enum.Font.GothamMedium
	actionText.TextSize = 19
	actionText.BackgroundTransparency = 1
	actionText.TextTransparency = 1
	actionText.TextColor3 = Color3.new(1, 1, 1)
	actionText.TextXAlignment = Enum.TextXAlignment.Left
	actionText.Parent = container

	table.insert(tweensForButtonHoldBegin, TweenService:Create(actionText, tweenInfoFast, { TextTransparency = 1 }))
	table.insert(tweensForButtonHoldEnd, TweenService:Create(actionText, tweenInfoFast, { TextTransparency = 0 }))
	table.insert(tweensForFadeOut, TweenService:Create(actionText, tweenInfoFast, { TextTransparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(actionText, tweenInfoFast, { TextTransparency = 0 }))

	--[[ Object Text ]]

	local objectText: TextLabel = Instance.new("TextLabel")
	objectText.Name = "ObjectText"
	objectText.Size = UDim2.fromScale(1, 1)
	objectText.Font = Enum.Font.GothamMedium
	objectText.TextSize = 14
	objectText.BackgroundTransparency = 1
	objectText.TextTransparency = 1
	objectText.TextColor3 = Color3.new(0.7, 0.7, 0.7)
	objectText.TextXAlignment = Enum.TextXAlignment.Left
	objectText.Parent = container

	table.insert(tweensForButtonHoldBegin, TweenService:Create(objectText, tweenInfoFast, { TextTransparency = 1 }))
	table.insert(tweensForButtonHoldEnd, TweenService:Create(objectText, tweenInfoFast, { TextTransparency = 0 }))
	table.insert(tweensForFadeOut, TweenService:Create(objectText, tweenInfoFast, { TextTransparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(objectText, tweenInfoFast, { TextTransparency = 0 }))

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
	roundBackgroundFrame.Size = UDim2.fromOffset(48, 48)
	roundBackgroundFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	roundBackgroundFrame.Position = UDim2.fromScale(0.5, 0.5)
	roundBackgroundFrame.BackgroundTransparency = 1
	roundBackgroundFrame.Parent = resizeableInputFrame

	local roundedFrameCorner: UICorner = Instance.new("UICorner")
	roundedFrameCorner.CornerRadius = UDim.new(0.5, 0)
	roundedFrameCorner.Parent = roundBackgroundFrame

	table.insert(tweensForFadeOut, TweenService:Create(roundBackgroundFrame, tweenInfoQuick, { BackgroundTransparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(roundBackgroundFrame, tweenInfoQuick, { BackgroundTransparency = 0.5 }))

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
			icon.Size = UDim2.fromOffset(24, 24)
			icon.Position = UDim2.fromScale(0.5, 0.5)
			icon.BackgroundTransparency = 1
			icon.ImageTransparency = 1
			icon.Image = gamepadImage
			icon.Parent = resizeableInputFrame

			-- Tweens
			table.insert(tweensForFadeOut, TweenService:Create(icon, tweenInfoQuick, { ImageTransparency = 1 }))
			table.insert(tweensForFadeIn, TweenService:Create(icon, tweenInfoQuick, { ImageTransparency = 0 }))
		end
	elseif inputType == Enum.ProximityPromptInputType.Touch then
		--
		--%%%%%%%%%%%%%%%%%%%% Mobile Input

		-- Element
		local buttonImage: ImageLabel = Instance.new("ImageLabel")
		buttonImage.Name = "ButtonImage"
		buttonImage.BackgroundTransparency = 1
		buttonImage.ImageTransparency = 1
		buttonImage.Size = UDim2.fromOffset(25, 31)
		buttonImage.AnchorPoint = Vector2.new(0.5, 0.5)
		buttonImage.Position = UDim2.fromScale(0.5, 0.5)
		buttonImage.Image = mappings.TouchTapImage
		buttonImage.Parent = resizeableInputFrame

		-- Tweens
		table.insert(tweensForFadeOut, TweenService:Create(buttonImage, tweenInfoQuick, { ImageTransparency = 1 }))
		table.insert(tweensForFadeIn, TweenService:Create(buttonImage, tweenInfoQuick, { ImageTransparency = 0 }))
	else
		--
		--%%%%%%%%%%%%%%%%%%%% Keyboard Input

		--[[ Key Border ]]

		-- Element
		local buttonImage: ImageLabel = Instance.new("ImageLabel")
		buttonImage.Name = "ButtonImage"
		buttonImage.BackgroundTransparency = 1
		buttonImage.ImageTransparency = 1
		buttonImage.Size = UDim2.fromOffset(28, 30)
		buttonImage.AnchorPoint = Vector2.new(0.5, 0.5)
		buttonImage.Position = UDim2.fromScale(0.5, 0.5)
		buttonImage.Image = mappings.KeyCapImage
		buttonImage.Parent = resizeableInputFrame

		-- Tweens
		table.insert(tweensForFadeOut, TweenService:Create(buttonImage, tweenInfoQuick, { ImageTransparency = 1 }))
		table.insert(tweensForFadeIn, TweenService:Create(buttonImage, tweenInfoQuick, { ImageTransparency = 0 }))

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
			icon.Size = UDim2.fromOffset(36, 36)
			icon.Position = UDim2.fromScale(0.5, 0.5)
			icon.BackgroundTransparency = 1
			icon.ImageTransparency = 1
			icon.Image = buttonTextImage
			icon.Parent = resizeableInputFrame

			-- Tweens
			table.insert(tweensForFadeOut, TweenService:Create(icon, tweenInfoQuick, { ImageTransparency = 1 }))
			table.insert(tweensForFadeIn, TweenService:Create(icon, tweenInfoQuick, { ImageTransparency = 0 }))
		elseif buttonTextString ~= nil and buttonTextString ~= "" then
			-- Element
			local buttonText: TextLabel = Instance.new("TextLabel")
			buttonText.Name = "ButtonText"
			buttonText.Position = UDim2.fromOffset(0, -1)
			buttonText.Size = UDim2.fromScale(1, 1)
			buttonText.Font = Enum.Font.GothamMedium
			buttonText.TextSize = 14
			if string.len(buttonTextString) > 2 then
				buttonText.TextSize = 12
			end
			buttonText.BackgroundTransparency = 1
			buttonText.TextTransparency = 1
			buttonText.TextColor3 = Color3.new(1, 1, 1)
			buttonText.TextXAlignment = Enum.TextXAlignment.Center
			buttonText.Text = buttonTextString
			buttonText.Parent = resizeableInputFrame

			-- Tweens
			table.insert(tweensForFadeOut, TweenService:Create(buttonText, tweenInfoQuick, { TextTransparency = 1 }))
			table.insert(tweensForFadeIn, TweenService:Create(buttonText, tweenInfoQuick, { TextTransparency = 0 }))
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

		local actionTextSize: Vector2 = TextService:GetTextSize(prompt.ActionText, 19, Enum.Font.GothamMedium, Vector2.new(1000, 1000))
		local objectTextSize: Vector2 = TextService:GetTextSize(prompt.ObjectText, 14, Enum.Font.GothamMedium, Vector2.new(1000, 1000))
		local promptHeight = 72
		local promptWidth = 72
		local textPaddingLeft = 72

		--[[ Calculating Prompt Size/Offsets ]]

		local maxTextWidth: number = math.max(actionTextSize.X, objectTextSize.X)
		if (prompt.ActionText ~= nil and prompt.ActionText ~= "") or (prompt.ObjectText ~= nil and prompt.ObjectText ~= "") then
			promptWidth = maxTextWidth + textPaddingLeft + 24
		end

		local actionTextYOffset = 0
		if prompt.ObjectText ~= nil and prompt.ObjectText ~= "" then
			actionTextYOffset = 9
		end

		--[[ Updating Displayed Texts ]]

		actionText.Text = prompt.ActionText
		actionText.AutoLocalize = prompt.AutoLocalize
		actionText.RootLocalizationTable = prompt.RootLocalizationTable
		actionText.Position = UDim2.new(0.5, textPaddingLeft - promptWidth / 2, 0, actionTextYOffset)

		objectText.Text = prompt.ObjectText
		objectText.AutoLocalize = prompt.AutoLocalize
		objectText.RootLocalizationTable = prompt.RootLocalizationTable
		objectText.Position = UDim2.new(0.5, textPaddingLeft - promptWidth / 2, 0, -10)

		--[[ Updating Size ]]

		promptUI.Size = UDim2.fromOffset(promptWidth, promptHeight)
		promptUI.SizeOffset = Vector2.new(prompt.UIOffset.X / promptUI.Size.Width.Offset, prompt.UIOffset.Y / promptUI.Size.Height.Offset)
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
		task.wait(0.5)
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
