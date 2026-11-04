--- @class Progression_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Levels

	-- The highest level
	MAX_LEVEL = 100,

	-- Going from level n to n + 1 costs LEVEL_BASE_XP + LEVEL_STEP_XP × n
	LEVEL_BASE_XP = 100,
	LEVEL_STEP_XP = 4,

	--%%%%%%%%%%%%%%%%%%%% Rewards

	-- The item each level gives when it's reached
	--- @type { [number]: string }
	LEVEL_REWARDS = {
		[25] = "Skin_Prisoner",
		[50] = "Skin_FbiAgent",
		[100] = "Skin_Wizard",
	},
}

return _settings
