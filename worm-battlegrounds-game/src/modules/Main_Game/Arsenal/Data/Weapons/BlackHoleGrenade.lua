--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Black hole grenade",
	Icon = "rbxassetid://126733567159283",

	--[[ Behavior ]]

	Kind = "Roller",
	Aim = "Feet",
	Wind = false,

	--[[ Damage ]]

	DamageMax = 100,
	DamageEdge = 25,
	BlastRadius = 14,
	Knockback = "High",

	--[[ Limits ]]

	Uses = 1,
	Cooldown = 0,

	--[[ Extras ]]

	RollSpeed = 10,
	MaxRollTime = 8,
}

return _data
