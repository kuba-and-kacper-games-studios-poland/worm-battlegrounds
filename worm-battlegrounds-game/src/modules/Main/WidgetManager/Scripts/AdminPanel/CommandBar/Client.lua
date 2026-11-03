--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "WidgetManager"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _data = script:FindFirstAncestor(_localName):FindFirstChild("Data")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--- @type WidgetManager_TweenPresets
local tweenPresets = require(_data.TweenPresets)

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

--- @class WidgetManager_CommandBar_Client
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommandDictionaries()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Command Dictionaries

--[[
	Registers dictionaries used by module commands.
]]
function Module._registerCommandDictionaries()
	--%%%%%%%%%%%%%%%%%%%% Tween Names

	--[[ Getting Values ]]

	local allTweenNames = {} --- @type { string }
	--- @param _tweenData WidgetManager_TweenPreset
	for tweenName: string, _tweenData in pairs(tweenPresets) do
		table.insert(allTweenNames, tweenName)
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary("WidgetManager_TweenNames", allTweenNames, 255)

	--%%%%%%%%%%%%%%%%%%%% Widget Names

	--[[ Getting Values ]]

	local allWidgetNames = {} --- @type { string }
	for guiName: string, widgetGui: ScreenGui in pairs(I.UserInterface.UI) do
		local widget: Instance? = widgetGui:FindFirstChild("U_Widget")
		if widget and widget:IsA("Frame") then
			table.insert(allWidgetNames, guiName)
		end
	end

	--[[ Updating Directories ]]

	I.AdminPanel_CommandBar.SetDictionary("WidgetManager_WidgetNames", allWidgetNames, 255)

	--[[ Dynamic Updating ]]

	I.Topic.Subscribe("UserInterface_UIAdded", function(widgetGui: ScreenGui)
		local widget: Instance? = widgetGui:FindFirstChild("U_Widget")
		if widget and widget:IsA("Frame") then
			I.AdminPanel_CommandBar.UpdateDictionary("WidgetManager_WidgetNames", { widgetGui.Name })
		end
	end)
	I.Topic.Subscribe("UserInterface_UIRemoved", function(widgetName: string)
		I.AdminPanel_CommandBar.UpdateDictionary("WidgetManager_WidgetNames", nil, { widgetName })
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
