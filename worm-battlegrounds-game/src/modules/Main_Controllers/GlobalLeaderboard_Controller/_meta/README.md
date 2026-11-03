# GlobalLeaderboard_Controller

The game's global leaderboards and the boards and statues that show them. On the server it registers one store per `TRACKED_STATISTICS` entry (Playtime by default) and keeps it updated from that statistic, writing only values that changed, all players at once; it builds the tagged boards and dummy statues from the cached top pages, with player names, flags and avatars. On the client it plays an animation on the statues.

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/GlobalLeaderboard_Controller` |
| Runs on | Server, Client |
| Exposes | `I.GlobalLeaderboard_Controller` (server) |
| Uses | `I.GlobalLeaderboard`, `I.Statistic`, `I.CountryCode`, `I.Component`, `I.Topic`, `I.Player`, `I.G_Player` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Registers the tracked statistics' update functions and writes them, value formatting, name and country caches, registers the server components |
| `Client.lua` | Registers `GLC_Dummy` |
| `Settings.lua` | Tracked statistics, cache size |
| `Components/S_Leaderboard.lua` | A board: rows of place, name, flag, avatar and value |
| `Components/S_Dummy.lua` | A statue of the player at one place |
| `Components/Dummy.lua` | Plays the statue's animation on the client |
| `_meta/_types.lua` | `GlobalLeaderboard_Controller_TrackedStatistic` |

## API

### Server: `I.GlobalLeaderboard_Controller`

| Function | Returns | What it does |
| --- | --- | --- |
| `ConvertValue(value: number, displayType: string)` | `string` | Formats a value for a board: `"Time"` as a duration, any other type the `Default` way |
| `GetPlayerName(playerId: number)` | `string?` | A user's name, cached |
| `GetPlayerCountryData(playerId: number)` | | A user's country, cached |

## Data

| Where | Key | What |
| --- | --- | --- |
| `OrderedDataStore` per `TRACKED_STATISTICS` entry | `[userId]` | The statistic's value, as a raw integer |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `TRACKED_STATISTICS` | `Playtime` | `[statisticName] = { UpdateGroup, PageSize, IsAscending }`: a store of that name, written from the statistic in `UpdateGroup`, whose top page is cached with `PageSize` (at most 100) and `IsAscending` |
| `CACHE_MAX_ENTRIES` | `5000` | Names and countries cached before the oldest are dropped |

Shipped entry: `Playtime = { UpdateGroup = "Statistic", PageSize = 100, IsAscending = false }`.

## Components

The `GLC` prefix stands for GlobalLeaderboard_Controller. A board or statue reads the store named by `GLC_LeaderboardName` (and `GLC_Scope`) from the cache and refreshes on `GlobalLeaderboard_Updated` for that store. `{day}`, `{week}` and `{month}` in the name are replaced with today's UTC day of the year, week of the year and month. For a store in `TRACKED_STATISTICS` the page is read with that entry's `PageSize` and `IsAscending`; for any other store `GLC_PageSize` and `GLC_IsAscending` must match the store's registration. When the store updated but nothing is cached for the board's read, it warns once.

### `GLC_S_Leaderboard` (`Components/S_Leaderboard.lua`)

| | |
| --- | --- |
| Tag on | `Model` (a SurfaceGui board) or `ScreenGui` |
| Side | Server (`Register`) |
| Needs | An `S_Container` descendant holding `Place_*` row prefabs; optional `S_PlaceIcons` |

| Attribute | Type | Default | What |
| --- | --- | --- | --- |
| `GLC_LeaderboardName` | string | `""` | Store name |
| `GLC_Scope` | string | `""` | Store scope |
| `GLC_IsAscending` | boolean | `false` | Lowest first (stores not in `TRACKED_STATISTICS` only) |
| `GLC_PageSize` | number | `50` | Rows shown |
| `GLC_DataDisplayType` | string | `"Standard"` | How values are formatted (`ConvertValue`): `"Time"` as a duration, anything else the default number format |
| `GLC_ConvertValue` | boolean | `false` | Values were stored log base 1.0000000001 and are decoded first; leave off for raw stores such as Playtime |
| `GLC_IsPlayerLeaderboards` | boolean | `true` | Keys are user ids: show names, flags and avatars |

| ObjectValue child | Points to | What |
| --- | --- | --- |
| `GLC_Container` | | In the manifest, but the script finds `S_Container` by name instead |

### `GLC_S_Dummy` (`Components/S_Dummy.lua`)

A statue of the player at place `GLC_PlaceId`, rebuilt when the board updates. A failed avatar fetch is retried on the next update; the statue is removed with its component.

| | |
| --- | --- |
| Tag on | `Model` |
| Side | Server (`Register`) |

| Attribute | Type | Default | What |
| --- | --- | --- | --- |
| `GLC_LeaderboardName`, `GLC_Scope`, `GLC_IsAscending`, `GLC_PageSize`, `GLC_DataDisplayType`, `GLC_ConvertValue` | | | As on `GLC_S_Leaderboard` (`GLC_ConvertValue` defaults to `false`) |
| `GLC_PlaceId` | number | `1` | Which place the statue shows |
| `GLC_IsR15` | boolean | `true` | Rig type of the statue |
| `GLC_DummyScale` | number | `1` | Statue scale |
| `GLC_InsertPlaceholderDummy` | boolean | `true` | Show a placeholder while the place is empty |
| `GLC_Client_AnimationId` | number | `0` | Animation the statue plays (passed to `GLC_Dummy`) |

### `GLC_Dummy` (`Components/Dummy.lua`)

| | |
| --- | --- |
| Tag on | The statue model `GLC_S_Dummy` builds |
| Side | Client (`RegisterOnLoaded`) |

| Attribute | Type | Default | What |
| --- | --- | --- | --- |
| `GLC_Client_AnimationId` | number | `0` | Animation to load and play |
