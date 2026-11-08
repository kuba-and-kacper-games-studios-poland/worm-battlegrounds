--- @class Arsenal_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% Damage

	-- What a shiny copy multiplies its damage by (whether shiny keeps a boost is still asked on the wiki: set 1 if not)
	SHINY_DAMAGE_MULTIPLIER = 1.05,

	--%%%%%%%%%%%%%%%%%%%% Knockback

	-- The speed each knockback class throws a snail at, in studs per second: a first proposal to tune
	--- @type { [string]: number }
	KNOCKBACK = { Small = 20, Medium = 45, High = 70, VeryHigh = 95, Extreme = 130 },

	--%%%%%%%%%%%%%%%%%%%% Models

	-- Shots a weapon's burst sends out (the projectile part's name) that may have a model in Assets/Arsenal/Projectiles
	--- @type { string }
	BURST_SHOTS = { "Worm" },
}

return _settings
