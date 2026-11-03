<h1 align="center">Actors</h1>

<p align="center">
GameMode <code>Actors</code> client/server scripts under <code>src/actors/</code>: where they mount in the DataModel, how they relate to <code>Ume.Bloom()</code>, and when to prefer modules instead.
</p>

---

## 📑 Table of contents

| Name | Description |
| ---- | ----------- |
| **[🎭 What this means in ume](#what-this-means-in-ume)** | Actors vs GameMode, bloom, and Roblox `Actor` instances. |
| **[📂 Repository layout and Rojo mapping](#repository-layout-and-rojo-mapping)** | Server/client paths and Roblox mount points. |
| **[⏱️ Scheduling vs GameMode](#scheduling-vs-gamemode)** | Ordering relative to `Ume.Bloom()` and startup docs. |
| **[✅ When to use Actors](#when-to-use-actors)** | Good fits vs preferring modules. |
| **[🔗 Dependencies on the framework](#dependencies-on-the-framework)** | Defer patterns and when to use `I.OnStarted` / `I.OnLoaded`. |
| **[📚 Related docs](#related-docs)** | Links to project structure, startup order, and core globals. |

---

<span id="what-this-means-in-ume"></span>

## 🎭 What this means in ume

**Actors** here are ordinary Roblox scripts that ume-sync maps into the **`Actors`** folder next to **`GameMode`**. They are **not** started by core (<code>Ume-Server</code> / <code>Ume-Client</code>) and **not** part of module <code>_init</code> / <code>_start</code> ordering.

They are also unrelated to Roblox’s **`Actor`** instance type and parallel Luau (<code>task.desynchronize</code>): this folder is only a **named place** for optional entry scripts.

---

<span id="repository-layout-and-rojo-mapping"></span>

## 📂 Repository layout and Rojo mapping

| Side | Repo path | Roblox location |
| --- | --- | --- |
| Server | `src/actors/server/` | `ServerScriptService.Actors` (<code>Configuration</code>) |
| Client | `src/actors/client/` | `StarterPlayer.StarterPlayerScripts.Actors` (<code>Configuration</code>) |

Neither folder ships with the template: create it on first use. `default.project.json` already maps the server folder; for client actors, add a `StarterPlayerScripts.Actors` entry (a `Configuration` with `"$path": "src/actors/client"`) next to the client `GameMode`.

Authoring follows the same Rojo naming convention as elsewhere: use <code>*.server.lua</code> for server scripts and <code>*.client.lua</code> for client-local scripts.

Full tree context: [Project structure](../architecture/project-structure.md).

---

<span id="scheduling-vs-gamemode"></span>

## ⏱️ Scheduling vs GameMode

- **GameMode** scripts require `ServerScriptService.Instance.Start` (server) or wait for replicated pointers (client), then call **`Ume.Bloom()`** and run the staged loader in `src/core/game_instance/Start/`.
- **Actors** scripts run as separate roots: Roblox schedules them like any other `Script` / `LocalScript` under those services. There is **no guaranteed order** between an actor script and `Ume-Server` / `Ume-Client`, and actors do **not** automatically wait for bloom to finish.

The startup diagram treats Actors as an independent lane for that reason: [Startup order](../architecture/startup-order.md).

---

<span id="when-to-use-actors"></span>

## ✅ When to use Actors

Good fits:

- Code that should run **without** going through the framework pipeline (tiny probes, Studio-only helpers, experiments).
- Logic that intentionally starts **early** or **alongside** bloom, as long as you accept nondeterministic ordering relative to `Ume.Bloom()`.

Prefer **modules** (`src/modules/`, `src/modules_ume/`) when you need:

- predictable lifecycle hooks (<code>Global</code>/<code>Server</code>/<code>Client</code> `._init` / `._start`),
- shared config from **global_data**,
- the framework instance **`I`** after bloom ([Core globals](../reference/core-globals.md)).

---

<span id="dependencies-on-the-framework"></span>

## 🔗 Dependencies on the framework

Anything under **`ServerScriptService.Instance`** (including **`Instance.Start`**) may not be safe to require from a server actor **at line one**: bloom might not have run yet, or siblings might still be loading.

Practical patterns:

- **Defer**: wait for the instance or module you need (e.g. `WaitForChild`, or retry/`task.defer` until `require` succeeds), or listen for remotes / attributes your game sets after startup.
- **Client**: match the discipline used in `Ume-Client` if you depend on **ReplicatedStorage** pointers populated during startup; do not assume they exist in the first lines of an actor.

If most of your code needs **`I`**, put it in a module and hook **`I.OnStarted`** / **`I.OnLoaded`** instead of an actor.

---

<span id="related-docs"></span>

## 📚 Related docs

- [Project structure](../architecture/project-structure.md) — where `actors/` sits under `src/`
- [Startup order](../architecture/startup-order.md) — GameMode vs Actors vs bloom stages
- [Core globals](../reference/core-globals.md) — what becomes available on **`I`** after startup
