--[[
	Created By: 	Nari
]]

local _localName: string = "PromptPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local promptGui = require(script.Parent) --- @type UmeGui_Gui

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local ServerScriptService: ServerScriptService = game:GetService("ServerScriptService")
local TweenService: TweenService = game:GetService("TweenService")
local UserInputService: UserInputService = game:GetService("UserInputService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Layout ]]

-- How Roblox's default prompt lays its texts out: the space after them (less by the action's drop when there is an
-- object name), the action's drop under the middle, the key text size for keys longer than two letters (as ume's
-- Interact Default style does), how much the key grows while held, and how far the texts slide under it
local TEXT_PADDING_RIGHT: number = 24
local ACTION_OFFSET: number = 9
local LONG_KEY_TEXT_SIZE: number = 12
local HOLD_SCALE: number = 1.33
local FOLDED_PADDING: UDim = UDim.new(-0.25, 0)

--[[ Inputs ]]

-- The sizes Roblox's default prompt draws a gamepad button and the touch hand at
local PAD_SIZE: UDim2 = UDim2.fromOffset(24, 24)
local TOUCH_SIZE: UDim2 = UDim2.fromOffset(25, 31)
-- The Keyboard key option that shows the typed key
local TYPED_KEY: string = "Typed key"

--[[ Mappings ]]

-- Where ume's Interact input mappings (src/global_data/Interact/Mappings) sync to, under ServerScriptService
local MAPPINGS_PATH = { "Instance", "GlobalData", "Interact", "Mappings" } --- @type { string }
-- The mappings in the place by name, and the keys they draw (KeyCode names), read when the preview loads
local mappingsByName = {} --- @type { [string]: UmeGui_PromptMapping }
local mappingNames = {} --- @type { string }
local keyboardKeys = { TYPED_KEY } --- @type { string }
local gamepadKeys = {} --- @type { string }

--[[ Motion ]]

-- Roblox's timings: the card and texts, the key's fade, the ring emptying after a hold
local Fast_TweenInfo: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local Quick_TweenInfo: TweenInfo = TweenInfo.new(0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local Reset_TweenInfo: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

--[[ Parts ]]

-- The parts of the build the preview is wired to
local boundView --- @type UmeGui_View?
local frame: Frame
local listLayout: UIListLayout
local padding: UIPadding
local inputScale: UIScale
local roundFrame: Frame
local buttonImage: ImageLabel
local buttonIcon: ImageLabel
local buttonText: TextLabel
local ring: Frame
local leftImage: ImageLabel
local rightImage: ImageLabel
local leftGradient: UIGradient
local rightGradient: UIGradient
local actionText: TextLabel
local objectText: TextLabel

--[[ Rest ]]

-- The gui's own values at rest, which a release brings back
local frameTransparency: number = 0
local roundTransparency: number = 0
local keyTextSize: number = 0
local capImage: string = ""
local capSize: UDim2 = UDim2.new()
local ringImage: string = ""

--[[ State ]]

local holdDuration: number = 0
-- The hold's progress from 0 to 1, tweened while the prompt is held and drawn by the ring
local holdProgress: NumberValue?
local pressed: boolean = false
local triggered: boolean = false

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	Tweens an instance's properties to their goals.
]]
--- @param goals { [string]: any }
local function play(instance: Instance, Play_TweenInfo: TweenInfo, goals)
	--[[ Playing ]]

	local Play_TweenGoal = goals --- @type { [string]: any }
	local Play_Tween: Tween = TweenService:Create(instance, Play_TweenInfo, Play_TweenGoal)
	Play_Tween:Play()
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

