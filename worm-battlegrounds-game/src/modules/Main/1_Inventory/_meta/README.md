# Inventory

Saved player items. **Standard** items are counted by id (`Coins: "120"`); **unique** items are single entries with their own UUID and metadata (a pet with stats, a weapon with a roll). Items are defined as ModuleScripts in `Data/Items/` with a name, icon, rarity and category, and an optional `Use` function. The server owns every change; the client gets a copy of the player's inventory on request and after each change, and may ask the server to remove, lock or use items.

| | |
| --- | --- |
| Folder | `src/modules/Main/1_Inventory` |
| Runs on | Server, Client, Global |
| Exposes | `I.Inventory` (server, client), `I.G_Inventory` (both) |
| Uses | `I.Player`, `I.G_Player`, `I.Network`, `I.Topic`, `I.BN`, `I.Number` |
| Saves | `Profile.Inventory` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Profile template, the remotes and Topics, `I.Inventory`, sending data to the client |
| `Client.lua` | The local copy of the inventory (`I.Inventory.Items`), client Topics |
| `Global.lua` | Loads every item in `Data/Items` and caches items and categories |
| `Settings.lua` | Categories and limits |
| `Data/Items/*.lua` | One item per file (`Inventory_ItemData`); `Example.lua` is the template |
| `Scripts/Server/Add.lua` | Adding standard items, adding and creating unique items |
| `Scripts/Server/Remove.lua` | Removing items, and the checked versions clients call |
| `Scripts/Server/Get.lua` | Reading quantities, unique items, the whole inventory |
| `Scripts/Server/Lock.lua` | Locking items against removal |
| `Scripts/Server/Use.lua` | Running an item's `Use` and removing what was used |
| `Scripts/Server/Unique.lua` | Counting unique items against `MAX_UNIQUE_ITEMS` |
| `Scripts/Server/Transfer.lua` | Moving standard and unique items from one player to another |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `inventory` command |
| `_meta/_types.lua` | Item, unique item and metadata shapes |

## API

Quantities are integer strings (BigNum). Functions with `sendUpdate` send the new data to the client when it is `true`.

### Server: `I.Inventory`

| Function | Returns | What it does |
| --- | --- | --- |
| `AddItem(player, itemId: string, quantity: string?, sendUpdate: boolean?)` | `boolean` | Adds standard items (1 by default) |
| `AddItemBulk(player, itemsToAdd: table)` | `boolean` | Adds several at once |
| `RemoveItem(player, itemId, quantity?, sendUpdate?)` | `boolean` | Removes standard items; fails when locked or not enough |
| `CreateUnique(player, itemId, setUUID: string?, metadata: Inventory_UniqueMetadata?, sendUpdate?)` | `boolean`, `string?` | Creates a unique item; returns its UUID |
| `AddUnique(player, uniqueUUID: string, uniqueData: Inventory_UniqueItem, sendUpdate?)` | `boolean`, `string?` | Adds an existing unique item (a trade, a transfer) |
| `RemoveUnique(player, uniqueUUID, quantity?, sendUpdate?)` | `boolean` | Removes a unique item, or some of its quantity |
| `RemoveBulk(player, removeTable: table)` | `boolean` | Removes several at once |
| `LockItem` / `UnlockItem(player, itemId, sendUpdate?)` | `boolean?` | Locks or unlocks an item |
| `LockSwitch(player, itemId, sendUpdate?)` | `boolean?`, `boolean?` | Flips the lock; returns success and the new state |
| `IsLocked(player, itemId)` | `boolean?` | Whether the item is locked |
| `UseItem(player, itemId, quantity?, useMax: boolean?)` | `boolean` | Runs the item's `UseRequirements` and `Use`, then removes what was used (up to `MAX_USE_QUANTITY`; `useMax` uses as many as allowed) |
| `UseUnique(player, uniqueUUID, quantity?, useMax?)` | `boolean` | The same for a unique item |
| `TransferItem(fromPlayer, toPlayer, itemId, quantity?, sendUpdate?)` | `boolean` | Moves standard items between players without yielding; the sender gets them back when the receiver can't take them |
| `TransferUnique(fromPlayer, toPlayer, uniqueUUID, quantity?, sendUpdate?)` | `boolean`, `string?` | Moves a unique item (or part of its quantity); returns the UUID the receiver holds it under. Keeps `_cts` and `_fo` |
| `GetItem(player, itemId)` | `string?` | Quantity of a standard item |
| `GetUnique(player, uniqueUUID, clonedData: boolean?)` | `Inventory_UniqueItem?` | A unique item (a copy with `clonedData`) |
| `GetInventory(player, dataType: Inventory_DataType?, clonedData?)` | `Inventory_Data?` | The whole inventory, or one part (`Standard`, `Unique`, `Locked`) |
| `HasItem(player, itemId: string, quantity: string?)` | `boolean` | Whether the player holds at least `quantity` (1 by default) of a standard item id or a unique UUID |
| `HasEnoughUniqueInventorySpace(player, quantity: string)` | `boolean` | Room for that many unique items |
| `RecountUniques(player)` | | Counts unique items again |
| `UpdateClientData(player, dataType?)` | `boolean` | Sends the inventory (or one part) to the client |
| `UpdateClientChanges(player, dataType, ids: { string })` | `boolean` | Sends only those Standard item ids or Unique UUIDs as saved now (`false` when removed); a Unique update also sends the unique count. Adds, removals, locks and uses send this instead of the whole table |

