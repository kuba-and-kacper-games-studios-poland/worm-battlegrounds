--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Console"

--- @type Console_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts: Folder = script.Parent:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Binds = require(_scripts:FindFirstChild("Client"):FindFirstChild("Binds")) --- @type Console_Client_Binds
local Hints = require(_scripts:FindFirstChild("Client"):FindFirstChild("Hints")) --- @type Console_Client_Hints
local Selection = require(_scripts:FindFirstChild("Client"):FindFirstChild("Selection")) --- @type Console_Client_Selection

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

	Hints.Init()

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.Console = {

		--[[ Control ]]

		Bind = Binds.Bind,
		Unbind = Binds.Unbind,
		Focus = Selection.Focus,
		Unfocus = Selection.Unfocus,
		SetHome = Selection.SetHome,
		RefreshHints = Hints.RefreshHints,

		--[[ Methods ]]

		GetAction = Binds.GetAction,
		IsAction = Binds.IsAction,
		IsHeld = Binds.IsHeld,
		GetIcon = Hints.GetIcon,
		GetButtonName = Hints.GetButtonName,
		IsPlayStationPad = Hints.IsPlayStationPad,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Hints.Start()
	Selection.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
