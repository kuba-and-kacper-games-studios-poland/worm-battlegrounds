# Ume events

`GetEvent` / `GetFunction` / `GetUEvent` **create** a remote. `Fired` / `OnInvoke` / `UFired` **listen**. `Fire` /
`FireAll` / `Invoke` / `UFire` **send**. `argTypes` check inbound payloads only; sends never check them. Call shapes:
`docs/guides/events.md`.

## Who creates

Only the module that owns a remote calls `Get*` for it, in the entry script or in the handler that owns that system
(timing: `ume/structure.md` → Handlers, Init and Start).

- Never `Get*` in `Components/`; a component may `Fired` once the owner has created the remote.
- Never `Get*` another module's remote: a consumer only `Fired` / `Fire` / `Invoke`.
- A `Get*` in a Global script (or Global handler) that only one side should run is wrapped in `I.Env.IsServer` (or
  the client check).

| This side | Does |
| --- | --- |
| Owns and listens | `Get*(name, argTypes)`, then `Fired` / `OnInvoke` / `UFired`. No arguments is `{}`. Server inbound starts with `"Player"` |
| Owns, only sends (usually the server) | `Get*(name)` with no schema, so the instance exists |
| Owns, client that only sends | No `Get*`: `Fire` / `Invoke` / `UFire` |
| Listens to another module's remote | `Fired` / `OnInvoke` / `UFired` only |

The first `Get*` of a name stores its schema; later calls don't change it, so the schema goes with the owner's receive
path, and its `argTypes` match exactly what the sender fires, argument for argument. Richer schemas (`Optional`, `Type = "table"`) are in `docs/guides/events.md`; don't invent another form.

```lua
-- Owner server: create, schema, listen
I.Network.GetEvent("ModuleName_Interact", { "Player", "string" })
I.Network.Fired("ModuleName_Interact", Module._onInteract)

-- Owner server that only sends
I.Network.GetEvent("ModuleName_PlayAnimation")

-- Owner client that only sends
I.Network.Fire("ModuleName_Interact", actionId)

-- Another module listening
I.Network.Fired("Owner_StateChanged", Module._onStateChanged)
```

## The server decides

**Every amount is the server's.** A client remote only asks (a sell request carries nothing); the server reads the
price, the player's data and what they hold, and pays.

## Topics

`Register` before any `Publish` (above it, when the same `Init` publishes). An owner's `Topic.Publish` is bare:
`Publish` already warns when the Topic is missing. `IsRegistered` only for an optional Topic (another module may be
off); `Component.IsRegistered` is a different API.

## The README's Network section

A module's `_meta/README.md` lists, under **Network**, the remotes and Topics this module creates, never other
modules'. There is no `_events.lua`.

- One `###` per side, `Server` then `Client`, each with these groups in order, leaving out empty ones:
  1. **Topics** this module registers.
  2. **Receive: RemoteEvents** / **Receive: RemoteFunctions**: this module's remotes listened to on this side; the
     payload is the `argTypes`, named.
  3. **Send: RemoteEvents** / **Send: RemoteFunctions**: this module's remotes sent from this side (on the server,
     `player` is the target).
- One bullet per name: `` `Name @ (arg: type, …)` `` (`@ ()` when empty), then a colon and when it fires, when that
  isn't obvious. Unreliable events go under RemoteEvents with `(unreliable)`. A remote that sends and receives on one
  side is listed under both.
- A module with no remotes says so in one line, and how its values travel instead (Replicator attributes, Topics).
