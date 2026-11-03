--- @class Badge_BadgeInfo
---
--- # Identity #
---
--- @field Name string
--- @field Description string
---
--- # Availability #
---
--- @field IconImageId number
--- @field IsEnabled boolean
---
--- # Client Display #
---
--- @field DisplayName string @ Can only be accessed by Client!
--- @field DisplayDescription string @ Can only be accessed by Client!
local _badge_BadgeInfo = {}

--- @class Badge_BadgesTableEntry
---
--- # Identity #
---
--- @field Id number
--- @field Version number
--- @field AwardPlaces { string }
--- @field RewardPlaces { string }
---
--- # Rewards #
---
--- @field SingleReward (player: Player) -> boolean?
--- @field SessionReward (player: Player) -> boolean?
--- @field CharacterReward (player: Player) -> boolean?
local _badge_BadgesTableEntry = {}

--- @class Badge_CachedInfo
--- @field Info Badge_BadgeInfo
--- @field Time number
local _badge_CachedInfo = {}

--- @alias Badge_AwardResult "Awarded" | "AlreadyOwned" | "Disabled" | "WrongPlace" | "Failed"
local _badge_AwardResult = {}
