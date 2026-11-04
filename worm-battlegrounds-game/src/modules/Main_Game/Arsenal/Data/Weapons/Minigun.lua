--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Minigun",
	Icon = "",

	--[[ Behavior ]]

	Kind = "Hitscan",
	Aim = "Straight",
	Wind = false,

	--[[ Damage ]]

	DamageMax = 0,
	DamageEdge = 0,
	BlastRadius = 0,
	Knockback = "Small",

	--[[ Limits ]]

	Uses = 3,
	Cooldown = 0,

	--[[ Extras ]]

	Pellets = 20,
	PerBulletDamage = 4,
	Spread = 5,
	Range = 100,
	BurstInterval = 0.05,
}

return _data
