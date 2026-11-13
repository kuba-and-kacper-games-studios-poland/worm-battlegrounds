--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchHud"

--- @type MatchHud_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The Leave game button, shown only while the player is in the match (the Studio map's lobby shares the server)
local leaveButton = nil --- @type TopBar_Button

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

--- @class MatchHud_Client_TopBar
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	--[[ Leave Game ]]

	-- After Settings and the music button (TopBar_Controller's)
	leaveButton = I.TopBar.AddButton("Left")
	leaveButton:SetLayoutOrder(3)
	leaveButton:SetIcon(_settings.LEAVE_ICON)
	leaveButton:SetCallback(Module._askLeave)

	--[[ Connections ]]

	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refreshShown)
	Module._refreshShown()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh Shown

--[[
	Shows Leave game while the player is in the match, and hides it in the Studio map's lobby.
]]
function Module._refreshShown()
	--[[ Applying ]]

	leaveButton.Instance.Visible = I.S.Players.LocalPlayer:GetAttribute("InMatch") == true
end

--%%%%%%%%%%%%%%%%%%%% Ask Leave

--[[
	Asks first, then leaves the match: a snail still in play dies as a leaver.
]]
function Module._askLeave()
	--[[ Asking ]]

	I.WidgetManager.ShowConfirmation(_settings.LEAVE_QUESTION, Module._leave)
end

--%%%%%%%%%%%%%%%%%%%% Leave

--[[
	Asks the server to take the player back to the lobby.
]]
function Module._leave()
	--[[ Sending ]]

	I.Network.Fire("Match_Leave")
end

return Module
