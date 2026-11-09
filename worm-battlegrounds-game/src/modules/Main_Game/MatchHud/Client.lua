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
local Teams = require(_scripts:FindFirstChild("Client"):FindFirstChild("Teams")) --- @type MatchHud_Client_Teams
local Panels = require(_scripts:FindFirstChild("Client"):FindFirstChild("Panels")) --- @type MatchHud_Client_Panels
local LoadoutBar = require(_scripts:FindFirstChild("Client"):FindFirstChild("LoadoutBar")) --- @type MatchHud_Client_LoadoutBar
local Aim = require(_scripts:FindFirstChild("Client"):FindFirstChild("Aim")) --- @type MatchHud_Client_Aim
local KillFeed = require(_scripts:FindFirstChild("Client"):FindFirstChild("KillFeed")) --- @type MatchHud_Client_KillFeed
local TouchControls = require(_scripts:FindFirstChild("Client"):FindFirstChild("TouchControls")) --- @type MatchHud_Client_TouchControls
local Results = require(_scripts:FindFirstChild("Client"):FindFirstChild("Results")) --- @type MatchHud_Client_Results
local TopBar = require(_scripts:FindFirstChild("Client"):FindFirstChild("TopBar")) --- @type MatchHud_Client_TopBar

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ General ]]

local moduleGui: ScreenGui

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

	moduleGui = I.UserInterface.UI[_settings.GUI_NAME]
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refreshShown)
	Module._refreshShown()

	Turn.Start(moduleGui)
	Teams.Start(moduleGui)
	Panels.Start(moduleGui)
	LoadoutBar.Start(moduleGui)
	Aim.Start(moduleGui)
	KillFeed.Start(moduleGui)
	TouchControls.Start(moduleGui)
	Results.Start()
	TopBar.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh Shown

--[[
	Shows the HUD while the player is in the match: always on a match server, and on the Studio map once its lobby
	starts one. The guis that are always on elsewhere (HIDDEN_IN_MATCH) are hidden meanwhile.
]]
function Module._refreshShown()
	--[[ Local Variables ]]

	local inMatch: boolean = I.S.Players.LocalPlayer:GetAttribute("InMatch") == true

	--[[ Applying ]]

	moduleGui.Enabled = inMatch
	for _index: number, guiName: string in ipairs(_settings.HIDDEN_IN_MATCH) do
		I.UserInterface.UI[guiName].Enabled = not inMatch
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
