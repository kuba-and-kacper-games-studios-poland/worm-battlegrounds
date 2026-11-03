<h1 align="center">Settings Structure</h1>

<p align="center">
The layout of a module's <code>Settings.lua</code>: one table of constants, typed with <code>--- @class</code>, split into <code>%</code> category bars. The rule is <code>.claude/rules/ume/settings.md</code>; this guide shows it. Looser authored rows belong under <code>Data/</code>: see <a href="data-structure.md">Data Structure</a>.
</p>

---

## 📑 Table of contents

| Name | Description |
| ---- | ----------- |
| **[📄 File shape](#file-shape)** | One `Settings.lua`, its `@class` and `return`. |
| **[🔗 Reading settings](#reading-settings)** | From the same module, and from other modules. |
| **[✏️ Categories and comments](#categories-and-comments)** | `%` bars, comments, `--- @type`, blank lines. |
| **[📚 Related](#related)** | Links to module structure, data, comments and types. |

---

<span id="file-shape"></span>

## 📄 File shape

Each module has at most one <code>Settings.lua</code>, next to its entry scripts. The table is named with a leading underscore so it never clashes with Roblox's global <code>settings()</code>.

```lua
--- @class ModuleName_Settings
local _settings = {

	MESSAGE_DESPAWN_SECONDS = 1.5,
}
return _settings
```

A table with one key needs no category. The class has no <code>@field</code> lines: the table itself is the shape.

---

<span id="reading-settings"></span>

## 🔗 Reading settings

From the module's own scripts:

```lua
--- @type ModuleName_Settings
local _settings = require(script:FindFirstAncestor(_localName):FindFirstChild("Settings"))
```

From another module, in code that already has `I`:

```lua
--- @type Inventory_Settings
local inventorySettings = I.Settings["Inventory"]
```

<code>Settings.lua</code> itself never requires other modules or <code>Scripts/</code>. A setting that needs an API requires the Ume pointer and calls <code>I.OtherModule</code> inside a function, so it resolves when it runs.

---

<span id="categories-and-comments"></span>

## ✏️ Categories and comments

- Two or more keys: every key sits under a <code>--%%%%%%%%%%%%%%%%%%%% Category</code> bar, with a blank line above and below it.
- A one-line comment is <code>-- text</code>; a longer one is a <code>--[[ ]]</code> block with its text indented one tab.
- <code>--- @type</code> goes between the comment and the key, on table values whose type isn't obvious.
- Every comment, <code>--- @type</code> and bar has a blank line above it, so it never touches the key before.
- Inside a value (rows, lists), group with <code>--[[ Label ]]</code> labels.

```lua
--- @class Inventory_Settings
local _settings = {

	--%%%%%%%%%%%%%%%%%%%% General

	-- Valid categories; any other becomes the last one.
	--- @type { string }
	CATEGORIES = {

		--[[ Items ]]

		"General",
		"Seed",

		--[[ Fallback ]]

		"Other",
	},

	-- How much of any item can be used at one time.
	MAX_USE_QUANTITY = 100,

	--%%%%%%%%%%%%%%%%%%%% Unique

	-- Most unique items a player can hold.
	MAX_UNIQUE_ITEMS = 5000,

	--[[
		The inventory counts its unique items again after adding one, when fewer than this many
		slots are left.
	]]
	RECOUNT_MARGIN = 20,
}
return _settings
```

Bar titles are short, in Title Case, as in [Comments](comments.md).

---

<span id="related"></span>

## 📚 Related

- [Module structure](module-structure.md)
- [Data Structure](data-structure.md)
- [Comments](comments.md)
- [Types](types.md)
