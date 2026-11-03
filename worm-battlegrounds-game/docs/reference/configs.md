<h1 align="center">Configs</h1>

<p align="center">
Lua modules under <code>Start/configs/</code>, loaded by <code>tasks/config</code> into <code>I.Config</code>. Covers versions, module load order, place/map tables, and datastore identifiers consumed during Bloom.
</p>

---

## 📑 Table of contents

| Name | Description |
| ---- | ----------- |
| **[📋 Overview](#overview)** | How `tasks/config` merges Start configs into `I.Config` and runtime overrides. |
| **[📄 `general.lua`](#generallua)** | Version strings, client-started marker name, production datastore normalization. |
| **[📦 `modules.lua`](#moduleslua)** | Default module-folder `LoadingOrder` and merge rules with map overlays. |
| **[🗺️ `place_loader.lua`](#place_loaderlua)** | Place/map tables, top-level settings, `PlaceSettings`, and `MapSettings` fields. |

---

<span id="overview"></span>

## 📋 Overview

`tasks/config.lua` requires `general.lua`, `modules.lua`, and `place_loader.lua` into `I.Config.General`, `I.Config.Modules`, and `I.Config.PlaceLoader`.

Server `place_loader` overwrites `PlaceLoader.PlaceId` / `PlaceLoader.MapId` and sets `I.Config.Map`, `I.Config.IsLobby`, and optional `I.Config.Metadata` after resolution. Client applies resolved map config without running server datastore probes.

Underscore-prefixed keys are internal: version/log strings, MemoryStore/DataStore ids, replicated marker names.

---

<span id="generallua"></span>

## 📄 `general.lua`

Versions, client-loaded marker name, production flag for datastore name normalization.

| Field                   | Type    | Role                                                                                                                                                                                                 |
| ----------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `_umeVersion`           | string  | Framework version string (shown in client Studio boot logs alongside game place info).                                                                                                               |
| `_clientStatusBoolName` | string  | Name of the `BoolValue` created on the `Player` when the client reports loaded (via `tasks/status.lua`). Default `__Ume_ClientStarted`.                                                              |
| `GameVersion`           | string  | Game version string for logging / display.                                                                                                                                                           |
| `IsProductionReady`     | boolean | When `true` and the experience is **not** Studio, `tasks/config.Update` may rewrite map datastore names that contain `UmeTesting` to `Production` for `ProfileStoreName` and `LeaderboardStoreName`. |

---

<span id="moduleslua"></span>

## 📦 `modules.lua`

Default module-folder load order. Map `LoadingOrder` entries append after this list for names not already listed (`tasks/modules.Run`).

| Field          | Type       | Role                                                                                                                                                                                                                                                          |
| -------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `LoadingOrder` | `{ string }` | Default module folder load order under `Instance/Modules*` (and merged directories). During `tasks/modules.Run`, map-specific `LoadingOrder` entries are **appended** after this list for any module names not already present (`I.Config.Map.LoadingOrder`). |

Entries are module **folder** names, not script names. Earlier names in the merged order run first.

Current default list in repo (source file wins if this drifts):

- **Ume:** Topic, Network, DoEvery, Component
- **Ume Data:** Player, Replicator, Buff, Statistic
- **Roblox:** Core, Debounce, Team, Sound, Badge, Group, Policy, Friends, Favorite, Platform, Marketplace, GlobalLeaderboard, Tool, Lighting, Interact, Leaderstats, UserInterface
- **Admin Panel:** AdminPanel

---

<span id="place_loaderlua"></span>

## 🗺️ `place_loader.lua`

Per-place and per-map tables: PlaceLoader directory targets, module buckets, datastore scope strings, teleport helpers. `place_loader.VerifyConfigs` validates shapes at startup (required `GameDirs` keys, map fields, `DefaultMapId` / `LobbyId` present in `MapConfigs`).

### Top-level place-loader settings

| Field                            | Type                           | Role                                                                                                                                                                      |
| -------------------------------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `DefaultPlaceId`                 | number                         | Default place used when resolving configs and fallbacks (template uses `game.PlaceId` at **require** time — duplicate explicitly for each place id in multi-place games). |
| `_mapStoreId`                    | string                         | `MemoryStoreService` hash map name used to associate reserved servers with a `MapId` (and metadata) for teleports.                                                        |
| `_lobbyStoreId`                  | string                         | `DataStore` name used for persistent lobby state (`GetPersistentLobbyState` / `UpdatePersistentLobbyState`).                                                              |
| `PersistentLobbyInStudio`        | boolean                        | Whether persistent-lobby logic runs in Studio (when API access allows).                                                                                                   |
| `PersistentLobbyExcludedServers` | `{ string }`                   | Private server ids where persistent lobby behavior is skipped (`game.PrivateServerId`).                                                                                   |
| `PlaceId`                        | `number?`                      | **Runtime:** current resolved place id (written by `place_loader`).                                                                                                       |
| `MapId`                          | `string?`                      | **Runtime:** current resolved map id (written by `place_loader`).                                                                                                         |
| `PlaceConfigs`                   | `{ [number]: PlaceSettings }`  | Per-place configuration; keys must include every place id players can land on if those places share this config module.                                                   |

### `PlaceSettings` (per entry in `PlaceConfigs`)

Type: `Ume_PlaceLoader_PlaceSettings` (`src/core/_meta/_types.lua`). `DefaultMapId` and `LobbyId` must be keys in `MapConfigs`.

| Field          | Type                         | Role                                                                                                                         |
| -------------- | ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `DefaultMapId` | string                       | Map used when no memory-store / lobby override applies; must exist as a key in `MapConfigs`.                                 |
| `LobbyId`      | string                       | Map id treated as the lobby for this place; must exist in `MapConfigs`. Used with runtime `MapId` to set `I.Config.IsLobby`. |
| `MapConfigs`   | `{ [string]: MapSettings }` | All maps available for this place, keyed by map id string.                                                                   |

### `MapSettings` (per entry in `MapConfigs`)

Type: `Ume_PlaceLoader_MapSettings` (`src/core/_meta/_types.lua`). Fields checked in `verifyMapConfig`.

| Field                  | Type       | Role                                                                                                                                                                                                                                                                              |
| ---------------------- | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ProfileStoreName`     | string     | Profile datastore scope string. With `IsProductionReady` and live server, `config.Update` can rename `UmeTesting*` to `Production`.                                                                                                                                               |
| `LeaderboardStoreName` | string     | Leaderboard datastore scope string; same optional normalization as `ProfileStoreName`.                                                                                                                                                                                            |
| `VRSupport`            | boolean    | Boolean; validated at startup. Modules interpret it.                                                                                                                                                                                                                              |
| `GameDirs`             | table      | Named buckets of **subdir name lists** used when relocating `PlaceLoader` content. Required keys (each value must be a table/array of strings): `Workspace_Ume`, `ReplicatedStorage_Ume`, `ServerStorage_Ume`, `StarterGui`, `StarterPack`, `StarterPlayer`, `Assets`, `SAssets`. |
| `ModulesDirs`          | `{ string }` | Names of module buckets under `Instance/Modules` (and merged containers) that participate in loading for this map.                                                                                                                                                                |
| `DisabledModules`      | `{ string }` | Module **folder names** excluded from loading for this map.                                                                                                                                                                                                                       |
| `LoadingOrder`         | `{ string }` | Extra module folder names appended after `I.Config.Modules.LoadingOrder` for this map (`tasks/modules.Run`).                                                                                                                                                                      |
| `ReturnPlaceId`        | `number?`  | For lobby / redirect flows: place id used when sending players to the “main” experience from a temporary lobby server (`TeleportPlayersToMainServer`).                                                                                                                            |
