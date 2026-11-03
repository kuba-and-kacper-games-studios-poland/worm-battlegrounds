--# selene: allow(unused_variable)

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

--- @class Marketplace_Bundles
--- @type { [string]: Marketplace_BundlesTableEntry }
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
}
return data
