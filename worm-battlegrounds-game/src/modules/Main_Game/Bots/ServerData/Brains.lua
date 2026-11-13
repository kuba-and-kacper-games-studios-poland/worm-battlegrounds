--- @type { [string]: Bots_Genome }
local data = {

	--[[ Hard ]]

	Hard = {
		EnemyDamage = 0.742,
		Knockout = 0.345,
		Focus = 0.172,
		Grudge = 0.315,
		Pressure = 0.141,
		AllyDamage = 0.139,
		AllyKnockout = 6.361,
		SelfDamage = 0.278,
		SelfKnockout = 3.712,
		Ammo = 0.189,
		Walk = 0.118,
		Jetpack = -0.008,
		Edge = 0.084,
		Footing = 0.423,
		Low = 0.641,
		Height = 0.235,
		Cover = -0.342,
		Exposure = 0.355,
		Crowd = -0.168,
		Threat = -0.082,
		HealBelow = 140,
	},

	--[[ Nightmare ]]

	Nightmare = {
		EnemyDamage = 1.56,
		Knockout = 0.069,
		Focus = 0.206,
		Grudge = 0.087,
		Pressure = 0.3,
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
		Cover = 0.1,
		Exposure = 0.139,
		Crowd = 0.065,
		Threat = -0.107,
		HealBelow = 64,
	},

	--[[ Medium ]]

	Medium = {
		EnemyDamage = 1.226,
		Knockout = 2.957,
		Focus = 0.137,
		Grudge = 0.083,
		Pressure = 0.104,
		AllyDamage = 2.383,
		AllyKnockout = 1.229,
		SelfDamage = 0.182,
		SelfKnockout = 2.997,
		Ammo = 0.297,
		Walk = 0.207,
		Jetpack = -0.095,
		Edge = 0.508,
		Footing = 0.314,
		Low = 0.649,
		Height = 0.412,
		Cover = -0.002,
		Exposure = 0.036,
		Crowd = 0.106,
		Threat = -0.038,
		HealBelow = 70,
	},

	--[[ Easy ]]

	Easy = {
		EnemyDamage = 1,
		Knockout = 1.2,
		Focus = 0.5,
		Grudge = 0.2,
		Pressure = 0.3,
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
		Cover = 0.1,
		Exposure = 0.1,
		Crowd = 0.1,
		Threat = 0.1,
		HealBelow = 90,
	},
}

return data
