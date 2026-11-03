<h1 align="center">TagListPlus</h1>

<p align="center">
The TagListPlus registry: per-component <code>*.comp.json</code> manifests, the merged file <code>src/other/TagListPlus.model.json</code>, how the Studio plugin mirrors entries into Roblox’s Tag UI, and how those entries relate to CollectionService tags and the <code>Component</code> module at runtime.
</p>

---

## 📑 Table of contents

| Name | Description |
| ---- | ----------- |
| **[🏷️ What TagListPlus is](#what-taglistplus-is)** | Registry roles: VS Code, Studio plugin, and runtime. |
| **[🔧 Tooling source](#tooling-source)** | `ume-vscode` and `ume-rbx` locations. |
| **[💻 VS Code extension (`ume-vscode`)](#vs-code-extension-ume-vscode)** | Extract Components flow and output paths. |
| **[🎮 Roblox Studio plugin (`ume-rbx`)](#roblox-studio-plugin-ume-rbx)** | Toolbar, Load Tags, apply/remove behavior. |
| **[📁 Files and layout](#files-and-layout)** | Merged model JSON vs per-component manifests. |
| **[📐 Shape of one definition (`*.comp.json`)](#shape-of-one-definition-compjson)** | Root object, metadata attrs, and `Default` child. |
| **[🔤 Attribute value encoding (Rojo JSON)](#attribute-value-encoding-rojo-json)** | Typed attribute JSON shapes. |
| **[📄 Minimal template (`*.comp.json`)](#minimal-template-compjson)** | Empty-default starter manifest. |
| **[📎 Example with defaults and an `ObjectValue`](#example-with-defaults-and-an-objectvalue)** | `Utils_MoveTo`-style pattern. |
| **[🔢 Example with numeric default attributes](#example-with-numeric-default-attributes)** | `Utils_UISpin`-style pattern. |
| **[🔄 Workflow (authoring)](#workflow-authoring)** | End-to-end authoring checklist. |
| **[⚡ Runtime recap](#runtime-recap)** | CollectionService, `Register`, and plugin-only flags. |

---

<span id="what-taglistplus-is"></span>

## 🏷️ What TagListPlus is

TagListPlus is a **registry of component definitions** stored as a Rojo **model JSON** file. It is mapped into Roblox as **`ServerStorage.TagListPlus`** (see `default.project.json`).

| Role | Detail |
| --- | --- |
| **VS Code (`ume-vscode`)** | Finds every **`*.comp.json`** in the workspace, parses each root object, and writes one merged **`Folder`** model JSON (default **`src/other/TagListPlus.model.json`**). |
| **Roblox Studio (`ume-rbx`)** | **`TagList+`** toolbar UI: **`Load Tags`** copies definitions into **`ServerStorage.TagList`**; listeners apply **`Default`** attributes / **`ObjectValue`** clones when tags are added or removed (per **`Auto*`** flags). |
| **Runtime (game)** | Does **not** read this folder. Components run through **`I.Component.Register(tag, module)`** and **`CollectionService`** tags; Lua reads **attributes** on instances (see [Component Structure](component-structure.md)). |

So: TagListPlus keeps **authoring-time** metadata in sync with what your component scripts expect; the **`Name`** on each definition is the **CollectionService tag** string you register in code.

---

<span id="tooling-source"></span>

## 🔧 Tooling source

The implementations live next to this framework repo (sibling repos in the same parent folder):

| Piece | Folder | Notes |
| --- | --- | --- |
| VS Code extension | **`ume-vscode`** | Command **`Ume: Open Menu`** (`ume-vscode.openUmeMenu`), **`Extract Components`** → `extract_components.ts`. |
| Studio plugin | **`ume-rbx`** | Toolbar **`Ume <version>`** → **`TagList+`** → `TagListPlus.lua`. |

Published VS Code extension metadata: [github.com/ume-roblox/ume-vscode](https://github.com/ume-roblox/ume-vscode).

---

<span id="vs-code-extension-ume-vscode"></span>

## 💻 VS Code extension (`ume-vscode`)

1. **Menu** — Command Palette: **`Ume: Open Menu`** opens a QuickPick titled **Ume**. Choose **`Extract Components`** (detail: *Extracts Components info into a single directory*).

2. **What it does** — `vscode.workspace.findFiles("**/*.comp.json")`, parses each file’s JSON, and builds:

```json
{ "ClassName": "Folder", "Children": [ /* each parsed comp.json root */ ] }
```

3. **Output path** — **`ume.yaml`** in the project folder (this repo's root; a game's **`<game>-game`** folder), defaults shown:

| Key | Default |
| --- | --- |
| **`component.extractDirectory`** | `src/other` |
| **`component.extractedFilename`** | `TagListPlus` |

The file written is **`{extractedFilename}.model.json`** (e.g. **`TagListPlus.model.json`**) in that directory, relative to the `ume.yaml` folder. A key `ume.yaml` leaves out takes the default, so UmeSync and ume-vscode write the same file. Without a `ume.yaml`, ume-vscode uses its workspace settings of the same name with the `ume-vscode.` prefix (**`ume-vscode.component.extractDirectory`**, **`ume-vscode.component.extractedFilename`**). UmeSync reads `ume.yaml` from 1.4.0; ume-vscode reads it from its next minor version (planned) and until then uses only its workspace settings.

4. **Failures** — Invalid JSON in any **`*.comp.json`** aborts with an error message and writes nothing; fix parsing errors and run **`Extract Components`** again.

5. **UmeSync** — From UmeSync 1.4.0 the same extract runs outside the editor, with the same output: right-click the project in the UmeSync app → **Extract components**, or, for agents, ume-sync's MCP tool **`extract_components`**.

---

<span id="roblox-studio-plugin-ume-rbx"></span>

## 🎮 Roblox Studio plugin (`ume-rbx`)

Implementation reference: **`ume-rbx/src/core/Plugin/Components/TagListPlus.lua`**.

### 🎛️ Toolbar and session lock

- Toolbar group **`Ume <version>`** exposes a **`TagList+`** button (*Control for TagListPlus*).
- On click, if **`App.IsSessionLocked()`** is **false** (another user holds **`ServerStorage.__Ume_SessionLock`**), the plugin shows **Claim Session Lock** instead of the main menu. **Team Create** / solo sessions skip this gate (see **`App.lua`**).
- If **`TagListPlus`** is missing under **`ServerStorage`**, the fallback menu offers **Find 'TagListPlus' Folder**. More than one folder named **`TagListPlus`** under **`ServerStorage`** clears the resolved folder and warns.

### 📥 Load Tags

**`Load Tags`** (when the session allows edits):

1. Resolves **`ServerStorage.TagListPlus`** (each **direct child** **`Configuration`** = one component tag).
2. Ensures **`ServerStorage.TagList`** exists (creates **`Folder`** named **`TagList`**, adds **`TagEditorTagContainer`** tag if new).
3. For each **`Configuration`** under **`TagListPlus`**, creates or updates a **`Configuration`** of the **same name** under **`TagList`**.
4. Fills **Tag Editor** attributes on that **`TagList`** entry: **`AlwaysOnTop`**, **`Color`**, **`DrawType`**, **`Group`**, **`Icon`**, **`Visible`**. Values come from attributes on the **`TagListPlus`** root **`Configuration`** when set; otherwise plugin defaults apply (e.g. random **`Color`** when unset).

So **`Load Tags`** does **not** push **`Default`** attribute payloads onto instances; it syncs **Studio’s tag definitions** under **`ServerStorage.TagList`**.

### 🔄 Apply and remove on instances

The plugin subscribes to **`CollectionService.TagAdded`** / **`TagRemoved`** and **`GetInstanceAddedSignal(tag)`** / **`GetInstanceRemovedSignal(tag)`**.

When an instance **gains** a tag that matches a **`Configuration`** name under **`TagListPlus`** with a **`Default`** child **`ApplyAttributesForInstance`** runs (subject to session lock and folder discovery):

| Flag | Default when attribute **missing** on root config | Behavior |
| --- | --- | --- |
| **`AutoAddAttributes`** | **true** | Copies **`Default:GetAttributes()`** onto the instance: set if missing; if present but **`typeof`** differs from default, clears then sets; same type → leave as-is. |
| **`AutoAddObjectValues`** | **true** | For each **`ObjectValue`** under **`Default`**, **clone** under the instance if no child with that name exists. Non-**`ObjectValue`** children are skipped. |

When a tag is **removed**, **`RemoveAttributesForInstance`** runs if configured:

| Flag | Default when attribute **missing** on root config | Behavior |
| --- | --- | --- |
| **`AutoRemoveAttributes`** | **false** | Clears instance attributes whose names appear on **`Default:GetAttributes()`**. |
| **`AutoRemoveObjectValues`** | **false** | Destroys **`ObjectValue`** children on the instance whose names match **`Default`** **`ObjectValue`** children. |

All **`Auto*`** flags on the manifest root apply only here; framework **`Component`** Lua does not read them.

### 🔁 Apply To Existing

**`Apply To Existing`** runs **`ApplyAttributesForTag`** for **every** tag currently registered on **`CollectionService`**—useful after changing **`Default`** templates without retagging instances.

---

<span id="files-and-layout"></span>

## 📁 Files and layout

| Artifact | Path |
| --- | --- |
| Merged registry (Rojo) | `src/other/TagListPlus.model.json` (default; overridable via VS Code settings) |
| Per-component manifest | Next to the component module, e.g. `.../Components/Visual/UISpin.comp.json` |
| Roblox instance | `ServerStorage.TagListPlus` → `Folder` whose **children** are one **`Configuration` per tag** |

Repository context: [Project structure](../architecture/project-structure.md).

---

<span id="shape-of-one-definition-compjson"></span>

## 📐 Shape of one definition (`*.comp.json`)

Each **`*.comp.json`** file describes **one** tag. It uses the same Rojo model-json shape as a single child under the root `Folder` in **`TagListPlus.model.json`**.

### 📌 Root object (required)

| Field | Value |
| --- | --- |
| `ClassName` | `"Configuration"` |
| `Name` | **CollectionService tag** (e.g. `"Utils_UISpin"`). Must match `I.Component.Register("<tag>", moduleScript)`. |
| `Properties.Attributes` | Metadata for Studio TagListPlus (see below). |
| `Children` | Exactly one child: **`Default`** (see next section). |

### 🏷️ Studio metadata (`Properties.Attributes`)

These keys appear on every shipped component in this repo. Framework **`Component`** Lua does not read them; the **Studio plugin** uses them for **`Load Tags`** (where relevant for **`TagList`** presentation) and for **apply/remove on instances**.

| Attribute | Typical type | Purpose |
| --- | --- | --- |
| `AutoAddAttributes` | `Bool` | When tag is added: merge **`Default`** attributes onto the instance (plugin default **true** if omitted). |
| `AutoRemoveAttributes` | `Bool` | When tag is removed: clear those attribute names (plugin default **false** if omitted). |
| `AutoAddObjectValues` | `Bool` | When tag is added: clone **`Default`** **`ObjectValue`** children onto the instance (plugin default **true** if omitted). |
| `AutoRemoveObjectValues` | `Bool` | When tag is removed: destroy matching **`ObjectValue`** children (plugin default **false** if omitted). |
| `Group` | `String` | **`Load Tags`** can set the **`Group`** attribute on the **`ServerStorage.TagList`** entry (Tag Editor grouping). |

Shipped **`*.comp.json`** files usually set **`AutoRemove*`** explicitly to **`true`** so cleanup matches add behavior; relying on omission means **no automatic removal**.

### ⚙️ `Default` child (required)

Under the root, add a **`Configuration`** named **`Default`**:

| Field | Purpose |
| --- | --- |
| `Properties.Attributes` | Default **attribute** names and values for instances that receive this tag. Keys must match what your component Lua reads via **`GetAttribute`** (e.g. `Utils_SpinSpeed`). |
| `Children` | Optional **`ObjectValue`** templates—the plugin **only** clones **`ObjectValue`** children (e.g. **`Utils_Destination`** on **`Utils_MoveTo`**). |

At runtime, your component script reads those attributes and values from the instance; the Studio plugin copies them from this **`Default`** definition when **`AutoAdd*`** allows.

---

<span id="attribute-value-encoding-rojo-json"></span>

## 🔤 Attribute value encoding (Rojo JSON)

Use Rojo’s typed attribute objects (same as in **`TagListPlus.model.json`**):

| Lua / Studio concept | JSON shape |
| --- | --- |
| Boolean | `{ "Bool": true }` |
| String | `{ "String": "..." }` |
| Number | `{ "Float64": 1 }` |
| `NumberRange` | `{ "NumberRange": [min, max] }` |
| `UDim2` | `{ "UDim2": [[scaleX, offsetX], [scaleY, offsetY]] }` |

Empty defaults use `"Attributes": {}` on **`Default`**.

---

<span id="minimal-template-compjson"></span>

## 📄 Minimal template (`*.comp.json`)

Use this when a component has **no default attributes** but still needs a Studio listing and tag name:

```json
{
	"ClassName": "Configuration",
	"Name": "YourModule_YourComponent",
	"Properties": {
		"Attributes": {
			"AutoAddAttributes": { "Bool": true },
			"AutoRemoveAttributes": { "Bool": true },
			"AutoAddObjectValues": { "Bool": true },
			"AutoRemoveObjectValues": { "Bool": true },
			"Group": { "String": "YourGroup" }
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

Replace **`Name`** with the exact **CollectionService tag** string you pass to **`I.Component.Register`**.

---

<span id="example-with-defaults-and-an-objectvalue"></span>

## 📎 Example with defaults and an `ObjectValue`

This matches the pattern used by **`Utils_MoveTo`**: attributes live under **`Default`**, and an **`ObjectValue`** holds an instance reference.

```json
{
	"ClassName": "Configuration",
	"Name": "Utils_MoveTo",
	"Properties": {
		"Attributes": {
			"AutoAddAttributes": { "Bool": true },
			"AutoRemoveAttributes": { "Bool": true },
			"AutoAddObjectValues": { "Bool": true },
			"AutoRemoveObjectValues": { "Bool": true },
			"Group": { "String": "Utils" }
		}
	},
	"Children": [
		{
			"ClassName": "Configuration",
			"Name": "Default",
			"Properties": {
				"Attributes": {}
			},
			"Children": [
				{
					"ClassName": "ObjectValue",
					"Name": "Utils_Destination"
				}
			]
		}
	]
}
```

---

<span id="example-with-numeric-default-attributes"></span>

## 🔢 Example with numeric default attributes

Pattern from **`Utils_UISpin`**: defaults are attributes your **`Init()`** reads.

```json
{
	"ClassName": "Configuration",
	"Name": "Utils_UISpin",
	"Properties": {
		"Attributes": {
			"AutoAddAttributes": { "Bool": true },
			"AutoRemoveAttributes": { "Bool": true },
			"AutoAddObjectValues": { "Bool": true },
			"AutoRemoveObjectValues": { "Bool": true },
			"Group": { "String": "Utils" }
		}
	},
	"Children": [
		{
			"ClassName": "Configuration",
			"Name": "Default",
			"Properties": {
				"Attributes": {
					"Utils_SpinSpeed": { "Float64": 1 }
				}
			},
			"Children": []
		}
	]
}
```

---

<span id="workflow-authoring"></span>

## 🔄 Workflow (authoring)

1. Implement the component **`ModuleScript`** and register it with **`I.Component.Register("Your_Tag", script)`** (same string as root **`Name`**).
2. Add **`YourName.comp.json`** beside it using the templates above.
3. Run **Extract Components**: in the UmeSync app, right-click the project → **Extract components**; in VS Code, **`Ume: Open Menu`** → **`Extract Components`**; an agent calls ume-sync's **`extract_components`**. Confirm output under **`component.extractDirectory`** in **`ume.yaml`** (default **`src/other`**) as **`TagListPlus.model.json`**.
4. ume-sync syncs it, so **`ServerStorage.TagListPlus`** matches the merged model.
5. In Studio: toolbar **`Ume <version>`** → **`TagList+`**. If prompted, resolve **session lock** / missing folder. Open the menu with **`Load Tags`**, then **`Load Tags`** to refresh **`ServerStorage.TagList`**. Use **`Apply To Existing`** if you changed **`Default`** and need instances updated without manual retagging.

If **`Name`** in JSON and the **`Register`** tag diverge, Studio will show one tag string and the runtime will listen for another—avoid that mismatch.

---

<span id="runtime-recap"></span>

## ⚡ Runtime recap

- **`CollectionService`** tags instances with the same string as the manifest **`Name`**.
- **`src/modules_ume/Ume/Component/Global.lua`** wires **`Register`** to **`GetTagged`** / **`GetInstanceAddedSignal`** for that tag.
- **`AutoAddAttributes`** and related flags affect **only the Studio plugin**, not **`Component`** module logic.

More on the component Lua side: [Component Structure](component-structure.md).
