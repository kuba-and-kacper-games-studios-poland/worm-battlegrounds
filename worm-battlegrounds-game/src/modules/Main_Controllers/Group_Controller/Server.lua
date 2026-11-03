--[[
    Created By:     Nari
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Group_Controller"

--- @type Group_Controller_Settings
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
	----------- DATA -----------
	----------------------------

	--- @type Player_ProfileData
	local _pt = I.Player.ProfileTemplate
	_pt["Group_Controller"] = {
		SettingsRewardsClaimed = {},
	}

	--- @type Player_SessionData
	local _st = I.Player.SessionTemplate
	_st["Group_Controller"] = {}

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic
	I.Topic.Subscribe("Group_DataUpdated", function(player: Player, groupName: string)
		-- One-time reward
		Module._awardSettingsReward(player, groupName)

		-- Bonus for the `GROUP_NAME` group
		if groupName == _settings.GROUP_NAME then
			Module._awardBonus(player, groupName)
		end
	end)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Award Settings Reward

--[[
	Awards player one-time reward from a settings table.
]]
function Module._awardSettingsReward(player: Player, groupName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	--- @type Player_ProfileData
	local profileData = I.Player.GetProfile(player).Data
	local moduleData = profileData["Group_Controller"]

	--[[ Group Settings Reward ]]

	--- @type Group_Controller_RewardTableEntry
	local groupRewardEntry = _settings.REWARDS_BY_GROUP[groupName]

	--[[ Checks ]]

	-- Group reward not set
	if not groupRewardEntry then
		return
	end

	-- Group reward already granted
	if moduleData.SettingsRewardsClaimed[groupName] and moduleData.SettingsRewardsClaimed[groupName] >= groupRewardEntry.Version then
		return
	end

	-- Membership check
	local isMember: boolean = I.Group.IsMember(player, groupName)
	if not isMember then
		return
	end

	--[[ Claiming ]]

	-- Claim before rewarding so an update that arrives while Reward yields is skipped
	local previousVersion: number? = moduleData.SettingsRewardsClaimed[groupName]
	moduleData.SettingsRewardsClaimed[groupName] = groupRewardEntry.Version

	--[[ Rewarding ]]

	local success: boolean
	local result: any | string?
	success, result = pcall(groupRewardEntry.Reward, player)

	-- Give the claim back when the reward failed
	if not success or not result then
		moduleData.SettingsRewardsClaimed[groupName] = previousVersion

		if not success then
			warn(`[{_localName}::{script.Name}]: Failed to grant one-time reward for ({groupName}) Group! - ({result})`)
		end
	end
end

--%%%%%%%%%%%%%%%%%%%% Award Bonus

--[[
	Works out the player's group bonus: `GROUP_BONUS` while they are a member of `GROUP_NAME`, `0` otherwise.
	Each game applies it at the `#TODO` (a currency multiplier or anything else).
]]
function Module._awardBonus(player: Player, groupName: string)
	-- Check if player is valid | SERVER
	if not I.Player.Valid(player) then
		return
	end

	--[[ Data ]]

	local isMember: boolean = I.Group.IsMember(player, groupName) == true

	--[[ Calculating ]]

	local _groupBonus: number = if isMember then _settings.GROUP_BONUS else 0

	--[[ Rewarding ]]

	-- #TODO Apply `_groupBonus`
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
