--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "TopBar"

--- @type TopBar_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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

--- @class TopBar_Button : Component
--- @field Instance ImageButton
--- @field Connections { RBXScriptConnection }
--- @field _destroyed boolean
---
--- # Elements #
---
--- @field Highlight Frame
--- @field UIPadding UIPadding
--- @field ButtonIcon ImageLabel
--- @field ButtonText TextLabel
--- @field KeyHint ImageLabel
---
--- # State #
---
--- @field Hovered boolean
--- @field CallbackConnection Interact_PressConnection?
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

--- @return TopBar_Button
function Component.new(instance: ImageButton)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init()
	--[[ Elements ]]

	self.Highlight = self.Instance:FindFirstChild("S_Highlight", true)
	self.UIPadding = self.Instance:FindFirstChild("S_Padding", true)
	self.ButtonIcon = self.Instance:FindFirstChild("S_Icon", true)
	self.ButtonText = self.Instance:FindFirstChild("S_Text", true)
	self.KeyHint = self.Instance:FindFirstChild("S_KeyHint", true)

	--[[ State ]]

	self.Hovered = false

	--[[ Connections ]]

	self:_createConnections()
end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end

	--[[ Cleanup ]]

	self._destroyed = true
	self:RemoveCallback()
	self.Instance:Destroy()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Fades the highlight in while the button is hovered or pressed (by a click, a touch or its key), and back out when it
	is left or released. Pads the button while its key hint shows, as a text does.
]]
function Component:_createConnections()
	--[[ Hover ]]

	table.insert(
		self.Connections,
		self.Instance.MouseEnter:Connect(function()
			self.Hovered = true
			self:_fadeHighlight(_settings.HOVER_TRANSPARENCY, _settings.PRESS_TWEENINFO)
		end)
	)

	table.insert(
		self.Connections,
		self.Instance.MouseLeave:Connect(function()
			self.Hovered = false
			self:_fadeHighlight(1, _settings.RELEASE_TWEENINFO)
		end)
	)

	--[[ Press ]]

	table.insert(
		self.Connections,
		self.Instance.InputBegan:Connect(function(input: InputObject)
			-- Skip inputs that are not a press
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			self:_fadeHighlight(_settings.PRESS_TRANSPARENCY, _settings.PRESS_TWEENINFO)
		end)
	)

	table.insert(
		self.Connections,
		self.Instance.InputEnded:Connect(function(input: InputObject)
			-- Skip inputs that are not a press
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			self:_releaseHighlight()
		end)
	)

	--[[ Key ]]

	-- Its key (Utils_ButtonKey) presses and releases it like a click
	table.insert(
		self.Connections,
		I.Utils.ConnectPress(self.Instance, "Down", function()
			self:_fadeHighlight(_settings.PRESS_TRANSPARENCY, _settings.PRESS_TWEENINFO)
		end)
	)
	table.insert(
		self.Connections,
		I.Utils.ConnectPress(self.Instance, "Up", function()
			self:_releaseHighlight()
		end)
	)

	--[[ Key Hint ]]

	-- The Console module shows the hint on Console only: pad the button while it shows
	table.insert(
		self.Connections,
		self.KeyHint:GetPropertyChangedSignal("Visible"):Connect(function()
			if self.KeyHint.Visible then
				self:SetPadding()
			elseif not self.ButtonText.Visible then
				self:RemovePadding()
			end
		end)
	)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Set Layout Order

--[[
	Sets the button's LayoutOrder inside its side of the top bar.
]]
function Component:SetLayoutOrder(layoutOrder: number)
	--[[ Applying ]]

	self.Instance.LayoutOrder = layoutOrder
end

--%%%%%%%%%%%%%%%%%%%% Set Padding

--[[
	Sets the horizontal padding inside the button (BUTTON_PADDING on a side left out).
]]
--- @return UIPadding
function Component:SetPadding(paddingLeft: number?, paddingRight: number?)
	--[[ Applying ]]

	self.UIPadding.PaddingLeft = UDim.new(0, paddingLeft or _settings.BUTTON_PADDING)
	self.UIPadding.PaddingRight = UDim.new(0, paddingRight or _settings.BUTTON_PADDING)

	--[[ Returning ]]

	return self.UIPadding
end

--%%%%%%%%%%%%%%%%%%%% Remove Padding

--[[
	Removes the padding inside the button.
]]
function Component:RemovePadding()
	--[[ Applying ]]

	self.UIPadding.PaddingLeft = UDim.new()
	self.UIPadding.PaddingRight = UDim.new()
end

--%%%%%%%%%%%%%%%%%%%% Set Text

--[[
	Shows a text on the button. Adds the default padding when the button had no text yet.
]]
--- @return TextLabel
function Component:SetText(text: string)
	--[[ Padding ]]

	-- Pad the button once, when its text first shows
	if not self.ButtonText.Visible then
		self:SetPadding()
	end

	--[[ Texts ]]

	self.ButtonText.Text = text
	self.ButtonText.Visible = true

	--[[ Returning ]]

	return self.ButtonText
