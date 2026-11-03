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

local _commandBar = _scripts:FindFirstChild("CommandBar")
local _helpers = _commandBar:FindFirstChild("Helpers")
local _client = _commandBar:FindFirstChild("Client")
local _dashboard = _scripts:FindFirstChild("Dashboard"):FindFirstChild("Client")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

--[[ Helpers ]]

--- @type AdminPanel_CommandBar_ClientUtils
local c_utils = require(_helpers:FindFirstChild("Client_Utils"))

--- @type AdminPanel_CommandBar_Utils
local utils = require(_helpers:FindFirstChild("Utils"))

--[[ Admin Panel ]]

local Permissions = require(_scripts:FindFirstChild("Global"):FindFirstChild("Permissions")) --- @type AdminPanel_Global_Permissions
local Window = require(_scripts:FindFirstChild("Client"):FindFirstChild("Window")) --- @type AdminPanel_Client_Window

--[[ Dashboard ]]

local Rail = require(_dashboard:FindFirstChild("Rail")) --- @type AdminPanel_Dashboard_Client_Rail

--[[ Command Bar ]]

--- @type AdminPanel_CommandBar_Client_Bootstrap
local Bootstrap = require(_client:FindFirstChild("Bootstrap"))

--- @type AdminPanel_CommandBar_Client_Connections
local Connections = require(_client:FindFirstChild("Connections"))

--- @type AdminPanel_CommandBar_Client_Data
local Data = require(_client:FindFirstChild("Data"))

--- @type AdminPanel_CommandBar_Client_Control
local Control = require(_client:FindFirstChild("Control"))

--- @type AdminPanel_CommandBar_Client_Cursor
local Cursor = require(_client:FindFirstChild("Cursor"))

--- @type AdminPanel_CommandBar_Client_Selection
local Selection = require(_client:FindFirstChild("Selection"))

--- @type AdminPanel_CommandBar_Client_Suggestions
local Suggestions = require(_client:FindFirstChild("Suggestions"))

