--- @type { [string]: Bots_Genome }
local data = {

	--[[ Hard ]]

	Hard = {
		EnemyDamage = 0.891,
		Knockout = 0.072,
		Focus = 0.089,
		Grudge = 0.159,
		Pressure = 0.049,
		AllyDamage = -0.061,
		AllyKnockout = 8.864,
		SelfDamage = 0.544,
		SelfKnockout = 5.837,
		Ammo = 0.461,
		Walk = 0.087,
		Jetpack = -0.211,
		Edge = 0.084,
		Footing = 0.496,
		Low = 0.821,
		Height = 0.108,
		Cover = -0.037,
		Exposure = 0.331,
		Crowd = 0.015,
		Threat = -0.351,
		HealBelow = 106,
	},

	--[[ Nightmare ]]

	Nightmare = {
		EnemyDamage = 0.993,
		Knockout = 0.221,
		Focus = 0.157,
		Grudge = 0.353,
		Pressure = 0.057,
		AllyDamage = 1.328,
		AllyKnockout = 0.747,
		SelfDamage = 0.805,
		SelfKnockout = 3.356,
		Ammo = 0.018,
		Walk = -0.625,
		Jetpack = 0.137,
		Edge = 0.216,
		Footing = 0.509,
		Low = 0.321,
		Height = -0.003,
		Cover = 0.229,
		Exposure = -0.138,
		Crowd = -0,
		Threat = 0.036,
		HealBelow = 76,
	},

	--[[ Medium ]]

	Medium = {
		EnemyDamage = 1.212,
		Knockout = 2.076,
		Focus = 0.656,
		Grudge = 0.062,
		Pressure = -0.112,
		AllyDamage = 2.645,
		AllyKnockout = 2.241,
		SelfDamage = 0.131,
		SelfKnockout = 1.648,
		Ammo = 0.122,
		Walk = 0.309,
		Jetpack = -0.365,
		Edge = 0.598,
		Footing = 0.279,
		Low = 2.453,
		Height = 0.326,
		Cover = 0.151,
		Exposure = 0.209,
		Crowd = 0.196,
		Threat = -0.087,
		HealBelow = 48,
	},

	--[[ Easy ]]

	Easy = {
		EnemyDamage = 2.477,
		Knockout = 1.217,
		Focus = 0.261,
		Grudge = 0.312,
		Pressure = 0.072,
		AllyDamage = 0.529,
		AllyKnockout = 2.207,
		SelfDamage = 0.743,
		SelfKnockout = 3.021,
		Ammo = -0.263,
		Walk = 0.154,
		Jetpack = 0.287,
		Edge = 0.211,
		Footing = 0.27,
		Low = 0.948,
		Height = 0.047,
		Cover = 0.202,
		Exposure = 0.405,
		Crowd = 0.061,
		Threat = 0.231,
		HealBelow = 83,
	},
}

return data
