--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "BGM_Controller"

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

--[[ Music ]]

local musicSound: Sound?
local musicName: string?

--[[ Ambient ]]

local ambientSound: Sound?
local ambientName: string?

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

	I.OnLoaded(I.Priority.Default, Module._playStartTracks)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.BGM_Controller = {

		--[[ Control ]]

		Play = Module.Play,
		Stop = Module.Stop,
		SetAmbient = Module.SetAmbient,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization

--%%%%%%%%%%%%%%%%%%%% Play Start Tracks

--[[
	Starts the `BGM` music and the `Ambient` sound once the player has loaded,
	unless another module already chose them.
]]
function Module._playStartTracks()
	--[[ Music ]]

	-- Skip when another module already chose the music
	if not musicName then
		Module.Play("BGM")
	end

	--[[ Ambient ]]

	-- Skip when another module already chose the ambient sound
	if not ambientName then
		Module.SetAmbient("Ambient")
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play

--[[
	**CLIENT** |
	Switches the music to `trackName` (a `SoundsList` name), crossfading over `fadeTime` seconds.
]]
function Module.Play(trackName: string, fadeTime: number?)
	--[[ Checks ]]

	-- Skip when that track is already playing
	if trackName == musicName then
		return
	end

	--[[ Playing ]]

	local newSound: Sound? = Module._playLooped(trackName)

	-- Keep the current music when the track couldn't play
	if not newSound then
		return
	end

	--[[ Fading ]]

	Module._crossfade(musicSound, newSound, fadeTime or 0)

	--[[ Saving ]]

	musicSound = newSound
	musicName = trackName
end

--%%%%%%%%%%%%%%%%%%%% Stop

--[[
	**CLIENT** |
	Fades the music out over `fadeTime` seconds and stops it.
]]
function Module.Stop(fadeTime: number?)
	--[[ Fading ]]

	Module._crossfade(musicSound, nil, fadeTime or 0)

	--[[ Saving ]]

	musicSound = nil
	musicName = nil
end

--%%%%%%%%%%%%%%%%%%%% Set Ambient

--[[
	**CLIENT** |
	Switches the ambient sound to `name` (a `SoundsList` name), or stops it when `name` is nil,
	crossfading over `fadeTime` seconds.
]]
function Module.SetAmbient(name: string?, fadeTime: number?)
	--[[ Checks ]]

	-- Skip when that ambient sound is already playing
	if name == ambientName then
		return
	end

	--[[ Playing ]]

	local newSound: Sound? = if name then Module._playLooped(name) else nil

	-- Keep the current ambient sound when the new one couldn't play
	if name and not newSound then
		return
	end

	--[[ Fading ]]

	Module._crossfade(ambientSound, newSound, fadeTime or 0)

	--[[ Saving ]]

	ambientSound = newSound
	ambientName = name
end

--%%%%%%%%%%%%%%%%%%%% Crossfade

--[[
	Fades `newSound` in to its volume and `oldSound` out over `fadeTime` seconds,
	then destroys `oldSound`.
]]
function Module._crossfade(oldSound: Sound?, newSound: Sound?, fadeTime: number)
	--[[ Local Variables ]]

	local Fade_TweenInfo: TweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)

	--[[ Fading In ]]

	if newSound then
		local targetVolume: number = newSound.Volume
		newSound.Volume = 0

		local FadeIn_TweenGoal = { Volume = targetVolume }
		local FadeIn_Tween: Tween = I.S.TweenService:Create(newSound, Fade_TweenInfo, FadeIn_TweenGoal)
		FadeIn_Tween:Play()
	end

	--[[ Fading Out ]]

	if oldSound then
		local FadeOut_TweenGoal = { Volume = 0 }
		local FadeOut_Tween: Tween = I.S.TweenService:Create(oldSound, Fade_TweenInfo, FadeOut_TweenGoal)
		FadeOut_Tween:Play()

		-- Destroy the old sound once it is silent
		FadeOut_Tween.Completed:Once(function()
			oldSound:Destroy()
		end)
	end
end

--%%%%%%%%%%%%%%%%%%%% Play Looped

--[[
	Starts a looped sound in the `Music` sound group at the music volume.
]]
--- @return Sound?
function Module._playLooped(soundName: string)
	return I.Sound.Play({
		Name = soundName,
		Volume = 0.5,
		SoundGroup = "Music",

		AutoPlay = true,
		AutoRemove = false,
		Looped = true,
	})
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
