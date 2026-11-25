# Transition

The teleport card between the lobby and a match: the destination map's own scene, full screen. Before a teleport the
server says where it goes (`SetDestination`), ume's teleport clones the `TeleportGui` card into each player's
PlayerGui, and this module builds the map's scene on it from the map's Atmosphere row (its sky and Parallax layers),
writes the destination on its plate, plays the intro (the scene whips in from the side, the plate rises) with a whoosh
(`Teleport_Out`), and hands Roblox a settled copy to show through the teleport, a fresh one every `HANDOVER_SECONDS`.
On the next server the arrival script (`src/replicated_first/Transition.client.lua`) puts that copy up at once,
removes the place's own loading screen for that join, keeps the scene moving, fills the bar once the player's avatar
and ume's client have started, then flies the camera through the layers into the real map; the module plays
`Teleport_In` as its client starts on a join that came by teleport. Joins from the website keep the place's loading
screen.

The scene is drawn by `src/replicated_first/TransitionMotion.lua`, shared by both sides (ReplicatedFirst runs before
the framework, so it holds its own numbers): each layer is placed every frame through the match camera's field of
view and distance, so the far range, clouds and near hills slide at their true depth speeds as the camera sways;
tiles repeat end to end, clouds drift and wrap, and the map's weather (sand, snow, pollen, motes) floats at its own
depths. The card's clock, progress and scene ride in its attributes, so a copy carries on where the original was.

A public Join puts the card up at once (`Show` with a `Pool`): the scene whips through the rotation's maps every
`SEARCH_WHIP_SECONDS` until the match is found, then whips to its map and punches its name in. The teleport's own card
takes over the scene, clock and progress of the one already up, with no second intro.

A teleport Roblox accepted can still fail on the way (`TeleportInitFailed`). The server then tries it again
(`TELEPORT_RETRIES`, for `Failure` and `Flooded`), and if it still fails it removes the card from the player's screen
and tells them (`TELEPORT_FAILED_MESSAGE`), so nobody is left on a card that never goes away.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Transition` |
| Runs on | Server, Client (both maps) |
| Uses | `I.Network`, `I.Notify`, `I.Sound`, Atmosphere's `PROFILES` (`Sky`, `Parallax`), `TeleportService` (`SetTeleportGui`, `GetArrivingTeleportGui`, `TeleportInitFailed`) |

## API

| Function | Side | What |
| --- | --- | --- |
| `I.Transition.SetDestination(players, destination)` | Server | Tells players where their next teleport goes, for the card (`Transition_Destination`, below). Call it right before the teleport |
| `I.Transition.Show(players, destination)` | Server | Puts the card up at once, for a teleport that takes a while to set up; the teleport's own card takes its place without a second intro |
| `I.Transition.Hide(players)` | Server | Takes the card off players' screens when the teleport it showed for isn't coming |

A `Transition_Destination` (`_meta/_types.lua`):

| Field | What |
| --- | --- |
| `Kicker` | The small line over the title, in the accent colour ("Heading to", "Back to", "Public match") |
| `Title` | The big title: the map's name, "Finding a match", "The lobby" |
| `MapId` | The map whose scene shows; without it, the lobby's (or the pool's while searching) |
| `Mode`, `ModeIcon`, `Detail` | The line on the band: the mode's glyph, "Deathmatch · 6 snails" |
| `Pool` | Maps to whip through while searching (with no `MapId`) |

Callers: MatchBoard's `Launch.Send` (`Launch.GetDestination`: "Heading to" the map, its mode and size) and its public
Join (`Show` with the rotation's pool the moment Join is pressed, "Match found" with the map once seated in a match
another lobby opened, `Hide` when it fails), Match's `Connection.SendToLobby` ("Back to" "The lobby"), Lobby's rejoin
("Back to" "Your match").

## Network

### Server

**Send: RemoteEvents**

- `Transition_Destination @ (destination: Transition_Destination)`: before a teleport, to each player it moves

## Attributes

On the card (the `TeleportGui` ScreenGui), written by this module and `TransitionMotion`:

| Attribute | What |
| --- | --- |
| `Transition_Scene` | The scene up now (a MapId, or `Lobby`); a change whips to it |
| `Transition_Searching` | True while a Join finds its match: the title's dots pulse |
| `Transition_Clock` | Seconds the scene has run: the camera's sway and the clouds' drift |
| `Transition_Progress` | The bar, 0 to 1 |
| `Transition_Ready` | Set by the arrival script: the bar fills |
| `Transition_Tip` | The tip shown, an index into `TIPS` |

Each layer carries its row as attributes (`L_Kind`, `L_X`, `L_Bottom`, `L_Width`, `L_Height`, `L_Depth`, `L_Span`,
`L_Horizon`, `L_Alpha`), each weather square its motion (`M_*`), so the motion needs no map data.

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | `SetDestination`, `Show`, `Hide` and the remote; retrying a failed teleport, or taking its card down |
| `Client.lua` | Building each scene from Atmosphere, filling the plate, the intro and its sound, search whips, tips, the copies handed to Roblox, `Teleport_In` on arrival |
| `Settings.lua` | The card, the maps' looks and weather, timings, tips, the teleport retries |
| `src/replicated_first/TransitionMotion.lua` | Outside the module: the scene's motion every frame, the intro, the reveal, the settled copies |
| `src/replicated_first/Transition.client.lua` | Outside the module: the card on arrival, its reveal |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `GUI_NAME` | `"TeleportGui"` | The card the teleports clone |
| `DEFAULT_DESTINATION` | "Loading", "Snail Battlegrounds" | What the card says when no destination came with it |
| `TITLE_PUNCH`, `TITLE_PUNCH_TWEENINFO` | `1.22`, 0.34 s Back Out | The found map's name punching in |
| `LOOKS` | Desert, Echo Caverns, Rolling Plains | Per map: where the horizon sits on its sky picture, its accent colour, its weather |
| `DEFAULT_LOOK` | yellow, motes | A map with no `LOOKS` row |
| `LOBBY_LOOK`, `LOBBY_SCENE` | Picnic Plains' gradient sky, yellow, motes; `"Lobby"` | The lobby's scene: that sky under Atmosphere's `Lobby` Parallax rows (snowy peaks, clouds, a meadow), which only the card draws |
| `CLOUD_MIN_BOTTOM` | `40` | A Parallax image row this high is a cloud (drifts, wraps) |
| `WEATHER` | Sand, Snow, Pollen, Motes | Each weather's squares: count, colours, sizes, depths, speeds, wobble, spin |
| `SEARCH_WHIP_SECONDS` | `1.6` | How often the search whips to the next map |
| `HANDOVER_SECONDS` | `0.5` | How often Roblox gets a fresh copy to hold through the teleport |
| `TIP_SECONDS`, `TIPS` | `5`, five tips | The tips, one at a time |
| `TELEPORT_RETRIES` | `2` | How many times a teleport that failed on the way is tried again |
| `TELEPORT_RETRY_DELAY` | `2` | Seconds between those tries |
| `TELEPORT_RETRY_RESULTS` | `Failure`, `Flooded` | The failures worth trying again; any other drops the card at once |
| `TELEPORT_FAILED_MESSAGE` | `"Couldn't get you there. Try again!"` | What the player is told when it failed for good |

The motion's numbers (the match camera's 30° and 110 studs, the sway, whips, intro, reveal, bar) are constants at the
top of `TransitionMotion.lua`, since ReplicatedFirst can't read the module's settings on arrival.
