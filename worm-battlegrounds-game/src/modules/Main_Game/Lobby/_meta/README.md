# Lobby

The lobby screen and where a player goes when they arrive. On join the server: sends everyone in an expired match
server (a reserved server that booted the Lobby map) to a public lobby; sends a player who hasn't played the tutorial
match there (in Studio, which can't teleport, it marks the match played instead); and offers a player who dropped out
of a running match to go back. The client turns the lobby's panels on.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Lobby` |
| Runs on | Server, Client · Lobby map |
| Uses | `I.Player`, `I.Tutorial`, `I.MatchBoard`, `I.TeleportExternal`, `I.TeleportToServer`, `I.WidgetManager`, `I.UserInterface` |
| Saves | `Profile.Match` (read and cleared here, written by the Match server) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Routing on join, the rejoin offer |
| `Client.lua` | Turns on `LOBBY_GUIS`, asks "Rejoin your match?" |
| `Settings.lua` | `Lobby_Settings` |

## Network

### Server

**Receive: RemoteEvents**

- `Lobby_Rejoin @ (player: Player, accept: boolean)`: the answer to the offer. Rate limit 1 per second.

**Send: RemoteEvents**

- `Lobby_RejoinOffer @ (secondsLeft: number)`: when the player's saved match is still running

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Match.Rejoin` | `false`, or `{ PlaceId, AccessCode, Until }` from the match the player dropped out of; cleared on join |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `LOBBY_GUIS` | Lobby, MatchBoard, Party, Loadout, Crates, Currency | The guis the client turns on |
| `TELEPORT_GUI` | `"TeleportGui"` | The teleport screen |
| `TUTORIAL_MAP`, `TUTORIAL_DIFFICULTY` | `"PicnicPlains"`, `"Tutorial"` | The tutorial match |
