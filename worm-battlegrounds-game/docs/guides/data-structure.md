<h1 align="center">Data Structure</h1>

<p align="center">
How authored rows live under <code>ModuleName/Data</code>: typing one-off vs shared schemas, PascalCase keys, nested folders, and how entry scripts <code>require</code> them. For the module skeleton and top-of-file <strong>Data</strong> region, see <a href="module-structure.md">Module Structure</a>; for strict constants use <a href="settings-structure.md">Settings Structure</a>.
</p>

---

## 📑 Table of contents

| Name                                                                   | Description                                                        |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------ |
| **[📊 Role of `Data/`](#role-of-data)**                                | Where data lives vs Settings and key naming.                       |
| **[📄 One-off definition](#one-off-definition)**                       | Single `@class` row modules.                                       |
| **[🗂️ Many files sharing one schema](#many-files-sharing-one-schema)** | `_meta/_types.lua` plus thin `@type` row files.                    |
| **[📜 Entry scripts and loading](#entry-scripts-and-loading)**         | Requiring from `Server` / `Client` / `Global` and `Init` caching.  |
| **[🔗 Related](#related)**                                             | Cross-links to module structure, settings, types, and global data. |

---

<span id="role-of-data"></span>

## 📊 Role of `Data/`

Data sits in **`ModuleName/Data`** (nested folders allowed — organize to match how your loaders walk the tree).

Compared to **Settings**, data is **looser**: entries can mix constants and default-like values. Prefer **PascalCase** keys for authored rows (**`HelloWorld`** style) when representing entities.

---

<span id="one-off-definition"></span>

## 📄 One-off definition

When something does **not** belong in Settings, give it its **own** class on the single module:

```lua
--- @class ModuleName_MyData
local data = {
	Name = "Golden Sword",
}
return data
```

That file is a unique **1‑of‑1** definition.

---

<span id="many-files-sharing-one-schema"></span>

## 🗂️ Many files sharing one schema

Describe the shared shape once in **`_meta/_types.lua`**:

```lua
--- @class ModuleName_MyData
---
--- # General #
---
--- @field Name string
--- @field IconId number?
---
--- # Tags #
---
--- @field Rarity string?
--- @field Category string?
local _moduleName_MyData = {}
```

Then each row file stays thin. Two or more keys always get `--[[ Title Case ]]` sections (blank line after `{`). Skip a named group only when the table has a **single** key:

```lua
--- @type ModuleName_MyData
local data = {

	--[[ General ]]

	Name = "Example",
	IconId = 123,

	--[[ Tags ]]

	Rarity = "Common",
}
return data
```

Annotation conventions: [Types](types.md).

---

<span id="entry-scripts-and-loading"></span>

## 📜 Entry scripts and loading

In **`Server.lua` / `Client.lua` / `Global.lua`**, the **`--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data`** region **`require`**s these modules.

- **Unique** or small sets — require directly in that region when cheap.
- **Large sets** (items, units, ...) — prefer requiring during **`Init`**, caching results, and validating as needed.

Full layout of regions and directory locals: [Module Structure](module-structure.md) (see **Above the banner**).

---

<span id="related"></span>

## 🔗 Related

- [Module structure](module-structure.md)
- [Settings Structure](settings-structure.md)
- [Types](types.md)
- [Global data](../reference/global-data.md) — repo-wide tunables under `src/global_data/`
