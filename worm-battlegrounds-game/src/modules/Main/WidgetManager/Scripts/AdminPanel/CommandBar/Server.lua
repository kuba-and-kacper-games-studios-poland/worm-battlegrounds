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

--- @class WidgetManager_CommandBar_Server
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._registerCommands()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start

--%%%%%%%%%%%%%%%%%%%% Register Commands

--[[
	Registers commands used for controlling module.
]]
function Module._registerCommands()
	--%%%%%%%%%%%%%%%%%%%% Open Control Functions

	local function toggle(player: Player, widgetName: string, tweenName: string?)
		--[[ Checks ]]

		if tweenName and not tweenPresets[tweenName] then
			return false, `Invalid TweenName: $|cr$|{tweenName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: any = I.Network.Invoke("WidgetManager_Toggle-Return", player, widgetName, tweenName)

		-- Report success only when the client answered true
		if value == true then
			return true, `Toggled Widget $|cr$|{widgetName}#| for $|cr$|{player.Name}#|`
		else
			return false, `Failed to toggle Widget $|cr$|{widgetName}#| for $|cr$|{player.Name}#|`
		end
	end

	local function open(player: Player, widgetName: string, tweenName: string?)
		--[[ Checks ]]

		if tweenName and not tweenPresets[tweenName] then
			return false, `Invalid TweenName: $|cr$|{tweenName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: any = I.Network.Invoke("WidgetManager_Open-Return", player, widgetName, tweenName)

		-- Report success only when the client answered true
		if value == true then
			return true, `Opened Widget $|cr$|{widgetName}#| for $|cr$|{player.Name}#|`
		else
			return false, `Failed to open Widget $|cr$|{widgetName}#| for $|cr$|{player.Name}#|`
		end
	end

	local function openQueue(player: Player, widgetName: string, tweenName: string?)
		--[[ Checks ]]

		if tweenName and not tweenPresets[tweenName] then
			return false, `Invalid TweenName: $|cr$|{tweenName}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: any = I.Network.Invoke("WidgetManager_OpenQueue-Return", player, widgetName, tweenName)

		-- Report success only when the client answered true
		if value == true then
			return true, `Added Widget $|cr$|{widgetName}#| to queue for $|cr$|{player.Name}#|`
		else
			return false, `Failed to add Widget $|cr$|{widgetName}#| to queue for $|cr$|{player.Name}#|`
		end
	end

	local function openPreviouslyOpened(player: Player)
		--[[ Executing ]]

		-- Getting value
		local value: any = I.Network.Invoke("WidgetManager_OpenPreviouslyOpened-Return", player)

		-- Report success only when the client answered true
		if value == true then
			return true, `Opened previously opened Widget for $|cr$|{player.Name}#|`
		else
			return false, `Failed to open previously opened Widget for $|cr$|{player.Name}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Close Control Functions

	local function close(player: Player, widgetName: string)
		--[[ Executing ]]

		-- Getting value
		local value: any = I.Network.Invoke("WidgetManager_Close-Return", player, widgetName)

		-- Report success only when the client answered true
		if value == true then
			return true, `Closed Widget $|cr$|{widgetName}#| for $|cr$|{player.Name}#|`
		else
			return false, `Failed to close Widget $|cr$|{widgetName}#| for $|cr$|{player.Name}#|`
		end
	end

	local function closeCurrent(player: Player)
		--[[ Executing ]]

		-- Getting value
		local value: any = I.Network.Invoke("WidgetManager_CloseCurrent-Return", player)

		-- Report success only when the client answered true
		if value == true then
			return true, `Closed currently opened Widget for $|cr$|{player.Name}#|`
		else
			return false, `Failed to close currently opened Widget for $|cr$|{player.Name}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Message Control Functions

	local function showMessage(player: Player, message: string)
		--[[ Checks ]]

		if typeof(message) ~= "string" or message == "" then
			return false, `Invalid Message: $|cr$|{message}#|`
		end

		--[[ Executing ]]

		-- Getting value
		local value: any = I.Network.Invoke("WidgetManager_ShowMessage-Return", player, message)

		-- Report success only when the client answered true
		if value == true then
			return true, `Showed message to player $|cr$|{player.Name}#|`
		else
			return false, `Failed to show message to player $|cr$|{player.Name}#|`
		end
	end

	--%%%%%%%%%%%%%%%%%%%% Commands

	--[[ Variants ]]

	local variants = {

		--[[ Open Control ]]

		{
			Aliases = { "toggle" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "widgetName", types = { "string" }, dict = "WidgetManager_WidgetNames", requireDict = true },
				{ name = "tweenName", types = { "string" }, dict = "WidgetManager_TweenNames", requireDict = true, optional = true },
			},
			Callback = toggle,
		},
		{
			Aliases = { "open" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "widgetName", types = { "string" }, dict = "WidgetManager_WidgetNames", requireDict = true },
				{ name = "tweenName", types = { "string" }, dict = "WidgetManager_TweenNames", requireDict = true, optional = true },
			},
			Callback = open,
		},
		{
			Aliases = { "open_queue" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "widgetName", types = { "string" }, dict = "WidgetManager_WidgetNames", requireDict = true },
				{ name = "tweenName", types = { "string" }, dict = "WidgetManager_TweenNames", requireDict = true, optional = true },
			},
			Callback = openQueue,
		},
		{
			Aliases = { "open_previously_opened" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = openPreviouslyOpened,
		},

		--[[ Close Control ]]

		{
			Aliases = { "close" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "widgetName", types = { "string" }, dict = "WidgetManager_WidgetNames", requireDict = true },
			},
			Callback = close,
		},
		{
			Aliases = { "close_current" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
			},
			Callback = closeCurrent,
		},

		--[[ Message Control ]]

		{
			Aliases = { "show_message" },
			Args = {
				{ name = "player", types = { "Player" }, dict = "players", requireDict = true },
				{ name = "message", types = { "string" } },
			},
			Callback = showMessage,
		},
	}

	--[[ Command ]]

	I.AdminPanel_CommandBar.Register("WidgetManager_Server", {
		Aliases = { "widget_manager" },
		PermissionLevel = 255,

		Variants = variants,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
