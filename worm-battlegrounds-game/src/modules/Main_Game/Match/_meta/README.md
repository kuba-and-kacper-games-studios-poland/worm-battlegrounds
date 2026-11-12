# Match

The match's rules on a match server. It reads the match's metadata (sent by MatchBoard with the teleport; on the
Studio map, handed over through `I.Match.Host`; on the Match map alone in Studio, `STUDIO_METADATA`; a live server
that got none, such as a public server someone joined directly, plays nothing and sends everyone to the lobby), loads the map
so it shows while everyone arrives, waits for the players (until each one's data has loaded, so their loadout and skin
can be read), seats them and fills the rest with bots (unless the match has none: a party's or a custom lobby's without bots), then
plays: the drop (each player
clicks or taps anywhere in the arena a snail fits, out of walls and liquid, to place where their snail lands; it
ends as soon as every connected player has placed, or after `DROP_SECONDS`), the landing (every snail parachutes
in: a placed one from its spot, bots and players who didn't place from up to `DROP_HEIGHT` over a spot of land from
`I.Arena.GetLandSpots`, which each bot but the tutorial's picks with `I.Bots.GetStart`), then turns (`TURN_SECONDS` each, with wind) until one team is left, with
sudden death from `SUDDEN_DEATH_ROUND`, after 10 rounds (the liquid rises every turn). Then it ends the match (MatchRewards pays and shows Results), runs the rematch
vote and sends everyone who didn't vote to the lobby. A snail knocked out at a turn's end turns into its ghost
(Snails' `GHOST_TIME`) before the next turn starts. A player who drops out keeps their snail, and a bot plays its
turns (`I.Bots.TakeTurn`, the `Autopilot` attribute) until they come back from the lobby, which offers it for
`REJOIN_SECONDS`; one who drops during their turn hands the rest of it to the bot, with at least `TAKEOVER_SECONDS`
left. Back, they play from their snail's next turn, as the bot left it (its moves, shots and uses stay), on their team
again. A player who leaves (the Leave button) is knocked out. A match that can't play (its map doesn't load, or
an error stops it) sends everyone to the lobby instead of leaving them waiting.

Match servers are reserved servers of the match place, which boots the `Match` map; the lobby place sends each one its
match (the place loader's metadata, `I.Config.Metadata`).

**The Studio map** (`STUDIO_MAP`) runs the lobby and the match on one server, the quick Studio test. The match
waits for the lobby to call `Host`, plays with the players it names, then sends them back to the lobby's screens
(the `InMatch` Player attribute) instead of teleporting, clears the snails and waits for the next one. A match every
player left stops at the next turn. One match plays at a time.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Match` |
| Runs on | Server, Client · Match map, Studio map |
| Exposes | `I.Match` (server, client) |
| Uses | `I.Snails`, `I.Combat`, `I.Bots`, `I.Arena`, `I.Loadout`, `I.Cosmetics`, `I.Team`, `I.Player`, `I.Config.Metadata`, `I.TeleportExternal`, `I.Tutorial`, `I.Console` (client), `I.AdminPanel_CommandBar` |
| Saves | `Profile.Match` (writes `Rejoin` when a player drops) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The match folders, remotes, Topics, the `I` table; starts the handlers |
| `Scripts/Server/Phases.lua` | The main loop: waiting, drop, landing, turns, the end, rematches |
| `Scripts/Server/Roster.lua` | Metadata, participants (players and bots), teams, the participant entries. `AssignTeam(participant)` puts a player on their Roblox team in a team match, making the team only when `Teams` has none of that name, at the start and when they come back |
| `Scripts/Server/Turns.lua` | Turn order, the timer (a turn also ends when its snail is hurt before its shot is away, as in Worms), wind, rounds, sudden death; a bot plays a dropped player's turns (`Autopilot`); at every turn's end each snail with its head under a pond's liquid loses `UNDERWATER_DAMAGE`, never below 1; the settle (below); after the knockouts at a turn's end it waits Snails' `GHOST_TIME` when any snail went out |
| `Scripts/Server/Placement.lua` | Knockout order and the final places |
| `Scripts/Server/Stats.lua` | Damage, knockouts, rounds and best shot per participant |
| `Scripts/Server/Connection.lua` | Leaving, dropping out, rejoining (control from the snail's next turn, its team and `ReplicationFocus` back), sending players to the lobby, the `InMatch` attribute |
| `Scripts/Server/Rematch.lua` | The rematch vote |
| `Client.lua` | Match state for other client modules |
| `Scripts/Client/DropPicker.lua` | Picking the drop point: the marker follows the mouse (or the left stick), faded where a snail doesn't fit; a click, a tap or the gamepad's A places it (the pad's buttons are the Console module's `Move` and `PlaceDrop`, read through `I.Console.IsAction`); each DropMarker is sized with the screen by `I.ScreenScale.AddBillboard` |
| `Scripts/AdminPanel/CommandBar/Server.lua` | The `match` command |
| `Settings.lua` | `Match_Settings` |
| `_meta/_types.lua` | `Match_Metadata`, `Match_RosterEntry`, `Match_Participant`, `Match_Placement`, `Match_Stats`, … |

## API

### Server: `I.Match`

| Function | Returns | What it does |
| --- | --- | --- |
| `Play(loaded: boolean?)` | `boolean` | Plays one match on this server (the main loop calls it), loading the map unless `loaded` says it's fresh; `false` when the map didn't load |
| `Host(players, metadata)` | `boolean` | Studio map only: plays a match the lobby hands over, with these players. `false` while another plays |
| `SkipTurn()` | | Ends the turn playing now as if its timer ran out; a shot in flight still lands. For testing |
| `SetTurnSeconds(seconds: number?)` | | How long every turn lasts from now on, the one playing now too, until the server closes; nil is `TURN_SECONDS` again. For testing |
| `SetWind(wind: number)` | | This turn's wind, kept within ±`WIND_MAX`. For testing |
| `SetRound(round: number)` | | The round the match is on; from `SUDDEN_DEATH_ROUND` the next turn starts sudden death. For testing |
| `GetParticipant(participantId)`, `GetParticipantOf(player)` | `Match_Participant?` | A participant by id, or a player's |
| `GetParticipants()` | `{ Match_Participant }` | Everyone in the match, in roster order |
| `GetMetadata()` | `Match_Metadata` | The match this server plays |
| `GetActive()` | `string?` | The active participant's id |
| `GetPhase()` | `string` | `Waiting`, `Drop`, `Landing`, `Turn`, `Flight`, `Settle` or `Ended` |
| `GetWind()` | `number` | The wind, −`WIND_MAX` to `WIND_MAX` |
| `IsActivePlayer(player)` | `boolean` | Whether it's this player's turn, played by them: `false` while a bot plays it (`IsAutopilot`) |
| `IsAutopilot()` | `boolean` | Whether a bot plays this turn for a player who dropped |

### Client: `I.Match`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetFolder()` | `Folder` | `Workspace.Ume.Match`, which holds the match's attributes |
| `GetPhase()`, `GetActive()` | | As on the server |
| `GetMyParticipantId()` | `string` | `P_<userId>` |
| `GetParticipantInfo(participantId)` | `Configuration?` | The participant's entry |
| `IsMyTurn()` | `boolean` | Whether the local player is active and plays the turn themselves (`false` while `Autopilot`) |

## Network

### Server

**Topics**

- `Match_PhaseChanged @ (phase: string)`
- `Match_TurnStarted @ (participantId: string)`, `Match_TurnEnded @ (participantId: string)`
- `Match_ParticipantOut @ (participantId: string, cause: string, killerId: string?, itemId: string?)`
- `Match_Ended @ (placements: { Match_Placement }, stats: { [string]: Match_Stats }, metadata: Match_Metadata)`

**Receive: RemoteEvents**

- `Match_PickDrop @ (player: Player, x: number, y: number)`: during the drop, a spot on the arena's plane; the server keeps it only where `I.Arena.IsFree` lets a snail fit
- `Match_Leave @ (player: Player)`: knocks out the player's snail, then sends them to the lobby. Rate limit 1 per second.
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
| `Workspace.Ume.Match` | `Kind`, `Mode`, `MapId`, `Phase`, `ActiveId`, `Autopilot` (a bot plays the active snail for its player, who dropped), `TurnOrder` (the snails that can play, comma-separated, in the order their next turn comes after the active one; set at each turn's start), `TurnEndsAt`, `Wind`, `Round`, `SuddenDeath`, `Arrived`, `Expected`, `DropMinX`, `DropMaxX`, `DropMinY`, `DropMaxY` (the play area a spot may be placed in: the bounds, minus Arena's `START_TOP_GAP` at the top), `DropEndsAt` (set to now when everyone placed early), `RematchVotes`, `RematchEndsAt` | The match's state for every client |
| `…Match.Participants.<id>` | `DisplayName`, `UserId`, `Team`, `Color`, `IsBot`, `Connected`, `Out`, `DropX`, `DropY` (the landing spot), `Placed` (whether it was placed; bots always are) | One `Configuration` per participant |
| `Player` attribute | `InMatch` | `true` while the player is in the match: everyone on a match server, those `Host` brought on the Studio map. Lobby and match screens follow it |

## Settings

| Key | Default | What |
| --- | --- | --- |
| `WAIT_FOR_PLAYERS` | `20` | Seconds to wait for the roster (each player in the server with their data loaded) before starting |
| `DROP_SECONDS`, `MAX_LANDING`, `DROP_STICK_SPEED`, `DROP_HEIGHT` | `10`, `12`, `40`, `20` | The drop phase, and how high over its land a snail nobody placed starts its parachute |
| `TURN_SECONDS`, `MAX_FLIGHT` | `25`, `20` | A turn's seconds, and the longest a shot flies |
| `SETTLE_HOLD`, `HIT_HOLD`, `STALL_SECONDS`, `MAX_SETTLE` | `0.3`, `3`, `5`, `20` | The settle after a turn: the next turn waits until every snail is at rest on the ground (or in a liquid), no debris falls, no shot flies and no health changes, for `SETTLE_HOLD` seconds, or `HIT_HOLD` after a shot or a hit; nothing moving or getting hurt for `STALL_SECONDS` moves on anyway (a snail stuck off the ground), and `MAX_SETTLE` seconds of settling always does |
| `UNDERWATER_DAMAGE`, `UNDERWATER_HEAD_HEIGHT` | `5`, `1.6` | At the end of every turn, damage to each snail whose head is under a liquid that doesn't knock it out (a pond, Desert's oasis), never taking it below 1 health, like Worms Armageddon's poison; the head's top is this many studs over the ball's centre (where Classic's eyestalks start), so a snail with only its body under is fine |
| `WIND_MAX` | `10` | Strongest wind |
| `SUDDEN_DEATH_ROUND`, `SUDDEN_DEATH_RISE` | `11`, `4` | The round sudden death starts at (after 10 rounds), and how many half-stud rows the liquid rises at the start of every turn from then |
| `REJOIN_SECONDS`, `TAKEOVER_SECONDS` | `900`, `12` | How long the lobby offers a dropped player to go back to their match (a bot plays their snail meanwhile); the least time a bot gets of a turn its player dropped during |
| `REMATCH_SECONDS` | `20` | The rematch vote |
| `LOBBY_RESEND_SECONDS`, `LOBBY_FAILED_MESSAGE` | `15`, "Couldn't get you to the lobby. Try again!" | A player on the way to the lobby isn't sent again for this long; a teleport that can't start says so, and Lobby works again at once |
| `TEAM_SIZES`, `TEAMS`, `FFA_COLORS` | | Teams by mode, team names and colours, deathmatch colours |
| `STUDIO_MAP` | `"Studio"` | The map that runs the lobby and its matches on one server |
| `STUDIO_METADATA`, `STUDIO_WAIT` | | The Match map alone in Studio: its stand-in match and wait |

## In the place

Creates `Workspace.Ume.Match`. The DropMarker billboard's holder is `Assets.Match` › `PREFAB | DropMarker` (authored in `Workspace.Ume.ReplicatedStorage_Assets/Match/`: a 1 × 1 × 1 invisible `RootPart`, its `Attachment`, the BillboardGui `U_DropMarker`); clients clone only the billboard and name the copy `DropMarker`. The tutorial match (`Kind = "Tutorial"`) skips the
rematch: everyone goes back to the lobby after the results. It counts as played (`I.Tutorial.CompleteMatch`, saved at
once) when it ends, and when a player leaves it early (Leave game, or a match that can't play), so the lobby doesn't
send the player straight back.

## Commands

`match` (server, level 255):

| Subcommand | Arguments | What |
| --- | --- | --- |
| `skip` | | Ends the turn playing now |
| `time` | `seconds` | Every turn lasts this long, until the server closes; `0` is `TURN_SECONDS` again |
| `wind` | `wind` | This turn's wind |
| `round` | `round` | The round (`11` starts sudden death next turn) |
| `win` | `participantId?` | Knocks out every other team's snails and skips the turn, so the invoker's team wins |
