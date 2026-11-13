--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Grenade",
	Icon = "rbxassetid://88613468948489",

	--[[ Behavior ]]

	Kind = "Bouncer",
	Aim = "Arc",
	Wind = true,

	--[[ Damage ]]

	DamageMax = 55,
	DamageEdge = 20,
	BlastRadius = 6.9,
	Knockback = "Medium",

	--[[ Limits ]]

	Uses = 2,
	Cooldown = 1,

	--[[ Launch ]]

	MinSpeed = 20,
	MaxSpeed = 180,

	--[[ Extras ]]

	Fuse = 3,
	Elasticity = 0.5,
}

return _data
