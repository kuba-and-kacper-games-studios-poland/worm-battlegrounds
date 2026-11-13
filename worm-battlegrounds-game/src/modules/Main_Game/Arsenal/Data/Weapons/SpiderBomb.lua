--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Spider bomb",
	Icon = "rbxassetid://126313994651146",

	--[[ Behavior ]]

	Kind = "Crawler",
	Aim = "Arc",
	Wind = true,

	--[[ Damage ]]

	DamageMax = 70,
	DamageEdge = 25,
	BlastRadius = 6,
	Knockback = "Medium",

	--[[ Limits ]]

	Uses = 2,
	Cooldown = 2,

	--[[ Launch ]]

	MinSpeed = 20,
	MaxSpeed = 180,

	--[[ Extras ]]

	Elasticity = 0.2,
	CrawlTime = 5,
	CrawlSpeed = 10,
}

return _data
