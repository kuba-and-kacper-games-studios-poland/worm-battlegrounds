# Match

The match's rules on a match server. It reads the match's metadata (sent by MatchBoard with the teleport; on the
Studio map, handed over through `I.Match.Host`; on the Match map alone in Studio, `STUDIO_METADATA`), waits for the players, seats them and fills the rest with bots, then plays: the drop (each player
clicks or taps anywhere in the arena a worm fits, out of walls and liquid, to place where their worm lands; it
ends as soon as every connected player has placed, or after `DROP_SECONDS`), the landing (a placed worm parachutes
from its spot; bots and players who didn't place start standing on land, from `I.Arena.GetLandSpots`), then turns (`TURN_SECONDS` each, with wind) until one team is left, with
sudden death from `SUDDEN_DEATH_ROUND`. Then it ends the match (MatchRewards pays and shows Results), runs the rematch
vote and sends everyone who didn't vote to the lobby. A player who drops out keeps their seat for `REJOIN_SECONDS`
and can come back from the lobby; a player who leaves is knocked out.

**The Studio map** (`STUDIO_MAP`) runs the lobby and the match on one server, since Studio can't teleport. The match
waits for the lobby to call `Host`, plays with the players it names, then sends them back to the lobby's screens
(the `InMatch` Player attribute) instead of teleporting, clears the worms and waits for the next one. A match every
player left stops at the next turn. One match plays at a time.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Match` |
| Runs on | Server, Client · Match map, Studio map |
| Exposes | `I.Match` (server, client) |
| Uses | `I.Worms`, `I.Combat`, `I.Bots`, `I.Arena`, `I.Loadout`, `I.Cosmetics`, `I.Team`, `I.Player`, `I.Config.Metadata`, `I.TeleportExternal` |
| Saves | `Profile.Match` (writes `Rejoin` when a player drops) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The match folders, remotes, Topics, the `I` table; starts the handlers |
| `Scripts/Server/Phases.lua` | The main loop: waiting, drop, landing, turns, the end, rematches |
| `Scripts/Server/Roster.lua` | Metadata, participants (players and bots), teams, the participant entries |
| `Scripts/Server/Turns.lua` | Turn order, the timer, wind, rounds, sudden death |
| `Scripts/Server/Placement.lua` | Knockout order and the final places |
| `Scripts/Server/Stats.lua` | Damage, knockouts, rounds and best shot per participant |
| `Scripts/Server/Connection.lua` | Leaving, dropping out, rejoining, sending players to the lobby, the `InMatch` attribute |
| `Scripts/Server/Rematch.lua` | The rematch vote |
| `Client.lua` | Match state for other client modules |
| `Scripts/Client/DropPicker.lua` | Picking the drop point: the marker follows the mouse (or the left stick), faded where a worm doesn't fit; a click, a tap or the gamepad's A places it |
| `Settings.lua` | `Match_Settings` |
| `_meta/_types.lua` | `Match_Metadata`, `Match_RosterEntry`, `Match_Participant`, `Match_Placement`, `Match_Stats`, … |

## API

### Server: `I.Match`

| Function | Returns | What it does |
| --- | --- | --- |
| `Play()` | | Plays one match on this server (the main loop calls it) |
| `Host(players, metadata)` | `boolean` | Studio map only: plays a match the lobby hands over, with these players. `false` while another plays |
| `GetParticipant(participantId)`, `GetParticipantOf(player)` | `Match_Participant?` | A participant by id, or a player's |
| `GetParticipants()` | `{ Match_Participant }` | Everyone in the match, in roster order |
| `GetMetadata()` | `Match_Metadata` | The match this server plays |
| `GetActive()` | `string?` | The active participant's id |
| `GetPhase()` | `string` | `Waiting`, `Drop`, `Landing`, `Turn`, `Flight`, `Settle` or `Ended` |
| `GetWind()` | `number` | The wind, −`WIND_MAX` to `WIND_MAX` |
| `IsActivePlayer(player)` | `boolean` | Whether it's this player's turn |

### Client: `I.Match`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetFolder()` | `Folder` | `ReplicatedStorage.Ume.Match`, which holds the match's attributes |
| `GetPhase()`, `GetActive()` | | As on the server |
| `GetMyParticipantId()` | `string` | `P_<userId>` |
| `GetParticipantInfo(participantId)` | `Configuration?` | The participant's entry |
| `IsMyTurn()` | `boolean` | Whether the local player is active |

## Network

### Server

**Topics**

- `Match_PhaseChanged @ (phase: string)`
- `Match_TurnStarted @ (participantId: string)`, `Match_TurnEnded @ (participantId: string)`
- `Match_ParticipantOut @ (participantId: string, cause: string, killerId: string?, itemId: string?)`
- `Match_Ended @ (placements: { Match_Placement }, stats: { [string]: Match_Stats }, metadata: Match_Metadata)`

**Receive: RemoteEvents**

- `Match_PickDrop @ (player: Player, x: number, y: number)`: during the drop, a spot on the arena's plane; the server keeps it only where `I.Arena.IsFree` lets a worm fit
- `Match_Leave @ (player: Player)`: knocks out the player's worm, then sends them to the lobby. Rate limit 1 per second.
- `Match_Rematch @ (player: Player)`: a rematch vote. Rate limit 2 per second.

**Send: RemoteEvents**

- `Match_KnockedOut @ (participantId: string, cause: string, killerId: string?, itemId: string?)`: to everyone

### Client

**Topics**

- `Match_PhaseChanged @ (phase: string)`, `Match_TurnStarted @ (participantId: string)`, `Match_MyTurn @ (isMyTurn: boolean)`

## Data

| Where | Key | What |
| --- | --- | --- |
| Profile | `Match.Rejoin` | `{ PlaceId, AccessCode, Until }` written when a player drops (the lobby reads it) |
| `ReplicatedStorage.Ume.Match` | `Kind`, `Mode`, `MapId`, `Phase`, `ActiveId`, `TurnEndsAt`, `Wind`, `Round`, `SuddenDeath`, `Arrived`, `Expected`, `DropMinX`, `DropMaxX`, `DropMinY`, `DropMaxY` (the play area a spot may be placed in), `DropEndsAt` (set to now when everyone placed early), `RematchVotes`, `RematchEndsAt` | The match's state for every client |
| `…Match.Participants.<id>` | `DisplayName`, `UserId`, `Team`, `Color`, `IsBot`, `Connected`, `Out`, `DropX`, `DropY` (the landing spot), `Placed` (whether it was placed; bots always are) | One `Configuration` per participant |
| `Player` attribute | `InMatch` | `true` while the player is in the match: everyone on a match server, those `Host` brought on the Studio map. Lobby and match screens follow it |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `WAIT_FOR_PLAYERS` | `20` | Seconds to wait for the roster before starting |
| `DROP_SECONDS`, `MAX_LANDING`, `DROP_STICK_SPEED` | `15`, `12`, `40` | The drop phase |
| `TURN_SECONDS`, `MAX_FLIGHT`, `SETTLE_HOLD`, `MAX_SETTLE` | `15`, `20`, `0.5`, `8` | Turn timing |
| `WIND_MAX` | `10` | Strongest wind |
| `SUDDEN_DEATH_ROUND`, `SUDDEN_DEATH_RISE` | `10`, `4` | When the water starts rising, and by how much a round |
| `REJOIN_SECONDS`, `REMATCH_SECONDS` | `60`, `20` | How long a dropped seat waits; the rematch vote |
| `TEAM_SIZES`, `TEAMS`, `FFA_COLORS` | | Teams by mode, team names and colours, deathmatch colours |
| `STUDIO_MAP` | `"Studio"` | The map that runs the lobby and its matches on one server |
| `STUDIO_METADATA`, `STUDIO_WAIT`, `STUDIO_LOADOUT` | | The Match map alone in Studio: its stand-in match and wait; the loadout of a Studio player with an empty one |

## In the place

Creates `Workspace.Ume.Match` and `ReplicatedStorage.Ume.Match`. The tutorial match (`Kind = "Tutorial"`) skips the
rematch: everyone goes back to the lobby after the results.
