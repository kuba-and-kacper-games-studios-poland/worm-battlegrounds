# ume-gui and a game's gui folder

## Who owns what

| Folder | Owner | In a game's gui folder |
| --- | --- | --- |
| `src/guis/<Game>*/` | the game | The game's guis, in folders of its own (any name but `Plugin` and `System`) |
| `src/themes/<Game>/` | the game | The game's theme: `Extends = "System"`, with its own `Styles/` and `Controls/` |
| Other skills | the game | The game's own skills. Its rules live in the code folder's `.claude/rules/game/` (`family/family.md` → Rules) |
| `src/engine/` | ume-gui | Never edit. A fix or a control every game needs goes to ume-gui; one only this game needs goes in its theme's `Controls/` |
| `src/engine/Libs/Mirror/` | generated | Never edit: `./scripts/Sync.ps1 Libs` |
| `src/themes/System/` | ume-gui | Never edit; restyle in the game's theme |
| `src/guis/Plugin/` | ume-gui | Never edit. The plugin's widgets, built on System: examples for the game's development tools |
| `src/guis/System/` | ume-gui | Never edit (below) |
| `scripts/`, `docs/` | ume-gui | Never edit |

`src/guis/System/` holds the guis every game starts with: `Prompt` (the default ProximityPrompt), `TopBar` (the game's
buttons in Roblox's top bar), the guis ume's modules find by name (`BackpackPlus`, `CommandBar`, `Currency`,
`Dashboard`, `HoverInfo`, `Main`, `Notify`, `Settings`, `WidgetManager_Confirmation`, `WidgetManager_Message`,
`AFKTeleport`), and two lookups that are never
exported: `_Primitives_ButtonsAnimations` (every ButtonScale preset) and `_Primitives_ButtonsColors` (the colours to
build System-styled buttons from; check it before picking one). To make one the game's own, copy it into
`src/guis/<Game>/` and change its values there. It keeps its `Name`, Ids and prefab names, which the modules look
for; only a prompt gets a `Name` of its own.

In ume-gui itself every folder is yours to change: keep `src/guis` to `Plugin/` and `System/`, and `src/themes` to
`System/`. A plugin widget changes here together with the ume-rbx tool that drives it.

## Gui READMEs

Every gui is a folder: `<Gui>/init.lua` (the table), an optional `Preview.lua`, and `_meta/README.md`. A gui that a
module or a plugin tool drives (every System gui) has an `## Integration` section, shaped as in `docs/readme-template.md`: its setup in the place, every input
that controls it (keyboard, mouse, touch, gamepad, and where each is bound) and its interaction looks (colours,
gradients, scales, tweens). It changes in the same piece of work as the gui, its keys or the module behaviour it
describes.

What a gui table can't hold is set in the place after each export (an ObjectValue's target, such as a slot's
`Currency_UIScale`; TagList+ adds the empty ObjectValue with the tag), and the README's Integration → Setup lists that
step.

## Libs mirror and generated files

- `./scripts/Sync.ps1 Libs` copies the framework libraries that previews need (components, signals, sounds) from
  the framework folder beside it (`../<name>-game` in a game, `../ume` beside ume-gui) into `src/engine/Libs/Mirror`;
  `-Check` reports drift without writing. A mirrored library is changed in the framework folder, then mirrored again.
- Never edit by hand: `src/engine/Libs/Mirror/**` and every theme's `Gamepad.lua` (generated outside this repo).

## Versions

`src/engine/Version.model.json` is UmeGui's version. Bump the minor version when the API grows, and the major version
when the host API changes (`gui/format.md` → Host API). Tag ume-gui releases `v<version>`: new-project's setup copies
the newest tag, and ume-rbx's releases bundle it.