`AddUnique` stores a copy of the metadata it is given and keeps `_cts` / `_fo` when they are already set (a trade or a restore), so two profiles never share one metadata table.

### Client: `I.Inventory`

| Field | What it is |
| --- | --- |
| `HasItem(itemId: string, quantity: string?)` | Whether the local player holds at least `quantity` (1 by default), read from `Items` |
| `Items` | The local player's inventory as last sent by the server, with `UniqueAmount` |

### Global: `I.G_Inventory`

| Field | What it is |
| --- | --- |
| `Items[itemId]` | Every item's data (`Inventory_ItemData`) |
| `Categories` | Items grouped by category (`Modules`, `Names`) |

## Usage

```lua
-- Server
I.Inventory.AddItem(player, "Potion", "3", true)
local ok, uuid = I.Inventory.CreateUnique(player, "Dragon", nil, nil, true)

-- Client
I.Topic.Subscribe("Inventory_DataUpdated-Standard", Module._refresh) -- (newData: table, initialUpdate: boolean)
```

## Network

### Server

**Topics**

- `Inventory_ItemAdded @ (player: Player, itemId: string, quantity: string)`, `Inventory_BulkAdded @ (player: Player, itemsToAdd: table)`
- `Inventory_UniqueAdded @ (player: Player, uniqueUUID: string)`, `Inventory_UniqueCreated @ (player: Player, uniqueUUID: string)`
- `Inventory_ItemRemoved @ (player: Player, itemId: string, quantity: string)`, `Inventory_UniqueRemoved @ (player: Player, uniqueUUID: string, quantity: string?)`, `Inventory_BulkRemoved @ (player: Player, removeTable: table)`
- `Inventory_ItemLocked @ (player: Player, itemId: string)`, `Inventory_ItemUnlocked @ (player: Player, itemId: string)`
- `Inventory_ItemUsed @ (player: Player, itemId: string, quantity: string)`, `Inventory_ItemUsed-Standard @ (player: Player, itemId: string, quantity: string)`, `Inventory_ItemUsed-Unique @ (player: Player, uniqueUUID: string, quantity: string)`: only after a successful `Use` (a failed `Use` gives the items back without Topics)
- `Inventory_Transferred @ (fromPlayer: Player, toPlayer: Player, idOrUUID: string, quantity: string, receivedIdOrUUID: string)`

