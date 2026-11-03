<h1 align="center">Global Data</h1>

<p align="center">
Game-adjustable data: tables and scripts you swap or extend per title (badges, sounds, teams, marketplace rows, buff/stat defs, tool handlers, etc.). Lives under <code>src/global_data/</code>, synced as <code>Instance/GlobalData</code>. Runtime path <code>I.Dirs.GlobalData</code>. <code>modules_ume</code> reads it with <code>require(I.Dirs.GlobalData.&lt;path&gt;)</code> or by iterating Instances where noted below.
</p>

---

## 📑 Table of contents

| Name | Description |
| ---- | ----------- |
| **[📋 Overview](#overview)** | What `GlobalData` is, how modules load it, and non-table exceptions. |
| **[📚 Namespaces](#namespaces)** | Folder → artifacts → which framework module consumes each. |

---

<span id="overview"></span>

## 📋 Overview

`GlobalData` is a normal Instance subtree on the framework model. It is not merged into `I.Config`; each consumer module loads the pieces it needs.

Most entries are plain ModuleScripts that `return` a table. Exceptions:

- **`Interact/PromptStyles/`** — multiple ModuleScripts; Interact loads every child/descendant module as a style definition (see Interact module code).
- **`Interact/Mappings/`** — multiple ModuleScripts; Interact loads every child as a set of input mappings, by name.
- **`Lighting/Presets/`** — one ModuleScript per preset; Lighting iterates `Presets:GetChildren()` and requires each.
- **`Tool/`** — one folder per tool; each folder holds environment scripts (e.g. `Server.lua`, `Client.lua`) discovered by the Tool module from that folder tree.

---

<span id="namespaces"></span>

## 📚 Namespaces

Rows list the primary ModuleScript(s) or folder and the framework module that reads them.

| Folder         | Artifacts                                                                                                                                                                                 | Loaded by               |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| `Badge/`       | `Badges.lua` — keyed badge definitions (`Id`, `Version`, place allowlists, optional reward hooks).                                                                                        | Badge                   |
| `Buff/`       | `Buff.lua` — nested `Server` / `Client` tables of buff ids → defaults and replication flags.                                                                                             | Buff (`Ume_Data`)      |
| `AdminPanel/`  | `Permissions.lua` — group aliases, user-id overrides, the global-command level and the dashboard level (`DashboardLevel`).                                                               | AdminPanel              |
| `Group/`       | `Groups.lua` — string alias → group id numbers (e.g. command autocomplete / APIs).                                                                                                        | Group, AdminPanel       |
| `Interact/`    | `Mappings/*.lua` — one ModuleScript per set of input mappings (`Default`: Roblox's textures; `Enhanced`: ume's images with PlayStation buttons): gamepad, keyboard, key cap, touch and hold-ring images and key texts. `PromptStyles/` — ModuleScripts per style (large UI builders; read their prompt's `Interact_Mappings` through `I.Interact.GetMappings`). | Interact                |
| `Lighting/`    | `Tweens.lua` — named `TweenInfo` presets. `Presets/*.lua` — lighting/atmosphere/sky property snapshots.                                                                                   | Lighting                |
| `Marketplace/` | `Assets.lua`, `Bundles.lua`, `GamePasses.lua`, `Products.lua` — keyed catalog entries with ids, place purchase rules, optional requirement/reward functions.                              | Marketplace             |
| `Sound/`       | `SoundsList.lua` — logical name → Roblox asset id array. `SoundGroupsList.lua` — group name → default volume scale.                                                                       | Sound                   |
| `Statistic/`  | `Statistic.lua` — statistic id → default string value, min/max rules, server/client update flags.                                                                                        | Statistic (`Ume_Data`) |
| `Team/`        | `Teams.lua` — team name → color / auto-assign flags.                                                                                                                                      | Team                    |
| `Tool/`        | Subfolders (e.g. `Example/`) with `Server.lua` / `Client.lua` tool behavior modules (`Tool.Init`, `Equipped`, etc. per Tool API).                                                         | Tool                    |
