--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MatchHud"

--- @type MatchHud_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The music volume to go back to when the player unmutes
local musicBefore: number = 0

-- The top bar buttons, shown only while the player is in the match (the Studio map's lobby shares the server)
local buttons = {} --- @type { TopBar_Button }

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

	local leaveButton = I.TopBar.AddButton("Left") --- @type TopBar_Button
	leaveButton:SetLayoutOrder(2)
	leaveButton:SetText(_settings.LEAVE_TEXT)
	leaveButton:SetCallback(Module._askLeave)

	--[[ Mute Music ]]

	local musicButton = I.TopBar.AddButton("Left") --- @type TopBar_Button
	musicButton:SetLayoutOrder(3)
	musicButton:SetText(_settings.MUSIC_TEXT)
	musicButton:SetCallback(Module._toggleMusic)

	--[[ Connections ]]

	buttons = { leaveButton, musicButton }
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refreshShown)
	Module._refreshShown()
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Refresh Shown

--[[
	Shows the buttons while the player is in the match, and hides them in the Studio map's lobby.
]]
function Module._refreshShown()
	--[[ Applying ]]

	--- @param button TopBar_Button
	for _index: number, button in ipairs(buttons) do
		button.Instance.Visible = I.S.Players.LocalPlayer:GetAttribute("InMatch") == true
	end
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

--%%%%%%%%%%%%%%%%%%%% Toggle Music

--[[
	Turns the music off, or back to the volume it had.
]]
function Module._toggleMusic()
	--[[ Local Variables ]]

	local volume: number = I.PlayerSettings.Get("Music")

	--[[ Saving ]]

	if volume > 0 then
		musicBefore = volume
		I.PlayerSettings.Set("Music", 0)
	else
		I.PlayerSettings.Set("Music", if musicBefore > 0 then musicBefore else 50)
	end
end

return Module
