# Game

The game's own starter module. `src/modules/Main_Game` holds the game's modules, one folder each: the loader runs the `Server.lua`, `Client.lua` and `Global.lua` it finds in each module folder, so a loose script dropped straight into `Main_Game` never runs. This folder is that shape with nothing in it yet, following [Module structure](../../../../../docs/guides/module-structure.md): fill it in, or copy it and rename the folder, `_localName`, the Settings class and the `I` table for another module. It creates no remotes, Topics or saved data.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Game` |
| Runs on | Client, Server |
| Exposes | `I.Game` (client, server), empty for now |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The server side: every template region, `Init` sections and `Start`, ready to fill |
| `Client.lua` | The client side, the same way |
| `Settings.lua` | `Game_Settings`, empty for now |
