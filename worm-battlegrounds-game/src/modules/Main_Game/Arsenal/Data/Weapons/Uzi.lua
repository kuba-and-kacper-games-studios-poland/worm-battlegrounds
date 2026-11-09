--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Uzi",
	Icon = "rbxassetid://79744307043186",

	--[[ Behavior ]]

	Kind = "Hitscan",
	Aim = "Straight",
	Wind = false,
	HoldPose = "Gun",

	--[[ Damage ]]

	DamageMax = 0,
	DamageEdge = 0,
	BlastRadius = 0,
	Knockback = "Small",

	--[[ Limits ]]

	Uses = 3,
	Cooldown = 0,

	--[[ Extras ]]

	Pellets = 5,
	PerBulletDamage = 10,
	Spread = 3,
	Range = 80,
	BurstInterval = 0.08,
}

return _data
