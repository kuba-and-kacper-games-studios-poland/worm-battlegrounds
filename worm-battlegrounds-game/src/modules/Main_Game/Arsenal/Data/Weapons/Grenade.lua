--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Grenade",
	Icon = "rbxasset://textures/wb_guipreview/grenade_5bb5dee8.png",

	--[[ Behavior ]]

	Kind = "Bouncer",
	Aim = "Arc",
	Wind = false,

	--[[ Damage ]]

	DamageMax = 55,
	DamageEdge = 20,
	BlastRadius = 6,
	Knockback = "Medium",

	--[[ Limits ]]

	Uses = 2,
	Cooldown = 1,

	--[[ Launch ]]

	MinSpeed = 15,
	MaxSpeed = 90,

	--[[ Extras ]]

	Fuse = 3,
	Elasticity = 0.5,
}

return _data
