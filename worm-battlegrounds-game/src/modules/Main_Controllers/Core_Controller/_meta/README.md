# Core_Controller

Sets up Roblox's own interface for the game. At start it hides every core gui; `ENABLE_DELAY` seconds after the player has loaded it turns the core guis in `ENABLED_CORE_GUIS` back on (chat, player list, emotes menu and captures by default). It also replaces the reset button with one that kills the character by setting its `Humanoid`'s health to 0 (at most once a second, and also while a spawn `ForceField` is up), so other modules see a normal death.

| | |
| --- | --- |
| Folder | `src/modules/Main_Controllers/Core_Controller` |
| Runs on | Client |
| Uses | `I.Core`, `I.Debounce`, `I.OnLoaded` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Core gui visibility and the reset button callback |
| `Settings.lua` | Which core guis come back, and when |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `ENABLED_CORE_GUIS` | `Captures`, `Chat`, `EmotesMenu`, `PlayerList` | `Enum.CoreGuiType`s turned back on after loading; every other core gui stays hidden |
| `ENABLE_DELAY` | `3` | Seconds after loading before they are turned on |
