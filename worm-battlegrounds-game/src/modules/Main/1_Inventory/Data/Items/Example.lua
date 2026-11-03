--- @type Inventory_ItemData
local _data = {

	--[[ General ]]

	Name = "Example - PreSetup",
	IconId = "rbxassetid://0",

	Rarity = "Common",
	Category = "Other",

	RemoveByClientRequest = true,
	UseByClientRequest = true,

	Use = function(player: Player, quantity: string)
		print(`Player ({player.Name}) used Example item ({quantity}) times`)
		return true
	end,
	UseRequirements = function(_player: Player, _quantity: string)
		return true
	end,
}

function _data._setupFunction()
	_data.Name = "Example"
end

return _data
