--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
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
local Hints = require(_scripts:FindFirstChild("Client"):FindFirstChild("Hints")) --- @type MatchHud_Client_Hints
local BattleIntro = require(_scripts:FindFirstChild("Client"):FindFirstChild("BattleIntro")) --- @type MatchHud_Client_BattleIntro
local KnockedOut = require(_scripts:FindFirstChild("Client"):FindFirstChild("KnockedOut")) --- @type MatchHud_Client_KnockedOut

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

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.MatchHud = {

		--[[ Methods ]]

		HasAimedThisTurn = Aim.HasAimedThisTurn,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	moduleGui = I.UserInterface.UI[_settings.GUI_NAME]
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refreshShown)
	Module._refreshShown()
	I.Topic.Subscribe("Platform_Changed", Module._refreshInsets)
	I.S.GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(Module._refreshInsets)
	Module._refreshInsets()

	Turn.Start(moduleGui)
	Teams.Start(moduleGui)
	Panels.Start(moduleGui)
	LoadoutBar.Start(moduleGui)
	Aim.Start(moduleGui)
	KillFeed.Start(moduleGui)
	TouchControls.Start(moduleGui)
	Results.Start()
	TopBar.Start()
	Hints.Start()
	BattleIntro.Start(moduleGui)
	KnockedOut.Start(moduleGui)
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

--%%%%%%%%%%%%%%%%%%%% Refresh Insets

--[[
	Lays the HUD over the whole screen, out to a phone's very edges (the owner, 2026-11-25: "we need it to be on the
	edges"), its top padded below Roblox's top bar on phones and tablets, where the bar's buttons covered the team
	panels and the turn and wind; consoles keep the TV's safe area.
]]
function Module._refreshInsets()
	--[[ Local Variables ]]

	local platform: string = I.Platform.Current

	--[[ Applying ]]

	moduleGui.ScreenInsets = if platform == "Console" then Enum.ScreenInsets.DeviceSafeInsets else Enum.ScreenInsets.None
	moduleGui:FindFirstChild("U_Inset").PaddingTop = UDim.new(0, if platform == "Mobile" then I.S.GuiService.TopbarInset.Max.Y else 0)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
