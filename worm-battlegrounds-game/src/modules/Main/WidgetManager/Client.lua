--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "WidgetManager"

--- @type WidgetManager_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local TweenService = I.S.TweenService

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _components = script:FindFirstAncestor(_localName):FindFirstChild("Components")
local _data = script:FindFirstAncestor(_localName):FindFirstChild("Data")
local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type WidgetManager_TweenPresets
local tweenPresets = require(_data.TweenPresets)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

--- @type WidgetManager_Dim
local Dim = require(_scripts.Dim)

--- @type WidgetManager_MessageWidget
local MessageWidget = require(_scripts.MessageWidget)

--- @type WidgetManager_ConfirmationWidget
local ConfirmationWidget = require(_scripts.ConfirmationWidget)

local UtilityQueue = require(_scripts:FindFirstChild("UtilityQueue")) --- @type WidgetManager_UtilityQueue

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Queue ]]

-- Queue of widgets requested to be opened.
--- @type { WidgetManager_QueueEntry }
local widgetQueue = {}

--[[ Tweens ]]

-- Table for storing all created Tweens for Widgets.
--- @type { [string]: { [string]: Tween } }
local storedTweens = {}

--%%%%%%%%%%%%%%%%%%%% Shared

--- @type WidgetManager_ClientContext
local WidgetManager = {

	--[[ Widgets ]]

	CurrentlyOpened = nil, --- @type ScreenGui?
	PreviouslyOpened = nil, --- @type ScreenGui?
}

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Get Tween For Widget

--[[
    Returns a Tween and a function to translate the widget before playing the Tween.
]]
--- @return Tween, WidgetManager_PreTranslate
local function getTweenForWidget(widget: Frame, tweenName: string)
	if not tweenPresets[tweenName] then
		warn(`[{_localName}::{script.Name}]: Invalid tween ({tweenName}); using Default.`)
		tweenName = "Default"
	end

	-- Getting Widget UUID
	local widgetUUID: string = widget:GetAttribute("WidgetManager_TweenUUID")
	if not widgetUUID then
		widgetUUID = I.Obfuscate.GetRandomString(16)
		widget:SetAttribute("WidgetManager_TweenUUID", widgetUUID)
	end

	-- Return existing Tween and PreTranslate function.
	if storedTweens[widgetUUID] and storedTweens[widgetUUID][tweenName] then
		return storedTweens[widgetUUID][tweenName], tweenPresets[tweenName].PreTranslate
	end

	-- Create Table for `widget` Instance.
	if not storedTweens[widgetUUID] then
		storedTweens[widgetUUID] = {}
	end

	-- Creates new Tween and return it with PreTranslate function.
	storedTweens[widgetUUID][tweenName] = TweenService:Create(widget, tweenPresets[tweenName].Info, tweenPresets[tweenName].PostTranslate)
	return storedTweens[widgetUUID][tweenName], tweenPresets[tweenName].PreTranslate
end

--%%%%%%%%%%%%%%%%%%%% Get Widget

