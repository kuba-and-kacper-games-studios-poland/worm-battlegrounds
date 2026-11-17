--- @class Progression_ServerSettings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Levels

	-- The highest level
	MAX_LEVEL = 100,

	-- Going from level n to n + 1 costs LEVEL_BASE_XP + LEVEL_STEP_XP × n
	LEVEL_BASE_XP = 100,
	LEVEL_STEP_XP = 4,
}

return _settings
