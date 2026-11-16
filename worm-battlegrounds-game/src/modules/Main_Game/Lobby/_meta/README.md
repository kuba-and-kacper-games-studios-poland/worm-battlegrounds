# Lobby

The lobby screen and where a player goes when they arrive. On join the server: sends everyone in an expired match
server (a reserved server that booted the Lobby map) to a public lobby; sends a player who hasn't played the tutorial
match there (in Studio, where nothing saves, it marks the whole tutorial done instead, `I.Tutorial.Skip`, unless the
Workspace attribute `StudioTutorial` is true; with it true, the Lobby map alone, which can't start the match, marks
only the match played, so the crate and loadout steps still play); and offers
a player who dropped out of a running match to go back. Behind the lobby's panels the camera looks at a stage, as
Fortnite's lobby does: the player's snail stands on the front pod in the pieces they wear, and the rest of their party
in this server stand on the pods around it, each in their own (the `Outfit` Player attribute Cosmetics
writes), by user id; empty pods stay bare. In a custom lobby (`I.MatchBoard.GetCustomRoom`) its members stand instead on the
eight pods of `PREFAB | CustomPods`, in the lobby's order, and the camera backs off just enough to fit them all (the
owner, 2026-11-16). Every snail on the stage holds the Bazooka (`STAGE_WEAPON`) and strikes one of `STAGE_POSES` at
random, never the one it had, picked again when the members change or the player comes back from a match. Each client builds its own snails, so everyone sees themselves in front.
The client shows the lobby's panels and holds the camera on the stage except while the player is in a match (the
`InMatch` Player attribute, which only changes on the Studio map), and hides the panels while a full-screen widget
(`FULL_SCREEN_WIDGETS`: Skins, Crates) is open, or the one panel a widget stands in for (`PANEL_WIDGETS`: the emote
shop over Loadout), from WidgetManager's `WidgetManager_Opened` and `WidgetManager_Closed` Topics.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Lobby` |
| Runs on | Server, Client · Lobby map, Studio map |
| Exposes | `I.Lobby` (client) |
| Uses | `I.Player`, `I.Tutorial`, `I.MatchBoard`, `I.TeleportExternal`, `I.TeleportToServer`, `I.WidgetManager`, `I.UserInterface`, `I.G_Cosmetics`, `I.SnailRig`, `I.G_Arsenal` (the stage's weapon), `I.Buff` (the `FOV` buff), the `PartyId` and `Outfit` Player attributes (Party, Cosmetics), MatchBoard's `MatchBoard_RoomChanged` Topic |
| Saves | `Profile.Match` (read and cleared here, written by the Match server) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Routing on join, the rejoin offer, `Workspace.Ume.Lobby` (where clients stand the party's snails) |
| `Client.lua` | Shows `LOBBY_GUIS` outside matches and while no full-screen widget is open, closes a lobby window still open when a match starts (the Studio map's custom lobby), asks "Rejoin your match?" |
| `Scripts/Client/Stage.lua` | The stage: the camera on its marker outside matches (eased there, `STAGE_CAMERA_EASE`; in a custom lobby backed off along its look to fit every snail, `STAGE_FIT_MARGIN`), and the party's snails on its pods, or a custom lobby's on the `CustomPods` swapped in for them, each holding `STAGE_WEAPON` (`I.SnailRig.Hold`) in a random one of `STAGE_POSES` (looped from a random point, over the idle), rebuilt when someone joins or leaves the party or the custom lobby (`MatchBoard_RoomChanged`) or changes skin, and posed again when the members change or the player is back from a match (`InMatch`); `GetSnail` (`I.Lobby.GetStageSnail`), which ChatBubbles stands a member's chat bubbles over |
| `Settings.lua` | `Lobby_Settings` |

## API

### Client: `I.Lobby`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetStageSnail(player: Player)` | `Model?` | The snail the player stands as on this screen's stage (its `PrimaryPart` is the skin's RootPart), or nil when they stand on none |

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
| `FULL_SCREEN_WIDGETS` | Skins, Crates, Shop | The widgets that cover the whole screen: `LOBBY_GUIS` hide while one is open |
| `PANEL_WIDGETS` | EmoteShop: Loadout | The widgets that stand in one lobby panel's place, by widget: those panels hide while one is open |
| `STAGE_PREFAB`, `PODS_FOLDER`, `POD_PREFIX`, `CAMERA_MARKER`, `SNAIL_MARKER` | `"PREFAB \| Stage"`, `"Pods"`, `"Pod_"`, `"Camera"`, `"Snail"` | The stage's prefab in Lobby's assets, its pods (`Pod_1` the player's), and the markers the camera and each snail stand on |
| `STAGE_FOV` | `50` | The stage camera's field of view (the `FOV` buff's base) |
| `STAGE_SNAIL_SCALE` | `1.5` | How much bigger the stage's snails are than in a match (`Model:ScaleTo` on the built snail); each is lifted by what grew under its pivot, so its feet stay on its pod |
| `CUSTOM_PODS_PREFAB` | `"PREFAB \| CustomPods"` | The custom lobby's eight pods in Lobby's assets, stood in the stage on its pivot while the player is in a custom lobby |
| `STAGE_FIT_MARGIN`, `STAGE_CAMERA_EASE` | `0.82`, `0.08` | In a custom lobby the camera backs off (and rises with its look) just as far as every snail needs to fit this share of the screen; it eases there by the second's share of the way each 1/60 s |
| `STAGE_WEAPON` | `"Bazooka"` | What every snail on the stage holds (its Arsenal model, scaled with the snail) |
| `STAGE_WEAPON_SCALE` | `0.72` | The stage weapon's size against its match model, as the studio's posed snail holds it (matches draw it bigger to read) |
| `STAGE_POSES` | `LobbyPose1` to `LobbyPose4` | The poses stage snails strike (Animations in `Assets/Snails/Animations`, the studio's bazooka poses; the owner, 2026-11-16: "make it feel organic and natural"). A pose with no `AnimationId` yet is skipped: until the owner uploads them, the snails idle |
| `TELEPORT_GUI` | `"TeleportGui"` | The teleport screen |
| `TUTORIAL_MAP`, `TUTORIAL_DIFFICULTY` | `"TutorialMeadow"`, `"Tutorial"` | The tutorial match: Training Meadow, against the tutorial bot |
| `STUDIO_TUTORIAL_ATTRIBUTE` | `"StudioTutorial"` | The Workspace attribute that plays the tutorial in Studio (set it to true); without it Studio skips all of it |

## In the place

| Instance | What |
| --- | --- |
| `Workspace.Ume.ReplicatedStorage_Assets.Lobby["PREFAB \| Stage"]` | The stage: since 2026-11-15 the owner's `NewSpawn` (the studio's meadow, `Spawn_New`: `GeneratedMeadow` with its terrain, cliffs, trees, central area, decorations, sky and waterfall, and the `Waterfall` beams, with four new platforms), moved so its meadow stands exactly where the 2026-11-12 stage's did (beyond the baseplate's +Z edge, the front snail at (0, 2.5, 1200.9), the camera at (0, 7, 1180)); the old stage and the `NewSpawn` it was made from are in `ServerStorage.!dump`. At runtime it's in `I.Dirs.Assets.Lobby`, and each client clones it into `Workspace.Ume.Lobby` as `Stage`: `Markers.Camera` (the camera's spot, looking along its front, set from the front snail as the old one was), and `Pods` › `Pod_1` to `Pod_4`, the four round platforms, laid out symmetrically about the camera's line (x 0: the front one and the raised back one; the side ones mirrored at x ±11.9, with the meadow's two hedges moved to stand clear behind them) (front, the one behind on the camera's left, the one behind on its right, then the back one, 7.5 studs higher than the front so its snail shows over the front snail's head (the owner, 2026-11-15: "the 4th player should be in the back, and it should be slightly taller"); the right one sits under the solo or party setup and the waiting room when they're open; each its `Platform_Front` › `Platform_Base` and `Platform_Top`, in the stud material like the whole stage (SmoothPlastic with `2022 Stud`), a glowing `Ring beam`, and an invisible `Snail` marker 1.3 studs over its top that the snail's pivot goes to, facing the camera). Move the pods or the camera in Studio to change the layout; more pods stand more of a party (`MAX_PARTY` is 4) |
| `Workspace.Ume.ReplicatedStorage_Assets.Lobby["PREFAB \| CustomPods"]` | The custom lobby's pods (2026-11-16), authored 300 studs beside the stage: `Pods` › `Pod_1` to `Pod_8` (three in front, two raised behind them, three higher at the back, packed close), each with a `Snail` marker as the stage's pods have. Each client clones it as `CustomPods`, puts its pivot on the stage's and parents it to the stage in place of the stage's own `Pods` while the player is in a custom lobby |
| `Workspace.Ume.Lobby` | Made by the server at start; each client parents its stage's snails here, on its own screen only |
