--[[
    Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

local _commandBar = _scripts:FindFirstChild("CommandBar")
local _helpers = _commandBar:FindFirstChild("Helpers")
local _global = _commandBar:FindFirstChild("Global")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

--[[ Helpers ]]

--- @type AdminPanel_CommandBar_Defaults
local commandDefaults = require(_helpers:FindFirstChild("Defaults"))

--- @type AdminPanel_CommandBar_Utils
local utils = require(_helpers:FindFirstChild("Utils"))

local LibraryTests = require(_helpers:FindFirstChild("LibraryTests")) --- @type AdminPanel_CommandBar_LibraryTests

--[[ Admin Panel ]]

local Permissions = require(_scripts:FindFirstChild("Global"):FindFirstChild("Permissions")) --- @type AdminPanel_Global_Permissions

--[[ Command Bar ]]

--- @type AdminPanel_CommandBar_Global_Messaging
local Messaging = require(_global:FindFirstChild("Messaging"))

--- @type AdminPanel_CommandBar_Global_History
local History = require(_global:FindFirstChild("History"))

--- @type AdminPanel_CommandBar_Global_Run
local Run = require(_global:FindFirstChild("Run"))

--- @type AdminPanel_CommandBar_Global_Register
local Register = require(_global:FindFirstChild("Register"))

--- @type AdminPanel_CommandBar_Global_Dictionary
local Dictionary = require(_global:FindFirstChild("Dictionary"))

--- @type AdminPanel_CommandBar_Global_Methods
local Methods = require(_global:FindFirstChild("Methods"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--- @type AdminPanel_CommandBar_GlobalShared
local shared = {

	--[[ State ]]

	state = {
		commands = {},
		argsDict = {},
		callbacks = {},
		aliases = {},

		commandsCache = {},
		dictLevels = {},
	},

	--[[ Helpers ]]

	commandDefaults = commandDefaults,
	utils = utils,

	--[[ Modules ]]

	Messaging = Messaging,
	History = History,
	Run = Run,
	Register = Register,
	Dictionary = Dictionary,
	Methods = Methods,

	--[[ Admin Panel ]]

	Permissions = Permissions,
}

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
	----------- DATA -----------
	----------------------------

	if I.Env.IsServer then
		--- @type Player_ProfileData
		local _pt = I.Player.ProfileTemplate
		_pt["AdminPanel"] = {
			CommandHistory = nil, --- @type { string }
		}
	end

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	--[[ Sub-Scripts ]]

	Messaging.Init(shared)
	History.Init(shared)
	Run.Init(shared)
	Register.Init(shared)
	Dictionary.Init(shared)
	Methods.Init(shared)

	--[[ Server Setup ]]

	if I.Env.IsServer then
		task.spawn(function()
			Messaging.ListenForGlobalCommands()
		end)

		I.G_Player.OnPlayerRemoving(I.Priority.Late, function(player: Player)
			Dictionary.RemoveDictionariesBoundToPlayer(player)
		end)
	end

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	if I.Env.IsServer then
		--[[ Running ]]

		I.Network.GetFunction("_AdminPanel_CommandBar_Run", { "Player", "string", { Type = "table" } }, { RateLimit = 10, Per = 1 })
		I.Network.OnInvoke("_AdminPanel_CommandBar_Run", Run.RunCommandServer)

		I.Network.GetFunction("_AdminPanel_CommandBar_RunGlobal", { "Player", "string", { Type = "table" } }, { RateLimit = 5, Per = 1 })
		I.Network.OnInvoke("_AdminPanel_CommandBar_RunGlobal", Run.RunCommandGlobal)

		--[[ Data ]]

		I.Network.GetFunction("_AdminPanel_CommandBar_GetCommands", { "Player" }, { RateLimit = 5, Per = 1 })
		I.Network.OnInvoke("_AdminPanel_CommandBar_GetCommands", Methods.GetCommands)

		I.Network.GetFunction("_AdminPanel_CommandBar_GetDictionaries", { "Player" }, { RateLimit = 5, Per = 1 })
		I.Network.OnInvoke("_AdminPanel_CommandBar_GetDictionaries", Methods.GetDictionaries)

		--[[ Command History ]]

		I.Network.GetEvent("_AdminPanel_CommandBar_UpdateCommandHistory", { "Player", { Type = "table" } }, { RateLimit = 5, Per = 1 })
		I.Network.Fired("_AdminPanel_CommandBar_UpdateCommandHistory", History.UpdatePlayerCommandHistory)

		I.Network.GetFunction("_AdminPanel_CommandBar_GetCommandHistory", { "Player" }, { RateLimit = 5, Per = 1 })
		I.Network.OnInvoke("_AdminPanel_CommandBar_GetCommandHistory", History.GetPlayerCommandHistory)

		--[[ Other ]]

		I.Network.GetEvent("_AdminPanel_CommandBar_PrintToOutput")
	end

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.AdminPanel_CommandBar = {

		--[[ Running ]]

		RunCommand = Run.RunCommand,

		--[[ Control ]]

		Register = Register.Register,
		Unregister = Register.Unregister,

		SetDictionary = Dictionary.SetDictionary,
		UpdateDictionary = Dictionary.UpdateDictionary,

		--[[ Methods ]]

		GetData = Methods.GetData,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	commandDefaults.Init()
	LibraryTests.Init()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
