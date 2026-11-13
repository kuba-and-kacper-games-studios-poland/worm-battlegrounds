--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Spartan spear",
	Icon = "rbxassetid://120095788569892",

	--[[ Behavior ]]

	Kind = "Rocket",
	Aim = "Arc",
	Wind = true,

	--[[ Damage ]]

	DamageMax = 65,
	DamageEdge = 65,
	BlastRadius = 0,
	Knockback = "Medium",

	--[[ Limits ]]

	Uses = 4,
	Cooldown = 0,

	--[[ Launch ]]

	MinSpeed = 20,
	MaxSpeed = 180,

	--[[ Extras ]]

	Pierce = true,
}

return _data
