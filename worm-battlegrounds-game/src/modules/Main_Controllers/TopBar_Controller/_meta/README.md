# TopBar_Controller

The game's buttons in Roblox's top bar. It adds two buttons on the left of the TopBar module's bar: a gear (the System theme's `gear` icon, `rbxassetid://123765846716976`) opens and closes the `Settings` widget through WidgetManager, and, outside a match, the music button (**Mute music**, **Play music** while muted; text like the match's own beside Leave game, MatchHud's top bar) mutes the music by setting the saved `Music` volume to 0, and brings it back to the volume it had, or its default. It follows the volume when the Settings window changes it, and hides while the player is in a match (the `InMatch` Player attribute).

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/TopBar_Controller` |
| Runs on | Client |
| Uses | `I.TopBar`, `I.WidgetManager`, `I.PlayerSettings`, `I.Replicator` (the `Settings` folder's `Music`), `I.Settings` (the Settings module's `GUI_NAME` and `Music` default) |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | The top bar's buttons |
