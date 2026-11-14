--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Black hole grenade",
	Icon = "rbxassetid://126733567159283",

	--[[ Behavior ]]

	Kind = "Roller",
	Aim = "Arc",
	Wind = true,

	--[[ Damage ]]

	DamageMax = 100,
	DamageEdge = 25,
	BlastRadius = 14,
	Knockback = "None",

	--[[ Limits ]]

	Uses = 1,
	Cooldown = 0,

	--[[ Launch ]]

	MinSpeed = 20,
	MaxSpeed = 180,

	--[[ Extras ]]

	HoleTime = 2.5,
	PullRadius = 20,
}

return _data
