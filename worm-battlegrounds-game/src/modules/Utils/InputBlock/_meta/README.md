# InputBlock

Stops the local character from moving while anything needs it still (a dialog, a cutscene). Each blocker holds a lock id; movement input is sunk through `ContextActionService` until every id is released. A lock can be given a duration so it releases itself (a script that errors before `Unblock` can't freeze the player). The server can block and unblock a player's client and clears their locks when they leave. With `SERVER_ENFORCED`, a server lock also zeroes the character's `WalkSpeed`, `JumpPower` and `JumpHeight` on the server, so the block holds even when the client's sink didn't run. It is not exploit-proof: the client simulates its own character and can set those values locally.

| | |
| --- | --- |
| Folder | `src/modules/Utils/InputBlock` |
| Runs on | Client, Server |
| Exposes | `I.InputBlock` (client, server) |
| Uses | `ContextActionService`, `I.Network`, `I.G_Player`, `I.Player` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | The lock ids and the movement sink |
| `Server.lua` | Each player's lock ids, telling their client |
| `Settings.lua` | The sink action name, the default lock id, server enforcement |
| `_meta/_types.lua` | `InputBlock_EnforcedHumanoid` (a humanoid held at zero and its saved values) |

## API

### Client: `I.InputBlock`

| Function | Returns | What it does |
| --- | --- | --- |
| `Block(lockId: string, duration: number?)` | | Holds the lock; with `duration`, releases it after that many seconds unless it is blocked again or released first |
| `Unblock(lockId)` | | Releases it; movement returns when no lock is left |
| `IsBlocked()` | `boolean` | Whether any lock is held |

### Server: `I.InputBlock`

`lockId` defaults to `DEFAULT_LOCK_ID`.

| Function | Returns | What it does |
| --- | --- | --- |
| `Block(player, lockId: string?, duration: number?)` | | Adds the lock and blocks the player's client; with `duration`, releases it after that many seconds unless it is blocked again or released first |
| `Unblock(player, lockId?)` | | Removes it and tells the client |
| `Clear(player)` | | Removes every lock of the player |
| `IsBlocked(player, lockId?)` | `boolean` | Any lock, or that lock |

## Usage

```lua
I.InputBlock.Block(player, "Dialog")
I.InputBlock.Unblock(player, "Dialog")
```

## Network

### Server

**Send: RemoteEvents**

- `InputBlock_SetLock @ (player: Player, lockId: string, isBlocked: boolean)`

### Client

**Receive: RemoteEvents**

- `InputBlock_SetLock @ (lockId: string, isBlocked: boolean)`

## Settings

| Key | Default | What |
| --- | --- | --- |
| `ACTION_NAME` | `"InputBlock_Sink"` | ContextActionService action that sinks movement |
| `DEFAULT_LOCK_ID` | `"Default"` | Lock id when none is given |
| `SERVER_ENFORCED` | `false` | While a player holds any server lock, zero their character's `WalkSpeed`, `JumpPower` and `JumpHeight` on the server (values other code writes meanwhile are kept for the restore); restored when the last lock is released, applied again to a respawned character while locks remain |
