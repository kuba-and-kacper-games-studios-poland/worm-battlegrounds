# Lobby

The lobby screen and where a player goes when they arrive. On join the server: sends everyone in an expired match
server (a reserved server that booted the Lobby map) to a public lobby; sends a player who hasn't played the tutorial
match there (in Studio, where nothing saves, it marks the match played instead, unless the Workspace attribute
`StudioTutorial` is true; the Lobby map alone can't start one either); and offers
a player who dropped out of a running match to go back. Behind the lobby's panels a slow bot match plays: the server copies
`BACKDROP_MAP` (Picnic Plains) to `BACKDROP_ORIGIN`, and each client plays `BACKDROP_SNAILS` bots on it (the first in
the player's equipped skin), turn after turn: each thinks, walks toward a rival or now and then hops over with the
jetpack, turns its weapon to the shot, and fires the Bazooka or the Grenade (`BACKDROP_WEAPONS`) on an arc that no
ledge overhead or hill in the way catches, under the backdrop's own gentle gravity; the blast deals the weapon's
Arsenal damage and throws snails with a share of its knockback, a snail at 0 health or in the liquid floats off as a
ghost, and a round with one snail left starts again. The camera follows the snail playing and the shot, and the match is blurred. The client shows the lobby's
panels, plays and watches the match except while the player is in a match (the `InMatch` Player attribute, which only
changes on the Studio map). shortcut: blasts make no craters and the liquid is still, because the Arena module doesn't
run in the lobby; they need its carving and liquid code shared to the client to look like a real match.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Lobby` |
| Runs on | Server, Client · Lobby map, Studio map |
| Uses | `I.Player`, `I.Tutorial`, `I.MatchBoard`, `I.TeleportExternal`, `I.TeleportToServer`, `I.WidgetManager`, `I.UserInterface`, `I.Replicator`, `I.G_Cosmetics`, `I.G_Arsenal`, `I.Buff` (the `FOV` buff), `I.Lighting` (the blur) |
| Saves | `Profile.Match` (read and cleared here, written by the Match server) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Routing on join, the rejoin offer, `Workspace.Ume.Lobby` (the backdrop's folder) |
| `Client.lua` | Shows `LOBBY_GUIS` outside matches and closes a lobby window still open when a match starts (the Studio map's custom lobby), asks "Rejoin your match?" |
| `Scripts/Server/Backdrop.lua` | Copies the backdrop's map: `BACKDROP_MAP`'s Terrain and Decor, its liquid markers filled, its Bounds |
| `Scripts/Client/Backdrop.lua` | The bot match: snails, turns, walks and jetpack hops, aimed shots, blasts, knockback and ghosts; the camera and the blur outside matches; the first snail's skin follows the equipped one |
| `Settings.lua` | `Lobby_Settings` |
| `_meta/_types.lua` | `Lobby_BackdropSnail` |

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
| `BACKDROP_MAP`, `BACKDROP_NAME`, `BACKDROP_ORIGIN` | `"PicnicPlains"`, `"Backdrop"`, `(0, 400, -1500)` | The arena the bots play on, its Model in `Workspace.Ume.Lobby`, and where its centre sits |
| `BACKDROP_LIQUID_COLORS`, `BACKDROP_LIQUID_TRANSPARENCY` | Water blue `0.2`, Lava orange `0` | The still liquid filling the map's liquid markers |
| `BACKDROP_DISTANCE`, `BACKDROP_FOV`, `BACKDROP_FOLLOW_SPEED` | `90`, `30`, `1.5` | The camera: studs from the plane, field of view (the `FOV` buff's base), how fast it catches up |
| `BACKDROP_BLUR`, `BACKDROP_BLUR_WEIGHT`, `BACKDROP_BLUR_TWEENINFO` | `30`, `1000`, 0.4 s | The blur over the match, as a Lighting layer over an open window's (WidgetManager's 14 at 999), so a window never sharpens it |
| `BACKDROP_SNAILS`, `BACKDROP_SPACING` | `4`, `18` | How many bots play, and the least room between their start spots |
| `BACKDROP_SNAIL_RADIUS`, `BACKDROP_HEALTH` | `1.3`, `200` | A snail's ball radius and health, as in a match (Snails' `ROOT_SIZE` / 2, `MAX_HEALTH`) |
| `BACKDROP_WEAPONS` | Bazooka (flies as the HomingMissile), Grenade | The weapons bots fire, and what each shot flies as |
| `BACKDROP_THINK`, `BACKDROP_WALK`, `BACKDROP_WALK_SPEED`, `BACKDROP_AIM`, `BACKDROP_REST` | `{ 2, 3.5 }` s, `{ 0, 8 }` studs, `5`, `1.6` s, `1.5` s | A turn's thinking, walk, aim, and the rest after everything landed |
| `BACKDROP_JETPACK_CHANCE`, `BACKDROP_JETPACK_HEIGHT`, `BACKDROP_JETPACK_TIME`, `BACKDROP_JETPACK_REACH` | `0.35`, `4`, `2.2` s, `{ 8, 16 }` studs | How often a bot hops with the jetpack instead of walking, how high (and how far up or down it may land), how long and how far |
| `BACKDROP_JETPACK_UP`, `BACKDROP_JETPACK_BEHIND` | `0.4`, `2.4` | Where the jetpack sits on the shell, as Snails' `GEAR` |
| `BACKDROP_GRAVITY` | `50` | The fall of shots and thrown snails, gentler than a match's, for slow arcs |
| `BACKDROP_FLIGHT`, `BACKDROP_MISS`, `BACKDROP_AIM_TRIES` | `{ 1.4, 3.2 }` s, `7`, `16` | A shot's flight time, how far off its rival it may land, and how many arcs a bot tries for a clear one |
| `BACKDROP_KNOCKBACK_SCALE` | `0.4` | A blast's Arsenal knockback, scaled for the backdrop |
| `BACKDROP_HELD_FORWARD`, `BACKDROP_HELD_HEIGHT`, `BACKDROP_HELD_DEPTH` | `0.8`, `-0.3`, `1.5` | Where the held weapon sits, as Combat's `HELD_*` |
| `TELEPORT_GUI` | `"TeleportGui"` | The teleport screen |
| `TUTORIAL_MAP`, `TUTORIAL_DIFFICULTY` | `"PicnicPlains"`, `"Tutorial"` | The tutorial match |
| `STUDIO_TUTORIAL_ATTRIBUTE` | `"StudioTutorial"` | The Workspace attribute that plays the tutorial match in Studio (set it to true) |

## In the place

| Instance | What |
| --- | --- |
| `Workspace.Ume.Lobby.Backdrop` | Made by the server at start: a `Persistent` Model holding the arena's `Terrain` (the only parts the clients' raycasts hit) and `Decor`, a `Water` or `Lava` part per liquid marker, and an invisible `Bounds`, all anchored and never colliding. The clients' snails, held weapons, shots and blasts go in it too, on their own screen only |

The arenas come from `SAssets.Arenas` (authored in `Workspace.Ume.ServerStorage_Assets/Arenas`), which the lobby
place has too. The old 3D stage, the Model `LobbyStage` in `ServerStorage.Ume.PlaceLoader_Workspace/Lobby`, is no
longer used; it can be removed from the place.
