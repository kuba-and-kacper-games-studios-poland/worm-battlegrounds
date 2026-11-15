# Favorite_Controller

**Off on every map** since 2026-11-15 (the owner: "remove the favorite pop-up showing in the game entirely, even
after purchase"): it's in the place loader's `ALWAYS_OFF`, so neither prompt shows. Its saved keys stay.

Asks players to favourite the game, at most twice ever: once `PROMPT_AFTER_JOINED` seconds after their first join, and once `PROMPT_AFTER_PURCHASE` seconds after their first purchase of anything. It waits for the client to say whether the prompt opened; only a prompt that opened is saved as shown, so one that didn't (another prompt was open, the client failed or timed out) is tried again on the next join or purchase.

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/Favorite_Controller` |
| Runs on | Server |
| Uses | `I.Favorite`, `I.Topic` (Marketplace purchase Topics), `I.G_Player` |
| Saves | `Profile.Favorite_Controller` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The two prompts and when they fire |
| `Settings.lua` | The delays |

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Favorite_Controller.FirstTimePromptShown` | The after-joining prompt opened |
| | `Favorite_Controller.MarketplacePromptShown` | The after-purchase prompt opened |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `PROMPT_AFTER_JOINED` | `90` | Seconds after joining |
| `PROMPT_AFTER_PURCHASE` | `30` | Seconds after a purchase |