end

--%%%%%%%%%%%%%%%%%%%% Remove Text

--[[
	Hides the button's text, and removes the padding when no icon is left.
]]
function Component:RemoveText()
	--[[ Applying ]]

	self.ButtonText.Visible = false
	self.ButtonText.Text = ""

	--[[ Padding ]]

	if not self.ButtonIcon.Visible then
		self:RemovePadding()
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Icon

--[[
	Shows a square icon on the button. `size` is the share of the button's height (ICON_SIZE when left out).
]]
--- @return ImageLabel
function Component:SetIcon(iconId: string | number, size: number?)
	--[[ Icon ]]

	self.ButtonIcon.Size = UDim2.fromScale(size or _settings.ICON_SIZE, size or _settings.ICON_SIZE)
	self.ButtonIcon.Image = tostring(iconId)
	self.ButtonIcon.Visible = true

	--[[ Returning ]]

	return self.ButtonIcon
end

--%%%%%%%%%%%%%%%%%%%% Remove Icon

--[[
	Hides the button's icon, and removes the padding when no text is left.
]]
function Component:RemoveIcon()
	--[[ Applying ]]

	self.ButtonIcon.Visible = false
	self.ButtonIcon.Image = ""

	--[[ Padding ]]

	if not self.ButtonText.Visible then
		self:RemovePadding()
	end
end

--%%%%%%%%%%%%%%%%%%%% Set Callback

--[[
	Replaces the function the button runs when it is activated (clicked, tapped or picked with a gamepad) or pressed
	by its key (SetGamepadKey).
]]
--- @return Interact_PressConnection?
function Component:SetCallback(callback: () -> ())
	--[[ Checks ]]

	-- Check if the callback is a function
	if type(callback) ~= "function" then
		warn(`[{_localName}::{script.Name}]: Invalid (callback) type. Expected (function), got ({typeof(callback)})! -`, self.Instance)
		return nil
	end

	--[[ Connecting ]]

	self:RemoveCallback()
	self.CallbackConnection = I.Interact.OnPress(self.Instance, callback)

	--[[ Returning ]]

	return self.CallbackConnection
end

--%%%%%%%%%%%%%%%%%%%% Remove Callback

--[[
	Disconnects the button's callback.
]]
function Component:RemoveCallback()
	--[[ Checks ]]

	-- Check if a callback is connected
	if not self.CallbackConnection then
		return
	end

	--[[ Disconnecting ]]

	self.CallbackConnection:Disconnect()
	self.CallbackConnection = nil
end

--%%%%%%%%%%%%%%%%%%%% Set Gamepad Key

--[[
	Lets a gamepad button press the button as a click does (Utils_ButtonKey), and shows that button's icon next to
	its icon and text on Console (a Console_Hint, swapped to the player's pad by the Console module).
]]
--- @return ImageLabel
function Component:SetGamepadKey(keyCode: Enum.KeyCode)
	--[[ Key ]]

	-- Retag so the key component reads the new key
	self.Instance:RemoveTag("Utils_ButtonKey")
	self.Instance:SetAttribute("Utils_GamepadKey", keyCode.Name)
	self.Instance:AddTag("Utils_ButtonKey")

	--[[ Hint ]]

	self.KeyHint.Image = I.Console.GetIcon(keyCode, _settings.KEY_HINT_STYLE)
	self.KeyHint:AddTag("Console_Hint")

	--[[ Returning ]]

	return self.KeyHint
end

--%%%%%%%%%%%%%%%%%%%% Remove Gamepad Key

--[[
	Stops the button's gamepad key from pressing it, and hides its hint.
]]
function Component:RemoveGamepadKey()
	--[[ Key ]]

	self.Instance:RemoveTag("Utils_ButtonKey")
	self.Instance:SetAttribute("Utils_GamepadKey", nil)

	--[[ Hint ]]

	self.KeyHint:RemoveTag("Console_Hint")
	self.KeyHint.Visible = false
	self.KeyHint.Image = ""
end

--%%%%%%%%%%%%%%%%%%%% Fade Highlight

--[[
	Tweens the highlight to a transparency.
]]
function Component:_fadeHighlight(transparency: number, tweenInfo: TweenInfo)
	--[[ Tweening ]]

	local Highlight_TweenGoal = { BackgroundTransparency = transparency }
	local Highlight_Tween: Tween = I.S.TweenService:Create(self.Highlight, tweenInfo, Highlight_TweenGoal)
	Highlight_Tween:Play()
end

--%%%%%%%%%%%%%%%%%%%% Release Highlight

--[[
	Fades the highlight back to its hover look while the button is hovered, otherwise out.
]]
function Component:_releaseHighlight()
	--[[ Tweening ]]

	if self.Hovered then
		self:_fadeHighlight(_settings.HOVER_TRANSPARENCY, _settings.PRESS_TWEENINFO)
	else
		self:_fadeHighlight(1, _settings.RELEASE_TWEENINFO)
	end
end

return Component
