--# selene: allow(unused_variable)

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

--- @class Badge_Badges
--- @type { [string]: Badge_BadgesTableEntry }
local data = {
	--[[
        ["Example"] = {
            Id = 0,
            Version = 1,

            -- List of places/maps player can be rewarded in - PlaceId_MapId / MapId
            AwardPlaces = { `{I.Config.PlaceLoader.PlaceId}`, `{I.Config.PlaceLoader.PlaceId}_{I.Config.PlaceLoader.MapId}` },
            RewardPlaces = { `{I.Config.PlaceLoader.PlaceId}`, `{I.Config.PlaceLoader.PlaceId}_{I.Config.PlaceLoader.MapId}` },

            SingleReward = function(player: Player): boolean? end,
            SessionReward = function(player: Player): boolean? end,
            CharacterReward = function(player: Player): boolean? end,
        },
    ]]
}
return data
