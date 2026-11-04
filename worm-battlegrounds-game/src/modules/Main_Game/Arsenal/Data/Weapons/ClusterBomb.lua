--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Cluster bomb",
	Icon = "rbxasset://textures/wb_guipreview/cluster_bomb_389e0749.png",

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

	MinSpeed = 15,
	MaxSpeed = 90,

	--[[ Extras ]]

	Elasticity = 0.3,
	BurstOnContact = true,
	Bomblets = { Count = 5, DamageMax = 15, DamageEdge = 5, Radius = 3 },
}

return _data
