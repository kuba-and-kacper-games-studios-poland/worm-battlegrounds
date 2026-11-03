--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "CharacterAnimation"

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
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("CharacterAnimation_PlayAnimation")
	I.Network.GetEvent("CharacterAnimation_StopAnimation")
	I.Network.GetEvent("CharacterAnimation_StopAllAnimations")

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	I.CharacterAnimation = {

		--[[ Control ]]

		PlayAnimation = Module.PlayAnimation,
		StopAnimation = Module.StopAnimation,
		StopAllAnimations = Module.StopAllAnimations,
	}
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Play Animation

--[[
	Requests animation playback on the player's owning client.
]]
--- @param animationSettings CharacterAnimation_AnimationSettings?
function Module.PlayAnimation(player: Player, animationId: string, animationSettings)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	I.Network.Fire("CharacterAnimation_PlayAnimation", player, animationId, animationSettings)
end

--%%%%%%%%%%%%%%%%%%%% Stop Animation

--[[
	Requests animation stop on the player's owning client.
]]
function Module.StopAnimation(player: Player, animationId: string, fadeTime: number?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	I.Network.Fire("CharacterAnimation_StopAnimation", player, animationId, fadeTime)
end

--%%%%%%%%%%%%%%%%%%%% Stop All Animations

--[[
	Requests a stop of every playing animation on the player's owning client.
]]
function Module.StopAllAnimations(player: Player, fadeTime: number?)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Sending ]]

	I.Network.Fire("CharacterAnimation_StopAllAnimations", player, fadeTime)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
