--[[
	Created By: 	Nari
]]

local _localName: string = "TopBarPreview"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local TweenService: TweenService = game:GetService("TweenService")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Buttons ]]

-- Example icons the buttons take in turn (ume's TopBar_Controller backpack and music icons), and the padding the
-- TopBar module gives a button with a text
--- @type { string }
local ICONS = { "rbxassetid://83230059633723", "rbxassetid://124536081693916" }
local TEXT_PADDING: UDim = UDim.new(0, 12)
-- The first button's gamepad key on Console, as ume's TopBar_Controller gives the backpack button: D-pad up, in the
-- System theme's Color style (the same image on both pads)
local KEY_NAME: string = "DPadUp"
local KEY_ICON: string = "rbxassetid://96798501786319"

--[[ Highlight ]]

-- How the TopBar module fades a button's highlight in game (its Settings): in while the button is hovered or
-- pressed, back out when it is left or released
local HOVER_TRANSPARENCY: number = 0.925
local PRESS_TRANSPARENCY: number = 0.85
local Press_TweenInfo: TweenInfo = TweenInfo.new(0.075, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local Release_TweenInfo: TweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Fade Highlight

--[[
	Tweens a button's highlight to a transparency.
]]
local function fadeHighlight(highlight: Frame, transparency: number, tweenInfo: TweenInfo)
	--[[ Tweening ]]

	local Highlight_TweenGoal = { BackgroundTransparency = transparency }
	local Highlight_Tween: Tween = TweenService:Create(highlight, tweenInfo, Highlight_TweenGoal)
	Highlight_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Is Press

--[[
	Returns whether an input is a mouse click or a touch.
]]
--- @return boolean
local function isPress(input: InputObject)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
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

--- @class UmeGui_Guis_System_TopBar_Preview
local Module = {

	--[[ Settings ]]

	-- How many example buttons each side shows, and the text the right side's buttons carry next to their icon
	--- @type { UmeGui_Node }
	Settings = {
		{ Control = "Slider", Id = "S_Left", Label = "Left buttons", Value = 2, Min = 0, Max = 4, Step = 1 },
		{ Control = "Slider", Id = "S_Right", Label = "Right buttons", Value = 1, Min = 0, Max = 4, Step = 1 },
		{ Control = "Input", Id = "S_Text", Label = "Right text", Value = "Shop" },
	},
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Apply

--[[
	Fills both sides with example buttons, as the TopBar module adds them: icons on every button, the text with its
	padding on the right side's buttons when there is one, the highlight on hover and press, and on the first button
	a gamepad key (D-pad up) whose hint shows on Console.
]]
--- @param preview UmeGui_Preview
function Module.Apply(preview)
	--[[ Local Variables ]]

	local leftCount: number = preview.Values.S_Left
	local text: string = preview.Values.S_Text
	local rightSide: Instance = preview.View:Get("U_Right").Instance

	--[[ Buttons ]]

	local buttons = preview.Fill("PREFAB | Button", leftCount + preview.Values.S_Right) --- @type { UmeGui_Subview }

	--- @param button UmeGui_Subview
	for index: number, button in ipairs(buttons) do
		--[[ Icon ]]

		local icon: ImageLabel = button:Get("S_Icon").Instance
		icon.Image = ICONS[(index - 1) % #ICONS + 1]
		icon.Visible = true

		--[[ Highlight ]]

		Module._connectHighlight(button)

		--[[ Key ]]

		-- The first button's key: its hint shows on Console, padded like a text, and the key presses it
		if index == 1 then
			local hint: ImageLabel = button:Get("S_KeyHint").Instance
			local hintPadding: UIPadding = button:Get("S_Padding").Instance
			local console: boolean = preview.Device == "Console"
			hint.Image = KEY_ICON
			hint.Visible = console
			hintPadding.PaddingLeft = if console then TEXT_PADDING else UDim.new()
			hintPadding.PaddingRight = hintPadding.PaddingLeft
			button.Root.Instance:SetAttribute("Utils_GamepadKey", KEY_NAME)
			button.Root.Instance:AddTag("Utils_ButtonKey")
		end

		--[[ Right Side ]]

		-- Skip the left side's buttons
		if index <= leftCount then
			continue
		end

		local label: TextLabel = button:Get("S_Text").Instance
		local padding: UIPadding = button:Get("S_Padding").Instance
		button.Root.Instance.Parent = rightSide
		label.Text = text
		label.Visible = text ~= ""
		padding.PaddingLeft = if text ~= "" then TEXT_PADDING else UDim.new()
		padding.PaddingRight = padding.PaddingLeft
	end
end

--%%%%%%%%%%%%%%%%%%%% Connect Highlight

--[[
	Fades a button's highlight in while it is hovered or pressed and back out when it is left or released, as the
	TopBar module does in game. The connections go with the button when the next Fill replaces it.
]]
--- @param button UmeGui_Subview
function Module._connectHighlight(button)
	--[[ Local Variables ]]

	local instance: ImageButton = button.Root.Instance
	local highlight: Frame = button:Get("S_Highlight").Instance
	local hovered: boolean = false

	--[[ Hover ]]

	instance.MouseEnter:Connect(function()
		hovered = true
		fadeHighlight(highlight, HOVER_TRANSPARENCY, Press_TweenInfo)
	end)
	instance.MouseLeave:Connect(function()
		hovered = false
		fadeHighlight(highlight, 1, Release_TweenInfo)
	end)

	--[[ Press ]]

	instance.InputBegan:Connect(function(input: InputObject)
		-- Skip inputs that are not a press
		if not isPress(input) then
			return
		end

		fadeHighlight(highlight, PRESS_TRANSPARENCY, Press_TweenInfo)
	end)
	instance.InputEnded:Connect(function(input: InputObject)
		-- Skip inputs that are not a press
		if not isPress(input) then
			return
		end

		if hovered then
			fadeHighlight(highlight, HOVER_TRANSPARENCY, Press_TweenInfo)
		else
			fadeHighlight(highlight, 1, Release_TweenInfo)
		end
	end)
end

return Module
