# Limited

Limited-stock items. Each limited (in `Data/Limited/`) has a global maximum shared by every server, an optional per-player cap, and a reward. The global sold count lives in a DataStore and is incremented atomically when a purchase is finalised, so stock never oversells; the counts are mirrored as attributes everyone can read, and `Limited_Slot` labels show what is left. A sale is a developer product (the limited's `ProductId`) whose `Requirements` call `ProductRequirements` and whose `Reward` returns `RewardPurchase`.

**Counts across servers.** Each sale is published over MessagingService, so other servers apply it right away, and every server reloads all counts from the DataStore every `REFRESH_INTERVAL` seconds (which also picks up copies given back and limiteds whose first load failed). `Limited_StockChanged` fires on the server whenever a count changes.

**Holds.** While a player's purchase prompt is open, `ProductRequirements` holds one copy for them in a MemoryStore hash map for `HOLD_TIME` seconds. A prompt is refused when every copy left is sold or held by other players, so several players can't pay for the last copy. The hold is released when the prompt closes without a purchase, when the player leaves before buying, or when `RewardPurchase` finishes. Without DataStore access, or when the MemoryStore fails, prompts go ahead without a hold (`RewardPurchase` still checks the stock).

**Failed purchases.** `RewardPurchase` claims the player's per-player slot before the stock update yields, so two receipts at once can't pass the cap. When the player leaves during the stock update, or the limited's `Reward` errors or returns `false`, the copy goes back to the stock, the `Bought` count is undone and it returns `false`, so Marketplace keeps the receipt and Roblox delivers it again on the player's next join. A `Reward` should error before it grants anything, since it runs again on that retry.

| | |
| --- | --- |
| Folder | `src/modules/Main/Limited` |
| Runs on | Server, Client, Global |
| Exposes | `I.Limited` (server, client), `I.G_Limited` (both) |
| Uses | `DataStoreService` (`I.MockDataStores` without DataStore access), `MessagingService`, `MemoryStoreService`, `MarketplaceService.PromptProductPurchaseFinished`, `I.Player`, `I.G_Player`, `I.DoEvery`, `I.Topic`, `I.Component`, the Marketplace products (`src/global_data/Marketplace/Products.lua`) |
| Saves | `Profile.Limited.Bought` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Profile key, starts the handlers, `I.Limited` |
| `Scripts/Server/Stock.lua` | The stock DataStore, the shared counts folder, reserving and giving back copies, the refresh loop, sale messages, `Limited_StockChanged` |
| `Scripts/Server/Hold.lua` | Holds while purchase prompts are open (MemoryStore), the `ProductId` check |
| `Scripts/Server/Purchase.lua` | `RewardPurchase`, `ProductRequirements`, the purchase checks, purchases in progress |
| `Client.lua` | Reads the counts, registers `Limited_Slot` |
| `Global.lua` | Loads every limited in `Data/Limited` |
| `Settings.lua` | The stock DataStore, refresh, messaging and hold settings |
| `Data/Limited/*.lua` | One limited per file (`Example.lua` is the template) |
| `Components/Slot.lua` | `Limited_Slot`, a label that shows the stock |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `limited` command |
| `_meta/_types.lua` | `Limited_LimitedData`, `Limited_SaleMessage` |

## API

### Server: `I.Limited`

| Function | Returns | What it does |
| --- | --- | --- |
| `RewardPurchase(player, limitedId: string, ignoreGlobalLimit: boolean?, ignorePlayerLimit: boolean?, ignoreBoughtIncrement: boolean?)` | `boolean` | Finalises a purchase: increments the global sold count (refusing to go past the maximum), increments the player's bought count, runs the limited's `Reward`. `false` when out of stock, over the cap, the player left, or the `Reward` errors or returns `false` (the copy and the count are given back) |
| `ProductRequirements(player, limitedId)` | `boolean` | For a product's `Requirements`: `CanPurchase`, then holds a copy while the prompt is open; `false` when every copy left is held by others |
| `CanPurchase(player, limitedId)` | `boolean` | Stock left globally and for this player |
| `HasBought(player, limitedId)` | `number` | Copies the player bought |
| `GetRemaining(limitedId)` | `number` | Copies left globally |
| `GetRemainingPurchases(player, limitedId)` | `number` | Purchases left for this player, counting purchases in progress; `-1` when unlimited |

### Client: `I.Limited`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetSold(limitedId)` | `number` | Copies sold globally |
| `GetMax(limitedId)` | `number` | Copies available in total |
| `GetRemaining(limitedId)` | `number` | Copies left |

### Global: `I.G_Limited`

| Field | What it is |
| --- | --- |
| `Data[limitedId]` | Every limited's data |

## Usage

```lua
-- src/global_data/Marketplace/Products.lua, the product named by the limited's ProductId
["Limited_GoldenDragon"] = {
	Id = 123456789,
	Requirements = function(player: Player): boolean
		return I.Limited.ProductRequirements(player, "GoldenDragon")
	end,
	Reward = function(player: Player)
		return I.Limited.RewardPurchase(player, "GoldenDragon")
	end,
},
```

## Network

No remotes: counts reach clients as attributes on the shared folder. Servers tell each other about sales on the MessagingService topic `MESSAGING_TOPIC` (`{ Id, Sold }`).

### Server

**Topics**

- `Limited_StockChanged @ (limitedId: string, sold: number, max: number)`: a limited's sold count changed on this server (a sale, a copy given back, a sale message or a refresh), after the first load.

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Limited.Bought[limitedId]` | Copies this player bought |
| DataStore `DATASTORE_NAME` | `[limitedId]` | Global sold count |
| MemoryStore hash map `HOLD_MAP_NAME` | `[limitedId]` | `{ [userId]: expiresAt }`, the copies held while prompts are open |
| `Limited` folder in the framework's shared storage | `{limitedId}_Sold`, `{limitedId}_Max` | Counts every client reads |
| `Data/Limited/<Limited>.lua` | | `Name`, `ProductId` (the Marketplace product's name), `MaximumAmount`, `AmountPerPlayer` (`-1` unlimited), `Reward` (`false` = not granted) |

A limited file whose name can't be part of an attribute name, or that is missing a field, is skipped with a warning. A `ProductId` that isn't in the Marketplace products warns at start.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `DATASTORE_NAME` | `"Limited_Stock"` (`"Limited_Stock_Test"` in Studio) | DataStore holding the sold counts |
| `REFRESH_INTERVAL` | `60` | Seconds between reloads of every sold count |
| `MESSAGING_TOPIC` | `"Limited_Sold"` | MessagingService topic each sale is published on |
| `HOLD_MAP_NAME` | `"Limited_Holds"` (`"Limited_Holds_Test"` in Studio) | MemoryStore hash map of held copies |
| `HOLD_TIME` | `120` | Seconds a copy stays held after the prompt opens |

## Components

### `Limited_Slot` (`Components/Slot.lua`)

Shows how many copies of a limited are left, and updates when the count changes.

| | |
| --- | --- |
| Tag on | `TextLabel` |
| Side | Client (`RegisterOnLoaded`) |

| Attribute | Type | Default | What |
| --- | --- | --- | --- |
| `Limited_Id` | string | `""` | Which limited |
| `Limited_CustomFormat` | string | `""` | `string.format` pattern with two `%s`: amount left, then total |

## Commands

`limited` (server): `reward_purchase`, `can_purchase`, `has_bought`, `get_remaining`, `get_remaining_purchases`.
