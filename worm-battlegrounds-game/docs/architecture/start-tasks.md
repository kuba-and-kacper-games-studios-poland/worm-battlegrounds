<h1 align="center">Start Tasks</h1>

<p align="center">
Each entry is a ModuleScript under <code>src/core/game_instance/Start/tasks/</code>, required from <code>Start/init.lua</code> and invoked during <code>Ume.Bloom()</code>. Tasks are grouped by role (<strong>General</strong>, <strong>Special</strong>, <strong>Runtime</strong>). Within each table, rows follow Bloom order. For diagrams and entry scripts, see <a href="./startup-order.md">startup-order.md</a>.
</p>

---

## 📑 Table of contents

| Name | Description |
| ---- | ----------- |
| **[⚙️ General](#general)** | Infrastructure before maps and modules—replication through libraries. |
| **[🗺️ Special](#special)** | Place/map and lobby resolution; may exit Bloom early on lobby servers. |
| **[🚀 Runtime](#runtime)** | Module pipeline, hooks, protection, and load-ready signaling. |

---

<span id="general"></span>

## ⚙️ General

Early framework plumbing: replication gate, services, environment, folders, config, datastore probe, and libraries.

| Task               | Summary                                                                                                                                                                                                                   | More                                                     |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| `replication_gate` | Gates framework load on the client until replicated instance state is ready (with diagnostics/time limits). On the server, writes the replication manifest near the end of Bloom so clients can validate what replicated. | —                                                        |
| `services`         | Builds the framework’s Roblox service accessor (`I.S`) so later code uses one consistent, typed service table instead of scattering `game:GetService` calls.                                                              | —                                                        |
| `environment`      | Fills `I.Env` (server/client/studio flags, player identity on the client, etc.) so the rest of startup and modules can branch safely.                                                                                     | —                                                        |
| `directories`      | Ensures the expected folder instances exist under the game instance model (containers for modules, assets, protected scripts, etc.) and exposes them on the framework instance for later tasks.                           | —                                                        |
| `config`           | Loads merged framework config tables from `Start/configs/` onto the instance (general, modules, place loader, and related slices used during startup).                                                                    | [Configs reference](../reference/configs.md)             |
| `datastore_access` | On the server in Studio, probes DataStore access and records a small state string so game code can avoid assuming live datastore behavior when access is blocked or offline.                                              | —                                                        |
| `libraries`        | Loads shared libraries from the configured tree, wires them onto the framework where applicable, and injects the framework reference into libraries that expect `Ume`.                                                    | —                                                        |

---

<span id="special"></span>

## 🗺️ Special

Place and map resolution; can short-circuit Bloom on temporary lobby servers.

| Task           | Summary                                                                                                                                                                                                                                                                  | More                                           |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------- |
| `place_loader` | Server: validates place/map config, resolves map and lobby behavior, may reorganize workspace map folders, registers teleport/lobby helpers, and can early-exit Bloom for temporary lobby servers. Client: applies the resolved map-side config slice after replication. | [Place loader architecture](./place-loader.md) |

---

<span id="runtime"></span>

## 🚀 Runtime

Pointers, lifecycle hooks, module execution, hardening, and client/server load signaling.

| Task                 | Summary                                                                                                                                                                                                                | More                                                                                                     |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `pointer`            | Server-only: creates `ReplicatedStorage` object values pointing at the Start module (and failed bucket) so clients and tooling can resolve the live framework module after replication.                                | —                                                                                                        |
| `finished_functions` | Registers and runs prioritized hooks: framework-started callbacks, optional player-loaded wiring on client, remotes for “player loaded” coordination, and ordered execution after modules run.                         | —                                                                                                        |
| `modules`            | Server may preprocess the module tree (rename/filter/prepare); both sides collect module scripts, store them on the instance, then run the module loader pipeline so every registered module boots in framework order. | [Module structure](../guides/module-structure.md)          |
| `protect`            | Server-only: moves server-marked scripts (naming conventions and `.comp` assets, respecting opt-out attributes) into the protected folder, then later exposes only the intended instance subtree to the client.        | —                                                                                                        |
| `status`             | Server listens for a client “loaded” signal and stamps player status for replication; client fires that signal once its side reports ready—aligning “framework started” vs “this player finished loading.”             | —                                                                                                        |
