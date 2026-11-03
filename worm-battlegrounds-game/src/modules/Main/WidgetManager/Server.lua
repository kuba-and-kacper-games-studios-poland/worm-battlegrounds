--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "WidgetManager"

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

	--- @Network

	--%%%%%%%%%%%%%%%%%%%% Normal

	--[[ Display Control ]]

	I.Network.GetEvent("WidgetManager_Toggle")
	I.Network.GetEvent("WidgetManager_Open")
	I.Network.GetEvent("WidgetManager_OpenQueue")

	I.Network.GetEvent("WidgetManager_Close")
	I.Network.GetEvent("WidgetManager_CloseCurrent")

	--[[ Info Widgets ]]

	I.Network.GetEvent("WidgetManager_ShowMessage")

	--%%%%%%%%%%%%%%%%%%%% Return

	--[[ Display Control ]]

	I.Network.GetFunction("WidgetManager_Toggle-Return")
	I.Network.GetFunction("WidgetManager_Open-Return")
	I.Network.GetFunction("WidgetManager_OpenQueue-Return")
	I.Network.GetFunction("WidgetManager_OpenPreviouslyOpened-Return")

	I.Network.GetFunction("WidgetManager_Close-Return")
	I.Network.GetFunction("WidgetManager_CloseCurrent-Return")

	--[[ Info Widgets ]]

	I.Network.GetFunction("WidgetManager_ShowMessage-Return")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.WidgetManager = {

		--[[ Display Control ]]

		Toggle = Module.Toggle,
		Open = Module.Open,
		OpenQueue = Module.OpenQueue,

		Close = Module.Close,
		CloseCurrent = Module.CloseCurrent,

		--[[ Info Widgets ]]

		ShowMessage = Module.ShowMessage,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Toggle

--[[
	Asks the player's client to open the widget, or close it when it is open.
]]
function Module.Toggle(player: Player, widgetName: string, tweenName: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("WidgetManager_Toggle", player, widgetName, tweenName)
end

--%%%%%%%%%%%%%%%%%%%% Open

--[[
	Asks the player's client to open the widget, closing the one it has open.
]]
function Module.Open(player: Player, widgetName: string, tweenName: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("WidgetManager_Open", player, widgetName, tweenName)
end

--%%%%%%%%%%%%%%%%%%%% Open Queue

--[[
	Asks the player's client to open the widget, or queue it until the open one closes.
]]
function Module.OpenQueue(player: Player, widgetName: string, tweenName: string?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("WidgetManager_OpenQueue", player, widgetName, tweenName)
end

--%%%%%%%%%%%%%%%%%%%% Close

--[[
	Asks the player's client to close the widget when it is the open one.
]]
function Module.Close(player: Player, widgetName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("WidgetManager_Close", player, widgetName)
end

--%%%%%%%%%%%%%%%%%%%% Close Current

--[[
	Asks the player's client to close whatever widget is open.
]]
function Module.CloseCurrent(player: Player)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("WidgetManager_CloseCurrent", player)
end

--%%%%%%%%%%%%%%%%%%%% Show Message

--[[
	Asks the player's client to show the message widget with this text.
]]
function Module.ShowMessage(player: Player, message: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("WidgetManager_ShowMessage", player, message)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
