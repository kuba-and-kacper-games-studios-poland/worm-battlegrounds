# Ume components

Component ModuleScripts in `<Module>/Components/`, each with a `*.comp.json`. Layout and `I.Component`:
`docs/guides/component-structure.md`. Tag registry: `docs/guides/tag-list-plus.md`.

## Class and lifecycle

- `Component.new` sets `Instance`, `Connections`, `_destroyed`. The `@class` lists those three first, ungrouped; every
  other `self.` field goes under a `--- # Group #` heading by job.

```lua
--- @class ModuleName_ComponentName : Component
--- @field Instance Instance
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
---
--- # State #
---
--- @field Id string
--- @field Value number
local Component = {}
Component.__index = Component
```

## Destroy

Keep the connection-disconnect loop in `Destroy` exactly as it is: its comments, order and body. New cleanup goes
below it.

## Names

- One id names the component everywhere: its `@class`, the `*.comp.json` `Name`, `Register` / `RegisterOnLoaded` and
  `AddTag`. It is `ModuleName_ComponentName`, or a short prefix for a long module name (`LMC_Row`), used for its
  attributes too (`LMC_RowName`). Never mix the full name and the prefix on one component.
- No `Scripts/` module of the same module uses that id as its `@class`: rename the script instead (`Region.lua` →
  `RegionController.lua`).

## Tags and loading

- **Tags are authored, not added by code.** An element a component drives gets its tag and attributes where it is
  made: a gui's node `Tags` (ume-gui's `gui/format.md`), or the instance in the place. Code never adds or
  removes a component's tag at runtime. An effect that depends on game data keeps its tag with attributes that leave it
  off, and code turns it on and off by writing those attributes: removing a tag makes the component put back what it
  had (a `Utils_UIGradientMove` gradient's colours) over what code set.
- **A component whose tag guis export** sets `IgnoreAncestors = { I.S.ReplicatedStorage, I.S.StarterGui }`, so only the
  live copy in `PlayerGui` builds.
- **`RegisterOnLoaded` components register at `I.Priority.Late`.** What they need must exist by then: author it in the
  place, or set it up in `I.OnLoaded(I.Priority.Default, …)`, never in `Init`.

## Effects only while shown

Anything that moves a gui every frame or on a loop (scrolling gradients, spins, pulses, flipbooks, letter waves, an
eased scale) runs only while every GuiObject from it up is `Visible` and its ScreenGui, BillboardGui or SurfaceGui is
`Enabled`.

- A component follows that with the Utils module's `GuiVisibility.Watch` and leaves its loop while hidden;
  `GuiVisibility.IsShown` answers once, for work on a timer.
- A module's own loop runs only while something is moving or its gui shows, and an endless tween stops when its window
  closes.
- An effect that builds or moves many instances every frame also skips what nobody can see while it's shown (a label
  scrolled out of its list, a billboard beyond its `MaxDistance`, behind the camera or off the screen), and reads
  layout and writes properties only when they change. A gui that clips moving labels without a ScrollingFrame hides
  them while clipped, so they stop.

## Warns

A component's `warn` passes `self.Instance` as a second argument, so Studio highlights the instance, after a message
ending in ` -`:

```lua
warn(`[{_localName}::{script.Name}]: Label (S_Label) is missing! -`, self.Instance)
```
