<h1 align="center">Place loader</h1>

<p align="center">
Resolves <strong>place</strong> and <strong>map</strong> at framework boot, merges staged <code>PlaceLoader</code> folders into live trees, and registers teleport / lobby helpers. Code: <code>src/core/game_instance/Start/tasks/place_loader/init.lua</code> · Config: <code>src/core/game_instance/Start/configs/place_loader.lua</code>.
</p>

<p align="center">
Runs inside <code>Ume.Bloom()</code> after libraries load. Diagrams: <a href="./startup-order.md">startup-order.md</a> · Task index: <a href="./start-tasks.md">start-tasks.md</a>.
</p>

---

## 📑 Table of contents

| Name                                                                        | Description                                                         |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| **[📋 1. Overview](#1-overview)**                                           | Place vs map, what the loader merges, and what `I.Config` exposes.  |
| **[⚙️ 2. Configuration](#2-configuration)**                                 | `place_loader.lua` root options, places, maps, and per-map fields.  |
| **[📦 3. Staging folders and `GameDirs`](#3-staging-folders-and-gamedirs)** | Merge pipeline, directory keys, workspace staging, and scaffolding. |
| **[🔌 4. Exposed API](#4-exposed-api)**                                     | `I.Teleport*` helpers and persistent lobby getters/setters on `I`.  |
| **[➕ 5. Adding a map or place](#5-adding-a-map-or-place)**                 | Steps for new map ids and new place ids in config.                  |
| **[⚠️ 6. Constraints and edge cases](#6-constraints-and-edge-cases)**       | Validation failures, MemoryStore limits, temporary lobby behavior.  |
| **[📚 7. Related docs](#7-related-docs)**                                   | Pointers to configs and module structure guides.                    |

---

<span id="1-overview"></span>

## 📋 1. Overview

### 1.1 Place vs map

| Term      | Meaning                                                                                                                                                       |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Place** | A Roblox place id (`game.PlaceId`). Each entry in `PlaceConfigs` describes one place in your experience.                                                      |
| **Map**   | A string id (`Default`, `UmeLobby`, ...) defined under that place’s `MapConfigs`. Maps choose **which staged folders merge** and **which module roots load**. |

### 1.2 What the loader does

- Validates every place and map in config before the rest of Bloom continues.
- Picks the active **place** (`PlaceConfigs[game.PlaceId]` or `DefaultPlaceId`).
- Picks the active **map**: persistent lobby flag → MemoryStore payload on reserved private servers → `DefaultMapId`.
- **Merges** instances from `PlaceLoader` staging into Starter\*, `Workspace/Ume`, Replicated/ServerStorage under Ume, and Assets / server Assets.
- **Temporary lobby** servers (lobby map, not persistent): teleport everyone to main and **stop Bloom early** (no modules).

Startup ordering and internal steps live in **`start-tasks.md`** / **`startup-order.md`**; this page focuses on **config**, **staging**, and **`I` APIs**.

### 1.3 What game code reads

| Path                                     | Use                                                                                                                |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `I.Config.Map`                           | Active map row: stores, VR, `GameDirs`, `ModulesDirs`, `DisabledModules`, `LoadingOrder`.                          |
| `I.Config.PlaceLoader.PlaceId` / `MapId` | Resolved ids for analytics, marketplace keys, badges, etc.                                                         |
| `I.Config.IsLobby`                       | True when current map id equals that place’s `LobbyId`.                                                            |
| `I.Config.Metadata`                      | **Server only** — payload from reserved-server teleport (see `Ume_PlaceLoader_Metadata` in `src/core/_meta/_types.lua`). |

Clients sync map choice via attributes `Ume_PlaceId` / `Ume_MapId` on the place loader script plus replicated config.

---

<span id="2-configuration"></span>

## ⚙️ 2. Configuration

All editable defaults live in **`src/core/game_instance/Start/configs/place_loader.lua`**. Types: **`src/core/_meta/_types.lua`** (`Ume_PlaceLoader_PlaceSettings`, `Ume_PlaceLoader_MapSettings`).

### 2.1 Root options

```lua
-- Abbreviated — see full file in repo
DefaultPlaceId = game.PlaceId,

_mapStoreId = "__Ume_MapId",           -- MemoryStore HashMap: reservedServerId -> { MapId, Metadata }
_lobbyStoreId = "__Ume_PersistentLobby", -- DataStore: IsLobbyPersistent flag

PersistentLobbyInStudio = true,
PersistentLobbyExcludedServers = {}, -- private server ids that skip persistent lobby logic

-- Filled at runtime by place_loader:
PlaceId = nil,
MapId = nil,

PlaceConfigs = {
	-- [placeId] = { DefaultMapId, LobbyId, MapConfigs = { ... } }
},
```

| Field            | Role                                                                                                               |
| ---------------- | ------------------------------------------------------------------------------------------------------------------ |
| `DefaultPlaceId` | Used when `PlaceConfigs[game.PlaceId]` is missing; also fallback target when a lobby map’s `ReturnPlaceId` is nil. |
| `_mapStoreId`    | HashMap name for `I.Teleport` routing data.                                                                        |
| `_lobbyStoreId`  | DataStore used for persistent lobby on/off.                                                                        |

### 2.2 One place, two maps (stock layout)

Same shape as **`configs/place_loader.lua`** today: **`Default`** for the main map and **`UmeLobby`** for the lobby. **`ReturnPlaceId`** on the lobby row targets the main place when this server is a **temporary** lobby.

```lua
PlaceConfigs = {
	[game.PlaceId] = {
		DefaultMapId = "Default",
		LobbyId = "UmeLobby",

		MapConfigs = {
			["Default"] = {
				ProfileStoreName = "UmeTesting_-1",
				LeaderboardStoreName = "UmeTesting_-1",
				VRSupport = false,

				GameDirs = {
					Workspace_Ume = { "Default" },
					ReplicatedStorage_Ume = { "Default" },
					ServerStorage_Ume = { "Default" },
					StarterGui = { "Default" },
					StarterPack = { "Default" },
					StarterPlayer = { "Default" },
					Assets = { "Default" },
					SAssets = { "Default" },
				},

				ModulesDirs = {
					"Ume", "Ume_Data", "Roblox",
					"Utils", "Main", "Main_Game", "Main_Controllers",
				},
				DisabledModules = {},
				LoadingOrder = {},
				ReturnPlaceId = nil,
			},

			["UmeLobby"] = {
				ProfileStoreName = "UmeTesting_-1",
				LeaderboardStoreName = "UmeTesting_-1",
				VRSupport = false,

				GameDirs = {
					Workspace_Ume = { "UmeLobby" },
					ReplicatedStorage_Ume = { "UmeLobby" },
					ServerStorage_Ume = { "UmeLobby" },
					StarterGui = { "UmeLobby" },
					StarterPack = { "UmeLobby" },
					StarterPlayer = { "UmeLobby" },
					Assets = { "UmeLobby" },
					SAssets = { "UmeLobby" },
				},

				ModulesDirs = {
					"Ume", "Ume_Data", "Roblox",
					"Utils", "Main", "Main_Game", "Main_Controllers",
				},
				DisabledModules = {},
				LoadingOrder = {},
				ReturnPlaceId = game.PlaceId,
			},
		},
	},
},
```

### 2.3 Multi-place experiences

Add another numeric key for each live place. **`DefaultPlaceId`** should be your hub / main entry place id.

```lua
DefaultPlaceId = 1234567890,

PlaceConfigs = {
	[1234567890] = {
		DefaultMapId = "Lobby",
		LobbyId = "Lobby",
		MapConfigs = {
			["Lobby"] = { /* ... */ },
			["Dungeon"] = { /* ... */ },
		},
	},

	[9876543210] = {
		DefaultMapId = "Arena",
		LobbyId = "Lobby",
		MapConfigs = {
			["Arena"] = { /* ... */ },
			["Lobby"] = { /* ... */ },
		},
	},
},
```

Every place **must** include valid **`DefaultMapId`**, **`LobbyId`**, and **`MapConfigs`** entries for both (and every map needs the full required fields — see §6).

### 2.4 Map fields reference

| Field                  | Type     | Notes                                                                         |
| ---------------------- | -------- | ----------------------------------------------------------------------------- |
| `ProfileStoreName`     | string   | Validated at startup.                                                         |
| `LeaderboardStoreName` | string   | Validated at startup.                                                         |
| `VRSupport`            | boolean  | Validated at startup.                                                         |
| `GameDirs`             | table    | Keys listed in §3; each value is `{ "FolderA", "FolderB", ... }` merge order. |
| `ModulesDirs`          | { string } | Passed to module preparation (`tasks/modules.lua`).                           |
| `DisabledModules`      | { string } | Map overlay for disabling modules.                                            |
| `LoadingOrder`         | { string } | Map overlay merged with global module loading order.                          |
| `ReturnPlaceId`        | number?  | Temporary lobby teleports; falls back to `DefaultPlaceId`.                    |

---

<span id="3-staging-folders-and-gamedirs"></span>

## 📦 3. Staging folders and `GameDirs`

### 3.1 How merging works

For each key in `GameDirs`, the loader looks up **`PlaceLoader/<FolderName>/`** (or the workspace-specific pipeline below), walks **`FolderName` entries in array order**, and moves/clones children into the **destination** tree. Same-named instances under folders recurse; duplicate **leaf** conflicts warn. When done, the staging **`PlaceLoader`** folder is removed.

### 3.2 Logical key → staging → destination

| `GameDirs` key          | Where staged                                                                                      | Merged into                    |
| ----------------------- | ------------------------------------------------------------------------------------------------- | ------------------------------ |
| `Workspace_Ume`         | After boot: children live under `ServerStorage/Ume/PlaceLoader_Workspace/<MapFolder>/` (see §3.3) | `Workspace/Ume`                |
| `ReplicatedStorage_Ume` | `ReplicatedStorage/Ume/PlaceLoader/<MapFolder>/`                                                  | `ReplicatedStorage/Ume`        |
| `ServerStorage_Ume`     | `ServerStorage/Ume/PlaceLoader/<MapFolder>/`                                                      | `ServerStorage/Ume`            |
| `StarterGui`            | `StarterGui/PlaceLoader/<MapFolder>/`                                                             | `StarterGui`                   |
| `StarterPack`           | `StarterPack/PlaceLoader/<MapFolder>/`                                                            | `StarterPack`                  |
| `StarterPlayer`         | `StarterPlayer/PlaceLoader/<MapFolder>/`                                                          | `StarterPlayer`                |
| `Assets`                | `ReplicatedStorage/Ume/Assets/PlaceLoader/<MapFolder>/`                                           | `ReplicatedStorage/Ume/Assets` |
| `SAssets`               | `ServerStorage/Ume/Assets/PlaceLoader/<MapFolder>/`                                               | `ServerStorage/Ume/Assets`     |

`<MapFolder>` is each string in the array for that key, e.g. `{ "Default", "Shared" }` merges **Default** first, then **Shared**.

### 3.3 Workspace pipeline

1. **Author** under `Workspace/Ume/PlaceLoader/<MapFolder>/...`.
2. On server startup, that staging tree is moved into **`ServerStorage/Ume/PlaceLoader_Workspace/`** so large geometry is not left under `Workspace`.
3. Workspace-side merges read from **`PlaceLoader_Workspace`** into **`Workspace/Ume`**.

If **`Workspace/Ume/PlaceLoader` does not exist**, workspace map loading is skipped for that server.

### 3.4 Example: shared layer + map layer

```lua
GameDirs = {
	Workspace_Ume = { "Shared", "Arena" },
	ReplicatedStorage_Ume = { "Shared", "Arena" },
	-- ... same idea for other keys
},
```

Roblox instance tree (conceptual):

```text
StarterGui
└── PlaceLoader
    ├── Shared          ← merged first
    │   └── SomeGui
    └── Arena           ← merged second (can override / nest into SameGui if folders align)
        └── SomeGui
```

Keep sibling **folder names** under `PlaceLoader` unique — see §6.

### 3.5 Scaffolding with `create_placeloader_dirs.lua`

The repo ships **`.other/create_placeloader_dirs.lua`**: a short Roblox script that creates the **`PlaceLoader`** staging shell (plus **`PlaceLoader_Workspace`** under **`ServerStorage/Ume`**) so you do not have to build the tree by hand.

**When to run it:** once per **place file**, after **`Workspace/Ume`**, **`ReplicatedStorage/Ume`**, and **`ServerStorage/Ume`** exist (for example after syncing with ume-sync / opening the framework instance). If a target already has **`PlaceLoader`** (or **`PlaceLoader_Workspace`** where applicable), that location is **skipped**.

**How to run it (Studio):**

1. Open your experience in **Roblox Studio** with the Ume hierarchy present.
2. Copy the contents of **`.other/create_placeloader_dirs.lua`** from the repo.
3. Paste into the **Command bar** and run **once**, **or** insert a temporary **Script** under **ServerScriptService**, paste the code, **Play** once (then delete the Script so it does not run every session).

**What it creates**

| Parent                                                        | Instance added                  | Notes                                                              |
| ------------------------------------------------------------- | ------------------------------- | ------------------------------------------------------------------ |
| `StarterGui`, `StarterPack`, `StarterPlayer`                  | `PlaceLoader` (`Configuration`) | Contains a **`Default`** folder as the first map bucket.           |
| `Workspace/Ume`, `ReplicatedStorage/Ume`, `ServerStorage/Ume` | `PlaceLoader`                   | Same shape.                                                        |
| `ReplicatedStorage/Ume/Assets`, `ServerStorage/Ume/Assets`    | `PlaceLoader`                   | Only if those **Assets** folders exist.                            |
| `ServerStorage/Ume`                                           | `PlaceLoader_Workspace`         | Workspace staging target (see §3.3); skipped if it already exists. |

Add **more map folders** as siblings of **`Default`** under each `PlaceLoader` (or duplicate the pattern) so names match every entry in your **`GameDirs`** arrays in **`place_loader.lua`**. The framework loader only requires folders that match **every name** you list there.

---

<span id="4-exposed-api"></span>

## 🔌 4. Exposed API

These are attached to the framework instance **`I`** on **normal** servers after the place loader finishes (not on temporary lobby servers that exit Bloom early).

### 4.1 Teleports

```lua
--- @type Ume
local I = ...

-- Same experience: reserved server + map routing (needs MemoryStore / MapHashMap)
local ok = I.Teleport(
	{ player },
	targetPlaceId,
	"Arena",
	{ MatchId = "abc" }, -- optional; AccessCode added internally
	"TeleportGui"        -- optional UtilityGuis ScreenGui name
)

-- Join specific server instance or reserved code (exactly one of jobId / accessCode)
I.TeleportToServer({ player }, placeId, jobId, nil, "TeleportGui")
I.TeleportToServer({ player }, placeId, nil, accessCode, "TeleportGui")

-- Different experience (no map routing)
I.TeleportExternal({ player }, otherExperiencePlaceId, "TeleportGui")

-- Default place + its LobbyId map
I.TeleportToDefaultLobby({ player }, "TeleportGui")
```

| Function                                                                  | Purpose                                                                                       |
| ------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `I.Teleport(playersList, placeId, mapId, metadata?, guiName?)`            | Reserve a private server, store map + metadata in MemoryStore, teleport with the access code. |
| `I.TeleportToServer(playersList, placeId, jobId?, accessCode?, guiName?)` | Teleport with **`jobId`** or **`accessCode`** — not both.                                     |
| `I.TeleportExternal(playersList, placeId, guiName?)`                      | Teleport to another experience by place id.                                                   |
| `I.TeleportToDefaultLobby(playersList, guiName?)`                         | Teleport to **`DefaultPlaceId`** using that place’s **`LobbyId`** map.                        |

Optional **`guiName`**: clones `ServerStorage/Ume/UtilityGuis/<guiName>` into `PlayerGui`; optional **`GuiAnimDuration`** NumberValue under that template delays the teleport.

### 4.2 Persistent lobby

```lua
local ok, stateOrErr = I.GetPersistentLobbyState()
local ok, err = I.UpdatePersistentLobbyState(true)
```

| Function                              | Purpose                                                                            |
| ------------------------------------- | ---------------------------------------------------------------------------------- |
| `I.GetPersistentLobbyState()`         | Read whether the lobby is persistent (`IsLobbyPersistent` in the lobby DataStore). |
| `I.UpdatePersistentLobbyState(state)` | Write **`state`** as the persistent lobby flag.                                    |

Backed by **`_lobbyStoreId`** DataStore key `IsLobbyPersistent`.

---

<span id="5-adding-a-map-or-place"></span>

## ➕ 5. Adding a map or place

### 5.1 New map id (`Forest`)

1. Under each staging root you use, create **`PlaceLoader/Forest`** (and fill with instances).
2. Add **`["Forest"] = { ... }`** to `MapConfigs` with complete fields (`GameDirs`, `ModulesDirs`, etc.).
3. Point **`GameDirs`** for that map at **`{ "Forest", ... }`** as needed.

Minimal **`GameDirs`** shape (same keys as other maps — all validated):

```lua
["Forest"] = {
	ProfileStoreName = "YourGame_Profile",
	LeaderboardStoreName = "YourGame_LB",
	VRSupport = false,
	GameDirs = {
		Workspace_Ume = { "Forest" },
		ReplicatedStorage_Ume = { "Forest" },
		ServerStorage_Ume = { "Forest" },
		StarterGui = { "Forest" },
		StarterPack = { "Forest" },
		StarterPlayer = { "Forest" },
		Assets = { "Forest" },
		SAssets = { "Forest" },
	},
	ModulesDirs = { "Ume", "Ume_Data", "Roblox", "Utils", "Main" },
	DisabledModules = {},
	LoadingOrder = {},
	ReturnPlaceId = nil,
},
```

### 5.2 New place id

1. Add **`PlaceConfigs[newPlaceId] = { DefaultMapId, LobbyId, MapConfigs }`**.
2. Ensure **`DefaultPlaceId`** exists and every **`LobbyId` / `DefaultMapId`** references real map entries.
3. Align **`ModulesDirs`** with folders that actually exist under your Instance module roots — see [Module structure](../guides/module-structure.md).

---

<span id="6-constraints-and-edge-cases"></span>

## ⚠️ 6. Constraints and edge cases

- **Duplicate map folder names** under one `PlaceLoader` container → startup **errors** before modules run.
- **Invalid place/map config** → startup **fails** after validation warnings.
- **MemoryStore map hash unavailable** → **`I.Teleport`** cannot route by map (warns, returns `false`).
- **Temporary lobby servers** run minimal Bloom: players go to **`ReturnPlaceId`** or **`DefaultPlaceId`**; **`LobbyGui`** may move to **`ReplicatedFirst`**.
- **`I.Config.Metadata`**: only meaningful on the server for reserved-server joins; do not rely on it client-side.

---

<span id="7-related-docs"></span>

## 📚 7. Related docs

- [Configs reference](../reference/configs.md) — Start config layout.
- [Module structure](../guides/module-structure.md) — module folders vs `ModulesDirs`.
