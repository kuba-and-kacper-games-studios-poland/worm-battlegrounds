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
	Anchors a new avatar at PARK_POSITION and hides it, with its name, since players play as worms, not as their
	avatars. It runs as soon as the avatar spawns, before the player counts as loaded.
]]
function Module._park(_player: Player, character: Model)
	--[[ Data ]]

	local root: BasePart? = character:FindFirstChild("HumanoidRootPart")
	local humanoid: Humanoid? = character:FindFirstChildOfClass("Humanoid")
	if not root then
		return
	end

	--[[ Parking ]]

	root.Anchored = true
	character:PivotTo(CFrame.new(_settings.PARK_POSITION))

	--[[ Hiding ]]

	-- Roblox's camera still looks at the avatar until a game camera takes over (the match's waiting screen)
	I.HideOnPlay.Hide({ character })
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end

	-- Clothes, hats and the face load after the avatar spawns
	character.DescendantAdded:Connect(Module._hideAdded)
end

--%%%%%%%%%%%%%%%%%%%% Hide Added

--[[
	Hides a part or a picture added to a parked avatar.
]]
function Module._hideAdded(instance: Instance)
	--[[ Checks ]]

	-- Skip what can't be seen (welds, attachments, scripts)
	if not instance:IsA("BasePart") and not instance:IsA("Decal") then
		return
	end

	--[[ Hiding ]]

	I.HideOnPlay.Hide({ instance })
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
