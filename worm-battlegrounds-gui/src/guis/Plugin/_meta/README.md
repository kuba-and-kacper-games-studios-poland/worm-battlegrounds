# Plugin

The Ume Roblox plugin's widgets: one gui per tool window or view, all on the System theme in Night and Light (they follow Studio's theme). ume-rbx copies this folder with the engine (`scripts/Sync.ps1 Gui`) and draws its widgets from that copy. Every game's gui folder gets it too, so the Gui tool previews the widgets in any place and a game can start its own development tools from them. ume-gui owns the folder; a game never edits it (`gui/repo.md`).

| | |
| --- | --- |
| Folder | `src/guis/Plugin` (`UmeGui.Guis.Plugin`) |
| Theme | `System` |
| Modes | `Night`, `Light` |
| Preview | Each gui has a `Preview` size: its widget's size |
| Scrolling | Every page `Scroll` adds the `Overlay` variant: its bar draws over the content, so pages keep their width when they start to scroll |

## Guis

| Path | Driven by (ume-rbx tool) | What it is |
| --- | --- | --- |
| `Plugin/Ume` | SessionLock | The Ume window's header, with its view buttons |
| `Plugin/SessionLock` | SessionLock | The Ume window's first view: the session lock |
| `Plugin/PluginSettings` | PluginSettings | A view in the Ume window: the plugin's settings |
| `Plugin/SavedData` | SavedData | A view in the Ume window: each tool's saved section, to export, import or remove |
| `Plugin/SavedDataTransfer` | SavedData | The floating window that saves or collects the part files of a split export |
| `Plugin/Sync` | Sync | Views Projects, Settings and Review |
| `Plugin/Gui` | Gui | The Category dropdown, the Kind switch (Default, Surface, Billboard, Prompt; the tool shows only the kinds the category has guis of, and hides the switch with fewer than two), a searchable list of guis in a box that scrolls past six rows, the part settings for Surface guis, the mode, device and pad switches, the previewed gui's own settings, and the Sound section's Volume slider for the preview's button sounds; has a `Preview` module |
| `Plugin/GuiResize` | GuiResize | The gui classes with their properties, and the Scale / Offset conversion; has a `Preview` module |
| `Plugin/ColorPalette` | ColorPalette | The UIGradient library |
| `Plugin/Scraper` | Scraper | The image asset library |
| `Plugin/TagListPlus` | TagListPlus | Pages Tags and Overview |
| `Plugin/LightingManager` | LightingManager | Pages Lighting and Sky |
| `Plugin/Photobooth` | Photobooth | The booth's models, camera views and picture export |
| `Plugin/Character` | Character | A user's character preview, inserted into Workspace, and the Recent list |

## Driven by

Each tool's `Gui/Main.lua` in ume-rbx mounts its gui through `Helpers/UmeGui` and finds its elements by Id. The tool's own README (`ume-rbx/src/core/Plugin/Modules/Tools/<Tool>/_meta/README.md`) describes what it does with them, so an Id or prefab changes here together with that tool.

## Preview

`Gui/Preview.lua` (`UmeGui_Guis_Plugin_Gui_Preview`) has no settings: it fills the widget with example guis (categories `Hud`, `Plugin`, `System`; `Hud`'s eight Default guis show the list scrolling past six rows) and wires the Category dropdown, the Kind switch and the search to the list, so clicking through the preview behaves like the tool: the Kind switch offers only the picked category's kinds and hides with one (`Plugin`), and a kind the category lacks falls back to Default, else its first kind (`System` has `TopBar` and `Prompt`). Surface shows the part settings; Prompt changes the export button to **Export prompt style**.

`GuiResize/Preview.lua` (`UmeGui_Guis_Plugin_GuiResize_Preview`) fills the class list in the Gui tool's preview:

| Setting | What it does |
| --- | --- |
| `S_Classes` (Slider, 0 to 8) | How many example class rows; with none, the empty message shows instead |
| `S_Expanded` (Toggle) | Opens the first row with its Size and Position properties |
| `S_Status` (Button) | Shows an example status line |
