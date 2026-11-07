# Transition

The teleport card between the lobby and a match. Before a teleport the server says where it goes
(`SetDestination`), ume's teleport clones the `TeleportGui` card into each player's PlayerGui, and this module writes
the destination on it ("Heading to Desert…"), slides it down over the screen and hands Roblox a copy to show through
the teleport. On the next server the arrival script (`src/replicated_first/Transition.client.lua`, in
ReplicatedFirst) puts that copy up at once, removes the place's own loading screen for that join, waits until the
player's avatar and ume's client have started, then slides the card off downwards. Joins from the website keep the
place's loading screen.

A teleport Roblox accepted can still fail on the way (`TeleportInitFailed`). The server then tries it again
(`TELEPORT_RETRIES`, for `Failure` and `Flooded`), and if it still fails it removes the card from the player's screen
and tells them (`TELEPORT_FAILED_MESSAGE`), so nobody is left on a card that never goes away.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Transition` |
| Runs on | Server, Client (both maps) |
| Uses | `I.Network`, `I.Notify`, `TeleportService` (`SetTeleportGui`, `GetArrivingTeleportGui`, `TeleportInitFailed`) |

## API

| Function | Side | What |
| --- | --- | --- |
| `I.Transition.SetDestination(players, text, image)` | Server | Tells players where their next teleport goes, for the card: its line (`S_Text`) and picture (`S_Image`, hidden when `""`). Call it right before the teleport |

Callers: MatchBoard's `Launch` ("Heading to <map>…", the map's `Thumbnail`), Match's `Connection.SendToLobby`
("Back to the lobby…"), Lobby's rejoin ("Back to your match…").

## Network

### Server

**Send: RemoteEvents**

- `Transition_Destination @ (text: string, image: string)`: before a teleport, to each player it moves

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | `SetDestination` and its remote; retrying a failed teleport, or taking its card down |
| `Client.lua` | Filling the card, its slide in, the copy handed to Roblox |
| `Settings.lua` | The card's name and its slide, the teleport retries |
| `src/replicated_first/Transition.client.lua` | Outside the module: the card on arrival, and its slide off |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `GUI_NAME` | `"TeleportGui"` | The card the teleports clone |
| `WIPE_TWEENINFO` | 0.4 s, Quad Out | The slide in, shorter than the gui's `GuiAnimDuration` (0.45 s) |
| `TELEPORT_RETRIES` | `2` | How many times a teleport that failed on the way is tried again |
| `TELEPORT_RETRY_DELAY` | `2` | Seconds between those tries |
| `TELEPORT_RETRY_RESULTS` | `Failure`, `Flooded` | The failures worth trying again; any other drops the card at once |
| `TELEPORT_FAILED_MESSAGE` | `"Couldn't get you there. Try again!"` | What the player is told when it failed for good |
