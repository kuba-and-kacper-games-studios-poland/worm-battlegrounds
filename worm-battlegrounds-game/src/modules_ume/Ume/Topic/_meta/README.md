# Topic

Publish and subscribe between modules on the same side. A module registers a Topic it owns, publishes it when something happens, and any other module subscribes to react. Topics never cross the network: the server and the client each have their own Topics, even when the names match. Use a Topic when other modules should **react** to a change; call `I.<Module>` when they should **ask** for something.

| | |
| --- | --- |
| Folder | `src/modules_ume/Ume/Topic` |
| Runs on | Global: one `Global.lua` for both sides |
| Exposes | `I.Topic` |
| Uses | `I.Signal`, `I.Validate` |
| Loads | `Ume` directory, first, before Network and every game module |

## Files

| File | What it controls |
| --- | --- |
| `Global.lua` | The Topic registry: one `Signal` per name, with its optional argument schema |

## API

### Global: `I.Topic`

| Function | Returns | What it does |
| --- | --- | --- |
| `Register(topicName: string, argTypes?)` | `Signal?` | Creates the Topic. `argTypes` (a `Validate_ArgumentSchema`) is compiled once and checked on every `Publish`. Registering a name twice warns and returns the existing signal, keeping its first schema. |
| `Subscribe(topicName: string, callback)` | `Signal_Connection?` | Runs `callback(...)` on each `Publish`. Warns and returns `nil` when the Topic isn't registered yet, so subscribe in `Start`. |
| `SubscribeOnce(topicName: string, callback)` | `Signal_Connection?` | Runs `callback(...)` on the next `Publish` only. Same checks as `Subscribe`. |
| `Publish(topicName: string, ...)` | | Fires the Topic. Warns and drops the call when the Topic isn't registered or the arguments don't match its `argTypes`. |
| `Wait(topicName: string, timeout: number?)` | `...any` | Yields until the next `Publish` and returns its arguments. With `timeout`, returns nothing when that many seconds pass first. |
| `IsRegistered(topicName: string)` | `boolean` | Whether the Topic exists. Only for Topics that are optional (their owner may be disabled). |

Who registers, when to subscribe, and when `IsRegistered` is allowed: `.claude/rules/ume/events.md` (Topics).

## Usage

```lua
-- Owner, in Init: register before anything publishes
I.Topic.Register("Shop_ItemBought", { "Player", "string" })

-- Owner: publish bare, no IsRegistered check
I.Topic.Publish("Shop_ItemBought", player, itemId)

-- Another module, in Start
I.Topic.Subscribe("Shop_ItemBought", Module._onItemBought)
```
