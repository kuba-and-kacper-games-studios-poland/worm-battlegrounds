<h1 align="center">Events</h1>

<p align="center">
The <strong>Network</strong> section of a module's <code>_meta/README.md</code> is the readable map of remotes and Topics <strong>this module creates</strong>. <code>argTypes</code> on <code>I.Network.GetEvent</code> / <code>GetFunction</code> / <code>GetUEvent</code> validate <strong>inbound</strong> payloads only — the environment that <code>Fired</code>, <code>OnInvoke</code>, or <code>UFired</code>.
</p>

---

## 📑 Table of contents

| Name | Description |
| ---- | ----------- |
| **[🎯 Rule](#rule)** | Pointer to the events rule. Runtime note on `I.Validate`. |
| **[📬 Registry](#registry)** | Shapes for listen, create-only, and a handler. |
| **[📄 README Network section](#network-section)** | Server / Client template. |
| **[🔗 Related](#related)** | Module structure and networking. |

---

<span id="rule"></span>

## 🎯 Rule

Who may `Get*`, when `argTypes` are required, and how the README's Network section is grouped: [`.claude/rules/ume/events.md`](../../.claude/rules/ume/events.md). Where that code sits (`Handler.Init` versus the entry script, and who assigns `I`) is [`.claude/rules/ume/structure.md`](../../.claude/rules/ume/structure.md).

`I.Validate` on remotes runs only inside `Fired`, `UFired`, and `OnInvoke` (`src/modules_ume/Ume/Network/Global.lua`). `Fire` / `FireAll` / `Invoke` / `UFire` never check `argTypes`.

---

<span id="registry"></span>

## 📬 Registry

These snippets show the call shape. A handler that owns the system may contain them. The entry script does not have to.

Owner server, create and listen:

```lua
--- @Network
I.Network.GetEvent("Inventory_RequestUpdate", { "Player", { Type = "string", Optional = true } })
I.Network.Fired("Inventory_RequestUpdate", Module.UpdateClientData)

I.Network.GetEvent("Inventory_UpdateClientData")
```

Handler that owns the remote (WidgetManager `MessageWidget`):

```lua
I.Network.GetEvent("WidgetManager_ShowMessage", { "string" })
I.Network.Fired("WidgetManager_ShowMessage", Module.Show)
```

`Global.lua` — one env only:

```lua
if I.Env.IsServer then
	I.Network.GetEvent("Example_ServerOnly", { "Player", "string" })
	I.Network.Fired("Example_ServerOnly", Module._onServerOnly)
end
```

Client receive (no `Player` in the schema):

```lua
I.Network.GetEvent("CharacterAnimation_PlayAnimation", { "string", { Type = "table" } })
I.Network.Fired("CharacterAnimation_PlayAnimation", Module.PlayAnimation)
```

Server send-only create (no schema):

```lua
I.Network.GetEvent("CharacterAnimation_PlayAnimation")
```

---

<span id="network-section"></span>

## 📄 README Network section

Group order and what to omit: [`.claude/rules/ume/events.md`](../../.claude/rules/ume/events.md). It sits in the module's `_meta/README.md` ([Module README](module-readme.md)). Don't list another module's names.

```markdown
## Network

### Server

**Send: RemoteEvents**

- `CharacterAnimation_PlayAnimation @ (player: Player, animationId: string, animationSettings: table)`: plays an animation on that player's character.

### Client

**Receive: RemoteEvents**

- `CharacterAnimation_PlayAnimation @ (animationId: string, animationSettings: table)`
```

Mixed directions (Inventory):

- Server **Receive** `Inventory_RemoveBulk`, **Send** `Inventory_UpdateClientData`
- Client **Send** `Inventory_RemoveBulk`, **Receive** `Inventory_UpdateClientData`

---

<span id="related"></span>

## 🔗 Related

- [Module structure](module-structure.md) — entry script and handlers
- [`.claude/rules/ume/events.md`](../../.claude/rules/ume/events.md) — who may `Get*`, `argTypes`, the README's Network groups
- [Networking](../architecture/networking.md) — remotes vs Replicator
- [Module README](module-readme.md) — where the Network section sits
