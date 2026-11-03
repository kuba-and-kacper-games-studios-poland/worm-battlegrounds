<h1 align="center">Types</h1>

<p align="center">
Luau inline types vs annotation tags (<code>--- @type</code>, <code>--- @class</code>, <code>--- @alias</code>, <code>--- @param</code>, <code>--- @return</code>), and how to organize <code>_types.lua</code>. Function headers and section comments are covered in <a href="comments.md">Comments</a>.
</p>

---

## 📑 Table of contents

| Name | Description |
| ---- | ----------- |
| **[🔤 Luau / Roblox inline types](#luau-roblox-inline-types)** | Built-in Luau and Roblox types on locals and parameters. |
| **[🧩 Custom types](#custom-types)** | `@alias`, `@class`, function annotations, and `_types.lua` layout. |
| **[📚 Related](#related)** | Links to comments, module/component structure, data, and settings. |

---

<span id="luau-roblox-inline-types"></span>

## 🔤 Luau / Roblox inline types

Use **inline** Luau types only for types that exist **in Luau / Roblox** (instances, primitives, Roblox value types).

```lua
local x: string = "hello"
local myPart: BasePart = Instance.new("BasePart")
local something: Instance = I.S.Workspace:FindFirstChild("S_SomeElem")
```

```lua
local function doSomething(a: string, b: number?)
	print(a, b)
end
```

```lua
for i: number, elem: Instance in ipairs(someTable) do
end
```

Type **both** `for` iterator bindings when they are Luau / Roblox types — including unused `_` / `_held`. Do not drop the type because the value is unused. A binding whose type is a `--- @class` uses `--- @param` above the loop, not a colon.

```lua
for id: string, _held: boolean in pairs(set) do
end
```

For **everything else** (your domain tables, settings shapes, DTOs), use **annotations** and `@class` / `@alias` below.

---

<span id="custom-types"></span>

## 🧩 Custom types

Custom types cover anything **outside** built-in Luau / Roblox — new classes and data shapes.

### 🏷️ `@alias`

Creates reusable names; can act like an enum.

```lua
--- @alias userId number @ Id of a user

--- @type userId
local a = player.UserId

-- or

local a = player.UserId --- @type userId
```

Put **`--- @type`** on its own line **above** a single assignment only when that `local` is **alone** (no sibling local in the consecutive block). Use **trailing** `--- @type` when **2–4** locals sit in a consecutive block — including mixed Luau + domain (one annotation per line, on the end of that `local` line, never above). Do not split a `pcall` / multi-assign just to put `--- @type` above. Every `local` is typed — never a bare `local x = value` (Luau / Roblox types on the colon, tables and `@class` names via `--- @type`). Every `pcall` / `xpcall` is typed: when it keeps both returns, declare `local success: boolean` and `local result: any | string?` first, then assign. `result` is the call's return on success, a string error when `success` is false. Never `local ok, err = pcall(...)`. When only success is kept: `local success: boolean = pcall(...)`.

In **`_getElements`**, always trail the assignment (`elems["Container"] = ... --- @type Frame`) even when the lookup is a single line.

Handler and helper `require`s always trail `--- @type` on that same line, even when the require is alone. Do not put the annotation above. Placement: [`.claude/rules/luau/types.md`](../../.claude/rules/luau/types.md).

```lua
--- @type userId
local a = player.UserId

--

local a = player.UserId --- @type userId
local b = player.UserId --- @type userId
local c = player.UserId --- @type userId

--

local success: boolean
local result: any | string?
success, result = pcall(require, playerModule)
```

Union-style alias (types on **one** line):

```lua
--- @alias myType "r" | "w"
--- @alias NPCInteraction_DialogueText string | (() -> string)
```

Documented **string-literal** variants only (each `---|` value is a quoted string):

```lua
--- @alias sides
---| "left" @ Left side of the screen
---| "right" @ Right side of the screen
---| "top" @ Top side of the screen
---| "bottom" @ Bottom side of the screen
```

> **Note:** In the form above, the leading **`|`** on each continuation line is required by the annotation syntax; it does **not** mean logical “OR” by itself.

### 📦 `@class`

Describes table-shaped types:

```lua
--- @class ModuleName_ClassName
--- @field a string
--- @field b number?
```

#### Where classes live

1. **`Module/_meta/_types.lua`** (core: `src/core/_meta/_types.lua`) — stub locals at the bottom; dummy local name is underscore + lowerCamel:

```lua
--- @class ModuleName_ClassName
--- @field a string
--- @field b number?
local _moduleName_ClassName = {}

--- @class ModuleName_AnotherClass
--- @field a string
--- @field b number?
local _moduleName_AnotherClass = {}
```

2. **Single-file settings or data** — class on the table you return:

```lua
--- @class ModuleName_Settings
local settings = {}
return settings
```

```lua
--- @class ModuleName_MyData
local data = {}
return data
```

If the same shape is used in **multiple files**, centralize it in **`_meta/_types.lua`** under that module.

3. **`Scripts/` module** that **`return Module`**. The class name and the no-`@field` rule are [`.claude/rules/ume/classes.md`](../../.claude/rules/ume/classes.md). Do not reuse a component tag ([Component Structure](component-structure.md)).

```lua
--- @class Pets_Server_Mounting
local Module = {}

function Module.Mount(player: Player, petId: string) end

return Module
```

#### Inheritance

```lua
--- @class Inventory_Item
--- @field CreatedTimestamp number
local _inventory_Item = {}

--- @class Inventory_Sword : Inventory_Item
--- @field Damage number
local _inventory_Sword = {}
```

#### `@type` assignments

```lua
--- @type Inventory_Sword
local newSword = {}

-- or

local newItem1 = Module.CreateRandomItem() --- @type Inventory_Item
local newItem2 = Module.CreateRandomItem() --- @type Inventory_Item
local newItem3 = Module.CreateRandomItem() --- @type Inventory_Item
local newItem4 = Module.CreateRandomItem() --- @type Inventory_Item
```

The annotated type is for **completion and organization** — it does not have to mirror every runtime field.

```lua
--- @alias Inventory_Backpack { Inventory_Item }

--- @type Inventory_Backpack
local playerBackpack = Module.GetPlayerBackpack(player)
```

Shared classes and aliases belong in **`_meta/_types.lua`** when reused. One-off shapes can stay next to a single `return` table.

### ⚙️ Functions: mix `@param`, `@return`, and inline Luau

```lua
--- @param itemData Inventory_Item
--- @return boolean
function Module.AddItem(player: Player, itemData)
	--...

	return true
end
```

> **Note:** For **`local function`**, do **not** encode return types inline on the function signature — use **`--- @return`** instead:

```lua
--- @return number
local function getValue()
	return 15
end
```

```lua
--- @param value Inventory_Item
for i: number, value in ipairs(someData) do
end
```

### 🛠️ Other handy annotation forms

```lua
--- @type string | number
local x
```

```lua
--- @type { string }
local x
```

```lua
--- @type { [string]: Inventory_Item }
local x
```

```lua
--- @type (player: Player, value: Inventory_Item) -> boolean
local addItem
```

```lua
--- @field UpdateItem (tool: Tool, initialUpdate: boolean | nil) -> ()
```

In `--- @type` / `--- @field` **function types**, optional **parameters** are **`T | nil`**, not **`T?`**. Optional **returns** may use **`T?`** or **`T | nil`**. Inline Luau colon types on `function` / `local` may still use `?`.

Prefer **`{ [K]: V }`** for dictionaries. Prefer **function types** on **`@field`** inside classes; functions under modules/settings often autocomplete without a separate function-type alias.

Use Luau table and function syntax on `@type` / `@return` / `@param` / `@field` / `@alias`, including inside another type. Arrays are `{ T }`. Dictionaries are `{ [K]: V }`. A dictionary value follows the same rule: `{ [string]: { string } }`, `{ [string]: { [string]: Model } }` — not `string[]`, not `table<string, string[]>`, not `table<string, table<string, Model>>`. Function types are `(a: string) -> string`. Record shapes stay `@class` + `@field`. Do not use `{ Field: Type }`.

`{ T }` and `{ [K]: V }` are annotation forms only. Do not put them on a colon (`orderArray: { number }`, `local list: { string }`, `cache: { [number]: any }`). Arrays, dictionaries, and a class declared with `--- @class` use `--- @param` on parameters and `--- @type` on locals. Never write a `--- @class` name on a colon (`libraryTable: Ume_Library`, `local item: Inventory_Item`). That warns. Use `--- @type` for a local and `--- @param` for a parameter or a `for` binding. A Luau or Roblox type with no `--- @class` is only the colon on the signature (`folder: Folder`, `amount: number`, `child: Instance`, `_index: number`). Do not add `--- @param` for it (`--- @param folder Folder`, `--- @param callback function`).

```lua
-- BAD (T[] and table<> in annotations)
local keys = {} --- @type number[]
--- @return string[]
--- @field Sounds string[]
local seen = {} --- @type table<number, boolean>

-- GOOD
local keys = {} --- @type { number }
--- @return { string }
--- @field Sounds { string }
local seen = {} --- @type { [number]: boolean }

-- BAD (table type on a colon)
local function evict(orderArray: { number }, mainCache: { [number]: any })
local separatedValue: { string } = text:split("e+")

-- GOOD
--- @param orderArray { number }
--- @param mainCache { [number]: any }
local function evict(orderArray, mainCache, removeCount: number)
local separatedValue = text:split("e+") --- @type { string }

-- BAD (--- @param on a type with no --- @class)
--- @param folder Folder
local function loadFolder(folder: Folder)
--- @param callback function
local function register(callback)

-- GOOD
local function loadFolder(folder: Folder)
local function register(callback: () -> ())

-- BAD (--- @class on a colon)
for _index: number, libraryTable: Ume_Library in ipairs(libraries) do
local item: Inventory_Item = row

-- GOOD
--- @param libraryTable Ume_Library
for _index: number, libraryTable in ipairs(libraries) do
local item --- @type Inventory_Item
item = row
```

### 📂 Organizing `_types.lua`

The file is `Module/_meta/_types.lua`. Core types are `src/core/_meta/_types.lua`.

Do **not** put a profile shape here. No `ModuleName_ProfileData`, no `Player_ProfileData`, and no `@class` for any key stamped on `I.Player.ProfileTemplate`. Do not annotate `moduleData` with a custom profile class, and do not add an ensure or repair function that reshapes saved profile data. The template in the module entry script is the shape.

Spread `@class` fields with **`--- # Group #`** by **functional** category (not Roblox type). Two or more fields always get sections. Skip a named group only when the class has a **single** field.

```lua
--- @class Inventory_ItemData : Inventory_UseData
---
--- # General #
---
--- @field Name string
--- @field IconId string
---
--- # Tags #
---
--- @field Rarity string
--- @field Category string
---
--- # Setup #
---
--- @field _setupFunction () -> ()
local _inventory_ItemData = {}
```

Use **`--%%%%%%%%%%%%%%%%%%%% Section`** headers when unrelated classes live in one file:

```lua
--%%%%%%%%%%%%%%%%%%%% Item Module

--- @class Inventory_ItemData : Inventory_UseData
---
--- # General #
---
--- @field Name string
--- @field IconId string
---
--- # Tags #
---
--- @field Rarity string
--- @field Category string
---
--- # Setup #
---
--- @field _setupFunction () -> ()
local _inventory_ItemData = {}

--- @class Inventory_UseData
---
--- # Use #
---
--- @field Use (player: Player, quantity: string) -> boolean
--- @field UseRequirements (player: Player, quantity: string) -> boolean
local _inventory_UseData = {}

--%%%%%%%%%%%%%%%%%%%% Inventory Item

--- @class Inventory_UniqueItem
---
--- # Identity #
---
--- @field Id string
--- @field Metadata Inventory_UniqueMetadata
local _inventory_UniqueItem = {}

--- @class Inventory_UniqueMetadata
---
--- # Record #
---
--- @field Quantity string
--- @field FirstOwner number
--- @field CreatedTimestamp number
local _inventory_UniqueMetadata = {}
```

---

<span id="related"></span>

## 📚 Related

- [Comments](comments.md) — function doc blocks, internal sections, `*` / `**SERVER** |`
- [Events](events.md) — the README's Network section, inbound Network `argTypes`
- [Module structure](module-structure.md)
- [Component Structure](component-structure.md)
- [Data Structure](data-structure.md)
- [Settings Structure](settings-structure.md)
