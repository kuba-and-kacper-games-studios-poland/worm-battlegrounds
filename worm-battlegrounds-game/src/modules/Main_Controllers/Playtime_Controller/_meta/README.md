# Playtime_Controller

Counts time played. Every `UPDATE_EVERY` seconds it adds that many seconds to each player's `Playtime` statistic.

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/Playtime_Controller` |
| Runs on | Server |
| Uses | `I.Statistic`, `I.DoEvery` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The playtime tick |
| `Settings.lua` | The tick interval |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `UPDATE_EVERY` | `1` | Seconds between increments |
