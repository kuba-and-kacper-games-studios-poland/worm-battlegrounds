--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Shotgun",
	Icon = "rbxassetid://104705832389891",

	--[[ Behavior ]]

	Kind = "Hitscan",
	Aim = "Straight",
	Wind = false,
	HoldPose = "ShotGun",

	--[[ Damage ]]

	DamageMax = 0,
	DamageEdge = 0,
	BlastRadius = 0,
	Knockback = "Small",

	--[[ Limits ]]

	Uses = 4,
	Cooldown = 0,

	--[[ Extras ]]

	Pellets = 5,
	PerBulletDamage = 10,
	Spread = 8,
	Range = 60,
}

return _data
