--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Homing missile",
	Icon = "rbxassetid://107350591430267",

	--[[ Behavior ]]

	Kind = "Homing",
	Aim = "Target",
	Wind = true,
	HoldPose = "Bazooka",

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
	MaxSpeed = 180,

	--[[ Extras ]]

	LockDelay = 1,
	HomingSpeed = 60,
}

return _data
