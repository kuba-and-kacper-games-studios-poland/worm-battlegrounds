# AGENTS.md — the gui folder

The game's guis (`<name>-gui`), on UmeGui (copied from ume-gui by new-project's setup). `../AGENTS.md` names the game,
gives the versions and maps the repo; the code that drives these guis is in the code folder (`../<name>-game`).

Every gui is a ModuleScript that returns only a table; UmeGui builds it from controls styled by a theme. This folder
syncs one thing into the place, `ServerStorage.UmeGui`, which only Studio uses: the Ume Roblox plugin's Gui tool
previews the guis and exports them (to StarterGui, prompt styles to `ReplicatedStorage.Ume.Assets.ProximityPrompts`),
and the game's code uses those exports. Game code never requires UmeGui.

## Read first

- `.claude/rules/gui/format.md`: gui tables, controls, styles, themes, devices, views.
- `.claude/rules/gui/code.md` with `.claude/rules/luau/*`: how Lua here is written, and how a gui is changed and checked.
- `.claude/rules/gui/repo.md`: which folders are the game's, gui READMEs, generated files.
- The code folder's `.claude/rules/game/practices.md`: the game's decisions, its gui ones included
  (`family/family.md` → Rules).
- The unit READMEs: the gui's or theme's `_meta/README.md`, `src/engine/_meta/README.md`,
  `src/engine/Controls/_meta/README.md`.

## Commands

```sh
rokit install                                                # selene and stylua at the versions in rokit.toml
selene src                                                   # lint, after every Lua edit
stylua --check src                                           # formatting, after every Lua edit
ume-sync build default.project.json -o <scratchpad>/gui.rbxl # after structural changes (gui/code.md)
./scripts/Sync.ps1 Libs [-Check]                             # regenerate (or check) src/engine/Libs/Mirror from the code folder
```

## Map

Who owns each folder and what may be edited: `gui/repo.md` → Who owns what.

| Path | In the place | What |
| --- | --- | --- |
| `src/guis/<Game>` | `UmeGui.Guis.<Game>` | The game's guis: windows, huds, prompts, world guis |
| `src/guis/<Game>-System` | `UmeGui.Guis.<Game>-System` | The game's development guis, on the System theme |
| `src/guis/<Game>-<Gui>` | | Design options for one gui while they're compared (`gui/code.md`) |
| `src/themes/<Game>` | `UmeGui.Themes.<Game>` | The game's theme: `Styles/` and its own `Controls/` |
| `src/engine` | `ServerStorage.UmeGui` | The engine: `init.lua` (the API), `Engine/`, `Controls/`, `Primitives.lua`, `Libs/` |
| `src/engine/Libs/Mirror` | `UmeGui.Libs.Mirror` | The game's libraries, mirrored for previews (generated) |
| `src/themes/System` | `UmeGui.Themes.System` | The default theme |
| `src/guis/Plugin` | `UmeGui.Guis.Plugin` | The Ume plugin's widgets: examples for development tools |
| `src/guis/System` | `UmeGui.Guis.System` | The guis ume's modules find by name, the default prompt and top bar (`gui/repo.md`) |
| `docs/`, `scripts/` | | Getting started, ADRs, the README template; the Libs mirror script |

## Skills

`readme` (`.claude/skills/readme/SKILL.md`): write or refresh a unit's `_meta/README.md` (a gui, a theme, the engine).
Skills the game adds are listed in `../AGENTS.md`.

## Studio

This folder is the game's gui project in UmeSync (its name: `../AGENTS.md` → Studio). Connecting:
`.claude/rules/luau/studio.md`; checking guis there: `gui/code.md` → Checks.
