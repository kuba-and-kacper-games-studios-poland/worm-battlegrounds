--[[
	Created By: 	Nari
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

	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refreshGuis)
	Module._refreshGuis()
	I.Network.Fired("Lobby_RejoinOffer", Module._onRejoinOffer)
	Stage.Start()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh Guis

--[[
	Shows the lobby's screens, except while the player is in a match (the Studio map plays both on one server).
]]
function Module._refreshGuis()
	--[[ Local Variables ]]

	local inLobby: boolean = not I.S.Players.LocalPlayer:GetAttribute("InMatch")

	--[[ Applying ]]

	for _index: number, guiName: string in ipairs(_settings.LOBBY_GUIS) do
		I.UserInterface.UI[guiName].Enabled = inLobby
	end
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
