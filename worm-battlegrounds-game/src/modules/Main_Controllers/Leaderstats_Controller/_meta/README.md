# Leaderstats_Controller

Puts the game's values in the player list. When a player joins it adds one leaderstat per `STATS` row, and every 5 seconds it refreshes each from its source (a statistic or a currency), formatted as a duration or an abbreviated number. Rows with an unknown `Source` or `Format` are skipped with a warning at start.

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/Leaderstats_Controller` |
| Runs on | Server |
| Uses | `I.Leaderstats`, `I.Statistic`, `I.Currency`, `I.Time`, `I.BN`, `I.DoEvery`, `I.G_Player` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Adding and refreshing the leaderstats, the sources and formats |
| `Settings.lua` | The leaderstats list |
| `_meta/_types.lua` | `Leaderstats_Controller_Stat` |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `STATS` | `Playtime` | Rows of `{ Name, Priority, Source, Key, Format }`: the leaderstat's name and `Priority` (higher first), `Source` `"Statistic"` or `"Currency"`, `Key` the statistic or currency name, `Format` `"Time"` (duration) or `"Number"` (abbreviated) |

Shipped row: `{ Name = "Playtime", Priority = 1, Source = "Statistic", Key = "Playtime", Format = "Time" }`.
