# Replicator

Per-player values the client can read. The server gives every player a hidden `ScreenGui` (the replicator) with one Folder per module; modules write attributes on their folder and only that player's client sees them. It is how saved and session values (currency, statistics, buffs) reach the client without remotes.

| | |
| --- | --- |
| Folder | `src/modules_ume/Ume_Data/Replicator` |
| Runs on | Server, Client |
| Exposes | `I.Replicator` (server, client) |
| Uses | `I.G_Player`, `I.Network` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Creates the replicator in the player's `PlayerGui` when they join, clears it when they leave, creates module folders |
| `Client.lua` | Moves the replicator into `ReplicatedStorage` when the server says so, finds folders |
| `Settings.lua` | The replicator's name |
| `_meta/_types.lua` | `Replicator_PlayerTable` |

## API

### Server: `I.Replicator`

| Function | Returns | What it does |
| --- | --- | --- |
| `CreateFolder(player, folderName: string)` | `Folder?` | Creates the module's folder in that player's replicator. Call it once, from an `I.G_Player.OnPlayerAdded` callback at `I.Priority.Replicator`. |
| `Set(player, folderName: string, name: string, value: any)` | `boolean` | Sets an attribute on the player's folder. Errors (naming the attribute and folder) when Roblox rejects the name or value, checked the first time each name is set; after that, skips a value that didn't change. `false` when the player isn't valid or the folder doesn't exist. |
| `Get(player)` | `ScreenGui?` | The player's replicator |
| `GetFolder(player, folderName: string)` | `Folder?` | A folder created earlier |

### Client: `I.Replicator`

| Function | Returns | What it does |
| --- | --- | --- |
| `Get()` | `ScreenGui?` | The local player's replicator |
| `GetFolder(folderName: string)` | `Folder?` | A module's folder |
| `WaitForFolder(folderName: string, timeout: number?)` | `Folder?` | Waits for the replicator to move into `ReplicatedStorage`, then for the folder; `nil` after `timeout` seconds. For folders the server creates later in the session. |

Read folders from `_connectReplicator`, which runs only through `I.OnLoaded` (`.claude/rules/ume/structure.md`).

## Usage

```lua
-- Server, OnPlayerAdded
I.Replicator.CreateFolder(player, _localName)
I.Replicator.Set(player, _localName, "Cash", "0")

-- Client, I.OnLoaded
local folder: Folder? = I.Replicator.GetFolder(_localName)
folder:GetAttributeChangedSignal("Cash"):Connect(Module._refresh)
```

## Network

### Server

**Send: RemoteEvents**

- `Replicator_Move @ (player: Player)`: tells the client its replicator is ready to move.

### Client

**Receive: RemoteEvents**

- `Replicator_Move @ ()`: moves the replicator from `PlayerGui` into `ReplicatedStorage`.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `REPLICATOR_STORAGE_NAME` | `"_replicator"` | Name of the replicator `ScreenGui` |
