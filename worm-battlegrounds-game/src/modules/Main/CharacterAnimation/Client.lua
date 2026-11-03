--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "CharacterAnimation"

--[[ Animations ]]

--- @type { [string]: AnimationTrack }
local loadedAnimations = {}

-- How many times each animation was played, so a scheduled fade-out skips a track played again since
--- @type { [string]: number }
local playCounts = {}

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

	I.G_Player.OnCharacterRemoving(I.Priority.Default, Module._clearLoadedAnimations)

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("CharacterAnimation_PlayAnimation", { "string", { Type = "table", Optional = true } })
	I.Network.Fired("CharacterAnimation_PlayAnimation", Module.PlayAnimation)

	I.Network.GetEvent("CharacterAnimation_StopAnimation", { "string", { Type = "number", Optional = true } })
	I.Network.Fired("CharacterAnimation_StopAnimation", Module.StopAnimation)

	I.Network.GetEvent("CharacterAnimation_StopAllAnimations", { { Type = "number", Optional = true } })
	I.Network.Fired("CharacterAnimation_StopAllAnimations", Module.StopAllAnimations)

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.CharacterAnimation = {

		--[[ Control ]]

		PreloadAnimation = Module.PreloadAnimation,

		PlayAnimation = Module.PlayAnimation,
		StopAnimation = Module.StopAnimation,
		StopAllAnimations = Module.StopAllAnimations,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Preload Animation

--[[
	**CLIENT** |
	Preloads animation assets asynchronously.
]]
function Module.PreloadAnimation(animationIds: { string })
	task.spawn(function()
		pcall(function()
			--[[ Creating ]]

			local animations: { Animation } = {}
			for _, animationId: string in ipairs(animationIds) do
				table.insert(
					animations,
					I.Create("Animation")({
						AnimationId = animationId,
					})
				)
			end

			--[[ Pre-loading ]]

			I.S.ContentProvider:PreloadAsync(animations)
		end)
	end)
end

--%%%%%%%%%%%%%%%%%%%% Play Animation

--[[
	Loads animation to character animator and plays it with provided settings.
	`autoPlay` defaults to true; pass false to return the track without playing it.
]]
--- @param animationSettings CharacterAnimation_AnimationSettings?
--- @return AnimationTrack
function Module.PlayAnimation(animationId: string, animationSettings, autoPlay: boolean?)
	if autoPlay == nil then
		autoPlay = true
	end

	--[[ Getting Animator ]]

	local character: Model = I.Env.LocalPlayer.Character
	local humanoid: Humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animator: Animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end

	--[[ Creating and Loading Animation ]]

	if not loadedAnimations[animationId] then
		-- Creating
		local newAnim: Animation = Instance.new("Animation")
		newAnim.AnimationId = animationId

		-- Saving
		loadedAnimations[animationId] = animator:LoadAnimation(newAnim)
	end

	--[[ Getting Animation Track ]]

	local animTrack: AnimationTrack? = loadedAnimations[animationId]
	if not animTrack then
		return
	end

	--[[ Local Variables ]]

	local fadeInTime: number = animationSettings and animationSettings.FadeInTime or 0.1

	--[[ Playing Check ]]

	if autoPlay and animTrack.IsPlaying then
		if not animationSettings then
			return animTrack
		end

		-- Freeze the playing track and fade it out beside a fresh one, so the pose blends instead of jumping to the start
		local oldTrack: AnimationTrack = animTrack
		oldTrack:AdjustSpeed(0)
		oldTrack:Stop(fadeInTime)
		oldTrack.Ended:Once(function()
			oldTrack:Destroy()
		end)

		animTrack = animator:LoadAnimation(oldTrack.Animation)
		loadedAnimations[animationId] = animTrack
	end

	--[[ Updating Properties ]]

	if animationSettings then
		if animationSettings.Looped ~= nil then
			animTrack.Looped = animationSettings.Looped
		end

		if animationSettings.Priority ~= nil then
			animTrack.Priority = animationSettings.Priority
		end
	end

	--[[ Playing ]]

	if autoPlay then
		animTrack:Play(fadeInTime)
		playCounts[animationId] = (playCounts[animationId] or 0) + 1
	end

	--[[ Play Properties Update ]]

	if animationSettings then
		if animationSettings.TimePosition ~= nil then
			animTrack.TimePosition = animationSettings.TimePosition
		end

		if animationSettings.Speed ~= nil then
			animTrack:AdjustSpeed(animationSettings.Speed)
		end
	end

	--[[ Fading Out ]]

	-- Freeze the track at FadeOutAt and fade it out into the animations under it
	if autoPlay and animationSettings and animationSettings.FadeOutAt ~= nil then
		local playCount: number = playCounts[animationId]
		local delayTime: number = (animationSettings.FadeOutAt - animTrack.TimePosition) / animTrack.Speed

		task.delay(delayTime, function()
			-- Skip a track played again or stopped since
			if playCounts[animationId] ~= playCount or not animTrack.IsPlaying then
				return
			end

			animTrack:AdjustSpeed(0)
			animTrack:Stop(animationSettings.FadeOutTime or 0.1)
		end)
	end

	return animTrack
end

--%%%%%%%%%%%%%%%%%%%% Stop Animation

--[[
	Stops animation track indexed under given `animationId`.
]]
function Module.StopAnimation(animationId: string, fadeTime: number?)
	local animTrack: AnimationTrack? = loadedAnimations[animationId]
	if animTrack and animTrack.IsPlaying then
		animTrack:Stop(fadeTime or 0.1)
	end
end

--%%%%%%%%%%%%%%%%%%%% Stop All Animations

--[[
	Stops every loaded animation track that is playing.
]]
function Module.StopAllAnimations(fadeTime: number?)
	--[[ Stopping ]]

	for _animationId: string, animTrack: AnimationTrack in pairs(loadedAnimations) do
		-- Skip tracks that are not playing
		if not animTrack.IsPlaying then
			continue
		end

		animTrack:Stop(fadeTime or 0.1)
	end
end

--%%%%%%%%%%%%%%%%%%%% Clear Loaded Animation

--[[
	Destroys all loaded animation tracks.
]]
function Module._clearLoadedAnimations()
	--[[ Saving Table Copy ]]

	--- @type { [string]: AnimationTrack }
	local tableCopy = loadedAnimations
	loadedAnimations = {}

	--[[ Clearing All Entries ]]

	for _animationId: string, animTrack: AnimationTrack in pairs(tableCopy) do
		animTrack:Destroy()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
