# Core

The framework itself: the scripts that start it on each side, the loader that runs its start tasks in order, and the configs every game sets. Modules don't call into core directly; they use what it puts on `I` (`docs/reference/core-globals.md`).

| | |
| --- | --- |
| Folder | `src/core` |
| Runs on | Server, Client |
| Exposes | The framework instance `I` and its globals (`I.Env`, `I.S`, `I.Dirs`, `I.Config`, `I.OnStarted`, `I.OnLoaded`, `I.Priority`, the place loader…) |

## Files

| File | What it controls |
| --- | --- |
| `game_mode/server/Ume-Server.server.lua`, `game_mode/client/Ume-Client.client.lua` | Start the framework on each side |
| `game_instance/Start/init.lua` | `Bloom`: runs the start tasks in order |
| `game_instance/Start/tasks/*.lua` | One task each: replication gate, services, environment, directories, config, DataStore access, libraries, place loader, modules, pointer, finished functions, protect, status ([Start Tasks](../../../docs/architecture/start-tasks.md)) |
| `game_instance/Start/tasks/place_loader/` | Places, maps, lobbies and teleports ([Place Loader](../../../docs/architecture/place-loader.md)) |
| `game_instance/Start/configs/general.lua`, `modules.lua`, `place_loader.lua` | The game's configs ([Configs](../../../docs/reference/configs.md)) |
| `game_instance/Failed/init.lua` | What runs when startup fails |
| `_meta/_types.lua` | `Ume` and the core types |

Startup order on each side: [Startup Order](../../../docs/architecture/startup-order.md).

## Network

### Server

**Receive: RemoteEvents**

- `ClientLoaded @ (player: Player)`: the client finished starting; from then on `I.Player.Valid` can be true for the player.

**Send: RemoteEvents**

- `PlayerLoaded @ (player: Player)`: the server finished loading the player; runs the client's `I.OnLoaded` callbacks.

### Client

**Receive: RemoteEvents**

- `PlayerLoaded @ ()`

**Send: RemoteEvents**

- `ClientLoaded @ ()`
