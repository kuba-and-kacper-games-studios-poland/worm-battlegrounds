--- @class Group_Controller_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% General

	-- List of groups and their rewards.
	--- @type { [string]: Group_Controller_RewardTableEntry }
	REWARDS_BY_GROUP = {

		--[[
			["Default"] = {
				Version = 0,
				Reward = function(_player: Player)
					print("Reward for (Default) Group!")
					return true
				end,
			},
		]]
	},

	--%%%%%%%%%%%%%%%%%%%% Bonus

	-- Group whose members get `GROUP_BONUS`.
	GROUP_NAME = "Default",

	-- Reward bonus for members of `GROUP_NAME` (`0.1` = 10%), applied by the game in `Server.lua`.
	GROUP_BONUS = 0.1,
}
return _settings
