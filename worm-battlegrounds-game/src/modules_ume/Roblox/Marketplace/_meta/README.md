# Marketplace

Purchases by name: assets, bundles, game passes, developer products and Roblox Plus. Each kind is defined in `src/global_data/Marketplace/` with its id, the places it can be bought or rewarded in, and reward functions. The server prompts purchases (a client can ask it to), processes developer product receipts, publishes success and failure, and runs rewards the way badges do: once ever (`SingleReward`, kept per `Version`), once per session, or on every character spawn. Game passes can also be gifted by the server.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/Marketplace` |
| Runs on | Server, Global |
| Exposes | `I.Marketplace` (server), `I.G_Marketplace` (both) |
| Uses | `MarketplaceService`, `I.Player` (`GetProfile` and its `Save`), `I.G_Player`, `I.Replicator`, `I.Topic`, `I.Network`, `I.Config.PlaceLoader` |
| Saves | `Profile.Marketplace` (claimed rewards, Robux spent, gifted game passes, the last 20 processed product PurchaseIds, a log of product purchases) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Profile and session keys, checks the Marketplace data at start, rewards on character spawn, the shared purchase-succeeded path, starts the handlers |
| `Global.lua` | Product info (cached), prices and ownership checks (owned items cached per player for the session; game passes read from the replicator on the client) |
| `Scripts/Asset/Server.lua` | Asset prompts and purchase events |
| `Scripts/Bundle/Server.lua` | Bundle prompts and purchase events |
| `Scripts/GamePass/Server.lua` | Game pass prompts, purchase events, gifts, game pass ownership on the player's replicator |
| `Scripts/Product/Server.lua` | Developer product prompts, `ProcessReceipt` (once per PurchaseId, logged, granted only after the save is written), gifts |
| `Scripts/Premium/Server.lua` | Roblox Plus prompt and membership changes |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `marketplace` command |
| `_meta/_types.lua` | Table entries per kind, product info |

## API

### Server: `I.Marketplace`

Each handler adds its functions as `<Kind>_<Function>`.

| Function | Returns | What it does |
| --- | --- | --- |
| `Asset_PromptPurchase(player, assetName: string)` | `boolean` | Prompts an asset purchase |
| `Bundle_PromptPurchase(player, bundleName)` | `boolean` | Prompts a bundle purchase |
| `GamePass_PromptPurchase(player, gamepassName)` | `boolean` | Prompts a game pass purchase |
| `GamePass_Gift(player, gamepassName)` / `GamePass_GiftAll(player)` | `boolean` (, `{ string }`) | Gives the game pass (or all) without a purchase; saved in the profile. Runs the pass's rewards once; `GiftAll` skips passes the player already had |
| `GamePass_ClearGift(player, gamepassName)` / `GamePass_ClearAllGifts(player)` | `boolean` (, `{ string }`) | Takes gifts back |
| `GamePass_IsGifted(player, gamepassName)` | `boolean` | Whether it was gifted |
| `GamePass_GetGifted(player)` | `boolean`, `{ string }` | Every gifted game pass |
| `Product_PromptPurchase(player, productName)` | `boolean` | Prompts a developer product purchase, when its `Requirements` pass |
| `Product_Gift(player, productName)` | `boolean` | Runs the product's `Reward` without a purchase; `false` when it errors or returns `false` |
| `RobloxPlus_PromptPurchase(player)` | `boolean` | Prompts the Roblox Plus subscription |
| `RobloxPlus_IsRobloxPlus(player)` | `boolean` | Whether the player has Roblox Plus |

The table also holds `_createIndividualEvents`, `_purchaseSucceeded`, `_awardReward` and `_awardRewardForAll`, which the handlers share; don't call them from other modules.

### Global: `I.G_Marketplace`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetProductInfo(productName: string, productType: Enum.InfoType)` | `Marketplace_ProductInfo?` | Info for a named asset, bundle, game pass or product, cached for 5 minutes (callers asking at once share one request) |
| `GetProductPrice(productName, productType, addPrefix: boolean)` | `string \| number?` | Its price, with the Robux sign when `addPrefix` |
| `PlayerOwns(player, productName, productType)` | `boolean` | Ownership of any kind |
| `PlayerOwnsAsset(player, assetName)`, `PlayerOwnsBundle(player, bundleName)` | `boolean` | Ownership of one kind |
| `PlayerOwnsGamePass(player, gamepassName, stopAfterGifted: boolean?, includeGifted: boolean?)` | `boolean` | Owns it, or was gifted it. `includeGifted = false` counts real ownership only (the Robux spent count uses this). On the client it reads the replicated ownership once the server wrote it |
| `PlayerHasRobloxPlus(player)` | `boolean` | Roblox Plus membership |

**Products and receipts.** A product's `Reward(player)` counts as granted unless it errors or returns `false`; `nil` (no return) is success. A `Reward` may return a string saying what it granted (`"Pet: Dragon"`), which goes in the purchase log. `ProcessReceipt` waits for a player who is still loading, checks only `PurchasedRequirements` (not the pre-prompt `Requirements`), grants once per PurchaseId, adds the PurchaseId to `ProcessedPurchaseIds` (the last 20) and the purchase to `PurchaseLog`, forces a profile save and returns `PurchaseGranted` only after a written save holds that PurchaseId. Anything else returns `NotProcessedYet`, so Roblox delivers the receipt again. A re-delivered receipt whose PurchaseId is already listed is only saved again, never granted twice.

