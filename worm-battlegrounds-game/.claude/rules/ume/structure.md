# Ume structure

How a game module is laid out: `Server.lua` / `Client.lua` / `Global.lua` and `Scripts/`. `luau/file.md` is the base
(skeleton, rails, names, splits, fail fast, gui writes); this rule adds what the framework needs. Template:
`docs/guides/module-structure.md`.

## Top of the file

After the author header: the Ume pointer, `_localName`, then the module's Settings when it has one.

```lua
--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "Currency"

--- @type Currency_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))
```

- A file that never uses `I` keeps both pointer lines commented out with a leading `-- ` (`-- --- @type Ume`); never
  delete them.
- Region bars, in this order when present: **Services**, **Directories**, **Data**, **Scripts**, **Templates**,
  **Components**, **Local Variables**, **Local Functions**.
- An entry script ends with `return { _init = Module.Init, _start = Module.Start }`, even when those functions are
  omitted (`_start` may be nil). `Scripts/` modules `return Module`.
- The `I` pointer is valid for the whole module lifecycle: call APIs directly
  (`I.Currency.HasEnough(player, "Cash", "30")`). What exists during `Init`: Init and Start, below.

## Services

`I.S.ServiceName` inside functions. A service is cached as a local only in the top **Services** region, for tight
loops (`RunService`); never `local x = I.S.ContextActionService` inside a function.

## Hidden server code

`HideServerScripts` moves each child of the Ume instance whose name starts with `s_` or contains `server` (any case)
into a protected folder, children and all. So:

- `Scripts/Server` is hidden. Client and shared code (`Client.lua`, `Scripts/Client`, `Scripts/Global`,
  `Scripts/Helpers`, client components) never starts its name with `s_` or has `server` in it.
- Scene instances named `S_` (`S_Container`) are lookups; this doesn't apply to them.
- `_meta` folders are hidden at runtime too (the protect start task).

## Handlers

A module that does one thing and stays under the line band (`luau/file.md`) lives in its entry scripts. A Global script
that only caches data or models may pass 1000 lines.

A module that does more splits into one handler per system, by environment: `Scripts/Server/`, `Scripts/Client/`,
`Scripts/Global/` (when Global is more than a cache). The entry stays a thin shell: requires, `Handler.Init()` and
`Handler.Start()` calls, the registry of any system still on the entry, and the `I` assignment.

- A handler uses the entry's skeleton and `return Module`, with `Init` / `Start` only when it needs setup.
- The entry calls `Handler.Init()` in `Module.Init` under INITIALIZATION, before ASSIGN TO INSTANCE. The handler may
  own its system's `Get*` / `Fired` / `Topic.Register` there (`ume/events.md`).
- `Handler.Init` runs before this module's `I` table exists. Work that needs `I.ThisModule`, a sibling's `I` API, a
  `Topic.Subscribe` or a foreign `Fired` goes in `Handler.Start`, called from the entry's `Module.Start`.
- **Only the entry assigns `I`**, inside ASSIGN TO INSTANCE.
- `Scripts/Helpers/` is for a function more than one environment uses. It replicates, so a helper only the server uses
  stays in `Scripts/Server`. Create it only when something is shared; a helper's `Init` is called from the entry's
  INITIALIZATION.
- A handler split into a folder (`luau/file.md` → When to split) names its side scripts by the hiding rule above.
- Class names: `ume/classes.md`.

```lua
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Mounting = require(_scripts:FindFirstChild("Server"):FindFirstChild("Mounting")) --- @type Pets_Server_Mounting
```

```lua
	----------------------------
	------ INITIALIZATION ------
	----------------------------

	Mounting.Init()
```

## Init and Start

- No empty `Init` or `Start`.
- A module's own registry and setup run in `Init` (its REGISTRY block, or a handler's `Init`), `Main_Controllers`
  included.
