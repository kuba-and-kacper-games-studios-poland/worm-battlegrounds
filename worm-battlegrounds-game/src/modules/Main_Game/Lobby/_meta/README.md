# Lobby

The lobby screen and where a player goes when they arrive. On join the server: sends everyone in an expired match
server (a reserved server that booted the Lobby map) to a public lobby; sends a player who hasn't played the tutorial
match there (in Studio, where nothing saves, it marks the match played instead, unless the Workspace attribute
`StudioTutorial` is true; the Lobby map alone can't start one either); and offers
a player who dropped out of a running match to go back. The client shows the lobby's panels, except while the player
is in a match (the `InMatch` Player attribute, which only changes on the Studio map), and holds the camera on the
lobby's 3D stage, where the player's worm stands in their equipped skin.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Lobby` |
| Runs on | Server, Client · Lobby map, Studio map |
| Uses | `I.Player`, `I.Tutorial`, `I.MatchBoard`, `I.TeleportExternal`, `I.TeleportToServer`, `I.WidgetManager`, `I.UserInterface`, `I.Replicator`, `I.G_Cosmetics` |
| Saves | `Profile.Match` (read and cleared here, written by the Match server) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Routing on join, the rejoin offer, `Workspace.Ume.Lobby` (where clients put their worm) |
| `Client.lua` | Shows `LOBBY_GUIS` outside matches, asks "Rejoin your match?" |
| `Scripts/Client/Stage.lua` | The 3D stage: the camera on its `Camera` marker outside matches, the player's worm on its `Worm` marker, rebuilt when the equipped skin changes |
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
| `LOBBY_GUIS` | Lobby, MatchBoard, Party, Loadout, Currency | The guis the client shows outside matches |
| `STAGE_NAME`, `CAMERA_MARKER`, `WORM_MARKER` | `"LobbyStage"`, `"Camera"`, `"Worm"` | The stage Model in `Workspace.Ume`, and its markers: where the camera sits (looking along its front), where the worm stands |
| `STAGE_FOV` | `40` | The stage camera's field of view |
| `TELEPORT_GUI` | `"TeleportGui"` | The teleport screen |
| `TUTORIAL_MAP`, `TUTORIAL_DIFFICULTY` | `"PicnicPlains"`, `"Tutorial"` | The tutorial match |
| `STUDIO_TUTORIAL_ATTRIBUTE` | `"StudioTutorial"` | The Workspace attribute that plays the tutorial match in Studio (set it to true) |

## In the place

The stage is place content: the Model `LobbyStage` in `ServerStorage.Ume.PlaceLoader_Workspace/Lobby`, which the
place loader moves into `Workspace.Ume` on the Lobby and Studio maps. It's `Persistent` (streaming keeps it on every
client), anchored and out of the way: 400 studs up and 1200 out along Z, away from the arena and the spawn. It holds
`Ground`, `Hills`, `Clouds`, `Decor` (trees, bushes and rocks copied from Picnic Plains) and `Markers` (`Camera`,
`Worm`: invisible parts). shortcut: a placeholder stage built in stud parts; the owner's lobby scene replaces it,
keeping the two markers.
