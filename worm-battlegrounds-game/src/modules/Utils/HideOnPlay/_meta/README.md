# HideOnPlay

Hides helper instances while the game runs: spawn markers, zone volumes, debug guis. Instances tagged `HideOnPlay` are hidden on the client, `S_HideOnPlay` on the server; a tagged Model or Folder hides everything inside it. Hiding happens when the game loads (and when the tag is added); children added later under a tagged Model or Folder are not hidden. Hiding sets class-specific properties (`Transparency = 1`, `Enabled = false`, `Visible = false`…) and remembers the originals in attributes so `Show` can put them back. Descendants whose class has no hide properties (welds, attachments, scripts…) are skipped silently; an instance tagged or passed directly with such a class warns.

| | |
| --- | --- |
| Folder | `src/modules/Utils/HideOnPlay` |
| Runs on | Global: one `Global.lua` for both sides |
| Exposes | `I.HideOnPlay` (both) |

## Files

| File | What it controls |
| --- | --- |
| `Global.lua` | Hiding tagged instances at start, `Hide` / `Show` |
| `Settings.lua` | Tags per side, which properties hide each class, the class merge order |
| `Components/HideOnPlay.comp.json`, `S_HideOnPlay.comp.json` | The two tags (handled by `Global.lua`) |
| `Scripts/AdminPanel/CommandBar/Global.lua` | The `hide_on_play` / `s_hide_on_play` commands |

## API

### Global: `I.HideOnPlay`

| Function | Returns | What it does |
| --- | --- | --- |
| `Hide(instances: { Instance })` | | Hides them (and their descendants) |
| `Show(instances: { Instance })` | | Restores what `Hide` changed |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `HIDE_TAGS` | `Client = "HideOnPlay"`, `Server = "S_HideOnPlay"` | The tag each side hides |
| `HIDE_PROPERTY_CLASS_ORDER` | `BasePart`, `Decal`, … `GuiObject` | Classes matched from general to specific; later ones override |
| `HIDE_PROPERTIES` | per class | Property values that hide it |

## Components

### `HideOnPlay` / `S_HideOnPlay` (no script)

| | |
| --- | --- |
| Tag on | Any instance; Models and Folders hide their descendants |
| Side | `HideOnPlay`: client; `S_HideOnPlay`: server |

## In the place

Hidden instances get `<Env>_HideOnPlay_<Property>` attributes holding their original values.

## Commands

`hide_on_play` (client) and `s_hide_on_play` (server), permission level 255: show or hide every instance with that side's tag in a running game.

| Subcommand | Arguments |
| --- | --- |
| `show` | |
| `hide` | |
