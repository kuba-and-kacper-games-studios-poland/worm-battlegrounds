<h1 align="center">Networking</h1>

<p align="center">
<strong>Network</strong> (<code>src/modules_ume/Ume/Network/</code>): client ↔ server <strong>remotes</strong>. The server creates them under <code>Remotes</code>; clients use them after replication.
</p>

<p align="center">
<strong>Replicator</strong> (<code>src/modules_ume/Ume_Data/Replicator/</code>): the server sets <strong>attributes</strong> on folders in each player’s replicator tree; the client reads them when they replicate.
</p>

<p align="center">
Use <strong>remotes</strong> for actions and messages (<strong>events</strong> are one-way; <strong>functions</strong> return a value). Use <strong>Replicator</strong> when values update often or you want replicated state without firing a remote every time. For server-only or client-only messaging, see <a href="./module-communication.md">Module communication</a>.
</p>

---

## 📑 Table of contents

| Name                                                                      | Description                                                          |
| ------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| **[🌐 Overview](#overview)**                                              | When to use Replicator vs reliable/unreliable events vs functions.   |
| **[🔄 1. Replicator](#1-replicator--attribute-backed-state-ireplicator)** | Attribute-backed folders per player and typical server/client usage. |
| **[⚙️ 2. `I.Network` after startup](#2-inetwork-after-startup)**          | `GetEvent` / `GetFunction` / `GetUEvent` and fire/invoke helpers.    |
| **[📬 3. Reliable events](#3-reliable-events--register-fire-listen)**     | Create remotes, fire and listen on server and client.                |
| **[🔁 4. Remote functions](#4-remote-functions--oninvoke-and-invoke)**    | `OnInvoke` / `Invoke` patterns and return-channel naming.            |
| **[💨 5. Unreliable events](#5-unreliable-events)**                       | `GetUEvent`, `UFire`, and when loss tolerance is OK.                 |
| **[🏷️ 6. Naming and ownership](#6-naming-and-ownership)**                 | Prefixing remotes and keeping responsibilities clear.                |

---

<span id="overview"></span>

## 🌐 Overview

| Kind             | API surface                                                                   | Typical use                                                                                                                                                                                                                                                                                                                    |
| ---------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Replicator**   | `I.Replicator` (`CreateFolder`, `Get` / `GetFolder`, attributes on instances) | Server-owned folders under each player’s replicator tree; **set attributes on the server**, read or subscribe on the client via attribute signals. Prefer over spamming remotes when values change regularly or you are mirroring larger structured snapshots (still respect Roblox attribute limits—encode chunks if needed). |
| Reliable event   | `GetEvent`, `Fire`, `FireAll`, `Fired`                                        | Must-deliver signals (gameplay, UI commands).                                                                                                                                                                                                                                                                                  |
| Unreliable event | `GetUEvent`, `UFire`, `UFireAll`, `UFired`                                    | High-frequency or loss-tolerant traffic (movement-feel, cosmetic bursts).                                                                                                                                                                                                                                                      |
| Function         | `GetFunction`, `Invoke`, `OnInvoke`                                           | Ask the other side for a result (validation, UI state snapshot, ack pattern).                                                                                                                                                                                                                                                  |

**Important (Network):** The **server** must create remotes (via `GetEvent` / `GetFunction` / `GetUEvent`) so instances exist and replicate. Clients subscribe or invoke after those instances are available.

**`argTypes`:** Schemas on `GetEvent` / `GetFunction` / `GetUEvent` are **inbound only**, and **`Get*` is owner-only** — the module that creates the remote. Whenever the **owner** env **listens** (`Fired` / `OnInvoke` / `UFired`), pass `argTypes` (empty inbound is `{}`). Other modules that listen or send **do not** `Get*` that name. `Fire` / `Invoke` never validate against `argTypes`. An env that only **sends** does **not** `Get*` (client send-only is `Fire` only). The **owner server** still `Get*` so the instance exists; that create call has no schema unless the server also listens. If the **server receives**, the first schema entry must be `"Player"`. On the **client**, there is no `Player`-first requirement. How a module lists its remotes in its README: [Events](../guides/events.md).

Inbound arguments from clients are also scanned for basic safety (see `src/modules_ume/Ume/Network/Settings.lua`—string length, table size/depth, unsafe numbers, cycles). Remote **names** can be obfuscated when `OBFUSCATE` is enabled there.

More detail: `src/modules_ume/Ume/Network/` · `src/modules_ume/Ume_Data/Replicator/`.

---

<span id="1-replicator--attribute-backed-state-ireplicator"></span>

## 🔄 1. Replicator — attribute-backed state (`I.Replicator`)

The Replicator module builds a per-player container (a hidden `ScreenGui`, moved into `ReplicatedStorage` for the client) so the **server** can create folders and rely on **Roblox replication + attributes** instead of firing a remote for every field change.

| Side       | Typical use                                                                                                                      |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------- |
| **Server** | `I.Replicator.CreateFolder(player, folderName)` then `I.Replicator.Set(player, folderName, key, value)` (and again as state changes). |
| **Client** | `I.Replicator.GetFolder(folderName)` then `GetAttribute` / `GetAttributeChangedSignal` to drive UI or local caches.              |

**When to prefer this over Network:** the data is **continuously or frequently updated**, or you are exposing a **stable set of fields** clients should observe—attributes batch through the engine’s replication path instead of custom remote bursts. **Commands** (do this now, invoke skill, close UI) usually stay on **remotes**; **mirrored state** (scores, counts, encoded lists) often fits **Replicator**.

Examples inside the shipped framework are under **`src/modules_ume/`**—for instance **`Roblox/Friends`** registers **`I.G_Player.OnPlayerAdded`**, calls **`I.Replicator.CreateFolder`**, and sets attributes on that folder; **`Ume_Data/Buff`** uses the same **`OnPlayerAdded` → `CreateFolder`** idea and updates attributes when buff state changes. On the client, call **`I.Replicator.GetFolder`** once the replicator exists (many features defer wiring until **`I.OnLoaded`** so the tree has moved under **`ReplicatedStorage`**).

**Server** (`Server.lua` shape—create folders at `I.Priority.Replicator`, after the `I.Priority.Data` checks and before the client is told it loaded)

```lua
--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MyFeature"

function Module.Init()
	I.G_Player.OnPlayerAdded(I.Priority.Replicator, Module._createReplicator)
end

function Module._createReplicator(player: Player)
	if not I.Player.Valid(player) then
		return
	end

	I.Replicator.CreateFolder(player, _localName)
	I.Replicator.Set(player, _localName, "Score", 0)
end

function Module._pushScoreToClient(player: Player, score: number)
	I.Replicator.Set(player, _localName, "Score", score)
end
```

> ⚠️ **Reference:** Illustrative. A handler may register the remote. The environment entry script assigns `I`. Placement: `.claude/rules/ume/structure.md` and `.claude/rules/ume/events.md`. Template: [Module structure](../guides/module-structure.md).

**Client** (`Client.lua` shape—`I.OnLoaded` waits until player data / replicator wiring is ready; priority orders alongside other `OnLoaded` callbacks)

```lua
--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)
local _localName = "MyFeature"

function Module.Init()
	I.OnLoaded(I.Priority.Replicator, Module._connectReplicator)
end

function Module._connectReplicator()
	local folder = I.Replicator.GetFolder(_localName)
	if not folder then
		return
	end

	folder.AttributeChanged:Connect(function(attribute: string)
		if attribute ~= "Score" then
			return
		end

		Module._onScoreChanged(folder:GetAttribute(attribute))
	end)
end

function Module._onScoreChanged(value: number)
	-- ...
end
```

> ⚠️ **Reference:** Illustrative. A handler may register the remote. The environment entry script assigns `I`. Placement: `.claude/rules/ume/structure.md` and `.claude/rules/ume/events.md`. Template: [Module structure](../guides/module-structure.md).

---

<span id="2-inetwork-after-startup"></span>

## ⚙️ 2. `I.Network` after startup

The Network module assigns `I.Network` during its `Init`. Typical members you use from game modules:

| Member                          | Role                                                              |
| ------------------------------- | ----------------------------------------------------------------- |
| `GetEvent(name, argTypes?)`     | Ensures a `RemoteEvent` exists (server creates; client resolves). |
| `GetUEvent(name, argTypes?)`    | Same for `UnreliableRemoteEvent`.                                 |
| `GetFunction(name, argTypes?)`  | Same for `RemoteFunction`.                                        |
| `Fire` / `FireAll` / `Fired`    | Reliable event send / broadcast / listen.                         |
| `UFire` / `UFireAll` / `UFired` | Unreliable event variants.                                        |
| `Invoke` / `OnInvoke`           | RemoteFunction call / bind handler.                               |

---

<span id="3-reliable-events--register-fire-listen"></span>

## 📬 3. Reliable events — register, fire, listen

**Server** — create the remote during `Init` (the entry REGISTRY, or the handler `Init` that owns that system):

```lua
--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

function Module.Init()
	I.Network.GetEvent("MyFeature_StateChanged")
end
```

> ⚠️ **Reference:** Illustrative. A handler may register the remote. The environment entry script assigns `I`. Placement: `.claude/rules/ume/structure.md` and `.claude/rules/ume/events.md`. Template: [Module structure](../guides/module-structure.md).

**Server → one client**

```lua
--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

I.Network.Fire("MyFeature_StateChanged", player, newState)
```

**Server → all clients**

```lua
--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

I.Network.FireAll("MyFeature_StateChanged", newState)
```

**Client → server**

```lua
--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

I.Network.Fire("MyFeature_StateChanged", payload)
```

**Listen** (either side, after the remote exists):

```lua
--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

function Module.Init()
	I.Network.Fired("MyFeature_StateChanged", Module._onStateChanged)
end

function Module._onStateChanged(...)
	-- ...
end
```

> ⚠️ **Reference:** Illustrative. A handler may register the remote. The environment entry script assigns `I`. Placement: `.claude/rules/ume/structure.md` and `.claude/rules/ume/events.md`. Template: [Module structure](../guides/module-structure.md).

---

<span id="4-remote-functions--oninvoke-and-invoke"></span>

## 🔁 4. Remote functions — `OnInvoke` and `Invoke`

Use when the **caller needs a return value**. Convention in framework modules: pair names such as `SomeAction` (either direction) and `SomeAction-Return` when the **server** invokes a handler implemented on the **client**—see **`src/modules_ume/Roblox/Lighting/`** (`Invoke` / `OnInvoke` on the `-Return` remotes).

**Server** — host a function clients can call:

```lua
--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

function Module.Init()
	if not I.Env.IsServer then
		return
	end

	I.Network.GetFunction("MyFeature_GetAllowed")
	I.Network.OnInvoke("MyFeature_GetAllowed", function(player: Player, action: string)
		return Module._isAllowed(player, action)
	end)
end
```

> ⚠️ **Reference:** Illustrative. A handler may register the remote. The environment entry script assigns `I`. Placement: `.claude/rules/ume/structure.md` and `.claude/rules/ume/events.md`. Template: [Module structure](../guides/module-structure.md).

**Client** calling the server:

```lua
--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

local ok = I.Network.Invoke("MyFeature_GetAllowed", "jump")
```

**Server** calling into logic registered with `OnInvoke` on the client (after client bound it):

```lua
--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

local result = I.Network.Invoke("MyFeature_DoThing-Return", player, arg1)
```

**Client** binding the return-channel handler:

```lua
--- @type Ume
local I = require(game:GetService("ReplicatedStorage"):FindFirstChild("UmePointer").Value)

function Module.Init()
	I.Network.OnInvoke("MyFeature_DoThing-Return", Module._clientDoThing)
end
```

> ⚠️ **Reference:** Illustrative. A handler may register the remote. The environment entry script assigns `I`. Placement: `.claude/rules/ume/structure.md` and `.claude/rules/ume/events.md`. Template: [Module structure](../guides/module-structure.md).

---

<span id="5-unreliable-events"></span>

## 💨 5. Unreliable events

Same shapes as §3 with `GetUEvent`, `UFire`, `UFireAll`, and `UFired`. Prefer them only when dropping an occasional packet is acceptable.

---

<span id="6-naming-and-ownership"></span>

## 🏷️ 6. Naming and ownership

- Prefix remote names with your feature (`MyFeature_...`) so collisions are unlikely inside the shared `Remotes` folder. Use clear folder names under the replicator the same way (`CreateFolder(player, "MyFeature")`).
- Who creates, listens, and sends: [`.claude/rules/ume/events.md`](../../.claude/rules/ume/events.md). Template: [Events](../guides/events.md). A handler may own that registry. The entry script assigns `I` ([`.claude/rules/ume/structure.md`](../../.claude/rules/ume/structure.md)). Attribute writes on replicator folders are usually server-only.
- Combine with [Module communication](./module-communication.md) on each peer: Network and Replicator cross the boundary; Topic / `I.ModuleName` stays local.
