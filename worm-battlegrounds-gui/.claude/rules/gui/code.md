---
paths:
  - "src/**/*.lua"
---

# UmeGui code

What Lua in `src/` adds to the shared Luau rules. Gui modules return only a table and follow `gui/format.md`; controls,
Preview modules and theme files are scripts. Match the file next to the one you change.

## Skeleton

- After the author header: `local _localName: string = "Name"`.
- Require regions, in this order: **Directories**, **Services** (each `game:GetService` once, there), **Engine**,
  **Libs**.
- Controls and Preview modules keep their schema or settings in the module table, under `--[[ Section ]]` labels.
- A control's lifecycle is `Build`, then the **Control** rail (changes things) and **Methods** (reads). `return Module`.

## Classes

- Shapes are `UmeGui_*` classes in `src/engine/_meta/_types.lua`, named after their path: `UmeGui_Controls_Button`,
  `UmeGui_Guis_<Folder>_<Gui>_Preview`.
- A theme's `init.lua` is typed `--- @type UmeGui_ThemeDefinition`, a style file `--- @type` its style table, a gui
  module `--- @type UmeGui_Gui`.

## Changing a gui

The gui module is the source, and the Gui tool's preview comes first: StarterGui only ever gets an export of it.

- Every change (a look, a layout, an element, a new design) goes into the gui's table, and into its `Preview` module for
  what the game fills in at runtime (rows, slots, colours a module sets). Check it in the Gui tool, then export it over
  the copy in the place.
- Never make or show a change by restyling a built or exported copy with a script (a Studio command, an MCP call): the
  Gui tool never shows it, and the next export throws it away.
- Design options to compare are guis too, one per option, in a folder named after the gui:
  `src/guis/<Folder>-<Gui>/<NN>_<Option>/` (`init.lua`, `Preview.lua`), with one `_meta/README.md` listing them. Each
  keeps the gui's `Name`, Ids and prefab names, so any of them exports in its place, and its `Preview` runs the gui's
  own preview first. The picked option goes into the gui itself, and the option folder goes once the user says so.
- Screenshots for review are captures of those modules, never of a restyled copy.
- **Same sizes and looks in every gui.** Before giving an element a size or a look, find how the other guis beside it
  and their theme's controls draw that kind of element, and reuse those values or that control. Never a one-off value for one
  gui: a new look changes everywhere that element appears. After changing a gui, check it for values that differ from
  the rest, outline thicknesses first.

## Checks

- After every Lua change: selene and StyLua (`AGENTS.md` → Commands) or ume-sync's `check` (`luau/studio.md`). Fix what
  they report in your files.
- Structural changes (new folders, `init.lua` conversions): ume-sync's `instance_tree`, or the build in `AGENTS.md` →
  Commands.
- In Studio, with the Roblox Studio MCP: `GetErrors` and `Build` on `ServerStorage.UmeGui` for every gui you changed,
  in each of its modes.

To look at a gui:

- Build it (`UmeGui.Build` or `UmeGui.Export`) into a ScreenGui named `__Ume_Preview` in StarterGui, with `Archivable`
  off (so a save never keeps it) and `ZIndexBehavior` `Sibling`, as exports have it (a ScreenGui made by a script is
  `Global`, which hides children behind their parents' siblings). Capture, then destroy `__Ume_Preview`. Never build
  into CoreGui: `screen_capture` doesn't show it.
- The capture draws CanvasGroups as plain frames, with no clipping and no `GroupTransparency`: check those in the Gui
  tool.
- Tweens play during the call: open the gui through its own code (its Preview's `Apply`; `I.WidgetManager.Open` in a
  play test) and `task.wait` until they finish before capturing, since a running tween overwrites a value set directly.
