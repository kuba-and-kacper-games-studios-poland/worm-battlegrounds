--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Dynamite",
	Icon = "",

	--[[ Behavior ]]

	Kind = "Bouncer",
	Aim = "Arc",
	Wind = false,

	--[[ Damage ]]

	DamageMax = 85,
	DamageEdge = 40,
	BlastRadius = 9,
	Knockback = "High",

	--[[ Limits ]]

	Uses = 2,
	Cooldown = 2,

	--[[ Launch ]]

	MinSpeed = 15,
	MaxSpeed = 80,

	--[[ Extras ]]

	Elasticity = 0.2,
	BurstOnContact = true,
}

return _data
