# Unit READMEs

*Shared rule: the same file is in ume, ume-gui and ume-rbx, and in both folders of every game, where it is read only.
Change all copies together (`family/family.md`).*

Every unit of Luau code has a `<unit>/_meta/README.md` saying what it is, what it exposes and how to use it. It is the
only place the unit is described (`luau/file.md`). `/readme <unit folder>` writes or refreshes one.

| Repo | Units | Template |
| --- | --- | --- |
| ume (a game's code folder, `<name>-game`) | Each module (`src/modules*/<Dir>/<Module>/`), each library (`src/libs/{Internal,External}/<Lib>/`), the core (`src/core/`) | `docs/guides/module-readme.md` |
| ume-gui (a game's gui folder, `<name>-gui`) | Each gui (`src/guis/<Folder>/<Gui>/`; the plugin's widgets share one, `src/guis/Plugin/`, a row per widget), each theme (`src/themes/<Theme>/`), the engine (`src/engine/`), the controls (`src/engine/Controls/`, a section per control) | `docs/readme-template.md` |
| ume-rbx | Each tool (`src/core/Plugin/Modules/Tools/<Tool>/`), plus `Modules/Helpers/` and `Modules/Primitives/` with one section per file | `docs/tool-readme.md` |

## What it holds

- The template's sections in its order, leaving out empty ones (never "None").
- What the code does now, read from the code.
- Every public name, parameter, return value, remote, Topic, attribute, setting, saved key and command the unit
  exposes, and nothing it doesn't: tables for APIs, attributes, settings and commands, short sentences around them,
  code only in Usage.
- It changes in the same change as anything it lists. A new unit gets its README when it is created.

## Where it lives

- `.md` files never sync into Studio, so a README costs nothing at runtime. Never write unit docs as a `.txt` (it
  becomes a StringValue) or as comments in a `.lua` file.
- Never add a `_meta` folder where code requires every child of a folder: in ume-gui, not directly in `src/themes/` or a theme's
  `Styles/`. The generated `src/engine/Libs/Mirror/` is described in the engine's README.
