<h1 align="center">Module Structure</h1>

<p align="center">
Standard layout for an ume module: <code>Server.lua</code> / <code>Client.lua</code> / <code>Global.lua</code>, shared folders (<code>Scripts/</code>, <code>Components/</code>, <code>Data/</code>, <code>Templates/</code>), section banners, <code>Init</code> / <code>Start</code>, registry, and exposing APIs on the framework pointer <code>I</code>. Authoring rows under <code>Data/</code>: [Data Structure](data-structure.md).
</p>

---

## 📑 Table of contents

| Name                                                                                              | Description                                                     |
| ------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| **[🎯 Goals](#goals)**                                                                            | Same skeleton, stable `%` order, prescribed sections.           |
| **[📐 Section banners and ASCII art](#section-banners-and-ascii-art)**                            | Region bars, banner, short bars, and category rails.            |
| **[📜 Entry scripts](#entry-scripts)**                                                            | Global / Server / Client template, regions, and registry.       |
| **[🧩 Below `Init` / `Start`: module functions](#below-init-start-module-functions)**             | Rails after `Start`, private vs public buckets, `return` shape. |
| **[📂 Handlers and helpers](#scripts-folder-modules)**                                            | `Scripts/Server`, `Scripts/Client`, `Scripts/Global`, `Scripts/Helpers`. |
| **[🔗 Related](#related)**                                                                        | Links to components, data, settings, comments, types, events.   |

---

<span id="goals"></span>

## 🎯 Goals

- **Same skeleton everywhere** so modules stay easy to read, refactor, and navigate.
- **Sections stay ordered** — do not reorder the `%` blocks or the major regions below the banner.
- **Nothing belongs “where it fits”** — use the prescribed sections (see [Comments](comments.md) for comment rules).

---

<span id="section-banners-and-ascii-art"></span>

## 📐 Section banners and ASCII art

The **`%` lines** (long `--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ...` region bars, shorter `--%%%%%%%%%%%%%%%%%%%%` labels, and wide `--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%` rails) plus the **ASCII art** block are **not** optional decoration. They are the **map** of the file: jump points for humans, a shared contract for where code belongs, and a stable shape across every module and component.

| Kind               | Pattern                                                                                                      | Role                                                                                                                                                                  |
| ------------------ | ------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Region bars**    | `--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%` + a label (Services, Directories, Data, ...) | Split the **top of the file** into fixed regions. Keep labels consistent; **do not** delete empty regions until you have removed the whole section and its variables. |
| **Module banner**  | ASCII art block between two region bars                                                                      | **Major separator** between setup (requires, folder refs, cached locals) and the **`Module` table** (or component class). Treat it like a chapter break.              |
| **Short bars**     | `--%%%%%%%%%%%%%%%%%%%% Name`                                                                                | Mark **`Init` / `Start`**, **each function**, and major **subsections** inside long functions. Readers scan these first.                                              |
| **Category rails** | `--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SectionName`    | Group big areas below `Init`/`Start` (Initialization, Control, Methods, ...).                                                                                         |

When editing: **preserve** these markers; add new code **inside** the right region rather than inventing ad-hoc headings. Same rules apply to **component** scripts — see [Component Structure](component-structure.md).

---

<span id="entry-scripts"></span>

## 📜 Entry scripts

Each module may ship **Global**, **Server**, and **Client** scripts. They share one structural template; scripts under <code>ModuleName/Scripts</code> follow the same conventions with small differences (see [Scripts folder modules](#scripts-folder-modules)).

### 📋 Template

```lua
--[[
	Created By: 	{username}
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "{moduleName}"

--- @type {moduleName}_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _components = script:FindFirstAncestor(_localName):FindFirstChild("Components")
local _data = script:FindFirstAncestor(_localName):FindFirstChild("Data")
local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Templates

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Components

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance | GuiObject }
local prefabs = {} --- @type { [string]: Instance | GuiObject }
local connections = {} --- @type { [string]: RBXScriptConnection }

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--   __       __                  __            __
--  /  \     /  |                /  |          /  |
--  $$  \   /$$ |  ______    ____$$ | __    __ $$ |  ______
--  $$$  \ /$$$ | /      \  /    $$ |/  |  /  |$$ | /      \
--  $$$$  /$$$$ |/$$$$$$  |/$$$$$$$ |$$ |  $$ |$$ |/$$$$$$  |
--  $$ $$ $$/$$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |$$    $$ |
--  $$ |$$$/ $$ |$$ \__$$ |$$ \__$$ |$$ \__$$ |$$ |$$$$$$$$/
--  $$ | $/  $$ |$$    $$/ $$    $$ |$$    $$/ $$ |$$       |
--  $$/      $$/  $$$$$$/   $$$$$$$/  $$$$$$/  $$/  $$$$$$$/
--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	----------- DATA -----------
	----------------------------

	----------------------------
	------ INITIALIZATION ------
	----------------------------

	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Topic

	--- @Network

	--- @Component

	----------------------------
	---- ASSIGN TO INSTANCE ----
	----------------------------

	----------------------------
	-------- POST-INIT ---------
	----------------------------
end

--%%%%%%%%%%%%%%%%%%%% Start

function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ###

--%%%%%%%%%%%%%%%%%%%% ###

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
```

### 📍 Top of file

1. **<code>I</code>** — <code>require</code> the Ume pointer from <code>ReplicatedStorage</code>; this pattern stays the same in every module. If the script never uses <code>I</code>, comment the require and its <code>--- @type Ume</code> with a leading <code>-- </code> (do not delete the lines).
2. **<code>\_localName</code>** — module folder name; used with <code>FindFirstAncestor</code>.
3. **Settings** — <code>require(...Settings)</code> when the module has <code>Settings.lua</code>; omit if there is no settings module. Authoring rules: [Settings Structure](settings-structure.md).

### ✅ Mandatory layout rules

- **Section order** must stay intact — do not reorder blocks.
- The required **`I`** at the top is **always valid** in normal module lifecycle.
- Put variables and functions **only** in their designated sections — never “in the middle” of the script.

### 🔀 Flow from the top of the file

Always start with the Ume pointer require and **`_localName`** — same pattern in every module.

Remove the settings **`require`** entirely when the module has no **`Settings.lua`**.

The **`%`** regions **above the ASCII art** store module data and locals; keep them strictly organized.

### 🎨 Above the banner (`%` blocks before ASCII art)

| Section         | Purpose                                                                                                                                                                                                                                                                                     |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Services**    | Prefer <code>I.S.\*</code>. Cache in a local only when used heavily (for example <code>RunService</code> in a tight loop).                                                                                                                                                                  |
| **Directories** | <code>FindFirstChild</code> for <code>Components</code>, <code>Data</code>, <code>Scripts</code> (and optionally others). No existence checks — if a folder is missing and you still use it, that is a script error. Remove unused directory locals **and** the section if nothing remains. |
| **Data**        | <code>require</code> data modules from <code>Data/</code> — see [Data Structure](data-structure.md); cache and validate during <code>Init</code> when loading many defs (items, units).                                                                                                     |
| **Scripts**     | <code>require</code> helpers or handler modules from <code>Scripts/</code>.                                                                                                                                                                                                                 |
| **Templates**   | Optional; example: player session templates under a <code>Templates</code> folder.                                                                                                                                                                                                          |
| **Components**  | Internal component classes **not** registered with <code>I.Component.Register</code> — lightweight OOP helpers used only inside this module (rare).                                                                                                                                         |

#### Services (detail)

Usually skip this section because **`I.S.ServiceName`** is enough. If you hammer the same service (for example **`I.S.RunService.Heartbeat`**), cache it **only** in this **Services** region at the top of the file. Never assign `I.S.*` to a local inside a function.

```lua
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Services

local RunService = I.S.RunService
```

#### Directories (detail)

These locals point at folders **directly under** the module (`ModuleName/Components`, `ModuleName/Data`, `ModuleName/Scripts`). Three folders cover most cases; add another only when needed.

If a folder **does not exist** or is **unused**, remove that `FindFirstChild` local **and** remove the whole **Directories** section when nothing is left.

**Do not add a Luau type** to directory locals — `FindFirstChild` may return **`nil`**. Leave them untyped.

Lookups are **not** validated here: if a folder is absent but the script still uses it, the script is wrong.

```lua
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _components = script:FindFirstAncestor(_localName):FindFirstChild("Components")
local _data = script:FindFirstAncestor(_localName):FindFirstChild("Data")
local _scripts = script:FindFirstAncestor(_localName):FindFirstChild("Scripts")
```

#### Data (detail)

Patterns for files under **`Data/`** (typing, folders, one-off vs shared schema): [Data Structure](data-structure.md). In this script: require **unique** or small sets in the **Data** region; for **large sets**, require during **`Init`**, cache results, and validate as needed.

#### Scripts (detail)

Require handlers and helpers from **`ModuleName/Scripts`** so the environment script stays a thin shell. When to split, where each handler lives, and who assigns **`I`** is [`.claude/rules/ume/structure.md`](../../.claude/rules/ume/structure.md). This is the require shape:

```lua
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scripts

local Mounting = require(_scripts:FindFirstChild("Server"):FindFirstChild("Mounting")) --- @type Pets_Server_Mounting
local Stats = require(_scripts:FindFirstChild("Helpers"):FindFirstChild("Stats")) --- @type Pets_Stats
```

**`s_` / `server` hiding** stops at the hidden instance, so children of `Scripts/Server` stay parented. That behavior is the structure rule. Scene instances named `S_` (`S_Container`) are a lookup name only.

#### Templates (detail)

Optional folder — today mainly **player** session templates:

```lua
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Directories

local _templates = script:FindFirstAncestor(_localName):FindFirstChild("Templates")

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Templates

--- @type Player_Session
local sessionTemplate = require(_templates:FindFirstChild("SessionTemplate"))
```

#### Components (detail — internal OOP, not tag-driven)

For **metaclass** scripts used **inside** this module only — **not** registered with **`I.Component.Register`**. Example: ground collectibles built with **`OrbComponent.new(...)`** instead of clone + tag; skips the Component module overhead. Use sparingly.

### 📦 Local variables

> **Never** store module state on **`Module`** (`Module.Health` is forbidden). Only **functions** attach to **`Module`**. Put shared state in **Local Variables** (or closures).

**elems** — mostly client; filled from **`_getElements()`**; typically **`S_`**-prefixed names for stable discovery. That prefix on a scene instance does **not** hide it. Hiding applies to ModuleScripts and folders whose names start with **`s_`** or contain **`server`** (structure rule).

**prefabs** — same pattern but keys come from **`PREFAB \| ...`** names for clone/reuse.

**connections** — only if those connections are **disconnected** later. Do **not** keep an empty `connections` table, and do **not** stash gui `Enabled` or replicator `AttributeChanged` listeners that live for the session.

Organize with **`--[[ Section Name ]]`** subsections — **no** extra line comments inside those blocks; names must read cleanly:

```lua
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Variables

local elems = {} --- @type { [string]: Instance | GuiObject }
local prefabs = {} --- @type { [string]: Instance | GuiObject }

--[[ General ]]

local moduleGui: ScreenGui
local moduleRep: Folder

--[[ Some Data ]]

local createdSlots = {}
local selectedId: string?
```

### ⚙️ Local functions

A `local function` is for work called from two or more places in that script. A single call site stays inline ([file](../../.claude/rules/luau/file.md)). Same **`%`** titles, summary blocks, and **`--- @return`** rules as public **`Module`** functions ([Comments](comments.md), [Types](types.md)):

```lua
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions

--%%%%%%%%%%%%%%%%%%%% Do Something

--[[
	This function does this... and that...
]]
local function doSomething(a: string, b: number?)
	--...
end

--%%%%%%%%%%%%%%%%%%%% Do Something Else

--[[
	This function does something else...
]]
--- @return string
local function doSomethingElse(a: string, b: number?)
	--...
end
```

### 🚀 `Init` and `Start`

Between the ASCII banner and the long **`%`** divider, **only** **`Module.Init`** and **`Module.Start`** may appear — no stray functions in that gap. Do **not** put a summary block above **`Init`** / **`Start`** (short `%` title only).

**Init** runs first; **Start** runs after every module has finished **Init** ([Startup order](../architecture/startup-order.md)). Where registry, handler `Init` / `Start`, and `I` assignment go is [`.claude/rules/ume/structure.md`](../../.claude/rules/ume/structure.md).

You may omit unused **`function Module.Init()`** / **`function Module.Start()`** definitions (do not keep empty stubs). **Always** keep **`return { _init = Module.Init, _start = Module.Start }`** — `_start` may be nil.

Remove **empty** labeled sections inside **`Init`** / **`Start`** to reduce noise.

#### `Init` sections (omit unused blocks entirely)

1. **DATA** — Mostly server: stamp defaults onto profile / session templates.

```lua
----------------------------
----------- DATA -----------
----------------------------

--- @type Player_ProfileData
local _pt = I.Player.ProfileTemplate
_pt["ModuleName"] = {}

--- @type Player_SessionData
local _st = I.Player.SessionTemplate
_st["ModuleName"] = {}
```

2. **INITIALIZATION** — Everything required for setup (caches, UI, hooks).

```lua
----------------------------
------ INITIALIZATION ------
----------------------------

--[[ General ]]

Module._getElements()
Module._cacheData()
Module._createConnections()
Module._updateGui()

--[[ Player Setup ]]

I.G_Player.OnPlayerAdded:Connect(2, Module._validateItems)
I.G_Player.OnPlayerAdded:Connect(1, Module._createReplicator)
I.G_Player.OnPlayerAdded(I.Priority.Replicator, Module._updateReplicator)

--[[ Framework Started ]]

I.OnStarted(I.Priority.Default, Module._doSomethingOnFrameworkStarted)

--[[ Framework Loaded ]]

I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)

--[[ Handlers ]]

-- Only handlers that define Init. This runs before ASSIGN TO INSTANCE.
Mounting.Init()
```

`_connectReplicator`, listener stashing, and the gui `Enabled` check: [`.claude/rules/ume/structure.md`](../../.claude/rules/ume/structure.md). **`_createConnections`** (Init, after `_getElements`) is where those session listeners are wired.

Small loops, guards, or terse notes are fine when intent would otherwise be opaque.

3. **REGISTRY** — Topics, network, and components that still live on **this entry**. Lead each subsystem with **`--- @Topic`**, **`--- @Network`**, **`--- @Component`** when present; drop the label if unused. A split system keeps its `Get*` / `Fired` / `Topic.Register` inside that handler’s `Init` (called from INITIALIZATION above). Who may `Get*` and inbound `argTypes`: [`.claude/rules/ume/events.md`](../../.claude/rules/ume/events.md). Template: [Events](events.md).

Minimal pattern:

```lua
----------------------------
--------- REGISTRY ---------
----------------------------

--- @Topic
I.Topic.Register("ModuleName_TopicName")
I.Topic.Subscribe("ModuleName_TopicName", Module._onTopicName)

--- @Network
I.Network.GetEvent("ModuleName_RemoteName")
I.Network.Fired("ModuleName_RemoteName", Module._onRemoteName)

--- @Component
I.Component.Register("ModuleName_ComponentName", _components.ComponentName)
I.Component.RegisterOnLoaded("ModuleName_ComponentNameOnLoaded", _components.ComponentNameOnLoaded)
```

The shared id (`@class`, `*.comp.json` Name, `Register` / `RegisterOnLoaded`, `AddTag`) is [`.claude/rules/ume/components.md`](../../.claude/rules/ume/components.md). See [Component Structure](component-structure.md).

Large registry (Inventory-style organization):

```lua
----------------------------
--------- REGISTRY ---------
----------------------------

--- @Topic

--[[ Added Topics ]]

I.Topic.Register("Inventory_ItemAdded")
I.Topic.Register("Inventory_BulkAdded")

I.Topic.Register("Inventory_UniqueAdded")
I.Topic.Register("Inventory_UniqueCreated")

--[[ Removed Topics ]]

I.Topic.Register("Inventory_ItemRemoved")
I.Topic.Register("Inventory_UniqueRemoved")
I.Topic.Register("Inventory_BulkRemoved")

--- @Network

--[[ Remove Control ]]

I.Network.GetFunction("Inventory_RemoveItem", { "Player", "string", { Type = "string", Optional = true }, { Type = "boolean", Optional = true } })
I.Network.GetFunction("Inventory_RemoveUnique", { "Player", "string", { Type = "string", Optional = true }, { Type = "boolean", Optional = true } })
I.Network.GetEvent("Inventory_RemoveBulk", { "Player", { Type = "table" } })
I.Network.OnInvoke("Inventory_RemoveItem", Module.RemoveItem)
I.Network.OnInvoke("Inventory_RemoveUnique", Module.RemoveUnique)
I.Network.Fired("Inventory_RemoveBulk", Module.RemoveBulk)

--[[ Get Control ]]

I.Network.GetFunction("Inventory_GetItem", { "Player", "string" })
I.Network.GetFunction("Inventory_GetUnique", { "Player", "string", { Type = "boolean", Optional = true } })
I.Network.OnInvoke("Inventory_GetItem", Module.GetItem)
I.Network.OnInvoke("Inventory_GetUnique", Module.GetUnique)

--[[ Data Events ]]

I.Network.GetEvent("Inventory_RequestUpdate", { "Player", { Type = "string", Optional = true } })
I.Network.Fired("Inventory_RequestUpdate", Module.UpdateClientData)

I.Network.GetEvent("Inventory_UpdateClientData")
```

4. **ASSIGN TO INSTANCE** — Publish **`I.ModuleName`** APIs (and optional **`I.G_ModuleName`** shared tables). This assignment stays in the **entry** script. A handler does not assign **`I`**. A public function that lives on a handler is `Handler.Name`.

Naming (same-script helpers versus the public surface) is the structure rule.

```lua
----------------------------
---- ASSIGN TO INSTANCE ----
----------------------------

I.Pets = {

	--[[ Control ]]

	Mount = Mounting.Mount,
	Merge = Merging.Merge,

	--[[ Methods ]]

	GetPet = Inventory.GetPet,

	--[[ Internal ]]

	_recount = Inventory._recount,
}
```

Expose cached tables **carefully** — other modules might mutate them:

```lua
I.G_Inventory = {

	--[[ Data ]]

	Items = cachedItems,
	Categories = cachedCategories,
}
```

Keep **`--[[ ... ]]`** groupings inside **`I.*`** tables — **no** extra prose comments there.

5. **POST-INIT** — Omit this block unless the entry must run something **after its own** `I.ModuleName` assignment and still inside `Init`. Do not call `Handler.Init` here. Sibling `I` APIs are not ready until `Start`.

#### `Start`

Runs after **all** modules finish **Init**. Call `Handler.Start()` here when that handler defines `Start`. This is also the place for a same-directory sibling (`Topic.Subscribe` / foreign `Fired`, or a sibling `I` API). Omit unused **`Init`** / **`Start`**.

```lua
function Module.Start()
	----------------------------
	--------- STARTING ---------
	----------------------------

	Mounting.Start()
end
```

---

<span id="below-init-start-module-functions"></span>

## 🧩 Below `Init` / `Start`: module functions

Rail order, Control versus Methods and names are [`.claude/rules/luau/file.md`](../../.claude/rules/luau/file.md); ume's extra rails, cache `Get*` and the per-player `pcall` are [`.claude/rules/ume/structure.md`](../../.claude/rules/ume/structure.md). Short **`--%%%%%%%%%%%%%%%%%%%%`** titles still separate **each function** ([Comments](comments.md)).

Syntax reference:

```text
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SectionName
```

Examples: **Main**, **Initialization**, **Player Control**, **Control**, **Methods**.

Per-function titles:

```text
--%%%%%%%%%%%%%%%%%%%% Do Thing
```

Closing shape stays fixed:

```lua
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returning

return {
	_init = Module.Init,
	_start = Module.Start,
}
```

Example pair:

```lua
--%%%%%%%%%%%%%%%%%%%% Do Something

--[[
	This function does this... and that...
]]
function Module.DoSomething(a: string, b: number?)
	--...
end

--%%%%%%%%%%%%%%%%%%%% Get Sorted

--[[
	Returns rows sorted by LayoutOrder. Script-private.
]]
--- @return { ModuleName_Row }
function Module._getSorted()
	--...
end
```

---

<span id="scripts-folder-modules"></span>

## 📂 Handlers and helpers

Normative split, `I` re-export, `Init` / `Start` call sites and `s_` / `server` hiding: [`.claude/rules/ume/structure.md`](../../.claude/rules/ume/structure.md). The line band: [`.claude/rules/luau/file.md`](../../.claude/rules/luau/file.md). Class names: [Types](types.md).

```text
ModuleName/
  Server.lua
  Client.lua
  Global.lua
  Scripts/
    Server/
      Inventory.lua
      Mounting.lua
    Client/
      InventoryGui.lua
    Helpers/
      Stats.lua
```

A handler or helper **`return Module`** (no `{ _init, _start }` unless it intentionally mirrors an entry script). `Init` / `Start` exist only when that file needs setup. The entry calls them; the handler does not assign **`I`**.

```lua
--- @class Pets_Server_Mounting
local Module = {}

--%%%%%%%%%%%%%%%%%%%% Init

function Module.Init()
	----------------------------
	--------- REGISTRY ---------
	----------------------------

	--- @Network
	I.Network.GetEvent("Pets_Mount", { "Player", "string" })
	I.Network.Fired("Pets_Mount", Module._onMount)
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control

--%%%%%%%%%%%%%%%%%%%% Mount

function Module.Mount(player: Player, petId: string)
end

return Module
```

Every function still gets its own **`--%%%%%%%%%%%%%%%%%%%%`** heading ([Comments](comments.md)). Entry **`Init`** / **`Start`** keep the short `%` title only.

---

<span id="related"></span>

## 🔗 Related

- [Component Structure](component-structure.md)
- [Data Structure](data-structure.md)
- [Settings Structure](settings-structure.md)
- [Comments](comments.md)
- [Types](types.md)
- [Events](events.md)
- [Startup order](../architecture/startup-order.md)
