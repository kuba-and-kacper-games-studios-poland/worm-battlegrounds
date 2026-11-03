--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "TopBar_Controller"

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

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	--%%%%%%%%%%%%%%%%%%%% Left Buttons

	--[[ Backpack ]]

	--- @type TopBar_Button
	local backpackButton = I.TopBar.AddButton("Left")
	backpackButton:SetLayoutOrder(0)
	backpackButton:SetIcon("rbxassetid://83230059633723", 0.6)
	backpackButton:SetCallback(function()
		I.BackpackPlus.Toggle()
	end)
	-- D-pad up toggles the backpack from here, the key Console opens it with, and shows next to the icon on Console
	backpackButton:SetGamepadKey(I.Settings["Console"].BACKPACK_OPEN)

	--[[ Settings ]]

	--- @type TopBar_Button
	local settingsButton = I.TopBar.AddButton("Left")
	settingsButton:SetLayoutOrder(1)
	settingsButton:SetIcon("rbxassetid://123765846716976", 0.6)
	settingsButton:SetCallback(function()
		I.WidgetManager.Toggle(I.Settings["Settings"].GUI_NAME)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ###

return {
	_init = Module.Init,
	_start = Module.Start,
}
