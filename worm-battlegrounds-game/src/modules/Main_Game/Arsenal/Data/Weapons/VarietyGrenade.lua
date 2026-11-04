--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Variety grenade",
	Icon = "",

	--[[ Behavior ]]

	Kind = "Bouncer",
	Aim = "Arc",
	Wind = false,

	--[[ Damage ]]

	DamageMax = 50,
	DamageEdge = 20,
	BlastRadius = 5,
	Knockback = "Medium",

	--[[ Limits ]]

	Uses = 1,
	Cooldown = 0,

	--[[ Launch ]]

	MinSpeed = 15,
	MaxSpeed = 85,

	--[[ Extras ]]

	Elasticity = 0.3,
	BurstOnContact = true,
	Snails = { Count = 4, Hits = 8, Damage = 5, Radius = 2 },
}

return _data
