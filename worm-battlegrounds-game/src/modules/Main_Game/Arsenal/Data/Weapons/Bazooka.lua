--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Bazooka",
	Icon = "rbxassetid://134208977158560",

	--[[ Behavior ]]

	Kind = "Rocket",
	Aim = "Arc",
	Wind = true,

	--[[ Damage ]]

	DamageMax = 35,
	DamageEdge = 15,
	BlastRadius = 6,
	Knockback = "Medium",

	--[[ Limits ]]

	Uses = -1,
	Cooldown = 0,

	--[[ Launch ]]

	MinSpeed = 20,
	MaxSpeed = 150,
}

return _data
