--- @type { [string]: Bots_Genome }
local data = {

	--[[ Hard ]]

	Hard = {
		EnemyDamage = 0.267,
		Knockout = 0.566,
		Focus = 0.445,
		Grudge = 0.171,
		AllyDamage = 0.555,
		AllyKnockout = 3.005,
		SelfDamage = 1.22,
		SelfKnockout = 5.467,
		Ammo = 0.239,
		Walk = 0.1,
		Jetpack = -0.111,
		Edge = 0.126,
		Footing = 0.362,
		Low = 0.584,
		Height = 0.101,
		Exposure = 0.174,
		Crowd = 0.155,
		Threat = 0.1,
		HealBelow = 114,
	},

	--[[ Nightmare ]]

	Nightmare = {
		EnemyDamage = 1.56,
		Knockout = 0.069,
		Focus = 0.206,
		Grudge = 0.087,
		AllyDamage = 1.5,
		AllyKnockout = 1.155,
		SelfDamage = 1.245,
		SelfKnockout = 1.515,
		Ammo = -0.096,
		Walk = 0.096,
		Jetpack = 0.136,
		Edge = 0.241,
		Footing = 0.448,
		Low = 0.225,
		Height = 0.355,
		Exposure = 0.139,
		Crowd = 0.065,
		Threat = -0.107,
		HealBelow = 64,
	},

	--[[ Medium ]]

	Medium = {
		EnemyDamage = 1.085,
		Knockout = 2.957,
		Focus = 0.275,
		Grudge = 0.226,
		AllyDamage = 2.921,
		AllyKnockout = 3.047,
		SelfDamage = 0.441,
		SelfKnockout = 4.498,
		Ammo = 0.052,
		Walk = 0.09,
		Jetpack = -0.005,
		Edge = 0.502,
		Footing = 0.391,
		Low = 0.662,
		Height = 0.238,
		Exposure = 0.09,
		Crowd = 0.18,
		Threat = 0.047,
		HealBelow = 76,
	},

	--[[ Easy ]]

	Easy = {
		EnemyDamage = 1,
		Knockout = 1.2,
		Focus = 0.5,
		Grudge = 0.2,
		AllyDamage = 1.5,
		AllyKnockout = 2,
		SelfDamage = 1.2,
		SelfKnockout = 3,
		Ammo = 0.1,
		Walk = 0.1,
		Jetpack = 0.15,
		Edge = 0.3,
		Footing = 0.5,
		Low = 0.4,
		Height = 0.1,
		Exposure = 0.1,
		Crowd = 0.1,
		Threat = 0.1,
		HealBelow = 90,
	},
}

return data
