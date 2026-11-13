# AssetsPreload

Loads the game's pictures, models and effects in the background as soon as a player's client has started, so a gui,
a crate opening or a weapon shows its backgrounds, icons and models at once the first time instead of popping in. When
every module has started it hands Roblox's `ContentProvider:PreloadAsync`, on a thread of its own, three lists in
turn:

1. every gui in `I.UserInterface.UI`, open or not (their frames, backgrounds and icons);
2. the asset ids (`rbxassetid://` and digits) found in the game's data and settings, which code sets on guis later:
   Inventory's items, Arsenal's weapons and Crates' rows (their icons), and every module's settings (map pictures, pad
   glyphs, badges), leaving out `SKIP_SETTINGS`;
3. the asset folder, `I.Dirs.Assets` (crate, weapon and skin models, snails' animations, Vfx effects, the lobby
   stage).

Nothing waits for it: a gui opened before its turn loads what it needs as usual. The `0_` prefix starts it before the
other Main modules, so the downloads begin early. Models in a ViewportFrame still cost their first draw (practices →
Guis); this only takes the download out of the way.

| | |
| --- | --- |
| Folder | `src/modules/Main/0_AssetsPreload` |
| Runs on | Client |
| Exposes | nothing |
| Uses | `ContentProvider`, `I.UserInterface`, `I.G_Inventory`, `I.G_Arsenal`, `I.G_Crates`, `I.Settings`, `I.Dirs` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | Gathers the three lists in `Start` and preloads them in turn on a thread of its own |
| `Settings.lua` | What counts as an asset id, how deep the scan goes, which settings it leaves out |

## Network

No remotes: everything it loads is already on the client.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `ID_PATTERN` | `"^rbxassetid://%d+$"` | A string in the data and settings that is an asset id to load |
| `SCAN_DEPTH` | `8` | How many levels of nested tables the scan follows |
| `SKIP_SETTINGS` | `{ "Rarity" }` | Modules whose settings the scan leaves out (Rarity's icons are the template's placeholders, which don't load) |
