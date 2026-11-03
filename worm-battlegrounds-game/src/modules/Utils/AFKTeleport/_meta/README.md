# AFKTeleport

Moves idle players to the lobby so a server can close. The client counts the seconds since the player's last input of any kind (`InputBegan`, `InputChanged`, `InputEnded`: keys, clicks, mouse-look, thumbsticks, touch). For the last `WARNING_TIME` seconds before `TELEPORT_REQUEST_TIME` it shows a countdown in the `AFKTeleport` gui, which any input hides along with resetting the count. When the countdown runs out the client asks the server to teleport it; the server saves where the player was (per place and map, through the hooks in `Data/S_TeleportData.lua`) and sends them to the default lobby. When they come back to that place, their character is put back where they left. A teleport that fails clears that saved spot again. Nothing runs in Studio or in the lobby.

| | |
| --- | --- |
| Folder | `src/modules/Utils/AFKTeleport` |
| Runs on | Client, Server |
| Exposes | `I.AFKTeleport` (server) |
| Uses | `I.TeleportToDefaultLobby`, `I.Player`, `I.G_Player`, `I.Debounce`, `I.Network`, `I.DoEvery`, `I.UserInterface`, `I.Config` |
| Saves | `Profile.AFKTeleport.PlaceData` |

## Files

| File | What it controls |
| --- | --- |
| `Client.lua` | The idle timer, the warning countdown and the teleport request |
| `Server.lua` | Saving the player's state, teleporting, clearing it when the teleport fails, restoring it on the next spawn |
| `Data/S_TeleportData.lua` | Per place-and-map `Update(player)` (save) and `Resolve(player, character)` (restore) hooks; the default saves and restores the position |
| `Settings.lua` | Idle time, timer and retry intervals, warning length |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `afk_teleport` command |

## API

### Server: `I.AFKTeleport`

| Function | Returns | What it does |
| --- | --- | --- |
| `Teleport(player)` | `boolean` | Saves the player's state for this place and map and teleports them to the default lobby (at most once every 5 s; never in Studio or the lobby). On a failed teleport it clears the saved state and returns `false` |

## Network

### Server

**Receive: RemoteEvents**

- `AFKController_RequestTeleport @ (player: Player)`: the client has been idle long enough.

### Client

**Send: RemoteEvents**

- `AFKController_RequestTeleport @ ()`

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `AFKTeleport.PlaceData["<PlaceId>-<MapId>"]` | What `Update` saved (by default `Location`); cleared on the next spawn, or when the teleport fails |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `TELEPORT_REQUEST_TIME` | `960` | Seconds without input before the request |
| `TIMER_INTERVAL` | `1` | Seconds between idle-timer updates, and the countdown's step |
| `TELEPORT_RETRY_TIME` | `30` | Seconds before a failed request is retried |
| `WARNING_TIME` | `30` | Seconds before the request that the warning counts down |

## In the place

| Instance | Where | What |
| --- | --- | --- |
| `AFKTeleport` (ScreenGui) | StarterGui, moved into `PlayerGui` by `I.UserInterface` | The warning: ume-gui's System gui `System/AFKTeleport`, exported with the Ume plugin's Gui tool. The client enables it for the countdown, writes the seconds left into `U_Warning` › `S_Time`, and disables it on input. Required: the client errors at start without it |

## Commands

`afk_teleport` (server): `trigger`.
