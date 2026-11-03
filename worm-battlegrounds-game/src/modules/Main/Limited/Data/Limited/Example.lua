--- @type Limited_LimitedData
local _data = {

	--[[ General ]]

	Name = "Example",

	--[[ Sale ]]

	ProductId = "Limited_Example",
	MaximumAmount = 0,
	AmountPerPlayer = 0,

	--[[ Reward ]]

	Reward = function(player: Player)
		print(`[{player.Name}] purchased Example limited!`)
	end,
}
return _data