`Inventory_BulkRemoved` carries only what was actually removed.

**Receive: RemoteEvents**

- `Inventory_RemoveBulk @ (player: Player, removeTable: table)`: checked removal (`RemoveBulk_Client`); only items with `RemoveByClientRequest`. Rate limit 2 per second.
- `Inventory_RequestUpdate @ (player: Player, dataType: string?)`: rate limit 5 per 5 seconds.

The client can't silence Topics: a client's `sendUpdate` argument is accepted by the schemas and ignored.

**Receive: RemoteFunctions**

- `Inventory_RemoveItem @ (player: Player, itemId: string, quantity: BigNum? ≥ 1, sendUpdate: boolean?)`, `Inventory_RemoveUnique @ (player: Player, uniqueUUID: string, quantity: BigNum? ≥ 1, sendUpdate: boolean?)`: checked removal. Rate limit 10 per second.
- `Inventory_GetItem @ (player: Player, itemId: string)`, `Inventory_GetUnique @ (player: Player, uniqueUUID: string, clonedData: boolean?)`: rate limit 20 per second.
- `Inventory_LockItem`, `Inventory_UnlockItem`, `Inventory_LockSwitch` `@ (player: Player, itemId: string, sendUpdate: boolean?)` (rate limit 10 per second), `Inventory_IsLocked @ (player: Player, itemId: string)` (20 per second)
- `Inventory_UseItem @ (player: Player, itemId: string, quantity: BigNum? 1 to MAX_USE_QUANTITY, useMax: boolean?)`, `Inventory_UseUnique @ (player: Player, uniqueUUID: string, quantity: BigNum? 1 to MAX_USE_QUANTITY, useMax: boolean?)`: only items with `UseByClientRequest`. Rate limit 10 per second.

**Send: RemoteEvents**

- `Inventory_UpdateClientData @ (player: Player, dataType: string, newData: table | number)`: a whole part, or `UniqueAmount`
- `Inventory_UpdateClientChanges @ (player: Player, dataType: string, changes: table)`: only the changed entries (`false` for removed)

### Client

**Topics**

- `Inventory_DataUpdated-Standard`, `Inventory_DataUpdated-Unique`, `Inventory_DataUpdated-Locked` `@ (newData: table, initialUpdate: boolean)`

**Receive: RemoteEvents**

- `Inventory_UpdateClientData @ (dataType: string, newData: table | number)`
- `Inventory_UpdateClientChanges @ (dataType: string, changes: table)`

**Send: RemoteEvents**

- `Inventory_RemoveBulk @ (removeTable: table)`, `Inventory_RequestUpdate @ (dataType: string?)`

**Send: RemoteFunctions**

- The server's remote functions above, without `player`.

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Inventory.Standard[itemId]` | Quantity, a BigNum string |
| | `Inventory.Unique[uuid]` | `{ Id, Metadata }`; metadata keeps the quantity in `_q` and engine fields `_cts`, `_fo` |
| | `Inventory.Locked` | Locked item ids |
| | `Inventory.UniqueAmount` | Unique items counted |
| `Data/Items/<Item>.lua` | | `Name`, `IconId`, `Rarity`, `Category`, `RemoveByClientRequest`, `UseByClientRequest` (clients may use it), `Use`, `UseRequirements`, `_setupFunction` |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `CATEGORIES` | `General`, `Other` | Valid categories; an unknown one becomes `Other` |
| `MAX_USE_QUANTITY` | `100` | Most of one item used at once |
| `MAX_UNIQUE_ITEMS` | `5000` | Most unique items a player holds |
| `RECOUNT_MARGIN` | `20` | Recount unique items when fewer free slots than this remain |

## Commands

`inventory` (server): `add_standard`, `remove_standard`, `add_unique`, `create_unique`, `remove_unique`, `lock`, `unlock`, `lock_switch`, `is_locked`, `use_standard`, `use_unique`, and `get` (`item`, `unique`, …), each taking a `player` first.
