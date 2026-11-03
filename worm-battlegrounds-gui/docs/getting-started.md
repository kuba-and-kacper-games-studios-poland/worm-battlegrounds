# Getting started

## A new game

Every game is one repo made from the [new-project](https://github.com/ume-roblox/new-project) template. Say the game
is **epic-mining**:

1. **Make the repo.** On GitHub, use the new-project template to make `epic-mining`, then clone it into your projects
   folder.
2. **Run setup.** In the repo, run `./setup.ps1` (or ask an agent to set the project up). It copies the newest ume and
   ume-gui into two folders, without their history, and names everything after the game:

   ```
   epic-mining/
   	epic-mining-game/    a copy of ume: the game's code
   	epic-mining-gui/     a copy of ume-gui: the game's guis (this repo's files)
   	epic-mining.rbxl     the place
   ```

   It also adds the game's theme (`src/themes/EpicMining`) and mirrors the game's libraries into
   `src/engine/Libs/Mirror`, so previews use the game's components and sounds. Commit the result.
3. **Sync both.** In UmeSync, make a category named after the game and add both folders to it. Open
   `epic-mining.rbxl` and connect both projects in Studio's **Sync** tool. They never sync the same instances
   (`epic-mining-game` has no `ServerStorage.UmeGui`), so both stay connected.
4. **Make guis.** Add them under `epic-mining-gui/src/guis/<Folder>/`, and restyle in the game's theme. Open the **Gui**
   tool to preview, live-reload and export them to StarterGui. `src/guis/Plugin` holds the Ume Roblox plugin's own
   widgets, built on System: preview them in the Gui tool, and start the game's development tools from them in a
   folder of the game's own. `src/guis/System/Prompt` is the default ProximityPrompt; a game's own prompt is a copy of
   it in the game's folders, with its own `Name` and values. `src/guis/System/TopBar` is the bar of game buttons in
   Roblox's top bar that ume's TopBar module fills; export it to StarterGui. The other `System` guis are the ones ume's
   modules find by name (`BackpackPlus`, `CommandBar`, `Currency`, `Dashboard`, `HoverInfo`, `Main`, `Notify`, `Settings`, the two WidgetManager widgets,
   `AFKTeleport`); export them to StarterGui too, or a copy of one restyled in the game's folders. Leave `Plugin` and
   `System` as they are; they update with the engine.

## Updating the engine

A game doesn't track ume-gui: its gui folder has no history from it. To take a newer engine, copy `src/engine`,
`src/themes/System`, `src/guis/Plugin` and `src/guis/System` (and `scripts/` and the ume-gui-owned `.claude/` files
when they changed) from a ume-gui tag over the game's gui folder, then regenerate the mirror:

```powershell
./scripts/Sync.ps1 Libs      # reads ../epic-mining-game
```

Never copy over the game's own guis or theme. A fix the game needs in ume-gui's folders goes to ume-gui first. A
game's own controls go in its theme's `Controls/` folder.

## Working on ume-gui itself

```powershell
rokit install
```

Connect this repo in a place of its own with UmeSync and open the **Gui** tool: the plugin's widgets rebuild as you
save. After every Lua change, run `selene src` and `stylua --check src`. `./scripts/Sync.ps1 Libs -Check` reports
whether the mirror still matches `../ume`.

ume-rbx builds its widgets (`src/guis/Plugin`) from this repo: while you work on both, run
`./scripts/Sync.ps1 Gui -Watch` in ume-rbx so engine and widget edits reach the plugin.

Changing one of the seven functions the plugin calls (`Build`, `Export`, `GetGuiNames`, `GetGui`, `GetPreview`,
`GetDevices`, `ApplyDevice`) is a major version; see Host API in [`gui/format.md`](../.claude/rules/gui/format.md).
