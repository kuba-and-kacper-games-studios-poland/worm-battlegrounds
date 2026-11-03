--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "WidgetManager"

--- @type WidgetManager_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local UtilityQueue = require(_scripts:FindFirstChild("UtilityQueue")) --- @type WidgetManager_UtilityQueue

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Elements ]]

local confirmationWidget: ScreenGui

local messageText: TextLabel
local acceptButton: ImageButton | TextButton
local declineButton: ImageButton | TextButton

--[[ Confirmation ]]

local confirmationCallback --- @type WidgetManager_ConfirmationCallback?
local declineCallback --- @type WidgetManager_ConfirmationCallback?

--[[ Shared ]]

--- @type WidgetManager_ClientContext
local ctx

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

--- @class WidgetManager_ConfirmationWidget
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _ctx WidgetManager_ClientContext
function Module.Init(_ctx)
	ctx = _ctx

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	if I.UserInterface.UI["WidgetManager_Confirmation"] then
		Module._getElements()
		Module._createConnections()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements.
]]
function Module._getElements()
	confirmationWidget = I.UserInterface.UI["WidgetManager_Confirmation"]
	local widget: Frame = confirmationWidget:FindFirstChild("U_Widget")

	--[[ General ]]

	messageText = widget:FindFirstChild("S_MessageText", true) --- @type TextLabel
	acceptButton = widget:FindFirstChild("S_AcceptButton", true) --- @type ImageButton | TextButton
	declineButton = widget:FindFirstChild("S_DeclineButton", true) --- @type ImageButton | TextButton
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Creates connections for the Confirmation Widget.
]]
function Module._createConnections()
	--[[ Buttons ]]

	-- A click, or the button's key (Utils_ButtonKey), answers the confirmation
	I.Interact.OnPress(acceptButton, Module._accept)
	I.Interact.OnPress(declineButton, Module._decline)

	--[[ Closed ]]

	I.Topic.Subscribe("WidgetManager_Closed", Module._onWidgetClosed)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	**CLIENT** |
	Shows message on the `WidgetManager_Confirmation`, or queues it behind the message or confirmation on screen.
	`onAccept` runs on Accept; `onDecline` runs on Decline or when the widget closes any other way. Returns false when it couldn't be shown or queued.
]]
--- @param onAccept WidgetManager_ConfirmationCallback?
--- @param onDecline WidgetManager_ConfirmationCallback?
--- @return boolean
function Module.Show(message: string, onAccept, onDecline)
	--[[ Checks ]]

	-- Check if the confirmation widget exists
	if not messageText then
		return false
	end

	--[[ Callbacks ]]

	-- Keep only callbacks that are functions
	local onAcceptCallback = if type(onAccept) == "function" then onAccept else nil --- @type WidgetManager_ConfirmationCallback?
	local onDeclineCallback = if type(onDecline) == "function" then onDecline else nil --- @type WidgetManager_ConfirmationCallback?

	--[[ Showing ]]

	return UtilityQueue.Show(function()
		return Module._display(message, onAcceptCallback, onDeclineCallback)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Accept

--[[
	Answers the confirmation on screen with Accept: shows the next queued entry or closes the widget, then runs
	`onAccept`. Does nothing when the confirmation widget isn't the open widget.
]]
function Module._accept()
	--[[ Checks ]]

	-- Check if the confirmation widget is the open widget
	if I.WidgetManager.GetCurrent() ~= confirmationWidget then
		return
	end

	--[[ Callbacks ]]

	--- @type WidgetManager_ConfirmationCallback?
	local callback = confirmationCallback
	confirmationCallback = nil
	declineCallback = nil

	--[[ Closing ]]

	-- Show the next queued entry, or close the confirmation widget
	if not UtilityQueue.ShowNext() then
		I.WidgetManager.OpenPreviouslyOpened()
	end

	--[[ Accepting ]]

	-- Run the accept callback when one was given
	if callback then
		callback()
	end
end

--%%%%%%%%%%%%%%%%%%%% Decline

--[[
	Answers the confirmation on screen with Decline: shows the next queued entry or closes the widget, then runs
	`onDecline`. Does nothing when the confirmation widget isn't the open widget.
]]
function Module._decline()
	--[[ Checks ]]

	-- Check if the confirmation widget is the open widget
	if I.WidgetManager.GetCurrent() ~= confirmationWidget then
		return
	end

	--[[ Callbacks ]]

	--- @type WidgetManager_ConfirmationCallback?
	local callback = declineCallback
	confirmationCallback = nil
	declineCallback = nil

	--[[ Closing ]]

	-- Show the next queued entry, or close the confirmation widget
	if not UtilityQueue.ShowNext() then
		I.WidgetManager.OpenPreviouslyOpened()
	end

	--[[ Declining ]]

	-- Run the decline callback when one was given
	if callback then
		callback()
	end
end

--%%%%%%%%%%%%%%%%%%%% Display

--[[
	Puts the message on the `WidgetManager_Confirmation`, opens it and keeps its callbacks for the buttons.
]]
--- @param onAccept WidgetManager_ConfirmationCallback?
--- @param onDecline WidgetManager_ConfirmationCallback?
--- @return boolean
function Module._display(message: string, onAccept, onDecline)
	--[[ Updating Text ]]

	messageText.Text = `{message}`

	--[[ Widget ]]

	-- Save the `CurrentlyOpened` Widget as a `PreviouslyOpened` if it's not a utility widget.
	if ctx.CurrentlyOpened and not table.find(_settings.UTILITY_WIDGETS, ctx.CurrentlyOpened.Name) then
		ctx.PreviouslyOpened = ctx.CurrentlyOpened
	end

	-- Check if the widget opened
	if not I.WidgetManager.Open("WidgetManager_Confirmation") then
		return false
	end

	--[[ Callbacks ]]

	confirmationCallback = onAccept
	declineCallback = onDecline

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% On Widget Closed

--[[
	Runs the decline callback when the confirmation widget closes without its Accept or Decline button.
]]
function Module._onWidgetClosed(widgetName: string)
	--[[ Checks ]]

	-- Skip other widgets
	if widgetName ~= "WidgetManager_Confirmation" then
		return
	end

	--[[ Callbacks ]]

	--- @type WidgetManager_ConfirmationCallback?
	local callback = declineCallback
	confirmationCallback = nil
	declineCallback = nil

	--[[ Declining ]]

	-- Run the decline callback when one was pending
	if callback then
		callback()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
