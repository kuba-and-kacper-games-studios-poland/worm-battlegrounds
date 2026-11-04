--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Bazooka",
	Icon = "rbxasset://textures/wb_guipreview/bazooka_2c82e8ca.png",

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
	MaxSpeed = 120,
}

return _data
