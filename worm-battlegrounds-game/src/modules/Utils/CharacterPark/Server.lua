--[[
	Created By: 	Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "CharacterPark"

--- @type CharacterPark_Settings
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

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	I.G_Player.OnCharacterAdded(I.Priority.Default, Module._park)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Player Control

--%%%%%%%%%%%%%%%%%%%% Park

--[[
	Anchors a new avatar at PARK_POSITION, since players play as worms, not as their avatars. It runs as soon as the
	avatar spawns, before the player counts as loaded.
]]
function Module._park(_player: Player, character: Model)
	--[[ Data ]]

	local root: BasePart? = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	--[[ Parking ]]

	root.Anchored = true
	character:PivotTo(CFrame.new(_settings.PARK_POSITION))
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
