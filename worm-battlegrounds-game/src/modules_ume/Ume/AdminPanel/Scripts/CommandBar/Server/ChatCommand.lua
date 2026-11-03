--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--- @type AdminPanel_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Permissions = require(_scripts:FindFirstChild("Global"):FindFirstChild("Permissions")) --- @type AdminPanel_Global_Permissions

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

--- @class AdminPanel_CommandBar_Server_ChatCommand
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("_AdminPanel_CommandBar_ChatCommand")

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Module._createChatCommand()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Create Chat Command

--[[
	Creates the `TOGGLE_COMMAND` chat command on the server, so the message it is sent in never reaches the chat, and
	connects it to the sender's command bar.
]]
function Module._createChatCommand()
	--[[ Checks ]]

	-- Skip when the chat command is turned off
	if _settings.TOGGLE_COMMAND == "" then
		return
	end

	--[[ Creating ]]

	local chatCommand: TextChatCommand = I.Create("TextChatCommand")({
		Name = "__Ume_CommandBar_Toggle",
		PrimaryAlias = _settings.TOGGLE_COMMAND,
		AutocompleteVisible = _settings.COMMAND_VISIBLE,
		Parent = I.S.TextChatService,
	})

	--[[ Connections ]]

	chatCommand.Triggered:Connect(Module._onTriggered)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% On Triggered

--[[
	Tells the sender's client to open or close its command bar, when the sender may open it.
]]
function Module._onTriggered(originTextSource: TextSource, _unfilteredText: string)
	--[[ Data ]]

	local player: Player? = I.S.Players:GetPlayerByUserId(originTextSource.UserId)

	--[[ Checks ]]

	-- Check if the sender is a loaded player in this server
	if not player or not I.Player.Valid(player) then
		return
	end

	-- Check if the sender may open the command bar
	if Permissions.GetPermissionLevel(player) < _settings.OPEN_PERMISSION_LEVEL then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("_AdminPanel_CommandBar_ChatCommand", player)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return Module
