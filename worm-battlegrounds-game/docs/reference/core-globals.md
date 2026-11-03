<h1 align="center">Core Globals</h1>

<p align="center">
Public surface of the framework instance table (<code>I</code>): the value returned by <code>require(...Start)</code> after <code>Ume.Bloom()</code> runs. These are <strong>not</strong> entries on Lua’s <code>_G</code>; modules receive this table as their framework pointer.
</p>

---

## 📑 Table of contents

| Name | Description |
| ---- | ----------- |
| **[📛 Naming](#naming)** | `I` naming convention for everything below. |
| **[🚀 Bootstrap (`Start/init.lua`)](#bootstrap-startinitlua)** | `Bloom`, `Started`, and framework load timing. |
| **[🌍 Environment (`tasks/environment.lua`)](#environment-tasksenvironmentlua)** | `Env` flags and client-only player/UI shortcuts. |
| **[🔧 Services (`tasks/services.lua`)](#services-tasksserviceslua)** | Lazy `I.S` Roblox service cache. |
| **[📁 Directories (`tasks/directories.lua`)](#directories-tasksdirectorieslua)** | Public `Dirs` paths and internal `_dirs` instance roots. |
| **[⚙️ Configuration (`tasks/config.lua` + `tasks/place_loader/init.lua`)](#configuration-tasksconfiglua--tasksplace_loaderlua)** | `I.Config` slices after config + place resolution. |
| **[💾 DataStore access (`tasks/datastore_access.lua`)](#datastore-access-tasksdatastore_accesslua)** | Server-only `DataStoreAccess*` persistence probes. |
| **[📚 Libraries (`tasks/libraries.lua`)](#libraries-taskslibrarieslua)** | Shared library tables injected onto `I`. |
| **[🔁 Lifecycle callbacks (`tasks/finished_functions.lua`)](#lifecycle-callbacks-tasksfinished_functionslua)** | `OnStarted`, client `OnLoaded`, and player-loaded signaling. |
| **[🧩 Modules runtime (`tasks/modules.lua`)](#modules-runtime-tasksmoduleslua)** | Module phases, per-module `Settings`, execution timings. |
| **[🗺️ Place loader API (`tasks/place_loader/init.lua`)](#place-loader-api-tasksplace_loaderlua)** | Server-only teleport and persistent lobby helpers on `I`. |

---

<span id="naming"></span>

## 📛 Naming

Convention in core tasks is `local I = umeInstance`. Anything documented below is `I.<name>` unless noted.

---

<span id="bootstrap-startinitlua"></span>

## 🚀 Bootstrap (`Start/init.lua`)

| Member                  | Kind             | Notes                                                                                                                             |
| ----------------------- | ---------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `Bloom`                 | function → `nil` | Entry point: runs the full load pipeline once. After the first successful call, the field is set to `nil` so it cannot run twice. |
| `Started`               | boolean          | `false` at the beginning of `Bloom`, set to `true` when startup finishes.                                                         |
| `_frameworkLoadingTime` | number           | Seconds spent inside `Bloom` (wall clock via `os.clock()`).                                                                       |

---

<span id="environment-tasksenvironmentlua"></span>

## 🌍 Environment (`tasks/environment.lua`)

| Member            | Kind                                    | Server | Client |
| ----------------- | --------------------------------------- | ------ | ------ |
| `Env`             | table                                   | ✓      | ✓      |
| `Env.Key`         | `"Server"` \| `"Client"` \| `"Unknown"` | ✓      | ✓      |
| `Env.IsServer`    | boolean                                 | ✓      | ✓      |
| `Env.IsClient`    | boolean                                 | ✓      | ✓      |
| `Env.IsStudio`    | boolean                                 | ✓      | ✓      |
| `Env.LocalPlayer` | `Player`                                | —      | ✓      |
| `Env.Mouse`       | `Mouse`                                 | —      | ✓      |
| `Env.Camera`      | `Camera`                                | —      | ✓      |
| `Env.PlayerGui`   | `PlayerGui`                             | —      | ✓      |

---

<span id="services-tasksserviceslua"></span>

## 🔧 Services (`tasks/services.lua`)

| Member | Kind                        | Notes                                                                                                                                                                                                                                                                                                                       |
| ------ | --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `S`    | table (metatable `__index`) | Lazy cache of Roblox services: `I.S.<ServiceName>` resolves to `game:GetService("<ServiceName>")` and caches the instance. Documented fields in code include `Players`, `RunService`, `ReplicatedStorage`, `DataStoreService`, `TeleportService`, `Workspace`, and the rest of the standard service list in `services.lua`. |

---

<span id="directories-tasksdirectorieslua"></span>

## 📁 Directories (`tasks/directories.lua`)

### Public — `Dirs`

| Field           | Notes                                                       |
| --------------- | ----------------------------------------------------------- |
| `UmeWorkspace`  | `Workspace.Ume` (created as `Sparkles` if missing).         |
| `UmeReplicated` | `ReplicatedStorage.Ume`.                                    |
| `UmeServer`     | **Server only.** `ServerStorage.Ume`.                       |
| `Assets`        | `ReplicatedStorage.Ume.Assets`.                             |
| `SAssets`       | **Server only.** `ServerStorage.Ume.Assets`.                |
| `GlobalData`    | `Instance.GlobalData` under the Ume model (no auto-create). |
| `Storage`       | `ReplicatedStorage.Ume.Storage`.                            |
| `SStorage`      | **Server only.** `ServerStorage.Ume.Storage`.               |

### Internal — `_dirs`

| Field       | Notes                                                                                                                 |
| ----------- | --------------------------------------------------------------------------------------------------------------------- |
| `Instance`  | The Ume instance `Model` (ancestor of `Start`).                                                                       |
| `Configs`   | `Start.configs`.                                                                                                      |
| `Libs`      | `Libs` folder on the instance model.                                                                                  |
| `Modules`   | `Modules` folder on the instance model.                                                                               |
| `Protected` | **Server only.** `ServerStorage.Ume.PROTECTED` — server-only modules and matching assets are moved here by `protect`. |

---

<span id="configuration-tasksconfiglua--tasksplace_loaderlua"></span>

## ⚙️ Configuration (`tasks/config.lua` + `tasks/place_loader/init.lua`)

After load, `Config` has:

| Field         | Set by                        | Notes                                                                                                                                     |
| ------------- | ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `General`     | `config`                      | From `Start/configs/general.lua`.                                                                                                         |
| `Modules`     | `config`                      | From `Start/configs/modules.lua`.                                                                                                         |
| `PlaceLoader` | `config`, then `place_loader` | Base config from `Start/configs/place_loader.lua`; `place_loader` sets `PlaceLoader.PlaceId`, `PlaceLoader.MapId`, and derives map state. |
| `Map`         | `place_loader`                | Current map settings (`Ume_PlaceLoader_MapSettings`): modules dirs, disabled modules, store names, VR flag, `ReturnPlaceId`, etc.         |
| `IsLobby`     | `place_loader`                | Whether the active map id matches the configured lobby id for the current place.                                                          |
| `Metadata`    | `place_loader`                | **Server only** when applicable; optional map/join metadata.                                                                              |

Non-studio production builds: `config.Update` may normalize `Map.ProfileStoreName` and `Map.LeaderboardStoreName` from `UmeTesting` to `Production` when `General.IsProductionReady` is set.

---

<span id="datastore-access-tasksdatastore_accesslua"></span>

## 💾 DataStore access (`tasks/datastore_access.lua`)

**Server only** (task returns immediately on client — these fields are not defined there).

| Member                | Kind                                         | Notes                                                        |
| --------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| `DataStoreAccess`     | boolean                                      | `true` when API access is considered usable for persistence. |
| `DataStoreAccessType` | `"Access"` \| `"NoAccess"` \| `"NoInternet"` | Finer-grained outcome in Studio / failure cases.             |

---

<span id="libraries-taskslibrarieslua"></span>

## 📚 Libraries (`tasks/libraries.lua`)

`Load` requires every `ModuleScript` directly under `Libs/Internal`, then `Libs/External`, sorted by name. A library whose name starts with `s_` or contains `server` is server-only: the server's `protect.HideServerScripts` moves it out of the instance before `ExposeInstanceToClient` lets clients load, so the client never sees `S_ProfileStore` (and never starts its DataStore runtime).

`InjectUme` calls `_injectUme` on each required table. The library assigns itself there (`I.Color = Color`). Names that differ from the module are `MockDataStores` (`MockDataStore`), `BN` (`BigNum`), `Signal` (`GoodSignal`), and `ProfileStore` (`S_ProfileStore`). Sibling libraries read each other's `I` fields only after this pass, which is still before modules run.

| Member                                   | Server | Client |
| ---------------------------------------- | ------ | ------ |
| `Random`, `Table`, `Number`, `Create`    | ✓      | ✓      |
| `World`, `Gui`, `Color`                  | ✓      | ✓      |
| `Time`, `Date`                           | ✓      | ✓      |
| `Obfuscate`, `Format`, `RichText`        | ✓      | ✓      |
| `Country`, `Validate`                    | ✓      | ✓      |
| `MockDataStores`, `Ragdoll`, `UIEmitter` | ✓      | ✓      |
| `CameraShake`                            | ✓      | ✓      |
| `BN` (BigNum)                            | ✓      | ✓      |
| `Signal` (GoodSignal)                    | ✓      | ✓      |
| `ProfileStore` (S_ProfileStore)          | ✓      | —      |

---

<span id="lifecycle-callbacks-tasksfinished_functionslua"></span>

## 🔁 Lifecycle callbacks (`tasks/finished_functions.lua`)

| Member                | Scope           | Signature / behavior                                                                                                                                                                                       |
| --------------------- | --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `OnStarted`           | Server + client | `function(priority: number, callback: function)` — registers callbacks run after all modules finish `_init` / `_start` and the AdminPanel tool scripts' `_init` / `_start`; higher `priority` runs first. Registry is cleared after one run. |
| `OnLoaded`            | Client only     | Same registration shape as `OnStarted`; runs once after the server fires the player-loaded remote.                                                                                                         |
| `_informPlayerLoaded` | Server only     | `function(player: Player)` — fires the internal `PlayerLoaded` remote to that client so client `OnLoaded` callbacks run.                                                                                   |
| `Priority`            | Server + client | Frozen table of the shared priority bands for `OnStarted`, `OnLoaded` and the `I.G_Player` events (below).                                                                                                  |

**Priority bands** (`I.Priority`, from 100 down to -100, higher runs first; callbacks in one band run in registration order). Pass a band, never a raw number; to run just after a band, step one below it (`I.Priority.Setup - 1`):

| Band | Value | Use it for |
| --- | --- | --- |
| `First` | `100` | Framework only: before every module (the player's replicator, sorting the player events) |
| `Data` | `90` | Checking and repairing saved values before anything reads them |
| `Replicator` | `80` | Creating Replicator folders (server) and connecting to them (client `OnLoaded`) |
| `Setup` | `50` | Per-player state other modules read (spawn location, leaderstats, policies, client data) |
| `Default` | `0` | Gameplay |
| `Late` | `-50` | After everything else: command bar dictionaries, components after the modules' own `OnStarted` work |
| `Last` | `-100` | Framework only: telling the client it loaded, clearing the replicator on leave |

---

<span id="modules-runtime-tasksmoduleslua"></span>

## 🧩 Modules runtime (`tasks/modules.lua`)

| Member                        | Kind                   | Notes                                                                                                          |
| ----------------------------- | ---------------------- | -------------------------------------------------------------------------------------------------------------- |
| `Modules`                     | table                  | Boolean flags set as phases complete: `Initialized`, `Started`, then `Initialized_CommandBar`, `Started_CommandBar`, `Initialized_Dashboard`, `Started_Dashboard` (the AdminPanel tool scripts). |
| `Settings`                    | `{ [string]: table }`  | Per-module settings: `[moduleFolderName] = require(Settings)` when a settings module exists.                   |
| `_modulesExecutionTime_Total` | number                 | Sum of timed module entry executions for the current boot.                                                     |
| `_modulesExecutionTime`       | `{ string }`           | Human-readable lines `"[seconds] - [Module::Scope.function]"`, sorted slowest first (Studio prints this list). |

---

<span id="place-loader-api-tasksplace_loaderlua"></span>

## 🗺️ Place loader API (`tasks/place_loader/init.lua`)

**Server only** — these functions are attached inside server-guarded setup paths.

| Member                       | Notes                                                                                                                                                                            |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `GetPersistentLobbyState`    | Returns store-backed persistent lobby flag; requires `DataStoreAccess` and lobby store. Signatures: success boolean plus value or message (see implementation).                  |
| `UpdatePersistentLobbyState` | `function(state: boolean)` — updates persistent lobby flag in the lobby store.                                                                                                   |
| `Teleport`                   | `function(playersList, placeId, mapId, metadata?, guiName?)` — same-universe place + reserved server + MemoryStore map metadata; optional teleport GUI name under `UtilityGuis`. |
| `TeleportToServer`           | `function(playersList, placeId, jobId?, accessCode?, guiName?)` — either `jobId` or `accessCode`, not both.                                                                      |
| `TeleportExternal`           | `function(playersList, placeId, guiName?)` — `TeleportService` to an arbitrary place id (e.g. different experience).                                                             |
| `TeleportToDefaultLobby`     | `function(playersList, guiName?)` — uses default place config’s `LobbyId` and `I.Teleport`.                                                                                      |