**Purchase log.** `PurchaseLog` keeps each granted developer product for 30 days (at most 200 entries, oldest dropped first), so refund and withdrawal requests can be checked against what the player got. It is saved with the grant. Game passes, assets, bundles and `Product_Gift` aren't logged.

**Rewards.** A `SingleReward` or `SessionReward` that errors or returns `false` isn't counted as claimed. On character spawn, only items whose ownership isn't known yet are checked, once per session.

## Usage

```lua
-- Server
I.Marketplace.Product_PromptPurchase(player, "Coins100")
I.Topic.Subscribe("Marketplace_GamePassPurchaseSucceeded-VIP", Module._onVipBought) -- (player: Player)

-- Either side
if I.G_Marketplace.PlayerOwnsGamePass(player, "VIP") then ... end
```

## Network

In the names below, `<Kind>` is each of `Asset`, `Bundle`, `GamePass` and `Product`, and `<name>` is an entry of that kind.

### Server

**Topics**

- `Marketplace_<Kind>PurchaseSucceeded @ (player: Player, name: string)`, `Marketplace_<Kind>PurchaseFailed @ (player: Player, name: string)`
- `Marketplace_<Kind>PurchaseSucceeded-{name} @ (player: Player)`, `Marketplace_<Kind>PurchaseFailed-{name} @ (player: Player)`
- `Marketplace_RobloxPlusUpdated @ (player: Player, isRobloxPlus: boolean)`

**Receive: RemoteEvents**

- `Marketplace_Prompt<Kind>Purchase @ (player: Player, name: string)`: a client asking for a prompt. Rate limit 1 per second.
- `Marketplace_PromptRobloxPlusPurchase @ (player: Player)`

**Receive: RemoteFunctions**

- `Marketplace_IsGamePassGifted @ (player: Player, gamepassName: string)`, `Marketplace_IsRobloxPlus @ (player: Player)`

**Send: RemoteEvents**

- The same success and failure names as the Topics, to the buying player: `Marketplace_<Kind>PurchaseSucceeded @ (player: Player, name: string)`, `Marketplace_<Kind>PurchaseSucceeded-{name} @ (player: Player)`, and the `Failed` ones.
- `Marketplace_RobloxPlusUpdated @ (player: Player, isRobloxPlus: boolean)`

### Client

**Receive: RemoteEvents**

- `Marketplace_<Kind>PurchaseSucceeded @ (name: string)`, `Marketplace_<Kind>PurchaseFailed @ (name: string)`, and the `-{name} @ ()` forms.
- `Marketplace_RobloxPlusUpdated @ (isRobloxPlus: boolean)`

**Send: RemoteEvents**

- `Marketplace_Prompt<Kind>Purchase @ (name: string)`, `Marketplace_PromptRobloxPlusPurchase @ ()`

**Send: RemoteFunctions**

- `Marketplace_IsGamePassGifted @ (gamepassName: string)`, `Marketplace_IsRobloxPlus @ ()`

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Marketplace.AssetRewardsClaimed`, `BundleRewardsClaimed`, `GamePassRewardsClaimed` | `[name] = Version` whose single reward was claimed |
| | `Marketplace.<Kind>RobuxSpent`, `<Kind>RobuxSpentCalculatedFor` | Robux spent per kind, and the items already counted |
| | `Marketplace.GiftedGamePasses` | Gifted game pass names |
| | `Marketplace.ProcessedPurchaseIds` | The last 20 developer product PurchaseIds granted, oldest first |
| | `Marketplace.PurchaseLog` | Developer products granted in the last 30 days (at most 200), oldest first. Each entry: `PurchaseId`, `ProductId`, `Product` (its name), `CurrencySpent`, `Channel` (the receipt's `ProductPurchaseChannel` name: `InExperience`, `ExperienceDetailsPage`, `AdReward`, `CommerceProduct`), `PlaceId` (where it was bought), `Time` (Unix seconds), `Granted` (the `Reward`'s string, if any) |
| Replicator `Marketplace` folder | `GamePassOwned_{name}`, `GamePassGifted_{name}` | Each game pass's real and gifted ownership (names Roblox accepts as attribute names only) |
| Session | `Marketplace.<Kind>RewardsClaimed`, `IsRobloxPlus` | Session rewards claimed, Roblox Plus |
| `src/global_data/Marketplace/{Assets,Bundles,GamePasses}.lua` | `[name]` | `Id`, `Version`, `PurchasePlaces`, `RewardPlaces`, `SingleReward`, `SessionReward`, `CharacterReward` |
| `src/global_data/Marketplace/Products.lua` | `[name]` | `Id`, `PurchasePlaces`, `Requirements` (before prompting), `PurchasedRequirements` (before granting), `Reward` (`false` = not granted; a string = what was granted, for the log) |

At start, every entry is checked: a missing or placeholder (`0`) or repeated `Id`, a product without `Reward`, and rewards without a numeric `Version` warn.

Places are `PlaceId` or `PlaceId_MapId` strings.

## Commands

`marketplace` (server): `prompt_purchase`, `reward_for`, `reward_for_all`, `get_info`, `get_price`, `get_robux_spent`, `owns` (each per kind: `asset`, `bundle`, `gamepass`, `product`, `premium`), and the gift subcommands `gift` (`gamepass`, `all_gamepasses`, `product`), `clear_gamepass_gift`, `clear_all_gamepasses_gift`, `is_gifted`, `get_gifted`.