- Calls into a sibling in the same modules folder (its `I` API, `Topic.Subscribe`, a foreign `Fired`) go in `Start`.
  Calls into a module of an earlier `ModulesDirs` folder may stay in `Init` (`Main_Controllers` comes last). When
  unsure, `Start`.
- Sibling `Init` order isn't a contract, and a `Topic.Subscribe` before its `Register` warns and never connects.
- Core start tasks (`src/core/game_instance/Start/tasks/`) keep `if I.Started then return end` bare, with no
  `--[[ Checks ]]`.

## Rails

Before Control and Methods (`luau/file.md`), ume adds **Main** (when there is a session loop) → **Initialization** →
**Player Control** (when needed).

- **Main**: `Module._mainLoop()` (title **Main Loop**), called from `Module.Start`, wires the repeating loop
  (`I.DoEvery`, a Heartbeat poll, a per-player sweep).
- **Initialization** is one-shot setup (`_getElements`, `_populate*`, `_createConnections`, `_connectReplicator`).
  Initialization and Player Control stay private.
- `I.ModuleName` tables group `--[[ Control ]]`, `--[[ Methods ]]`, `--[[ Data ]]`, then `--[[ Internal ]]` when
  needed; public functions in a rail follow that order.
- Warnings start ``[{_localName}::{script.Name}]: ``.
- A loop over players wraps each player's call in a `pcall`, so one error doesn't stop the rest (a single-player
  client tick doesn't need it):

```lua
local success: boolean
local result: any | string?
success, result = pcall(Module._updatePlayer, player)
if not success then
	warn(`[{_localName}::{script.Name}]: Failed to update player for ({player.Name})! - ({result})`)
end
```

## Cache `Get*`

A miss warns under `--[[ Checks ]]` and returns from inside the `if`, with no `--[[ Returning ]]` there and no blank
lines in it.

- **Data rows**: warn and `return nil`. Never fall back to a default row.
- **Models**: return the cache's fallback model with a warning (`… model is missing - using <Fallback>.`); which
  model is the fallback is the game's to decide (its game rules). Only when that is missing too, warn `… is missing!`
  and `return nil`.
- An id-less singleton model getter warns and returns nil.

```lua
-- Check if the item has a model
if not cachedItemModels[itemId] then
	if fallbackModel then
		warn(`[{_localName}::{script.Name}]: Item ({itemId}) model is missing - using {fallbackModel.Name}.`)
		return fallbackModel
	end
	warn(`[{_localName}::{script.Name}]: Item ({itemId}) model is missing!`)
	return nil
end
```

## Locals, replicator, gui

- Locals: `elems` and `prefabs` first when used; `connections` only when they are disconnected later; then
  `--[[ General ]]` for the module's ScreenGui (`moduleGui`) and Replicator folders (`moduleRep`).
- `_getElements` assigns `moduleGui = I.UserInterface.UI["ModuleName"]` first, then `--[[ General ]]` /
  `--[[ Prefab ]]` elements.
- `_connectReplicator` runs only through `I.OnLoaded(...)`, never from `Init` or `Start`, and caches
  `I.Replicator.GetFolder` once onto the General locals.
- `_createConnections` is one-shot wiring after `_getElements`, including the module gui's `Enabled`
  (`ume/environments.md` → Client).
- A module never opens its own window: windows open through WidgetManager (`I.WidgetManager.Open(name)`, or a
  button's `Interact_Button` tags in the gui), and the module draws one when WidgetManager publishes
  `WidgetManager_Opened` with its name (ume-gui's `gui/format.md` → Widgets).
- A module that drives a gui keeps that gui's `_meta/README.md` → Integration true (in a game's gui folder, `../<name>-gui`,
  or ume-gui's for a System gui): its keys, colours, gradients and tweens change there in the same change.
- Gui writes follow `luau/file.md` → GUI writes. Prefer `instance.UIGradient.Color = …` to
  `FindFirstChild("UIGradient")`.