--- @type AdminPanel_CommandBar_Client_Input
local Input = require(_client:FindFirstChild("Input"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type AdminPanel_CommandBar_ClientShared
local shared = {

	--[[ State ]]

	state = {
		commandBar = nil,

		elems = {},
		prefabs = {},
		connections = {},

		commands = {},
		aliases = {},

		dictionaries = {
			--- @type AdminPanel_CommandBar_DictionaryEntry
			["boolean"] = {
				Protected = true,
				[1] = "true",
				[2] = "false",
			},
		},
		dataVersions = {
			["Commands-Client"] = 0,
			["Dictionaries-Client"] = 0,

			["Commands-Server"] = 0,
			["Dictionaries-Server"] = 0,
		},

		createdSuggestions = {},
		createdSuggestionsSeparators = {},
		defContainerPos = nil,

		autoCompletePhrase = nil,
		autoCompleteType = nil,
		autoCompleteTable = nil,
		suggestionsWindowStart = nil,

		activeArgIndex = nil,

		commandHistory = {},
		commandHistoryIndex = nil,
		commandHistoryToSend = {},
		commandHistorySendScheduled = false,

		createdOutputTexts = {},

		playerPermissionLevel = nil,
	},

	--[[ Helpers ]]

	c_utils = c_utils,
	utils = utils,

	--[[ Modules ]]

	Bootstrap = Bootstrap,
	Connections = Connections,
	Data = Data,
	Control = Control,
	Cursor = Cursor,
	Selection = Selection,
	Suggestions = Suggestions,
	Input = Input,
}

--[[ Dashboard ]]

local dashboardGui: ScreenGui? = nil

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
	------ INITIALIZATION ------
	----------------------------

	Module._initCommandBar()

	I.OnLoaded(I.Priority.Default, Module._bindTools)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.AdminPanel = {

		--[[ Control ]]

		OpenCommandBar = Module.OpenCommandBar,
		OpenDashboard = Module.OpenDashboard,
		CloseAll = Module.CloseAll,

		--[[ Methods ]]

		GetPermissionLevel = Permissions.GetPermissionLevel,
		CanOpenDashboard = Permissions.CanOpenDashboard,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Init Command Bar

--[[
	Starts the command bar when its gui is exported: its elements, its input and data, its window and its remotes,
	among them the server's signal that the player sent the `/cmd` chat command.
]]
function Module._initCommandBar()
	--[[ Checks ]]

	-- Skip the command bar when its gui isn't exported
	if not I.UserInterface.UI[_settings.COMMAND_BAR_GUI] then
		if I.Env.IsStudio then
			warn(`[{_localName}::{script.Name}]: CommandBar is turned off.`)
		end
		return
	end

	--[[ Sub-Scripts ]]

	Bootstrap.Init(shared)
	Connections.Init(shared)
	Data.Init(shared)
	Control.Init(shared)
	Cursor.Init(shared)
	Selection.Init(shared)
	Suggestions.Init(shared)
	Input.Init(shared)

	--[[ Setup ]]

	Bootstrap.GetElements()
	Bootstrap.CheckPrefixes()
	Bootstrap.ValidateSettings()
	Window.Bind(shared.state.commandBar:FindFirstChild("U_CommandBar", true), _settings.COMMAND_BAR_MIN_SIZE)

	I.OnLoaded(I.Priority.Default, Bootstrap.RetrieveCommandHistory)

	--[[ Connections ]]

	Connections.ConnectPlayersDictUpdate()
	Connections.ConnectCommandBar()
	Connections.ConnectInput()
	Connections.ConnectCursorUpdate()
	Connections.ConnectDataUpdates()

	--[[ Network ]]

	I.Network.GetFunction("_AdminPanel_CommandBar_GetCommandHistory", {})
	I.Network.OnInvoke("_AdminPanel_CommandBar_GetCommandHistory", function()
		return shared.state.commandHistory
	end)

	I.Network.GetEvent("_AdminPanel_CommandBar_PrintToOutput", { "boolean", "string", { Types = { "string", "table" } } })
	I.Network.Fired("_AdminPanel_CommandBar_PrintToOutput", Control.PrintToOutput)

	I.Network.GetEvent("_AdminPanel_CommandBar_ChatCommand", {})
	I.Network.Fired("_AdminPanel_CommandBar_ChatCommand", Control.ToggleCommandBar)
end

--%%%%%%%%%%%%%%%%%%%% Bind Tools

--[[
	Binds the dashboard with its window when its gui is exported, then the keys that open and close the command bar
	(`COMMAND_BAR_KEYS`) and the dashboard (`DASHBOARD_KEYS`).
]]
function Module._bindTools()
	--[[ Dashboard ]]

	dashboardGui = I.UserInterface.UI[_settings.DASHBOARD_GUI]

	-- Bind the dashboard when its gui is exported
	if dashboardGui then
		Rail.Bind(dashboardGui, Module._showResult)
		Window.Bind(dashboardGui:FindFirstChild("U_Dashboard", true), _settings.DASHBOARD_MIN_SIZE)
	elseif I.Env.IsStudio then
		warn(`[{_localName}::{script.Name}]: Dashboard is turned off.`)
	end

	--[[ Keys ]]

	I.S.UserInputService.InputBegan:Connect(Module._onKeyPressed)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Open Command Bar

--[[
	**CLIENT** |
	Opens the command bar when it is on (its gui is exported) and closed.
]]
function Module.OpenCommandBar()
	--[[ Checks ]]

	-- Check if the command bar is on and closed
	if not shared.state.commandBar or shared.state.commandBar.Enabled then
		return
	end

	--[[ Opening ]]

	Control.ToggleCommandBar()
end

--%%%%%%%%%%%%%%%%%%%% Open Dashboard

--[[
	**CLIENT** |
	Opens the dashboard on the players (`"Players"`), the modules (`"Modules"`) or where it was left (nil), for a player
	who may open it, once it is on (its gui is exported and bound when the player has loaded).
]]
function Module.OpenDashboard(page: string?)
	--[[ Checks ]]

	-- Check if the dashboard is on and the player may open it
	if not dashboardGui or not Permissions.CanOpenDashboard(I.Env.LocalPlayer) then
		return
	end

	--[[ Opening ]]

	Rail.Open(page)
end

--%%%%%%%%%%%%%%%%%%%% Close All

--[[
	**CLIENT** |
	Closes the command bar and the dashboard, each when it is on.
]]
function Module.CloseAll()
	--[[ Closing ]]

	-- Close the dashboard when it is on
	if dashboardGui then
		Rail.Close()
	end

	-- Close the command bar when it is on and open
	if shared.state.commandBar and shared.state.commandBar.Enabled then
		Control.ToggleCommandBar()
	end
end

--%%%%%%%%%%%%%%%%%%%% On Key Pressed

--[[
	Opens or closes the command bar on `COMMAND_BAR_KEYS` and the dashboard on `DASHBOARD_KEYS`, outside any text box
	but the command bar's own, so its keys also close it while typing.
]]
function Module._onKeyPressed(input: InputObject, gameProcessedEvent: boolean)
	--[[ Local Variables ]]

	local inputBox: TextBox? = shared.state.elems["InputBox"]
	local inCommandBar: boolean = inputBox ~= nil and I.S.UserInputService:GetFocusedTextBox() == inputBox

	--[[ Checks ]]

	-- Skip keys typed into another text box, such as the chat
	if gameProcessedEvent and not inCommandBar then
		return
	end

	--[[ Command Bar ]]

	if shared.state.commandBar and Module._isCombo(input, _settings.COMMAND_BAR_KEYS) then
		Control.ToggleCommandBar()
		return
	end

	--[[ Dashboard ]]

	-- Leave the dashboard's keys to what is typed in the command bar
	if inCommandBar or not dashboardGui or not Module._isCombo(input, _settings.DASHBOARD_KEYS) then
		return
	end

	if dashboardGui.Enabled then
		Rail.Close()
	else
		Module.OpenDashboard()
	end
end

--%%%%%%%%%%%%%%%%%%%% Is Combo

--[[
	Returns whether a pressed key finishes a combination: it is the combination's last key, and the others are held.
]]
--- @return boolean
function Module._isCombo(input: InputObject, keys: { Enum.KeyCode })
	--[[ Checks ]]

	-- Check if it is the combination's last key
	if input.KeyCode ~= keys[#keys] then
		return false
	end

	--[[ Held Keys ]]

	for index: number = 1, #keys - 1 do
		-- Check if the earlier key is held
		if not I.S.UserInputService:IsKeyDown(keys[index]) then
			return false
		end
	end

	--[[ Returning ]]

	return true
end

--%%%%%%%%%%%%%%%%%%%% Show Result

--[[
	Shows what a dashboard block did: a line in the command bar's output, and a Roblox notification.
]]
function Module._showResult(success: boolean, label: string, message: string)
	--[[ Output ]]

	-- Log it in the command bar when it is on
	if shared.state.commandBar then
		Control.PrintToOutput(success, label, message)
	end

	--[[ Notification ]]

	local _notified: boolean = pcall(I.S.StarterGui.SetCore, I.S.StarterGui, "SendNotification", {
		Title = label,
		Text = message,
		Duration = 3,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
