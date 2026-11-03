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
}
return data