--[[
	Gets and validates a widget GUI and its Widget frame.
]]
--- @return ScreenGui?, Frame?
local function getWidget(widgetName: string)
	local gui: ScreenGui? = I.UserInterface.UI[widgetName]
	if not gui then
		warn(`[{_localName}::{script.Name}]: ({widgetName}) is not a valid ScreenGui!`)
		return nil, nil
	end

	local widget: Instance? = gui:FindFirstChild("U_Widget")
	if not widget or not widget:IsA("Frame") then
		warn(`[{_localName}::{script.Name}]: ({widgetName}) is missing the U_Widget Frame! -`, gui)
		return nil, nil
	end

	return gui, widget
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

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Register("WidgetManager_Opened", { "string" })
	I.Topic.Register("WidgetManager_Closed", { "string" })

	--- @Network

	--%%%%%%%%%%%%%%%%%%%% Normal

	I.Network.GetEvent("WidgetManager_Toggle", { "string", { Type = "string", Optional = true } })
	I.Network.Fired("WidgetManager_Toggle", Module.Toggle)

	I.Network.GetEvent("WidgetManager_Open", { "string", { Type = "string", Optional = true } })
	I.Network.Fired("WidgetManager_Open", Module.Open)

	I.Network.GetEvent("WidgetManager_OpenQueue", { "string", { Type = "string", Optional = true } })
	I.Network.Fired("WidgetManager_OpenQueue", Module.OpenQueue)

	I.Network.GetEvent("WidgetManager_Close", { "string" })
	I.Network.Fired("WidgetManager_Close", Module.Close)

	I.Network.GetEvent("WidgetManager_CloseCurrent", {})
	I.Network.Fired("WidgetManager_CloseCurrent", Module.CloseCurrent)

	--%%%%%%%%%%%%%%%%%%%% Return

	I.Network.GetFunction("WidgetManager_Toggle-Return", { "string", { Type = "string", Optional = true } })
	I.Network.OnInvoke("WidgetManager_Toggle-Return", Module.Toggle)

	I.Network.GetFunction("WidgetManager_Open-Return", { "string", { Type = "string", Optional = true } })
	I.Network.OnInvoke("WidgetManager_Open-Return", Module.Open)

	I.Network.GetFunction("WidgetManager_OpenQueue-Return", { "string", { Type = "string", Optional = true } })
	I.Network.OnInvoke("WidgetManager_OpenQueue-Return", Module.OpenQueue)

	I.Network.GetFunction("WidgetManager_OpenPreviouslyOpened-Return", {})
	I.Network.OnInvoke("WidgetManager_OpenPreviouslyOpened-Return", Module.OpenPreviouslyOpened)

	I.Network.GetFunction("WidgetManager_Close-Return", { "string" })
	I.Network.OnInvoke("WidgetManager_Close-Return", Module.Close)

	I.Network.GetFunction("WidgetManager_CloseCurrent-Return", {})
	I.Network.OnInvoke("WidgetManager_CloseCurrent-Return", Module.CloseCurrent)

	--- @Component
	I.Component.Register("WidgetManager_TogglePart", _components.TogglePart)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.WidgetManager = {

		--[[ Display Control ]]

		Toggle = Module.Toggle,
		Open = Module.Open,
		OpenQueue = Module.OpenQueue,
		OpenPreviouslyOpened = Module.OpenPreviouslyOpened,

		Close = Module.Close,
		CloseCurrent = Module.CloseCurrent,

		--[[ Info Widgets ]]

		ShowMessage = MessageWidget.Show,
		ShowConfirmation = ConfirmationWidget.Show,

		--[[ Methods ]]

		GetCurrent = Module.GetCurrent,
	}

	----------------------------
	-------- POST-INIT ---------
	----------------------------

	--[[ Shared ]]

	UtilityQueue.Init()
	MessageWidget.Init(WidgetManager)
	ConfirmationWidget.Init(WidgetManager)

	--[[ Effects ]]

	Module._connectEffectsToggle()

	--[[ Dim ]]

	if _settings.BACKGROUND_DIM then
		Dim.Init()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Connect Effects Toggle

