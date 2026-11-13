# TopBar_Controller

The game's buttons in Roblox's top bar. It adds two buttons on the left of the TopBar module's bar: a gear (the System theme's `gear` icon, `rbxassetid://123765846716976`) opens and closes the `Settings` widget through WidgetManager, and the music button mutes the music by setting the saved `Music` volume to 0, and brings it back to the volume it had, or its default. The music button shows notes while the music plays (`rbxassetid://101278000628566`) and crossed-out notes while it's muted (`rbxassetid://117397305535105`), the repo's `art/topbar` icons uploaded to The Snail Studio group; it follows the volume when the Settings window changes it, and shows in the lobby and in matches, where MatchHud adds Leave game after it.

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/TopBar_Controller` |
| Runs on | Client |
| Uses | `I.TopBar`, `I.WidgetManager`, `I.PlayerSettings`, `I.Replicator` (the `Settings` folder's `Music`), `I.Settings` (the Settings module's `GUI_NAME` and `Music` default) |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | The top bar's buttons |
