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

local messageWidget: ScreenGui

local messageText: TextLabel
local acceptButton: ImageButton | TextButton

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

--- @class WidgetManager_MessageWidget
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

--- @param _ctx WidgetManager_ClientContext
function Module.Init(_ctx)
	ctx = _ctx

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	if I.UserInterface.UI["WidgetManager_Message"] then
		Module._getElements()
		Module._createConnections()
	end

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("WidgetManager_ShowMessage", { "string" })
	I.Network.Fired("WidgetManager_ShowMessage", Module.Show)

	I.Network.GetFunction("WidgetManager_ShowMessage-Return", { "string" })
	I.Network.OnInvoke("WidgetManager_ShowMessage-Return", Module.Show)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Get Elements

--[[
	Getting and storing key elements.
]]
function Module._getElements()
	messageWidget = I.UserInterface.UI["WidgetManager_Message"]
	local widget: Frame = messageWidget:FindFirstChild("U_Widget")

	--[[ General ]]

	messageText = widget:FindFirstChild("S_MessageText", true) --- @type TextLabel
	acceptButton = widget:FindFirstChild("S_AcceptButton", true) --- @type ImageButton | TextButton
end

--%%%%%%%%%%%%%%%%%%%% Create Connections

--[[
	Creates connections for the Message Widget.
]]
function Module._createConnections()
	--[[ Accept ]]

	-- A click, or the button's key (Utils_ButtonKey), dismisses the message
	I.Interact.OnPress(acceptButton, Module._accept)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	**CLIENT** |
	Shows message on the `WidgetManager_Message`, or queues it behind the message or confirmation on screen.
	Returns false when it couldn't be shown or queued.
]]
--- @return boolean
function Module.Show(message: string)
	--[[ Checks ]]

	-- Check if the message widget exists
	if not messageText then
		return false
	end

	--[[ Showing ]]

	return UtilityQueue.Show(function()
		return Module._display(message)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Accept

--[[
	Dismisses the message on screen: shows the next queued entry or closes the widget. Does nothing when the message
	widget isn't the open widget.
]]
function Module._accept()
	--[[ Checks ]]

	-- Check if the message widget is the open widget
	if I.WidgetManager.GetCurrent() ~= messageWidget then
		return
	end

	--[[ Closing ]]

	-- Show the next queued entry, or close the message widget
	if not UtilityQueue.ShowNext() then
		I.WidgetManager.OpenPreviouslyOpened()
	end
end

--%%%%%%%%%%%%%%%%%%%% Display

--[[
	Puts the message on the `WidgetManager_Message` and opens it.
]]
--- @return boolean
function Module._display(message: string)
	--[[ Updating Text ]]

	messageText.Text = `{message}`

	--[[ Widget ]]

	-- Save the `CurrentlyOpened` Widget as the `PreviouslyOpened` if it's not a utility widget.
	if ctx.CurrentlyOpened and not table.find(_settings.UTILITY_WIDGETS, ctx.CurrentlyOpened.Name) then
		ctx.PreviouslyOpened = ctx.CurrentlyOpened
	end

	-- Open Gui
	return I.WidgetManager.Open("WidgetManager_Message")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