--[[
	Creates connections to show effects while opening Widgets.
]]
function Module._connectEffectsToggle()
	--[[ Opened ]]

	I.Topic.Subscribe("WidgetManager_Opened", function()
		if _settings.BACKGROUND_FOV then
			I.Buff.Set("FOV", "Widget", _settings.FOV_INCREASE)
		end
		if _settings.BACKGROUND_BLUR then
			I.Lighting.SetValueBulk({
				{ "BlurEffect", "Size", { Value = _settings.BLUR_AMOUNT, Weight = _settings.BLUR_WEIGHT } },
				{ "BlurEffect", "Enabled", { Value = true, Weight = _settings.BLUR_WEIGHT } },
			}, _settings.BLUR_TWEENINFO)
		end
	end)

	--[[ Closed ]]

	I.Topic.Subscribe("WidgetManager_Closed", function()
		task.spawn(function()
			task.wait() -- Wait in case other widget is opened in the next frame
			if WidgetManager.CurrentlyOpened ~= nil then
				return
			end

			if _settings.BACKGROUND_FOV then
				I.Buff.Set("FOV", "Widget", nil)
			end
			if _settings.BACKGROUND_BLUR then
				I.Lighting.ClearValueBulk({
					{ "BlurEffect", "Size", _settings.BLUR_WEIGHT },
					{ "BlurEffect", "Enabled", _settings.BLUR_WEIGHT },
				}, _settings.BLUR_TWEENINFO)
			end
		end)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main Control

--%%%%%%%%%%%%%%%%%%%% Toggle

--[[
    **CLIENT** |
    Changes the state of the provided widget to it's opposite state.
]]
--- @return boolean
function Module.Toggle(widgetName: string, tweenName: string?)
	--[[ Closing ]]

	if WidgetManager.CurrentlyOpened and WidgetManager.CurrentlyOpened.Name == widgetName then
		return Module.Close(widgetName)
	end

	--[[ Opening ]]

	return Module.Open(widgetName, tweenName)
end

--%%%%%%%%%%%%%%%%%%%% Open

--[[
    **CLIENT** |
    Opens a widget with the given `widgetName`, and plays the tween animation.\
    Returns `true` if the widget was opened.
]]
--- @return boolean
function Module.Open(widgetName: string, tweenName: string?)
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Checks

	local gui: ScreenGui?, widget: Frame? = getWidget(widgetName)
	if not gui or not widget then
		return false
	end

	if WidgetManager.CurrentlyOpened and WidgetManager.CurrentlyOpened.Name == widgetName then
		return true
	end

	--[[
		Check if the currently opened widget has the `PreventClosing` attribute set to true.\
		If it's true then prevent opening other widget.
	]]

	if WidgetManager.CurrentlyOpened and WidgetManager.CurrentlyOpened:GetAttribute("PreventClosing") == true then
		return false
	end

	if WidgetManager.CurrentlyOpened then
		Module.Close(WidgetManager.CurrentlyOpened.Name)
	end

	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Opening

	if not table.find(_settings.UTILITY_WIDGETS, widgetName) then
		WidgetManager.PreviouslyOpened = nil
	end

	--[[ Open Widget ]]

	gui.Enabled = true
	WidgetManager.CurrentlyOpened = gui

	--[[ Animation ]]

	-- Without a tween asked for, play the one the widget names (its WidgetManager_Tween attribute), else Default
	local tween: Tween, translate = getTweenForWidget(widget, tweenName or widget:GetAttribute("WidgetManager_Tween") or "Default")
	translate(widget)
	tween:Play()

	--[[ Returning ]]

	I.Topic.Publish("WidgetManager_Opened", widgetName)
	return true -- Return that the widget has been opened successfully
end

--%%%%%%%%%%%%%%%%%%%% Close

--[[
    **CLIENT** |
    Closes currently opened widget, then tries to open widget from the queue.
]]
--- @return boolean
function Module.Close(widgetName: string)
	if WidgetManager.CurrentlyOpened and WidgetManager.CurrentlyOpened.Name == widgetName then
		--[[ Closing ]]

		WidgetManager.CurrentlyOpened.Enabled = false
		WidgetManager.CurrentlyOpened = nil

		I.Topic.Publish("WidgetManager_Closed", widgetName)

		--[[ Queue Open ]]

		Module._openFromQueue()

		return true
	end

	return false
end

--%%%%%%%%%%%%%%%%%%%% Close Current

--[[
	**CLIENT** |
	Closes currently opened widget.
]]
--- @return boolean
function Module.CloseCurrent()
	if WidgetManager.CurrentlyOpened then
		return Module.Close(WidgetManager.CurrentlyOpened.Name)
	end
	return false
end

--%%%%%%%%%%%%%%%%%%%% Open Queue

--[[
    **CLIENT** |
    Tries to open the given widget, but if it cannot be opened it's added to the queue.
]]
--- @return boolean
function Module.OpenQueue(widgetName: string, tweenName: string?)
	--[[ Checks ]]

	local _: ScreenGui?, widget: Frame? = getWidget(widgetName)
	if not widget then
		return false
	end

	-- Return if opening succeeded
	if not WidgetManager.CurrentlyOpened and Module.Open(widgetName, tweenName) then
		return true
	end

	-- Already Opened
	if WidgetManager.CurrentlyOpened and WidgetManager.CurrentlyOpened.Name == widgetName then
		return true
	end

	-- Widget already in queue
	--- @param queueData WidgetManager_QueueEntry
	for _, queueData in ipairs(widgetQueue) do
		if queueData.WidgetName == widgetName then
			return false
		end
	end

	-- Add new entry to queue
	table.insert(widgetQueue, {
		WidgetName = widgetName,
		TweenName = tweenName,
	})

	return true
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub Control

--%%%%%%%%%%%%%%%%%%%% Get Current

--[[
	**CLIENT** |
	Returns widget that is currently opened.
]]
--- @return ScreenGui | nil
function Module.GetCurrent()
	return WidgetManager.CurrentlyOpened
end

--%%%%%%%%%%%%%%%%%%%% Open From Queue

--[[
    Opens the first widget from the queue.
]]
function Module._openFromQueue()
	if #widgetQueue == 0 then
		return
	end

	task.spawn(function()
		--[[ Wait and check if another widget has been opened ]]

		task.wait()
		if WidgetManager.CurrentlyOpened then
			return
		end

		--[[ Opening from queue ]]

		--- @type WidgetManager_QueueEntry
		local queueEntry = table.remove(widgetQueue, 1)

		-- Opens widget from queue
		local success: boolean = Module.Open(queueEntry.WidgetName, queueEntry.TweenName)

		if not success then
			Module._openFromQueue()
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%% Open Previously Opened

--[[
    **CLIENT** |
    Opens previously opened widget or closes currently opened. Used for closing utility Guis.
]]
--- @return boolean
function Module.OpenPreviouslyOpened()
	if WidgetManager.PreviouslyOpened then
		local success: boolean = Module.Open(WidgetManager.PreviouslyOpened.Name)
		if success then
			WidgetManager.PreviouslyOpened = nil
		end
		return success
	elseif WidgetManager.CurrentlyOpened then
		return Module.Close(WidgetManager.CurrentlyOpened.Name)
	end

	return false
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
