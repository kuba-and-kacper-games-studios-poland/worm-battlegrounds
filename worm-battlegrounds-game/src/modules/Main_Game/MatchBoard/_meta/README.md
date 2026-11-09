# MatchBoard

The lobby's way into matches, along the bottom of the screen: ACTIVE LOBBIES, a scrolling row of public matches, one
lobby card per mode (`PUBLIC_ROWS`: Deathmatch, Duo, Trio, Quads), each with its map's picture (a landscape photo
of the map, its `Thumbnail`; the design's for a map with none yet), mode, players ("3/6 players"), map name, timer and **Join** (**Join teams** for team
modes); and at the right the yellow **Solo vs bots** with a blue **Custom** over it. **Solo vs bots** opens the setup in the
board's place: the bots' difficulty (Easy, Medium, Hard, what each means and what the match pays) and **Start**, a 1v1
against a bot. In a party the button reads **Play with party**: its leader sets up a friends-only deathmatch with bots
(`PARTY_BOTS_PER_PLAYER` per member) or with **No bots**, which pays half (MatchRewards). Joining a public match shows
the waiting room in the panel's place (the match, the countdown, the players, **Vote to start**, **Leave match**). A
party leader joins a row for the whole party. Every public row's `ROW_SECONDS` timer always runs, players or not, so
the board looks alive: the row starts when it's full, when its timer runs out (with whoever joined, bots filling every
empty seat, so one player can play Trios alone; with nobody, it only resets), or when `VOTE_FRACTION` of its players
vote to start early. A started row is replaced by a fresh one of its mode on another map, its timer starting over.
**Custom** makes a room that friends are invited into and its owner starts, its empty places filled with bots of the difficulty picked in its Bots row (`CUSTOM_DIFFICULTIES`: Off, Easy, Medium, Hard, and Nightmare, which plays only here). Without bots it needs 2 or more players; with bots its owner may start it alone. Launching builds the match's teams
(parties stay together), writes the match's metadata and teleports everyone to a reserved server of the Match map.
On the Studio map (the lobby and the match on one Studio server) it hands the match to `I.Match.Host` instead, and
refuses while one plays.

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
| `Scripts/Server/Launch.lua` | Teams, metadata and the teleport (on the Studio map, `I.Match.Host`); solo and party matches |
| `Client.lua` | Starts the three client handlers |
| `Scripts/Client/Board.lua` | The `MatchBoard` board: Solo vs bots (Play with party), the public lobby cards, the waiting room, votes and timers |
| `Scripts/Client/Setup.lua` | The panel's setup for a solo or party match: the bots, their text, Start |
| `Scripts/Client/Custom.lua` | The `CustomLobby` widget and room invites |
| `Settings.lua` | `MatchBoard_Settings` |
| `_meta/_types.lua` | `MatchBoard_RowOption`, `MatchBoard_MapRow`, `MatchBoard_Row` |

## API

### Server: `I.MatchBoard`

| Function | Returns | What it does |
| --- | --- | --- |
| `Launch(players, kind, mode, size, mapId, difficulty, tutorial?)` | `boolean` | Builds the teams and metadata and teleports the players. On the Studio map it starts the match on this server; on the Lobby map alone in Studio it only prints and notifies |
| `GetMap(size: number, avoid: string?)` | `string` | A random map from `MAP_POOL` that holds that many snails, never `avoid` while there's another |

## Network

### Server

**Receive: RemoteEvents**

- `MatchBoard_Join @ (player: Player, rowId: string)`: leaders only; the whole party must fit
- `MatchBoard_Leave @ (player: Player)`
- `MatchBoard_Vote @ (player: Player)`: vote to start the row early
- `MatchBoard_PlaySolo @ (player: Player, difficulty: string)`: refused in a party of 2 or more
- `MatchBoard_PlayParty @ (player: Player, difficulty: string)`: a difficulty or `"None"` (no bots); the leader of a party of 2 or more
- `MatchBoard_CreateCustom @ (player: Player, mapId: string, mode: string, size: number, difficulty: string)`: `difficulty` from `CUSTOM_DIFFICULTIES` (`"None"` for no bots)
- `MatchBoard_InviteCustom @ (player: Player, target: Player)`
- `MatchBoard_InviteAnswer @ (player: Player, roomId: string, accept: boolean)`
- `MatchBoard_StartCustom @ (player: Player)`: the owner, with 2 or more players, or alone with bots
- `MatchBoard_LeaveCustom @ (player: Player)`

**Send: RemoteEvents**

- `MatchBoard_Invited @ (fromUserId: number, roomId: string)`: to an invited player

## Data

Rows are `Configuration`s in `ReplicatedStorage.Ume.MatchBoard`, one per row, with the attributes `Kind`, `Mode`,
`Size`, `MapId`, `Difficulty` (the bots: `PUBLIC_DIFFICULTY`, or a custom room's pick), `Players` (JSON list of user ids), `Votes`, `VotesNeeded`, `EndsAt` (server time) and `Owner`
(custom rooms). The match metadata it sends is `Match_Metadata` (Match's types).

## Settings

| Key | Default | What |
| --- | --- | --- |
| `MATCH_PLACE_ID`, `TELEPORT_GUI` | `118265066788984` (Arena), `"TeleportGui"` | The match place (the place loader config's `MATCH_PLACE_ID`), the teleport screen |
| `STUDIO_MAP` | `"Studio"` | The map where matches start on the lobby's own server |
| `ROW_SECONDS` | `30` | Every public row's countdown, always running; at 0 it starts with whoever joined (bots filling the rest), or nobody, and a fresh row on another map takes its place |
| `VOTE_FRACTION` | `2 / 3` | Share of a row's players whose votes start it |
| `PUBLIC_ROWS` | Deathmatch 4, Duo 4, Trio 6, Quads 8 | The public rows, one per mode, always on the board |
| `TEAM_SIZES`, `MODE_NAMES`, `MATCH_NAMES` | | Players per team by mode; mode names on the cards (Deathmatch, Duo, Trio, Quads) and in full in the waiting room (Duo team deathmatch…) |
| `PUBLIC_DIFFICULTY` | `"Medium"` | Bots that fill public matches |
| `MAPS`, `MAP_POOL` | 7 map rows; `{ "PicnicPlains", "Desert", "RockslideRidge" }` | Map names, sizes and pictures (`Thumbnail`: Picnic Plains, Desert and Rockslide Ridge have theirs, the game home's `assets/ui/map_thumbnails`); the maps in rotation |
| `SOLO_DIFFICULTIES` | Easy, Medium, Hard | The bots' difficulties in the setup (a party also gets No bots) |
| `CUSTOM_DIFFICULTIES` | None, Easy, Medium, Hard, Nightmare | The custom lobby's Bots row; Nightmare is only here |
| `DIFFICULTY_TEXT`, `REWARD_TEXT` | | What the setup says about each choice, and what a solo match, a party match and a party match without bots pay |
| `PARTY_BOTS_PER_PLAYER`, `PARTY_MAX_SIZE` | `1`, `8` | Bots per member in a party match with bots, and its most snails |
| `BOARD_GUI_NAME`, `CUSTOM_GUI_NAME` | | The guis |
| `SELECTED_COLOR`, `SELECTED_TRANSPARENCY`, `TILE_COLOR`, `TILE_TRANSPARENCY` | `(40, 140, 255)`, `0.2`, `(0, 0, 0)`, `0.7` | A picked map's slot fill (its `Body`), and an unpicked one's, in the custom lobby. Difficulty, mode and player-count buttons swap to their selected skin instead (`Kit_SelectedImage`) |
