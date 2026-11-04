--- @class Arsenal_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Damage

	-- What a shiny copy multiplies its damage by (whether shiny keeps a boost is still asked on the wiki: set 1 if not)
	SHINY_DAMAGE_MULTIPLIER = 1.05,

	--%%%%%%%%%%%%%%%%%%%% Knockback

	-- The speed each knockback class throws a worm at, in studs per second: a first proposal to tune
	--- @type { [string]: number }
	KNOCKBACK = { Small = 20, Medium = 45, High = 70, VeryHigh = 95, Extreme = 130 },
}

return _settings
