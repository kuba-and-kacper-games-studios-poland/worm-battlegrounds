--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "TopBar_Controller"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The lobby's music button, and the music volume before it muted it
local musicButton = nil --- @type TopBar_Button
local unmutedVolume: number? = nil

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

	--%%%%%%%%%%%%%%%%%%%% Left Buttons

	--[[ Settings ]]

	--- @type TopBar_Button
	local settingsButton = I.TopBar.AddButton("Left")
	settingsButton:SetLayoutOrder(1)
	settingsButton:SetIcon("rbxassetid://123765846716976", 0.6)
	settingsButton:SetCallback(function()
		I.WidgetManager.Toggle(I.Settings["Settings"].GUI_NAME)
	end)

	--[[ Music ]]

	-- The lobby's; a match has its own beside Leave game (MatchHud's top bar)
	musicButton = I.TopBar.AddButton("Left")
	musicButton:SetLayoutOrder(2)
	musicButton:SetCallback(Module._toggleMusic)
	I.S.Players.LocalPlayer:GetAttributeChangedSignal("InMatch"):Connect(Module._refreshMusicButton)
	Module._refreshMusicButton()
	I.OnLoaded(I.Priority.Default, function()
		I.Replicator.GetFolder("Settings"):GetAttributeChangedSignal("Music"):Connect(Module._refreshMusicButton)
		Module._refreshMusicButton()
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Toggle Music

--[[
	Mutes the music (its volume setting to 0), or brings it back to the volume it had before, or its default.
]]
function Module._toggleMusic()
	--[[ Local Variables ]]

	local volume: number = I.PlayerSettings.Get("Music")

	--[[ Saving ]]

	if volume > 0 then
		unmutedVolume = volume
		I.PlayerSettings.Set("Music", 0)
	else
		I.PlayerSettings.Set("Music", unmutedVolume or I.Settings["Settings"].SETTINGS.Music.Default)
	end
end

--%%%%%%%%%%%%%%%%%%%% Refresh Music Button

--[[
	Shows the music button outside a match, reading Mute music while it plays and Play music while it's muted.
]]
function Module._refreshMusicButton()
	--[[ Applying ]]

	musicButton.Instance.Visible = I.S.Players.LocalPlayer:GetAttribute("InMatch") ~= true
	musicButton:SetText(if I.PlayerSettings.Get("Music") > 0 then "Mute music" else "Play music")
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ###

return {
	_init = Module.Init,
	_start = Module.Start,
}