--- @class UmeGui_Guis_System_Prompt_Preview
local Module = {

	--[[ Settings ]]

	-- The ProximityPrompt properties the prompt shows, and the input mappings it draws the key with (first the ones
	-- the gui prefers). The Device switch picks the input, as a player's device does: Desktop the keyboard key,
	-- Console the gamepad key (on the picked pad), Mobile the touch hand. Press the prompt to hold and trigger it
	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Input", Id = "S_Action", Label = "Action text", Value = "Open" },
		{ Control = "Input", Id = "S_Object", Label = "Object text", Value = "Chest" },
		{ Control = "Dropdown", Id = "S_Mappings", Label = "Mappings", Options = mappingNames, Value = promptGui.Mappings or "Default" },
		{ Control = "Dropdown", Id = "S_KeyboardKey", Label = "Keyboard key", Options = keyboardKeys, Value = TYPED_KEY },
		{ Control = "Input", Id = "S_Key", Label = "Typed key", Value = "E" },
		{ Control = "Dropdown", Id = "S_GamepadKey", Label = "Gamepad key", Options = gamepadKeys, Value = "ButtonX" },
		{ Control = "Slider", Id = "S_HoldDuration", Label = "Hold duration", Value = 1, Min = 0, Max = 5, Step = 0.25, Format = "{} s" },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Shows the prompt with the texts, the key and the hold duration from the settings, laid out as Roblox lays out its
	default prompt. With no hold, a press triggers at once; the ring only shows while a hold is under way.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Binding ]]

	-- Wire each build once
	if preview.View ~= boundView then
		Module._bind(preview.View)
	end

	--[[ Local Variables ]]

	local hasObject: boolean = preview.Values.S_Object ~= ""
	local hasText: boolean = hasObject or preview.Values.S_Action ~= ""
	local actionOffset: number = if hasObject then ACTION_OFFSET else 0

	--[[ Applying ]]

	actionText.Text = preview.Values.S_Action
	actionText.Position = UDim2.fromOffset(0, actionOffset)
	objectText.Text = preview.Values.S_Object
	padding.PaddingRight = UDim.new(0, if hasText then TEXT_PADDING_RIGHT - actionOffset else 0)
	holdDuration = preview.Values.S_HoldDuration

	--[[ Input ]]

	Module._applyInput(preview)
end

--%%%%%%%%%%%%%%%%%%%% Apply Input

--[[
	Shows the key as the previewed device sees it, from the picked mappings: on Desktop the key cap with the keyboard
	key's symbol, its mapped text or the typed key; on Console the gamepad button, in the picked pad's own look; on
	Mobile the touch hand. Without mappings in the place, the typed key on the gui's own cap on every device.
]]
--- @param preview UmeGui_Preview
function Module._applyInput(preview)
	--[[ Data ]]

	local mappings = mappingsByName[preview.Values.S_Mappings] --- @type UmeGui_PromptMapping?

	--[[ Local Variables ]]

	local device: string = if mappings then preview.Device else "Desktop"
	local keyText: string = preview.Values.S_Key
	local symbol: string? = nil

	-- A picked keyboard key: its symbol when the mappings draw one, else its mapped text or its own
	if mappings and preview.Values.S_KeyboardKey ~= TYPED_KEY then
		local keyCode: Enum.KeyCode = Enum.KeyCode[preview.Values.S_KeyboardKey]
		local ownText: string = UserInputService:GetStringForKeyCode(keyCode)
		symbol = mappings.KeyboardButtonImage[keyCode] or mappings.KeyboardButtonIconMapping[ownText]
		keyText = mappings.KeyCodeToTextMapping[keyCode] or ownText
	end

	--[[ Ring ]]

	leftImage.Image = if mappings then mappings.RadialFillImage else ringImage
	rightImage.Image = leftImage.Image

	--[[ Key ]]

	buttonIcon.Visible = false
	buttonText.Visible = false
	if device == "Console" then
		-- The pad's own image (PlayStation or Xbox), as ume's Interact picks it
		local gamepadKey: Enum.KeyCode = Enum.KeyCode[preview.Values.S_GamepadKey]
		local playStationImage: string? = if preview.Pad == "PlayStation" then mappings.PlayStationButtonImage[gamepadKey] else nil
		buttonImage.Image = playStationImage or mappings.GamepadButtonImage[gamepadKey] or ""
		buttonImage.Size = PAD_SIZE
	elseif device == "Mobile" then
		buttonImage.Image = mappings.TouchTapImage
		buttonImage.Size = TOUCH_SIZE
	else
		buttonImage.Image = if mappings then mappings.KeyCapImage else capImage
		buttonImage.Size = capSize
		buttonIcon.Image = symbol or ""
		buttonIcon.Visible = symbol ~= nil
		buttonText.Text = keyText
		buttonText.TextSize = if #keyText > 2 then LONG_KEY_TEXT_SIZE else keyTextSize
		buttonText.Visible = symbol == nil
	end
end

--%%%%%%%%%%%%%%%%%%%% Load Mappings

