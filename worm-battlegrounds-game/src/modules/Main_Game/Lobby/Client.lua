--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Lobby"

--- @type Lobby_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

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

	for _index: number, guiName: string in ipairs(_settings.LOBBY_GUIS) do
		I.UserInterface.UI[guiName].Enabled = true
	end
	I.Network.Fired("Lobby_RejoinOffer", Module._onRejoinOffer)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

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
