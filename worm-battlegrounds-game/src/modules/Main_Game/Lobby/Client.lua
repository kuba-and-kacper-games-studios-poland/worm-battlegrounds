--[[
	Created By: 	Nari
	Edited By: 	HungryN00B
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Lobby"

--- @type Lobby_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _scripts: Folder = script.Parent:FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Stage = require(_scripts:FindFirstChild("Client"):FindFirstChild("Stage")) --- @type Lobby_Client_Stage

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The full-screen widgets open now (one at a time, but a switch closes one before it opens the next)
local fullScreenOpen = {} --- @type { [string]: boolean }

-- The widgets open now that stand in a lobby panel's place (PANEL_WIDGETS)
local panelOpen = {} --- @type { [string]: boolean }

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

	I.Lobby = {

		--[[ Methods ]]

		GetStageSnail = Stage.GetSnail,
	}
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refreshGuis)
	I.Topic.Subscribe("WidgetManager_Opened", function(widgetName: string)
		Module._onWidgetChanged(widgetName, true)
	end)
	I.Topic.Subscribe("WidgetManager_Closed", function(widgetName: string)
		Module._onWidgetChanged(widgetName, false)
	end)
	Module._refreshGuis()
	I.Network.Fired("Lobby_RejoinOffer", Module._onRejoinOffer)
	Stage.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh Guis

--[[
	Shows the lobby's screens, except while the player is in a match (the Studio map plays both on one server) or a
	full-screen widget covers them, or a panel's own while a widget stands in its place, and closes a lobby window
	still open (the custom lobby's) when the match starts.
]]
function Module._refreshGuis()
	--[[ Local Variables ]]

	local inLobby: boolean = not I.S.Players.LocalPlayer:GetAttribute("InMatch")
	local covered: boolean = next(fullScreenOpen) ~= nil
	local replaced = {} --- @type { [string]: boolean }

	--[[ Panels ]]

	for widgetName: string in pairs(panelOpen) do
		for _index: number, guiName: string in ipairs(_settings.PANEL_WIDGETS[widgetName]) do
			replaced[guiName] = true
		end
	end

	--[[ Applying ]]

	for _index: number, guiName: string in ipairs(_settings.LOBBY_GUIS) do
		I.UserInterface.UI[guiName].Enabled = inLobby and not covered and not replaced[guiName]
	end
	if not inLobby then
		I.WidgetManager.CloseCurrent()
	end
end

--%%%%%%%%%%%%%%%%%%%% On Widget Changed

--[[
	Hides the lobby's screens while a full-screen widget (FULL_SCREEN_WIDGETS) is open, or the panel a widget stands in
	for (PANEL_WIDGETS), and brings them back when it closes.
]]
function Module._onWidgetChanged(widgetName: string, opened: boolean)
	--[[ Checks ]]

	-- Check if the widget covers the whole screen or a panel
	if not table.find(_settings.FULL_SCREEN_WIDGETS, widgetName) and not _settings.PANEL_WIDGETS[widgetName] then
		return
	end

	--[[ Saving ]]

	if _settings.PANEL_WIDGETS[widgetName] then
		panelOpen[widgetName] = if opened then true else nil
	else
		fullScreenOpen[widgetName] = if opened then true else nil
	end

	--[[ Applying ]]

	Module._refreshGuis()
end

--%%%%%%%%%%%%%%%%%%%% On Rejoin Offer

--[[
	Asks a player who dropped out of a running match whether to go back to it.
]]
function Module._onRejoinOffer(secondsLeft: number)
	--[[ Asking ]]

	I.WidgetManager.ShowConfirmation(`Rejoin your match? ({math.floor(secondsLeft)} seconds left)`, function()
		I.Network.Fire("Lobby_Rejoin", true)
	end, function()
		I.Network.Fire("Lobby_Rejoin", false)
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
