# Match

The match's rules on a match server. It reads the match's metadata (sent by MatchBoard with the teleport; in Studio,
`STUDIO_METADATA`), waits for the players, seats them and fills the rest with bots, then plays: the drop (each player
picks where their worm lands), the landing, then turns (`TURN_SECONDS` each, with wind) until one team is left, with
sudden death from `SUDDEN_DEATH_ROUND`. Then it ends the match (MatchRewards pays and shows Results), runs the rematch
vote and sends everyone who didn't vote to the lobby. A player who drops out keeps their seat for `REJOIN_SECONDS`
and can come back from the lobby; a player who leaves is knocked out.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Match` |
| Runs on | Server, Client · Match map |
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
| `Scripts/Server/Connection.lua` | Leaving, dropping out, rejoining, sending players to the lobby |
| `Scripts/Server/Rematch.lua` | The rematch vote |
| `Client.lua` | Match state for other client modules |
| `Scripts/Client/DropPicker.lua` | Picking the drop point |
| `Settings.lua` | `Match_Settings` |
| `_meta/_types.lua` | `Match_Metadata`, `Match_RosterEntry`, `Match_Participant`, `Match_Placement`, `Match_Stats`, … |

## API

### Server: `I.Match`

| Function | Returns | What it does |
| --- | --- | --- |
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

- `Match_PickDrop @ (player: Player, x: number)`: during the drop
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
| `ReplicatedStorage.Ume.Match` | `Kind`, `Mode`, `MapId`, `Phase`, `ActiveId`, `TurnEndsAt`, `Wind`, `Round`, `SuddenDeath`, `Arrived`, `Expected`, `DropMinX`, `DropMaxX`, `DropY`, `DropEndsAt`, `RematchVotes`, `RematchEndsAt` | The match's state for every client |
| `…Match.Participants.<id>` | `DisplayName`, `UserId`, `Team`, `Color`, `IsBot`, `Connected`, `Out` | One `Configuration` per participant |

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
| `STUDIO_METADATA`, `STUDIO_WAIT`, `STUDIO_LOADOUT` | | Studio's stand-in match, wait and loadout |

## In the place

Creates `Workspace.Ume.Match` and `ReplicatedStorage.Ume.Match`. The tutorial match (`Kind = "Tutorial"`) skips the
rematch: everyone goes back to the lobby after the results.
