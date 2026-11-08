--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Homing missile",
	Icon = "",

	--[[ Behavior ]]

	Kind = "Homing",
	Aim = "Target",
	Wind = true,

	--[[ Damage ]]

	DamageMax = 65,
	DamageEdge = 20,
	BlastRadius = 6,
	Knockback = "Medium",

	--[[ Limits ]]

	Uses = 2,
	Cooldown = 3,

	--[[ Launch ]]

	MinSpeed = 20,
	MaxSpeed = 112,

	--[[ Extras ]]

	LockDelay = 1,
	HomingSpeed = 60,
}

return _data
