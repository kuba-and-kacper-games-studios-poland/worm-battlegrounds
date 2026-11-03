# Network

Creates, finds and checks the game's remotes. Modules never touch a `RemoteEvent` directly: the server creates each remote the first time it's asked for, under a random name, the client finds it by its logical name, and every call that arrives is safety-scanned and, when the remote has one, checked against an argument schema.

| | |
| --- | --- |
| Folder | `src/modules_ume/Ume/Network` |
| Runs on | Global: one `Global.lua` for both sides |
| Exposes | `I.Network` |
| Uses | `I.Validate`, `I.Obfuscate`, `I.Create`, `I.Player` |
| Loads | `Ume` directory, after Topic and before every game module |

## Files

| File | What it controls |
| --- | --- |
| `Global.lua` | Creates the `Remotes` folder (server) or finds it (client), caches remotes by logical name, sends and invokes, assigns `I.Network` |
| `Settings.lua` | Which remote kinds exist, name obfuscation, the server invoke timeout, the rejected-call warn interval, limits of the inbound safety scan |
| `Scripts/Global/Inbound.lua` | The checks every inbound call goes through: per-player rate limit and safety scan (server), argument types, throttled warns |
| `Scripts/Global/Stats.lua` | Studio only: calls and estimated bytes per remote, for the `network` command |
| `Scripts/helpers.lua` | `ValidateRemoteArgs` (the server-side safety scan) and `EstimateSize` (the stats' payload size) |
| `Scripts/AdminPanel/CommandBar/Global.lua` | The `network` / `s_network` commands |

## API

### Global: `I.Network`

The same names exist on both sides; what they do depends on the side.

**Create or find**

| Function | Returns | Server | Client |
| --- | --- | --- | --- |
| `GetEvent(name: string, argTypes?, options?)` | `RemoteEvent` | Creates it on the first call | Finds it |
| `GetUEvent(name: string, argTypes?, options?)` | `UnreliableRemoteEvent` | Creates it on the first call | Finds it |
| `GetFunction(name: string, argTypes?, options?)` | `RemoteFunction` | Creates it on the first call | Finds it |

- `argTypes` is a `Validate_ArgumentSchema` (see Argument schemas). Only the first `Get*` for a name stores it; a later `Get*` that passes a different schema or options warns and changes nothing.
- `options` (`Network_RemoteOptions`, server only): `{ RateLimit = 10, Per = 1 }` lets each player make at most `RateLimit` inbound calls per `Per` seconds (default `Per` is 1). Calls over the limit are dropped before the safety scan.
- On the server, the schema's first entry must be `"Player"`.
- Only the module that owns a remote calls `Get*`, during its `Init` (`.claude/rules/ume/events.md`). In Studio, the server warns when a remote is fired, invoked or listened to before any `Get*` created it.

**Send and listen**

| Function | Side | What it does |
| --- | --- | --- |
| `Fire(name, player: Player, ...)` | server | `FireClient` to `player`; warns when `player` isn't valid |
| `Fire(name, ...)` | client | `FireServer` |
| `FireAll(name, ...)` | server | `FireAllClients`; warns on the client |
| `Fired(name, callback) -> RBXScriptConnection?` | both | Runs `callback(...)` for each call that passes the inbound checks |
| `UFire`, `UFireAll`, `UFired` | | The same for `UnreliableRemoteEvent` |
| `Invoke(name, player: Player, ...) -> ...` | server | `InvokeClient` inside a `pcall`; `nil` when it fails or the client hasn't answered after `INVOKE_CLIENT_TIMEOUT` seconds |
| `Invoke(name, ...) -> ...` | client | `InvokeServer` inside a `pcall`; `nil` when it fails |
| `OnInvoke(name, callback)` | both | Answers invokes with `callback(...)` after the inbound checks |

On the client, the first payload value travels in the `player` slot and is sent as it is, `false` and `nil` included.

**Inbound checks**

A `Fired`, `UFired` or `OnInvoke` callback runs only when:

1. **(server only)** the player is within the remote's `RateLimit`, when it has one;
2. **(server only)** the payload passes the safety scan: no NaN or ±inf numbers, strings at most `MAX_STRING_LENGTH` long and not spelling nan/inf, tables at most `MAX_TABLE_SIZE` entries and `MAX_TABLE_DEPTH` deep, no cycles;
3. the payload matches the remote's `argTypes`, when it has one.

A failed check drops the call. On the server it warns with the sender at most once every `REJECT_WARN_INTERVAL` seconds per player and remote, with the number of calls dropped in between; the payload is printed only in Studio. `Fire` and `Invoke` never check `argTypes`.

**Argument schemas**

One entry per argument, defined in `src/libs/Internal/Validate/_meta/_types.lua`:

| Entry | Accepts |
| --- | --- |
| `"string"`, `"number"`, `"boolean"`, `"table"` | Luau types |
| `"Vector3"`, `"CFrame"`, … | `typeof` names |
| `"Player"`, `"BasePart"`, … | Instance classes |
| `"BigNum"` | A BigNum string |
| `{ Type = "number", Min = 1, Optional = true }` | A spec table: `Type`/`Types`, `ClassName`, `Optional`, `Min`/`Max`, `Length`/`MinLength`/`MaxLength`, `Elements` |

## Usage

```lua
-- Owner server: create with a schema and a rate limit, then listen
I.Network.GetEvent("Shop_Buy", { "Player", "string", { Type = "number", Min = 1 } }, { RateLimit = 5, Per = 1 })
I.Network.Fired("Shop_Buy", Module._onBuy)

-- Owner client: send only, no Get*
I.Network.Fire("Shop_Buy", itemId, 1)

-- Server: answer one player, or everyone
I.Network.Fire("Shop_Bought", player, itemId)
I.Network.FireAll("Shop_Restocked")
```

## Settings

| Key | Default | What |
| --- | --- | --- |
| `REMOTE_TYPES` | RemoteEvent, RemoteFunction, UnreliableRemoteEvent | Kinds `Get*` may create |
| `OBFUSCATE` | `true` | Remote instances get 20 random characters as their name |
| `INVOKE_CLIENT_TIMEOUT` | `10` | Seconds a server `Invoke` waits for the client before it returns `nil` |
| `REJECT_WARN_INTERVAL` | `5` | Seconds between two warns about rejected calls from one player on one remote |
| `MAX_STRING_LENGTH` | `200` | Safety scan: longest string |
| `MAX_TABLE_SIZE` | `100` | Safety scan: most table entries |
| `MAX_TABLE_DEPTH` | `10` | Safety scan: deepest nesting |

## In the place

| Instance | Where | Attributes |
| --- | --- | --- |
| `Remotes` (Folder) | inside the Network module | |
| each remote | `Remotes` | `Network_Name`: the logical name (the client reads it, caches the remote and clears it). `Ume_Unprotected = true`: stops protect from hiding it. |

## Commands

`network` (client) and `s_network` (server), permission level 255. Stats are collected only in Studio.

| Subcommand | Arguments | What it does |
| --- | --- | --- |
| `stats` | | The busiest remotes since the last reset: calls and estimated bytes in and out |
| `reset` | | Clears the stats |
