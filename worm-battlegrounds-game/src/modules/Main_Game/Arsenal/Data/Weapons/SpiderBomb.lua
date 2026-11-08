--- @type Arsenal_WeaponData
local _data = {

	--[[ General ]]

	Name = "Spider bomb",
	Icon = "",

	--[[ Behavior ]]

	Kind = "Crawler",
	Aim = "Arc",
	Wind = false,

	--[[ Damage ]]

	DamageMax = 70,
	DamageEdge = 25,
	BlastRadius = 6,
	Knockback = "Medium",

	--[[ Limits ]]

	Uses = 2,
	Cooldown = 2,

	--[[ Launch ]]

	MinSpeed = 15,
	MaxSpeed = 125,

	--[[ Extras ]]

	Elasticity = 0.2,
	CrawlTime = 5,
	CrawlSpeed = 10,
}

return _data
