# GlobalLeaderboard

OrderedDataStore leaderboards shared by every server. Modules get a store by name, register functions that write their players' values into it, and read the top pages; the module runs the update functions on a timer, one per update group per tick, and caches the pages it read so many boards don't hit the DataStore limits. Without DataStore access (Studio without API access) it uses a mock store.

| | |
| --- | --- |
| Folder | `src/modules_ume/Roblox/GlobalLeaderboard` |
| Runs on | Server |
| Exposes | `I.GlobalLeaderboard` (server) |
| Uses | `DataStoreService`, `I.MockDataStores`, `I.DoEvery`, `I.Topic`, `I.Config.Map` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Stores, update groups and their timer, pages and the page cache |
| `Settings.lua` | Store name prefix, update delay, value limits |
| `_meta/_types.lua` | Page data, update-function tables, store aliases |

## API

### Server: `I.GlobalLeaderboard`

A store is named `{LEADERBOARDS_PREFIX}_{storeName}_{I.Config.Map.LeaderboardStoreName}` (`GL_Playtime_Production`), plus an optional `scope`.

| Function | Returns | What it does |
| --- | --- | --- |
| `Get(storeName: string, scope: string?)` | `OrderedDataStore?` | The store (or a mock one without DataStore access) |
| `RegisterUpdateFunction(storeName, scope?, updateGroup: string, functionTable)` | | Adds `{ UpdateFunction, CacheOnUpdate?, IsAscending, PageSize }` to `updateGroup`. Every `UPDATE_DELAY` seconds (and once, in its own thread, when the framework has started) each group runs its next function in turn, every group in its own thread; a group whose previous run is still going skips the tick. With `CacheOnUpdate` the top page is read and cached right after, then `GlobalLeaderboard_Updated` is published. A turn is postponed while the DataStore budget is low (fewer `SetIncrementSortedAsync` requests left than players, or no `GetSortedAsync` request left when it caches), and the update function is skipped while the server has no players. |
| `ClearUpdateFunction(storeName, scope?, updateGroup)` | | Removes it |
| `GetPages(storeName, scope?, isAscending: boolean, pageSize: number, cache: boolean?, getCached: boolean?, respectCached: boolean?)` | `DataStorePages?` | Reads sorted pages; `cache` stores the result, `getCached` returns the stored one, `respectCached` only reads the store when nothing is cached |
| `GetItems(storeName, scope?, isAscending, pageSize, fromCachedPages: boolean?, cache?, getCached?, respectCached?)` | `{ GlobalLeaderboard_PageData }?` | The top page as `{ key, value }` rows, between `MIN_PAGE_VALUE` and `MAX_PAGE_VALUE` |
| `GetCachedItems(storeName, scope?, isAscending, pageSize)` | `{ GlobalLeaderboard_PageData }?` | A copy of the cached top page (`nil` until one was cached); never reads the store |

## Usage

```lua
I.GlobalLeaderboard.RegisterUpdateFunction("Playtime", nil, "Main", {
	UpdateFunction = Module._savePlaytimes,
	CacheOnUpdate = true,
	IsAscending = false,
	PageSize = 50,
})
I.Topic.Subscribe("GlobalLeaderboard_Updated", Module._onBoardUpdated) -- (storeFullId: string)

local rows = I.GlobalLeaderboard.GetCachedItems("Playtime", nil, false, 50)
```

## Network

No remotes.

### Server

**Topics**

- `GlobalLeaderboard_Updated @ (storeFullId: string)`: after an update function with `CacheOnUpdate` ran and its page was cached; `storeFullId` is `storeName` or `storeName::scope`.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `LEADERBOARDS_PREFIX` | `"GL"` | First part of every store name |
| `UPDATE_DELAY` | `30` | Seconds between update ticks |
| `MIN_PAGE_VALUE`, `MAX_PAGE_VALUE` | `1`, `10e15` | Values outside this range aren't returned |
