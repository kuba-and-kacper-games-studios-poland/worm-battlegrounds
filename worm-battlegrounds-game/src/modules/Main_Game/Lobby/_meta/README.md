# Lobby

The lobby screen and where a player goes when they arrive. On join the server: sends everyone in an expired match
server (a reserved server that booted the Lobby map) to a public lobby; sends a player who hasn't played the tutorial
match there (in Studio, where nothing saves, it marks the match played instead, unless the Workspace attribute
`StudioTutorial` is true; the Lobby map alone can't start one either); and offers
a player who dropped out of a running match to go back. Behind the lobby's panels the camera looks at a stage, as
Fortnite's lobby does: the player's snail stands on the front pod in their equipped skin, and the rest of their party
in this server stand on the pods around it, each in their own skin (the `EquippedSkin` Player attribute Cosmetics
writes), by user id; empty pods stay bare. Each client builds its own snails, so everyone sees themselves in front.
The client shows the lobby's panels and holds the camera on the stage except while the player is in a match (the
`InMatch` Player attribute, which only changes on the Studio map), and hides the panels while a full-screen widget
(`FULL_SCREEN_WIDGETS`: Skins, Crates) is open, from WidgetManager's `WidgetManager_Opened` and `WidgetManager_Closed`
Topics.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Lobby` |
| Runs on | Server, Client · Lobby map, Studio map |
| Uses | `I.Player`, `I.Tutorial`, `I.MatchBoard`, `I.TeleportExternal`, `I.TeleportToServer`, `I.WidgetManager`, `I.UserInterface`, `I.G_Cosmetics`, `I.SnailRig`, `I.Buff` (the `FOV` buff), the `PartyId` and `EquippedSkin` Player attributes (Party, Cosmetics) |
| Saves | `Profile.Match` (read and cleared here, written by the Match server) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Routing on join, the rejoin offer, `Workspace.Ume.Lobby` (where clients stand the party's snails) |
| `Client.lua` | Shows `LOBBY_GUIS` outside matches and while no full-screen widget is open, closes a lobby window still open when a match starts (the Studio map's custom lobby), asks "Rejoin your match?" |
| `Scripts/Client/Stage.lua` | The stage: the camera on its marker outside matches, and the party's snails on its pods (idle, animated by `I.SnailRig`), rebuilt when someone joins or leaves the party or changes skin |
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
| `FULL_SCREEN_WIDGETS` | Skins, Crates | The widgets that cover the whole screen: `LOBBY_GUIS` hide while one is open |
| `STAGE_PREFAB`, `PODS_FOLDER`, `POD_PREFIX`, `CAMERA_MARKER`, `SNAIL_MARKER` | `"PREFAB \| Stage"`, `"Pods"`, `"Pod_"`, `"Camera"`, `"Snail"` | The stage's prefab in Lobby's assets, its pods (`Pod_1` the player's), and the markers the camera and each snail stand on |
| `STAGE_FOV` | `50` | The stage camera's field of view (the `FOV` buff's base) |
| `TELEPORT_GUI` | `"TeleportGui"` | The teleport screen |
| `TUTORIAL_MAP`, `TUTORIAL_DIFFICULTY` | `"PicnicPlains"`, `"Tutorial"` | The tutorial match |
| `STUDIO_TUTORIAL_ATTRIBUTE` | `"StudioTutorial"` | The Workspace attribute that plays the tutorial match in Studio (set it to true) |

## In the place

| Instance | What |
| --- | --- |
| `Workspace.Ume.ReplicatedStorage_Assets.Lobby["PREFAB \| Stage"]` | The stage, edited by hand where it stands (beyond the baseplate's +Z edge, grass top at Y 0, the camera at (0, 7, 1180)); at runtime it's in `I.Dirs.Assets.Lobby`, and each client clones it into `Workspace.Ume.Lobby` as `Stage`: `Ground`, `Hills`, `Clouds`, `Decor`, `Markers.Camera` (the camera's spot, looking along its front), and `Pods` › `Pod_1` to `Pod_4` (front, right, back on a pedestal, left: the left one fills last, since the solo or party setup and the waiting room hang over it; each a `Podium`, `PodiumRim`, a `Pedestal` on the raised ones, and an invisible `Snail` marker the snail's pivot goes to, facing the camera). Move the pods or the camera in Studio to change the layout; more pods stand more of a party (`MAX_PARTY` is 4) |
| `Workspace.Ume.Lobby` | Made by the server at start; each client parents its party's snails here, on its own screen only |
