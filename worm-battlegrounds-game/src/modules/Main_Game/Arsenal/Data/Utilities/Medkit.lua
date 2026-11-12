--- @type Arsenal_UtilityData
local _data = {

	--[[ General ]]

	Name = "Medkit",
	Icon = "rbxassetid://85030401627405",

	--[[ Effect ]]

	Effect = "Heal",
	Amount = 100,
	ShinyAmount = 110,

	--[[ Limits ]]

	Uses = 2,

	-- Once every 6 of the player's own turns, longer than the Bandage's for its bigger heal
	Cooldown = 5,
}

return _data
