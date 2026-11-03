# Premium_Controller

Roblox Plus perks. The server works out the player's bonus, `PLUS_BONUS` while they have Roblox Plus, on join and whenever their subscription changes. The framework doesn't apply it: each game applies it at the `#TODO` in `Server.lua` (a currency multiplier or anything else).

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/Premium_Controller` |
| Runs on | Server |
| Uses | `I.Marketplace` (`Marketplace_RobloxPlusUpdated`) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The Roblox Plus bonus on `Marketplace_RobloxPlusUpdated`; the game applies it at the `#TODO` |
| `Settings.lua` | The bonus amount |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `PLUS_BONUS` | `0.1` | Bonus for Roblox Plus members (`0.1` = 10%) |
