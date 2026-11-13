--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Bazooka",
	Icon = "rbxassetid://89888640314244",

	--[[ Behavior ]]

	Kind = "Rocket",
	Aim = "Arc",
	Wind = true,
	HoldPose = "Bazooka",

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
	MaxSpeed = 180,
}

return _data
