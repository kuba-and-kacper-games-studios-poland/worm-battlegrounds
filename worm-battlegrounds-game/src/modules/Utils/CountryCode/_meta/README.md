# CountryCode

Each player's country. When a player joins, the server reads their country (from `LocalizationService`, falling back to their locale) and saves the code in their profile and the `CountryData` DataStore when it differs from the saved one, so a returning player's country follows them. It returns the country with its name and flag from the `Country` library. Other players' countries can be looked up by user id, from a cache; a user id with no saved country is not read again for `MISS_RETRY_SEC`.

| | |
| --- | --- |
| Folder | `src/modules/Utils/CountryCode` |
| Runs on | Server |
| Exposes | `I.CountryCode` (server) |
| Uses | `LocalizationService`, `I.Country`, `I.G_Player`, `I.Topic` |
| Saves | `Profile.CountryCode.SavedCountryCode` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Reading, saving and caching countries |
| `Settings.lua` | Cache size |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `country_code` command |

## API

### Server: `I.CountryCode`

| Function | Returns | What it does |
| --- | --- | --- |
| `SavePlayerCountry(player, force: boolean?)` | `boolean` | Reads the player's country and saves it when the code changed (`force`: skips the debounce and saves even an unchanged code) |
| `GetPlayerCountryData(player)` | `Country_CountryData?` | The player's country |
| `GetPlayerCountryDataById(playerId: number)` | `Country_CountryData?` | Any user's country, cached; misses are cached for `MISS_RETRY_SEC` |

## Network

No remotes.

### Server

**Topics**

- `CountryCode_DataUpdated @ (player: Player, countryData: table)`: after a player's country was saved.

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `CountryCode.SavedCountryCode` | Numeric ISO country code |
| DataStore `CountryData` | user id | Numeric ISO country code, read by `GetPlayerCountryDataById` |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `CACHE_MAX_ENTRIES` | `5000` | Countries (and, separately, misses) cached before the oldest are dropped |
| `MISS_RETRY_SEC` | `600` | Seconds before a user id with no saved country is read from the DataStore again |

## Commands

`country_code` (server): `update`, `get`, `get_by_name`, `get_by_id`.
