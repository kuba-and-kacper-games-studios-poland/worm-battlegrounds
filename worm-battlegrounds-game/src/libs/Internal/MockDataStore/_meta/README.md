# MockDataStore

In-memory stand-ins for `DataStore` and `OrderedDataStore` with the same methods, used when the game has no DataStore access (Studio without API access).

| | |
| --- | --- |
| Folder | `src/libs/Internal/MockDataStore` |
| Exposes | `I.MockDataStores` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | Exposes both classes |
| `Scripts/DataStore.lua` | Mock DataStore |
| `Scripts/OrderedDataStore.lua` | Mock OrderedDataStore and its pages |
| `_meta/_types.lua` | The mock types |

## API

### I.MockDataStores.DataStore

| Function | Returns | What it does |
| --- | --- | --- |
| `DataStore.new()` | `MockDataStores_DataStore` | Creates an in-memory DataStore substitute. |
| `DataStore:SetAsync(key: any, value: any)` |  | Stores a copy of `value` under `key`. |
| `DataStore:UpdateAsync(key: any, transform: (oldValue: any) -> any)` | `any` | Passes a copy of the current value to `transform` and stores its result. Returning nil from `transform` cancels the update, like the real API. |
| `DataStore:IncrementAsync(key: any, delta: number?)` | `number` | Adds `delta` (default 1) to the number stored under `key` and returns the new value. |
| `DataStore:RemoveAsync(key: any)` | `any` | Removes the value under `key` and returns it. |
| `DataStore:GetAsync(key: any)` | `any` | Returns a copy of the value stored under `key`. |

### I.MockDataStores.OrderedDataStore

| Function | Returns | What it does |
| --- | --- | --- |
| `OrderedDataStore.new()` | `MockDataStores_OrderedDataStore` | Creates an in-memory OrderedDataStore substitute. |
| `OrderedDataStore:SetAsync(key: any, value: number)` |  | Stores a number under `key`. |
| `OrderedDataStore:UpdateAsync(key: any, transform: (oldValue: number?) -> number?)` | `number?` | Passes the current number to `transform` and stores its result. Returning nil from `transform` cancels the update, like the real API. |
| `OrderedDataStore:IncrementAsync(key: any, delta: number?)` | `number` | Adds `delta` (default 1) to the number stored under `key` and returns the new value. |
| `OrderedDataStore:RemoveAsync(key: any)` | `number?` | Removes the number under `key` and returns it. |
| `OrderedDataStore:GetAsync(key: any)` | `number?` | Returns the number stored under `key`. |
| `OrderedDataStore:GetSortedAsync(isAscending: boolean, pageSize: number, minValue: number?, maxValue: number?)` | `MockDataStores_DataStorePages` | Returns pages of entries sorted by value (ties by key), optionally limited to [minValue, maxValue]. |

## Usage

```lua
local store = if I.DataStoreAccess then DataStoreService:GetDataStore("Stock") else I.MockDataStores.DataStore.new()
```

## Types

In `_meta/_types.lua`: `MockDataStores_PageData`, `MockDataStores_DataStorePages`.
