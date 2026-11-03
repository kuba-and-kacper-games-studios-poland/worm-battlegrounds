--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "WidgetManager"

--- @type WidgetManager_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type { () -> boolean }
local utilityQueue = {}

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

--- @class WidgetManager_UtilityQueue
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.Topic.Subscribe("WidgetManager_Closed", Module._onWidgetClosed)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Show

--[[
	Shows a message or confirmation now through its `display` function, or queues it behind the utility widget on screen and the entries already waiting.
	`display` returns whether the widget opened. Returns false when it was not queued and couldn't open.
]]
--- @return boolean
function Module.Show(display: () -> boolean)
	--[[ Queueing ]]

	-- Wait behind the utility widget on screen and the entries already waiting
	if Module._isShowing() or #utilityQueue > 0 then
		table.insert(utilityQueue, display)
		return true
	end

	--[[ Displaying ]]

	return display()
end

--%%%%%%%%%%%%%%%%%%%% Show Next

--[[
	Shows the first queued message or confirmation.
	Returns false when nothing is queued or it couldn't open yet; it then stays first in the queue.
]]
--- @return boolean
function Module.ShowNext()
	--[[ Checks ]]

	-- Check if an entry is waiting
	if #utilityQueue == 0 then
		return false
	end

	-- Keep the entry queued until it can open
	if not utilityQueue[1]() then
		return false
	end

	--[[ Removing ]]

	table.remove(utilityQueue, 1)

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% On Widget Closed

--[[
	Shows the next queued entry a frame after a widget closes, when no utility widget took the screen.
	Covers a message or confirmation closed some other way than its buttons.
]]
function Module._onWidgetClosed()
	--[[ Checks ]]

	-- Skip when nothing is queued
	if #utilityQueue == 0 then
		return
	end

	--[[ Showing Next ]]

	task.spawn(function()
		-- Wait a frame in case another widget opens
		task.wait()

		-- Skip when a utility widget is on screen
		if Module._isShowing() then
			return
		end

		Module.ShowNext()
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods

--%%%%%%%%%%%%%%%%%%%% Is Showing

--[[
	Returns whether the open widget is a utility widget.
]]
--- @return boolean
function Module._isShowing()
	--[[ Local Variables ]]

	local current: ScreenGui? = I.WidgetManager.GetCurrent()

	--[[ Returning ]]

	return current ~= nil and table.find(_settings.UTILITY_WIDGETS, current.Name) ~= nil
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
