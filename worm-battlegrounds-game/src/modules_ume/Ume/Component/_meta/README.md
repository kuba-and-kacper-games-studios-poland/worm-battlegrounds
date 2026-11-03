# Component

Tag-driven components. A module registers a component class for a CollectionService tag; every instance with that tag gets its own object (`Component.new(instance)`, then `:Init()`), and removing the tag destroys it (`:Destroy()`). Instances tagged in Studio, at runtime or by an export all work the same way.

| | |
| --- | --- |
| Folder | `src/modules_ume/Ume/Component` |
| Runs on | Global: one `Global.lua` for both sides |
| Exposes | `I.Component` |
| Uses | `CollectionService`, `I.Signal`, `I.OnStarted`, `I.OnLoaded`, `I.AdminPanel_CommandBar` |

## Files

| File | What it controls |
| --- | --- |
| `Global.lua` | The registry: tag → class, the instances' component objects, the tag added and removed listeners, ancestry tracking for classes with `Ancestors` / `IgnoreAncestors`, the added and removed signals |
| `Scripts/AdminPanel/CommandBar/Global.lua` | The `component` / `s_component` commands |
| `_meta/_types.lua` | `Component`, the base class every component class extends; `Component_TagSignals` |

## API

### Global: `I.Component`

| Function | Returns | What it does |
| --- | --- | --- |
| `Register(tag: string, componentModule: ModuleScript, overwriteModule: boolean?)` | `boolean` | Requires `componentModule` and builds a component for every instance with `tag`, now (after startup) or once the framework has started, and for every instance tagged later. `false` when the tag is already registered, or was registered before with a different module and `overwriteModule` isn't set. |
| `RegisterOnLoaded(tag, componentModule)` | | Client: waits until the server says the player has loaded, then registers. On the server, or after loading, it registers at once. Use it for components that read the player's Replicator data or guis. |
| `Unregister(tag)` | `boolean` | Stops listening for the tag and destroys every component built for it. |
| `Get(instance: Instance, tag)` | `Component?` | The component object built for that instance and tag. |
| `GetAll(tag)` | `{ Component }` | Every live component of that tag. |
| `GetAddedSignal(tag)` | `Signal` | Fires with a component once its `Init` finished. |
| `GetRemovedSignal(tag)` | `Signal` | Fires with a component right before its `Destroy` (only for components whose `Init` finished). |
| `WaitFor(instance: Instance, tag, timeout: number?)` | `Component?` | The instance's component once its `Init` finished; yields until then, or returns `nil` after `timeout` seconds. |
| `IsRegistered(tag)` | `boolean` | Whether the tag has a registered class. |

**Lifecycle of one component:** `new(instance)` → `:Init()` (in its own thread) → … → `_destroyed = true` and `:Destroy()` when the tag is removed or the instance leaves the game. A `new` or `Init` that errors warns with the tag and the instance (Studio highlights it) and skips only that instance. The class shape and the `Destroy` loop: `.claude/rules/ume/components.md`, `docs/guides/component-structure.md`.

**Where a class builds.** A component class may set `Ancestors` (`{ Instance }`: build only under one of these) and `IgnoreAncestors` (`{ Instance }`: never build under these) on its class table. Tagged instances outside them (prefab templates in `ReplicatedStorage`, copies in `StarterGui`) get no component, and an instance that moves in or out builds or destroys its component.

**Manifests.** Each component has a `*.comp.json` next to it (its tag, its default attributes and ObjectValue children). ume-vscode's **Extract Components** merges them into `src/other/TagListPlus.model.json`, which the Studio plugin's TagList+ tool loads (`docs/guides/tag-list-plus.md`).

## Usage

```lua
-- Client.lua Init, REGISTRY
I.Component.RegisterOnLoaded("Currency_Slot", _components.Slot)

-- Anywhere: the object built for an instance
local slot = I.Component.Get(label, "Currency_Slot") --- @type Currency_Slot?

-- A component class that only builds on live copies
Component.IgnoreAncestors = { I.S.ReplicatedStorage, I.S.StarterGui }
```

## Commands

`component` (client) and `s_component` (server):

| Subcommand | Arguments |
| --- | --- |
| `register` | `compName` (an unregistered tag) |
| `unregister` | `compName` (a registered tag) |
| `is_registered` | `compName` |
