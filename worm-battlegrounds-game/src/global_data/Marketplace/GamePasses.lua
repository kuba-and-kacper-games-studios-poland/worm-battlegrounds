--# selene: allow(unused_variable)

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

--- @class Marketplace_GamePasses
--- @type { [string]: Marketplace_GamePassesTableEntry }
local data = {
	--[[
        ["Example"] = {
            Id = 0,
            Version = 1,

            -- List of places/maps player can be rewarded in - PlaceId_MapId / MapId
            PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}`, `{I.Config.PlaceLoader.PlaceId}_{I.Config.PlaceLoader.MapId}` },
            RewardPlaces = { `{I.Config.PlaceLoader.PlaceId}`, `{I.Config.PlaceLoader.PlaceId}_{I.Config.PlaceLoader.MapId}` },

            SingleReward = function(player: Player) end,
            SessionReward = function(player: Player) end,
            CharacterReward = function(player: Player) end,
        },
    ]]

	["Slot5"] = {
		Id = 2088224515,
		Version = 1,

		PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}` },
		RewardPlaces = { `{I.Config.PlaceLoader.PlaceId}` },
	},

	["Slot6"] = {
		Id = 2088944528,
		Version = 1,

		PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}` },
		RewardPlaces = { `{I.Config.PlaceLoader.PlaceId}` },
	},

	["DoubleCoins"] = {
		Id = 2089574514,
		Version = 1,

		PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}` },
		RewardPlaces = { `{I.Config.PlaceLoader.PlaceId}` },
	},

	["VIP"] = {
		Id = 2090714510,
		Version = 1,

		PurchasePlaces = { `{I.Config.PlaceLoader.PlaceId}` },
		RewardPlaces = { `{I.Config.PlaceLoader.PlaceId}` },
		SingleReward = function(player: Player)
			I.Inventory.AddItem(player, "Skin_Vip")
		end,
	},
}
return data
