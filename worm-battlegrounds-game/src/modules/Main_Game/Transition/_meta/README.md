# Transition

The teleport card between the lobby and a match. Before a teleport the server says where it goes
(`SetDestination`), ume's teleport clones the `TeleportGui` card into each player's PlayerGui, and this module writes
the destination on it ("Heading to Desert…"), slides it down over the screen and hands Roblox a copy to show through
the teleport. On the next server the arrival script (`src/replicated_first/Transition.client.lua`, in
ReplicatedFirst) puts that copy up at once, removes the place's own loading screen for that join, waits until the
player's avatar and ume's client have started, then slides the card off downwards. Joins from the website keep the
place's loading screen.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Transition` |
| Runs on | Server, Client (both maps) |
| Uses | `I.Network`, `TeleportService` (`SetTeleportGui`, `GetArrivingTeleportGui`) |

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
| `Server.lua` | `SetDestination` and its remote |
| `Client.lua` | Filling the card, its slide in, the copy handed to Roblox |
| `Settings.lua` | The card's name and its slide |
| `src/replicated_first/Transition.client.lua` | Outside the module: the card on arrival, and its slide off |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `GUI_NAME` | `"TeleportGui"` | The card the teleports clone |
| `WIPE_TWEENINFO` | 0.4 s, Quad Out | The slide in, shorter than the gui's `GuiAnimDuration` (0.45 s) |
