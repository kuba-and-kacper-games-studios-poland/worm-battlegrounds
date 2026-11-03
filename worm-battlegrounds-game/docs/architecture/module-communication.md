<h1 align="center">Module Communication</h1>

<p align="center">
How ume modules coordinate on a single peer: direct APIs on the framework instance, and pub/sub through the <strong>Topic</strong> module (<code>src/modules_ume/Ume/Topic/</code>). Topic only applies to the <strong>current environment</strong> (server or client)—it does not replicate across server ↔ client.
</p>

<p align="center">
For <strong>client ↔ server</strong> communication (remotes and replicated attributes), see <a href="./networking.md">Networking</a>—not this document.
</p>

<p align="center">
<strong>Exposing</strong> (<code>I.ModuleName</code>) is mainly for <strong>executing logic</strong>: another module calls your functions and you run behavior or return a result. <strong>Topics</strong> are mainly for <strong>listening to updates</strong>: one place publishes that something changed, and subscribers react without calling into each other directly.
</p>

---

## 📑 Table of contents

| Name | Description |
| ---- | ----------- |
| **[📋 Overview](#overview)** | Instance APIs vs Topic on one peer; cross-boundary is [Networking](./networking.md). |
| **[🧩 1. Exposing API](#1-exposing-api-on-the-framework-instance-imodulename)** | Attach `I.ModuleName` tables for callable surfaces after `UmePointer`. |
| **[📣 2. `I.Topic`](#2-same-environment-pubsub-with-itopic)** | Register, publish, and subscribe for same-environment updates. |
| **[🔗 3. Combining patterns](#3-combining-patterns)** | Mix direct calls and pub/sub on server or client. |

---

<span id="overview"></span>

## 📋 Overview

| Approach | Scope | Use when |
| --- | --- | --- |
| **Instance API** | Same environment only | Another module should **invoke** your feature—run logic, perform an action, or fetch data via explicit calls (`I.OtherModule.foo()`). |
| **Topic** (`I.Topic`) | Same environment only | Modules should **react to changes**: publishers broadcast updates; subscribers listen. Loose coupling via a shared topic name; in-memory on **this** server or **this** client only (no replication). |

**Important:** Anything published with `I.Topic.Publish` on the **server** is visible only to modules running on the **server**. Anything published on the **client** is visible only on **that client**. Server and client each maintain their own topic registry; publishes do not cross that boundary.

More detail: implementation in `src/modules_ume/Ume/Topic/` · cross-boundary patterns in [Networking](./networking.md).

---

<span id="1-exposing-api-on-the-framework-instance-imodulename"></span>

## 🧩 1. Exposing API on the framework instance (`I.ModuleName`)

Use this when callers need to **run your logic** on demand (commands, queries, shared helpers). Prefer Topic when the goal is to **notify** others that state changed.

After `require(ReplicatedStorage.UmePointer.Value)`, the framework instance is conventionally named `I`. Modules attach a **public surface** by assigning a table with functions (and read-only data if you choose) onto `I`:

```lua
--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

local Module = {}

function Module.Init()
	I.ModuleName = {
		GetData = Module.GetData,
		Mount = Mounting.Mount,
	}
end

return {
	_init = Module.Init,
	_start = Module.Start,
}
```

> ⚠️ **Reference:** Illustrative. `I` is assigned only from the environment entry script. A public function that lives on a handler is `Handler.Name` (`Mount = Mounting.Mount`). Placement: [`.claude/rules/ume/structure.md`](../../.claude/rules/ume/structure.md). Template: [Module structure](../guides/module-structure.md).

**Consumers** (any other module that runs later on the **same** peer):

```lua
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

function Module.Start()
	local data = I.ModuleName.GetData()
end
```

> ⚠️ **Reference:** Illustrative. `I` is assigned only from the environment entry script. A public function that lives on a handler is `Handler.Name` (`Mount = Mounting.Mount`). Placement: [`.claude/rules/ume/structure.md`](../../.claude/rules/ume/structure.md). Template: [Module structure](../guides/module-structure.md).

**Notes**

- Name the table something stable and collision-aware (`I.ModuleName`, `I.WidgetManager`, `I.G_Badge`, etc.).
- Only expose what other modules should call; keep helpers local to your module file.
- Call order matters: consumers must run **after** producers assign `I.ModuleName`. If init-order is awkward, prefer `_start` or decouple with Topic.

---

<span id="2-same-environment-pubsub-with-itopic"></span>

## 📣 2. Same-environment pub/sub with `I.Topic`

Use this when something **happens** in one module and others should **listen** and refresh UI, caches, or dependent state—without importing each other’s internals.

The Topic module (`src/modules_ume/Ume/Topic/Global.lua`) registers `I.Topic` during its `Init`:

| Method | Role |
| --- | --- |
| `Register(topicName, argTypes?)` | Creates the topic (backed by `I.Signal`) and optionally locks payload shapes with `I.Validate` schemas. Call once per topic before Subscribe/Publish. |
| `Subscribe(topicName, callback)` | Connects `callback` when that topic is published. Topic must already be registered. |
| `Publish(topicName, ...)` | Fires all subscribers on **this environment** with the given arguments. Warns if the topic is not registered. Authoring (bare owner `Publish`, `IsRegistered` only for an optional topic): [`.claude/rules/ume/events.md`](../../.claude/rules/ume/events.md). |
| `IsRegistered(topicName)` | Query helper for **optional** foreign topics (the owner module may be disabled). Not for owner `Publish`. |

Optional `argTypes` validates arguments passed to `Publish` the same way other validated channels do.

### Example — producer and consumer on the same peer

**Module A** (defines the topic early, e.g. in `Init`):

```lua
function Module.Init()
	I.Topic.Register("Economy_WalletUpdated")
end

function Module._commitWallet(playerId: number, balance: number)
	-- ...
	I.Topic.Publish("Economy_WalletUpdated", playerId, balance)
end
```

> ⚠️ **Reference:** Illustrative. `I` is assigned only from the environment entry script. A public function that lives on a handler is `Handler.Name` (`Mount = Mounting.Mount`). Placement: [`.claude/rules/ume/structure.md`](../../.claude/rules/ume/structure.md). Template: [Module structure](../guides/module-structure.md).

**Module B** (subscribes after the topic exists):

```lua
function Module.Init()
	I.Topic.Subscribe("Economy_WalletUpdated", Module.RefreshHud)
end

function Module.RefreshHud(playerId: number, balance: number)
	-- ...
end
```

> ⚠️ **Reference:** Illustrative. `I` is assigned only from the environment entry script. A public function that lives on a handler is `Handler.Name` (`Mount = Mounting.Mount`). Placement: [`.claude/rules/ume/structure.md`](../../.claude/rules/ume/structure.md). Template: [Module structure](../guides/module-structure.md).

Both snippets run in the **same** context (both on server scripts or both on client scripts). Subscribing on the client to a topic that only exists on the server does **not** receive server publishes—those are separate registries.

---

<span id="3-combining-patterns"></span>

## 🔗 3. Combining patterns

On a single peer you can mix:

1. **`I.MyFeature = { ... }`** so other modules **execute** your actions or query your API.
2. **`I.Topic.Register` / `Publish` / `Subscribe`** so other modules **listen for updates** when your feature publishes changes.