--[[
	Reads ume's Interact input mappings from the place, as fresh copies so edits show on the next rebuild, and lists
	them with every keyboard key and gamepad button they draw, for the settings' dropdowns.
]]
function Module._loadMappings()
	--[[ Finding ]]

	local folder: Instance? = ServerScriptService
	for _index: number, name: string in ipairs(MAPPINGS_PATH) do
		folder = if folder then folder:FindFirstChild(name) else nil
	end

	--[[ Checks ]]

	-- Check if the place has ume's mappings (a place without ume, such as ume-rbx's, has none)
	if not folder then
		return
	end

	--[[ Reading ]]

	for _index: number, mappingsModule: Instance in ipairs(folder:GetChildren()) do
		if mappingsModule:IsA("ModuleScript") then
			mappingsByName[mappingsModule.Name] = require(mappingsModule:Clone()) --- @type UmeGui_PromptMapping
			table.insert(mappingNames, mappingsModule.Name)
		end
	end
	table.sort(mappingNames)

	--[[ Listing Keys ]]

	-- Every key a mappings module draws, in KeyCode order: gamepad buttons, then keyboard keys
	for _index: number, keyCode: Enum.KeyCode in ipairs(Enum.KeyCode:GetEnumItems()) do
		local keyText: string = UserInputService:GetStringForKeyCode(keyCode)
		local isGamepad: boolean = false
		local isKeyboard: boolean = false

		-- Only the key a character belongs to (Quote for ', not QuotedDouble, which Studio also reports as ')
		local ownsText: boolean = keyText ~= "" and keyCode.Value == string.byte(keyText)

		--- @param mappings UmeGui_PromptMapping
		for _name: string, mappings in pairs(mappingsByName) do
			isGamepad = isGamepad or mappings.GamepadButtonImage[keyCode] ~= nil or mappings.PlayStationButtonImage[keyCode] ~= nil
			isKeyboard = isKeyboard or mappings.KeyboardButtonImage[keyCode] ~= nil or mappings.KeyCodeToTextMapping[keyCode] ~= nil or (ownsText and mappings.KeyboardButtonIconMapping[keyText] ~= nil)
		end

		if isGamepad then
			table.insert(gamepadKeys, keyCode.Name)
		elseif isKeyboard then
			table.insert(keyboardKeys, keyCode.Name)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Bind

--[[
	Finds the parts of a fresh build, remembers their values at rest, and wires the prompt's button: a press holds it (or
	triggers it without a hold), a finished hold triggers it, and a release brings it back.
]]
--- @param view UmeGui_View
function Module._bind(view)
	--[[ Data ]]

	local parts = view.Scoped.U_Prompt --- @type { [string]: UmeGui_Handle }
	local button: ImageButton = parts.S_InteractButton.Instance

	--[[ Parts ]]

	boundView = view
	frame = parts.S_Frame.Instance
	listLayout = parts.S_ListLayout.Instance
	padding = parts.S_Padding.Instance
	inputScale = parts.S_InputFrameScaler.Instance
	roundFrame = parts.S_RoundFrame.Instance
	buttonImage = parts.S_ButtonImage.Instance
	buttonIcon = parts.S_ButtonIcon.Instance
	buttonText = parts.S_ButtonText.Instance
	ring = parts.S_CircularProgressBar.Instance
	leftImage = parts.S_LeftImage.Instance
	rightImage = parts.S_RightImage.Instance
	leftGradient = parts.S_LeftGradient.Instance
	rightGradient = parts.S_RightGradient.Instance
	actionText = parts.S_ActionText.Instance
	objectText = parts.S_ObjectText.Instance

	--[[ Rest ]]

	frameTransparency = frame.BackgroundTransparency
	roundTransparency = roundFrame.BackgroundTransparency
	keyTextSize = buttonText.TextSize
	capImage = buttonImage.Image
	capSize = buttonImage.Size
	ringImage = leftImage.Image

	--[[ State ]]

	local progressValue: NumberValue = Instance.new("NumberValue")
	holdProgress = progressValue
	pressed = false
	triggered = false

	--[[ Connections ]]

	progressValue.Changed:Connect(function(progress: number)
		Module._showProgress(progress)

		-- The ring is full: the hold is done
		if pressed and not triggered and progress >= 1 then
			Module._trigger()
		end

		-- The ring has emptied after a release: hide it, since its clear halves still draw a pixel's edge
		if not pressed and progress <= 0 then
			ring.Visible = false
		end
	end)
	button.InputBegan:Connect(function(inputObject: InputObject)
		-- Skip other inputs, and a second press while one is held
		if not Module._isPress(inputObject) or pressed then
			return
		end

		pressed = true
		if holdDuration > 0 then
			Module._hold()
		else
			Module._trigger()
		end
	end)
	button.InputEnded:Connect(function(inputObject: InputObject)
		if Module._isPress(inputObject) then
			Module._release()
		end
	end)
	button.MouseLeave:Connect(Module._release)
