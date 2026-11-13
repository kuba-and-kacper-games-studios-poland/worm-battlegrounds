--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Variety grenade",
	Icon = "rbxassetid://132575441840814",

	--[[ Behavior ]]

	Kind = "Bouncer",
	Aim = "Arc",
	Wind = true,

	--[[ Damage ]]

	DamageMax = 50,
	DamageEdge = 20,
	BlastRadius = 5,
	Knockback = "Medium",

	--[[ Limits ]]

	Uses = 1,
	Cooldown = 2,

	--[[ Launch ]]

	MinSpeed = 20,
	MaxSpeed = 180,

	--[[ Extras ]]

	Elasticity = 0.3,
	BurstOnContact = true,
	Bomblets = { Count = 4, DamageMax = 20, DamageEdge = 8, Radius = 3.5, Mini = 0.5 },
}

return _data
