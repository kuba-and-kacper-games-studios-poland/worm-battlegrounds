--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Cluster bomb",
	Icon = "rbxassetid://125982425140000",

	--[[ Behavior ]]

	Kind = "Bouncer",
	Aim = "Arc",
	Wind = true,

	--[[ Damage ]]

	DamageMax = 25,
	DamageEdge = 10,
	BlastRadius = 4,
	Knockback = "Medium",

	--[[ Limits ]]

	Uses = 2,
	Cooldown = 2,

	--[[ Launch ]]

	MinSpeed = 20,
	MaxSpeed = 180,

	--[[ Extras ]]

	Elasticity = 0.3,
	BurstOnContact = true,
	Bomblets = { Count = 5, DamageMax = 15, DamageEdge = 5, Radius = 3, Mini = 0.5 },
}

return _data
