# MatchBoard

The lobby's way into matches. **Play** joins the open public row closest to starting (the most players with room left,
a deathmatch on a tie); the **Modes** window (`PlayModes`) lists the public rows (deathmatches of 2, 4, 6 and 8, and
team rows);
a party leader joins a row for the whole party, and a row starts when it's full, when its `ROW_SECONDS` timer runs out
with two or more players in it, or when `VOTE_FRACTION` of its players vote to start early. A started row is replaced
by a fresh one. **Solo** starts a match against bots at a chosen difficulty (one player only), and **Custom** makes a
room that friends are invited into and its owner starts. Launching builds the match's teams (parties stay together),
writes the match's metadata and teleports everyone to a reserved server of the Match map. On the Studio map (the
lobby and the match on one Studio server) it hands the match to `I.Match.Host` instead, and refuses while one plays.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/MatchBoard` |
| Runs on | Server, Client · Lobby map, Studio map |
| Exposes | `I.MatchBoard` (server) |
| Uses | `I.Party`, `I.Loadout`, `I.Teleport`, `I.Notify`, `I.Friends` (client), `I.WidgetManager`, `I.DoEvery` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Starts the three server handlers; the `I` table |
| `Scripts/Server/Rows.lua` | Public and custom rows: joining, leaving, votes, timers, publishing them as `Configuration`s |
| `Scripts/Server/Custom.lua` | Custom rooms: creating, inviting, answering, starting, leaving |
| `Scripts/Server/Launch.lua` | Teams, metadata and the teleport (on the Studio map, `I.Match.Host`); solo matches |
| `Client.lua` | Starts the three client handlers |
| `Scripts/Client/Board.lua` | The `MatchBoard` Play row (the quick match), the rows in `PlayModes`, the waiting room, votes and timers |
| `Scripts/Client/Solo.lua` | The `SoloSetup` widget |
| `Scripts/Client/Custom.lua` | The `CustomLobby` widget and room invites |
| `Settings.lua` | `MatchBoard_Settings` |
| `_meta/_types.lua` | `MatchBoard_RowOption`, `MatchBoard_MapRow`, `MatchBoard_Row` |

## API

### Server: `I.MatchBoard`

| Function | Returns | What it does |
| --- | --- | --- |
| `Launch(players, kind, mode, size, mapId, difficulty, tutorial?)` | `boolean` | Builds the teams and metadata and teleports the players. On the Studio map it starts the match on this server; on the Lobby map alone in Studio it only prints and notifies |
| `GetMap(size: number)` | `string` | A map from `MAP_POOL` that holds that many worms |

## Network

### Server

**Receive: RemoteEvents**

- `MatchBoard_Join @ (player: Player, rowId: string)`: leaders only; the whole party must fit
- `MatchBoard_Leave @ (player: Player)`
- `MatchBoard_Vote @ (player: Player)`: vote to start the row early
- `MatchBoard_PlaySolo @ (player: Player, difficulty: string)`: refused in a party of 2 or more
- `MatchBoard_CreateCustom @ (player: Player, mapId: string, mode: string, size: number)`
- `MatchBoard_InviteCustom @ (player: Player, target: Player)`
- `MatchBoard_InviteAnswer @ (player: Player, roomId: string, accept: boolean)`
- `MatchBoard_StartCustom @ (player: Player)`: the owner, with 2 or more players
- `MatchBoard_LeaveCustom @ (player: Player)`

**Send: RemoteEvents**

- `MatchBoard_Invited @ (fromUserId: number, roomId: string)`: to an invited player

## Data

Rows are `Configuration`s in `ReplicatedStorage.Ume.MatchBoard`, one per row, with the attributes `Kind`, `Mode`,
`Size`, `MapId`, `Players` (JSON list of user ids), `Votes`, `VotesNeeded`, `EndsAt` (server time) and `Owner`
(custom rooms). The match metadata it sends is `Match_Metadata` (Match's types).

## Settings

| Key | Default | What |
| --- | --- | --- |
| `MATCH_PLACE_ID`, `TELEPORT_GUI` | this place, `"TeleportGui"` | Where matches run, the teleport screen |
| `STUDIO_MAP` | `"Studio"` | The map where matches start on the lobby's own server |
| `ROW_SECONDS` | `30` | A row's countdown once someone joins |
| `VOTE_FRACTION` | `2 / 3` | Share of a row's players whose votes start it |
| `DEATHMATCH_SIZES` | `{ 2, 4, 6, 8 }` | The deathmatch rows |
| `TEAM_ROWS`, `TEAM_OPTIONS` | `2`, Duo/Trio/Quads options | How many team rows show, and their modes and sizes |
| `TEAM_SIZES`, `MODE_NAMES` | | Players per team by mode; mode names shown |
| `PUBLIC_DIFFICULTY` | `"Medium"` | Bots that fill public matches |
| `MAPS`, `MAP_POOL` | 6 map rows; `{ "PicnicPlains" }` | Map names and sizes; the maps in rotation |
| `SOLO_DIFFICULTIES` | Easy, Medium, Hard | Solo choices |
| `BOARD_GUI_NAME`, `MODES_GUI_NAME`, `SOLO_GUI_NAME`, `CUSTOM_GUI_NAME` | | The guis |
| `SELECTED_COLOR`, `SELECTED_TRANSPARENCY`, `TILE_COLOR`, `TILE_TRANSPARENCY` | `(40, 140, 255)`, `0.2`, `(0, 0, 0)`, `0.7` | A picked difficulty's or map's slot fill (its `Body`), and an unpicked one's. Mode and player-count buttons swap to their selected skin instead (`Kit_SelectedImage`) |
