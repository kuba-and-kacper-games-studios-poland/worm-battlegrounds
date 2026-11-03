# SoftShutdown

Keeps players when a server shuts down (an update, a restart). On close, every player still in the server, and anyone who arrives while it closes, is teleported to the default lobby with a shutdown screen instead of being disconnected.

| | |
| --- | --- |
| Folder | `src/modules/Utils/SoftShutdown` |
| Runs on | Server |
| Uses | `game:BindToClose`, `I.TeleportToDefaultLobby`, `TeleportService.TeleportInitFailed` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The close handler and the teleports |

## How players get back

1. On close, players are teleported in batches of up to 50 with `I.TeleportToDefaultLobby`. Each batch gets a new reserved server of the default place's lobby map, which runs the newest version of the game.
2. A batch whose teleport fails is retried every 2 seconds, and a player whose teleport fails after it started (`TeleportInitFailed`) is retried alone, until the close budget (29 seconds, shared with other `BindToClose` handlers) runs out.
3. When the lobby isn't persistent, that reserved server is a temporary lobby: the place loader sends everyone straight back to a public server of the lobby map's `ReturnPlaceId` (`TeleportPlayersToMainServer`), so players end up in an updated server of the original place. With a persistent lobby they stay in the lobby.

Players from a player-owned private (VIP) server come back to a public server: Roblox doesn't let a game teleport players into a private server it didn't reserve.
