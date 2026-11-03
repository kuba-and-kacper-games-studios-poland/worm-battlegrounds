--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "AdminPanel"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

local _dashboard = _scripts:FindFirstChild("Dashboard"):FindFirstChild("Server")
local _commandBar = _scripts:FindFirstChild("CommandBar"):FindFirstChild("Server")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Permissions = require(_scripts:FindFirstChild("Global"):FindFirstChild("Permissions")) --- @type AdminPanel_Global_Permissions

local ChatCommand = require(_commandBar:FindFirstChild("ChatCommand")) --- @type AdminPanel_CommandBar_Server_ChatCommand

local Registry = require(_dashboard:FindFirstChild("Registry")) --- @type AdminPanel_Dashboard_Server_Registry
local Run = require(_dashboard:FindFirstChild("Run")) --- @type AdminPanel_Dashboard_Server_Run
local Defaults = require(_dashboard:FindFirstChild("Defaults")) --- @type AdminPanel_Dashboard_Server_Defaults

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

	Registry.Init()
	Run.Init()
	Defaults.Init()

	ChatCommand.Init()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.AdminPanel = {

		--[[ Methods ]]

		GetPermissionLevel = Permissions.GetPermissionLevel,
		CanOpenDashboard = Permissions.CanOpenDashboard,
	}

	I.AdminPanel_Dashboard = {

		--[[ Control ]]

		Register = Registry.Register,
		Unregister = Registry.Unregister,
		Refresh = Registry.Refresh,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