end

--%%%%%%%%%%%%%%%%%%%% Hold

--[[
	Starts a hold (PromptButtonHoldBegan): the ring shows and fills over the hold, the key grows, the texts fade and slide
	under it and the card clears.
]]
function Module._hold()
	--[[ Local Variables ]]

	local Hold_TweenInfo: TweenInfo = TweenInfo.new(holdDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

	--[[ Animating ]]

	ring.Visible = true
	play(inputScale, Fast_TweenInfo, { Scale = HOLD_SCALE })
	play(actionText, Fast_TweenInfo, { TextTransparency = 1 })
	play(listLayout, Fast_TweenInfo, { Padding = FOLDED_PADDING })
	play(objectText, Fast_TweenInfo, { TextTransparency = 1 })
	play(frame, Fast_TweenInfo, { BackgroundTransparency = 1 })
	play(holdProgress, Hold_TweenInfo, { Value = 1 })
end

--%%%%%%%%%%%%%%%%%%%% Trigger

--[[
	Triggers the prompt (Triggered): it fades out until the press ends.
]]
function Module._trigger()
	--[[ Animating ]]

	triggered = true
	play(actionText, Fast_TweenInfo, { TextTransparency = 1 })
	play(listLayout, Fast_TweenInfo, { Padding = FOLDED_PADDING })
	play(objectText, Fast_TweenInfo, { TextTransparency = 1 })
	play(frame, Fast_TweenInfo, { BackgroundTransparency = 1 })
	play(roundFrame, Quick_TweenInfo, { BackgroundTransparency = 1 })
	play(buttonImage, Quick_TweenInfo, { ImageTransparency = 1 })
	play(buttonIcon, Quick_TweenInfo, { ImageTransparency = 1 })
	play(buttonText, Quick_TweenInfo, { TextTransparency = 1 })
	play(leftImage, Quick_TweenInfo, { ImageTransparency = 1 })
	play(rightImage, Quick_TweenInfo, { ImageTransparency = 1 })
end

--%%%%%%%%%%%%%%%%%%%% Release

--[[
	Ends a press (PromptButtonHoldEnded and TriggerEnded): a hold that did not finish stops, and the prompt comes back
	to its values at rest.
]]
function Module._release()
	--[[ Checks ]]

	-- Only a pressed prompt is released
	if not pressed then
		return
	end

	--[[ Animating ]]

	pressed = false
	triggered = false
	play(inputScale, Fast_TweenInfo, { Scale = 1 })
	play(actionText, Fast_TweenInfo, { TextTransparency = 0 })
	play(listLayout, Fast_TweenInfo, { Padding = UDim.new(0, 0) })
	play(objectText, Fast_TweenInfo, { TextTransparency = 0 })
	play(frame, Fast_TweenInfo, { BackgroundTransparency = frameTransparency })
	play(roundFrame, Quick_TweenInfo, { BackgroundTransparency = roundTransparency })
	play(buttonImage, Quick_TweenInfo, { ImageTransparency = 0 })
	play(buttonIcon, Quick_TweenInfo, { ImageTransparency = 0 })
	play(buttonText, Quick_TweenInfo, { TextTransparency = 0 })
	play(leftImage, Quick_TweenInfo, { ImageTransparency = 0 })
	play(rightImage, Quick_TweenInfo, { ImageTransparency = 0 })
	play(holdProgress, Reset_TweenInfo, { Value = 0 })

	-- A hold released before the ring moved never empties it again, so hide it now
	if holdProgress.Value <= 0 then
		ring.Visible = false
	end
end

--%%%%%%%%%%%%%%%%%%%% Show Progress

--[[
	Turns the ring's halves to a hold progress from 0 to 1.
]]
function Module._showProgress(progress: number)
	--[[ Local Variables ]]

	local angle: number = math.clamp(progress, 0, 1) * 360

	--[[ Applying ]]

	leftGradient.Rotation = math.clamp(angle, 180, 360)
	rightGradient.Rotation = math.clamp(angle, 0, 180)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Press

--[[
	Returns whether an input is the primary button or a touch.
]]
--- @return boolean
function Module._isPress(inputObject: InputObject)
	return inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch
end

Module._loadMappings()

return Module
