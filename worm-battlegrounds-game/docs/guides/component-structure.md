<h1 align="center">Component Structure</h1>

<p align="center">
Standard layout for an ume component: <code>*.comp.json</code> manifests (see <a href="tag-list-plus.md">TagListPlus</a>), the matching ModuleScript under <code>Components/</code>, class naming, section banners, lifecycle (<code>Init</code> / <code>Destroy</code>), and registration via <code>I.Component</code>.
</p>

---

## 📑 Table of contents

| Name | Description |
| ---- | ----------- |
| **[📋 Overview](#overview)** | Artifacts, tags, and runtime wiring. |
| **[📐 Section banners and ASCII art](#section-banners-and-ascii-art)** | Shared `%` / banner conventions with modules. |
| **[📝 Script layout](#script-layout)** | Class region, template, lifecycle, and naming. |
| **[📜 `*.comp.json` manifest](#compjson-manifest)** | Default attrs, ObjectValues, and Studio shape. |
| **[🔗 Related](#related)** | Module structure and TagListPlus. |

---

<span id="overview"></span>

## 📋 Overview

A **component** is a ModuleScript that defines an OOP-style table (metatable) used by the **Component** framework module. Components attach to Instances when a registered **tag** is applied; the runtime wires <code>Component.new</code>, <code>Init</code>, and <code>Destroy</code> for you.

| Artifact | Location / role |
| --- | --- |
| **Lua module** | <code>ModuleName/Components/ComponentName.lua</code> — behavior |
| **Manifest** | <code>ModuleName/Components/ComponentName.comp.json</code> — TagListPlus / Studio tooling; **Name** matches the CollectionService tag you pass to <code>I.Component.Register</code> |

Authoring flow and merged registry file: [TagListPlus](tag-list-plus.md).

---

<span id="section-banners-and-ascii-art"></span>

## 📐 Section banners and ASCII art

Component scripts use the **same** structural comments as entry modules: long **`%`** region bars, the **ASCII art** separator, and short **`--%%%%%%%%%%%%%%%%%%%%`** labels on methods and subsections. These are **navigation and layout contracts** — keep them so anyone can scan the file and know where to add code. Full conventions: [Module structure — Section banners and ASCII art](module-structure.md#section-banners-and-ascii-art).

---

<span id="script-layout"></span>

## 📝 Script layout

Sectioning matches a normal module script (services, directories, data, scripts, templates, components, local variables, local functions) with two differences:

1. **Below the ASCII banner**, you declare the **class** that extends the conceptual <code>Component</code> API (see [Types](types.md) for <code>--- @class</code>).
2. You implement <code>new</code>, <code>Init</code>, and <code>Destroy</code> — each gets a short **`%`** title — see lifecycle below. Do **not** add a summary block above those three (same as `Module.Init` / `Module.Start`).

### 📄 Full component template

```lua
--[[
	Created By: 	{username}
]]

--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "ModuleName"

--- @type ModuleName_Settings
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

--- @class ModuleName_ComponentName : Component
--- @field Instance Instance
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
local Component = {}
Component.__index = Component

--%%%%%%%%%%%%%%%%%%%% New Class

function Component.new(instance: Instance)
	return setmetatable({ Instance = instance, Connections = {}, _destroyed = false }, Component)
end

--%%%%%%%%%%%%%%%%%%%% Init

function Component:Init() end

--%%%%%%%%%%%%%%%%%%%% Destroy

function Component:Destroy()
	-- Disconnect All Connections
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
end

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ###

--%%%%%%%%%%%%%%%%%%%% ###

return Component
```

### 🏷️ Class naming

The class lives **under** the ASCII banner (same top sections as a normal module). Pattern:

```lua
--- @class ModuleName_ComponentName : Component
--- @field Instance Instance
--- @field Connections { [string]: RBXScriptConnection }
--- @field _destroyed boolean
local Component = {}
Component.__index = Component
```

- **`{ModuleName}_{ComponentName}`** matches **`*.comp.json` → `Name`** and the tag passed to **`I.Component.Register`** / **`RegisterOnLoaded`** / **`AddTag`**.
- When the module folder name is long enough to make that id unwieldy, one short prefix may replace **`ModuleName`**. Example: **`LongModule_Controller`** → **`LMC`**, so **`LMC_Row`**. The short id still matches across **`@class`**, manifest, and tag. Attribute names on that component may use the same prefix (**`LMC_RowName`**). Do not mix the full module name and the short prefix on one component.
- That string must **not** also be a `Scripts/` `@class` in the same module. Rename the script (`RegionController.lua` → `ModuleName_RegionController`) so the component keeps the tag name.
- Extend **`@field`** as you assign **`self.Property`** in **`Init`** or other methods. Keep the template trio first and ungrouped. Extra fields always go under **`--- # Group #`**:

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

> **Do not** document **methods** on the class block — only **data-shaped** fields set via **`self.Foo = ...`**. See [Types](types.md).

Sections **above** the ASCII banner match normal modules; sections **below** follow the same **`%`** discipline ([Module structure](module-structure.md)).

### 🆕 `Component.new`

Do **not** customize **`Component.new`** except in extraordinary cases. Always allocate **`Instance`**, **`Connections`**, **`_destroyed`**. Add runtime fields inside **`Init`**, not inside **`new`**.

### ⚡ `Init`, registration, and `Destroy`

- **`Init`** fires whenever the tagged Instance gains your component.
- Register with **`I.Component.Register`**. On clients, **`I.Component.RegisterOnLoaded`** waits until the player is fully loaded ([Startup order](../architecture/startup-order.md)).
- After registration, adding the **tag** instantiates the component with **`self.Instance`** pointing at that Instance.
- **`warn`** from a component: end the interpolated message with **` -`**, then pass **`self.Instance`** as the second argument so Studio can click through to the tagged instance.

```lua
warn(`[{_localName}::{script.Name}]: Label (S_Label) is missing! -`, self.Instance)
```

- **`Destroy`** runs when the tag is removed **or** the Instance is destroyed: **`_destroyed`** flips **true**, **`Destroy`** executes, then the instance is disposed.

---

<span id="compjson-manifest"></span>

## 📜 `*.comp.json` manifest

The root object describes a **Configuration** instance whose **Name** is your component id. **ClassName** stays <code>Configuration</code>. Under **Properties → Attributes**, tooling / Studio use flags such as <code>AutoAddAttributes</code>, <code>Group</code>, etc.; <code>Group</code> controls categorization in the Studio TagList UI.

Minimal shape:

```json
{
	"ClassName": "Configuration",
	"Name": "ModuleName_ComponentName",
	"Properties": {
		"Attributes": {
			"AutoAddAttributes": { "Bool": true },
			"AutoRemoveAttributes": { "Bool": true },
			"AutoAddObjectValues": { "Bool": true },
			"AutoRemoveObjectValues": { "Bool": true },
			"Group": { "String": "ModuleName" }
		}
	},
	"Children": [
		{
			"ClassName": "Configuration",
			"Name": "Default",
			"Properties": {
				"Attributes": {}
			},
			"Children": []
		}
	]
}
```

- **Default** child: default attributes for tagged instances. Most games rely on **String**, **Bool**, and **Float64**; other Roblox types are supported (UDim, UDim2, Vector2/3, CFrame, sequences, BrickColor, Color3, Font, Rect, etc.).
- **ObjectValue** children are valid when you need instance references in defaults; a common runtime pattern is naming instances with an <code>S_</code> prefix and resolving them with <code>self.Instance:FindFirstChild("S_Name", true)</code>.

**`ClassName`** on the root stays **`Configuration`**. **`Name`** must equal your Lua class prefix / registry tag. **`Group`** picks the Studio TagList category.

The **`Default`** child carries Studio defaults; attributes there mirror onto tagged Instances (including descendants).

Every attribute type TagListPlus understands is fair game — most projects lean on **String**, **Bool**, and **Float64**, but the full palette is available:

```json
"Properties": {
	"Attributes": {
		"MyString": { "String": "Some Text" },
		"MyBool": { "Bool": true },
		"MyNumber": { "Float64": 4.2 },
		"MyUDim": { "UDim": [1.0, 32] },
		"MyUDim2": {
			"UDim2": [
				[-1.0, 100],
				[1.0, -100]
			]
		},
		"MyVector2": { "Vector2": [-50.0, 50.0] },
		"MyVector3": { "Vector3": [-300.0, 0.0, 1500.0] },
		"MyCFrame": {
			"CFrame": {
				"position": [1.0, 2.0, 3.0],
				"orientation": [
					[4.0, 5.0, 6.0],
					[7.0, 8.0, 9.0],
					[10.0, 11.0, 12.0]
				]
			}
		},
		"MyNumberSequence": {
			"NumberSequence": {
				"keypoints": [
					{
						"time": 0.0,
						"value": 5.0,
						"envelope": 2.0
					},
					{
						"time": 1.0,
						"value": 22.0,
						"envelope": 0.0
					}
				]
			}
		},
		"MyColorSequence": {
			"ColorSequence": {
				"keypoints": [
					{
						"time": 0.0,
						"color": [1.0, 1.0, 0.5]
					},
					{
						"time": 1.0,
						"color": [0.0, 0.0, 0.0]
					}
				]
			}
		},
		"MyNumberRange": { "NumberRange": [-36.0, 94.0] },
		"MyBrickColor": { "BrickColor": 194 },
		"MyColor3": {
			"Color3": [0.63, 0.63, 0.6]
		},
		"MyFont": {
			"Font": {
				"family": "rbxasset://fonts/families/LegacyArial.json",
				"weight": "Regular",
				"style": "Normal"
			}
		},
		"MyRect": {
			"Rect": [
				[0.0, 5.0],
				[10.0, 15.0]
			]
		}
	}
}
```

#### `ObjectValue` children (optional)

You can attach **`ObjectValue`** rows under **`Children`** when you truly need default references — however the preferred runtime pattern is naming Instances with **`S_`** and resolving them via **`self.Instance:FindFirstChild("S_Name", true)`**.

```json
"Children": [
	{
		"ClassName": "ObjectValue",
		"Name": "ModuleName_Value"
	}
]
```

---

<span id="related"></span>

## 🔗 Related

- [Module structure](module-structure.md) — folders, `Init` / `Start`, registry sections.
- [TagListPlus](tag-list-plus.md) — extraction, `TagListPlus.model.json`, Studio workflow.
