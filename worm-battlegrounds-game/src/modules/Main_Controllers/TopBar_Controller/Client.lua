--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "TopBar_Controller"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

-- The music button, and the music volume before it muted it
local musicButton = nil --- @type TopBar_Button
local unmutedVolume: number? = nil

-- The music button's icons while the music plays and while it's muted (art/topbar's TopBar_Music, TopBar_MusicOff)
local MUSIC_ICON: string = "rbxassetid://101278000628566"
local MUSIC_OFF_ICON: string = "rbxassetid://117397305535105"

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

	-- In the lobby and in matches; a match adds Leave game after it (MatchHud's top bar)
	musicButton = I.TopBar.AddButton("Left")
	musicButton:SetLayoutOrder(2)
	musicButton:SetCallback(Module._toggleMusic)
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
	Shows the music button's notes while the music plays, and the crossed-out notes while it's muted.
]]
function Module._refreshMusicButton()
	--[[ Applying ]]

	musicButton:SetIcon(if I.PlayerSettings.Get("Music") > 0 then MUSIC_ICON else MUSIC_OFF_ICON)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ###

return {
	_init = Module.Init,
	_start = Module.Start,
}
