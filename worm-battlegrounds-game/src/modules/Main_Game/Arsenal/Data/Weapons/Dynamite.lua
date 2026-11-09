--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Dynamite",
	Icon = "rbxassetid://99998769993186",

	--[[ Behavior ]]

	Kind = "Bouncer",
	Aim = "Feet",
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

	MinSpeed = 0,
	MaxSpeed = 0,

	--[[ Extras ]]

	Fuse = 3.5,
	Elasticity = 0.2,
	Retreat = 3,
}

return _data
