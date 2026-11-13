--# selene: allow(unused_variable)

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

--- @class Marketplace_Products
--- @type { [string]: Marketplace_ProductsTableEntry }
local data = {
	--[[
        ["Example"] = {
            Id = 0,

            -- List of places/maps player can be rewarded in - PlaceId_MapId / MapId
            PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}`, `{I.Config.PlaceLoader.PlaceId}_{I.Config.PlaceLoader.MapId}` },
            
            Requirements = function(player: Player): boolean
                return true
            end,
            PurchasedRequirements = function(player: Player): boolean
                return true
            end,
            
            Reward = function(player: Player) end,
        },
    ]]

	["Diamonds_Handful"] = {
		Id = 3730916908,

		PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}` },

		Reward = function(player: Player)
			if not I.Currency.Add(player, "Diamonds", "250") then
				return false
			end
			return "Diamonds: 250"
		end,
	},

	["Diamonds_Pouch"] = {
		Id = 3730917013,

		PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}` },

		Reward = function(player: Player)
			if not I.Currency.Add(player, "Diamonds", "500") then
				return false
			end
			return "Diamonds: 500"
		end,
	},

	["Diamonds_Bag"] = {
		Id = 3730917086,

		PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}` },

		Reward = function(player: Player)
			if not I.Currency.Add(player, "Diamonds", "1000") then
				return false
			end
			return "Diamonds: 1000"
		end,
	},

	["Diamonds_Chest"] = {
		Id = 3730917175,

		PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}` },

		Reward = function(player: Player)
			if not I.Currency.Add(player, "Diamonds", "1500") then
				return false
			end
			return "Diamonds: 1500"
		end,
	},

	["Diamonds_Vault"] = {
		Id = 3730917219,

		PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}` },

		Reward = function(player: Player)
			if not I.Currency.Add(player, "Diamonds", "2500") then
				return false
			end
			return "Diamonds: 2500"
		end,
	},
}
return data
