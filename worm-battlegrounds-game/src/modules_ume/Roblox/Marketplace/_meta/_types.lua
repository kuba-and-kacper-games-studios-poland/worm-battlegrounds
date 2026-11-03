--%%%%%%%%%%%%%%%%%%%% Data

--- @class Marketplace_AssetsTableEntry
---
--- # Identity #
---
--- @field Id number
--- @field Version number
--- @field PurchasePlaces { string }
--- @field RewardPlaces { string }
---
--- # Rewards #
---
--- @field SingleReward (player: Player) -> ()
--- @field SessionReward (player: Player) -> ()
--- @field CharacterReward (player: Player) -> ()
local _marketplace_AssetsTableEntry = {}

--- @class Marketplace_BundlesTableEntry
---
--- # Identity #
---
--- @field Id number
--- @field Version number
--- @field PurchasePlaces { string }
--- @field RewardPlaces { string }
---
--- # Rewards #
---
--- @field SingleReward (player: Player) -> ()
--- @field SessionReward (player: Player) -> ()
--- @field CharacterReward (player: Player) -> ()
local _marketplace_BundlesTableEntry = {}

--- @class Marketplace_GamePassesTableEntry
---
--- # Identity #
---
--- @field Id number
--- @field Version number
--- @field PurchasePlaces { string }
--- @field RewardPlaces { string }
---
--- # Rewards #
---
--- @field SingleReward (player: Player) -> ()
--- @field SessionReward (player: Player) -> ()
--- @field CharacterReward (player: Player) -> ()
local _marketplace_GamePassesTableEntry = {}

--- @class Marketplace_ProductsTableEntry
---
--- # Product #
---
--- @field Id number
--- @field PurchasePlaces { string }
---
--- # Requirements #
---
--- @field Requirements (player: Player) -> boolean
--- @field PurchasedRequirements (player: Player) -> boolean
---
--- # Reward #
---
--- @field Reward (player: Player) -> (boolean | string)?
local _marketplace_ProductsTableEntry = {}

--%%%%%%%%%%%%%%%%%%%% Info

--- @class Marketplace_ProductInfoCreator
--- @field CreatorType string
--- @field CreatorTargetId number
--- @field HasVerifiedBadge boolean
--- @field Name string
--- @field Id number
local _marketplace_ProductInfoCreator = {}

--- @class Marketplace_PriceDiscountDetail
--- @field Type string
--- @field Percent number
--- @field AmountInRobux number
local _marketplace_PriceDiscountDetail = {}

--- @class Marketplace_ProductInfo
---
--- # Summary #
---
--- @field Name string
--- @field Description string
--- @field PriceInRobux number
--- @field UserBasePriceInRobux number?
--- @field PriceDiscountDetails { Marketplace_PriceDiscountDetail }?
--- @field Created string
--- @field Updated string
--- @field ContentRatingTypeId number
--- @field MinimumMembershipLevel number
--- @field IsPublicDomain boolean
--- @field Creator Marketplace_ProductInfoCreator
---
--- # Asset #
---
--- @field AssetId number
--- @field AssetTypeId number
--- @field IsForSale boolean
--- @field IsLimited boolean
--- @field IsLimitedUnique boolean
--- @field IsNew boolean
--- @field Remaining number
--- @field Sales number
--- @field SaleAvailabilityLocations { string }
--- @field CanBeSoldInThisGame boolean
---
--- # Product #
---
--- @field ProductId number
--- @field ProductType string
--- @field IconImageAssetId number
local _marketplace_ProductInfo = {}

--- @class Marketplace_ProductInfoCacheEntry
---
--- # Result #
---
--- @field Info Marketplace_ProductInfo?
--- @field ExpiresAt number
---
--- # Request #
---
--- @field Pending boolean
local _marketplace_ProductInfoCacheEntry = {}

--- @class Marketplace_ReceiptInfo
--- @field PurchaseId string
--- @field PlayerId number
--- @field ProductId number
--- @field PlaceIdWherePurchased number
--- @field CurrencySpent number
--- @field CurrencyType Enum.CurrencyType
--- @field ProductPurchaseChannel Enum.ProductPurchaseChannel?
local _marketplace_ReceiptInfo = {}
