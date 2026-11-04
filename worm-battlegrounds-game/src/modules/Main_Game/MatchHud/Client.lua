--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchHud"

--- @type MatchHud_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts: Folder = script.Parent:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Turn = require(_scripts:FindFirstChild("Client"):FindFirstChild("Turn")) --- @type MatchHud_Client_Turn
local Panels = require(_scripts:FindFirstChild("Client"):FindFirstChild("Panels")) --- @type MatchHud_Client_Panels
local LoadoutBar = require(_scripts:FindFirstChild("Client"):FindFirstChild("LoadoutBar")) --- @type MatchHud_Client_LoadoutBar
local Aim = require(_scripts:FindFirstChild("Client"):FindFirstChild("Aim")) --- @type MatchHud_Client_Aim
local KillFeed = require(_scripts:FindFirstChild("Client"):FindFirstChild("KillFeed")) --- @type MatchHud_Client_KillFeed
local TouchControls = require(_scripts:FindFirstChild("Client"):FindFirstChild("TouchControls")) --- @type MatchHud_Client_TouchControls
local Results = require(_scripts:FindFirstChild("Client"):FindFirstChild("Results")) --- @type MatchHud_Client_Results
local TopBar = require(_scripts:FindFirstChild("Client"):FindFirstChild("TopBar")) --- @type MatchHud_Client_TopBar

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

	local gui: ScreenGui = I.UserInterface.UI[_settings.GUI_NAME]
	gui.Enabled = true

	Turn.Start(gui)
	Panels.Start(gui)
	LoadoutBar.Start(gui)
	Aim.Start(gui)
	KillFeed.Start(gui)
	TouchControls.Start(gui)
	Results.Start()
	TopBar.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
