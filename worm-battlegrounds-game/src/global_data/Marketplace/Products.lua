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

	-- Placeholder Id until the owner creates the product on the Creator Hub
	["Diamonds_Handful"] = {
		Id = 0,

		PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}` },

		Reward = function(player: Player)
			if not I.Currency.Add(player, "Diamonds", "250") then
				return false
			end
			return "Diamonds: 250"
		end,
	},

	-- Placeholder Id until the owner creates the product on the Creator Hub
	["Diamonds_Pouch"] = {
		Id = 0,

		PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}` },

		Reward = function(player: Player)
			if not I.Currency.Add(player, "Diamonds", "500") then
				return false
			end
			return "Diamonds: 500"
		end,
	},

	-- Placeholder Id until the owner creates the product on the Creator Hub
	["Diamonds_Bag"] = {
		Id = 0,

		PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}` },

		Reward = function(player: Player)
			if not I.Currency.Add(player, "Diamonds", "1000") then
				return false
			end
			return "Diamonds: 1000"
		end,
	},

	-- Placeholder Id until the owner creates the product on the Creator Hub
	["Diamonds_Chest"] = {
		Id = 0,

		PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}` },

		Reward = function(player: Player)
			if not I.Currency.Add(player, "Diamonds", "1500") then
				return false
			end
			return "Diamonds: 1500"
		end,
	},

	-- Placeholder Id until the owner creates the product on the Creator Hub
	["Diamonds_Vault"] = {
		Id = 0,

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
