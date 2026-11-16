# MatchBoard

The lobby's way into matches, along the bottom of the screen: ACTIVE LOBBIES, a scrolling row of public matches, one
minimal lobby card per mode (`PUBLIC_ROWS`: Deathmatch, Duo, Trio, Quads): the mode and the map over the map's picture
(its `Thumbnail`, big, fading out to the right; a plain card for a map with none yet), a timer over **Join** counting down to the
card's next map (the owner, 2026-11-16), and **Join**, with no player count (the owner, 2026-11-15); and at the right the yellow **Solo vs bots** with a blue **Custom** over it. **Solo vs bots** opens the setup in the
board's place: the bots' difficulty (Easy, Medium, Hard), the coins a win pays and **Start**, a 1v1
against a bot. In a party the button reads **Play with party**: its leader sets up a friends-only deathmatch with bots
(`PARTY_BOTS_PER_PLAYER` per member) or with **No bots**, which pays half (MatchRewards).

**Public matches are global** (the owner, 2026-11-15). **Join** sends the player, with their whole party in this
server, straight to a match server (`Public`): the fullest open match of that mode on any server with a seat for each
of them, preferring one where the party sits on one team (Matchmaking's store, claimed in one step so a match never
overfills), on the card's map, or a new match on it when none has room (a party of 4 in Duo plays a 2v2 of its own).
**A card's map is the same on every server** for `MAP_SECONDS` (30, the owner, 2026-11-16): `Rotation` works it out
from the server clock, walking each mode through a shuffle of the rotation's maps for its size, never the same map
twice in a row, so nothing stores it and a Join never changes it. The card sends the map it shows with its Join, and a
Join less than `JOIN_GRACE` seconds after the cards moved on still plays that map. The waiting room is on the match server (Match's `WaitingRoom`): bots fill the seats nobody took.
A teleport that fails gives the seats back. A party leader joins for the whole party, and only the leader picks the
match: a party member's Join ("Host picks"), Solo vs bots ("Waiting for host") and Custom ("Host picks") are greyed
out, and pressing one says "Your party's leader picks the match."
**Custom** makes a room that friends are invited into and its owner starts, its empty places filled with bots of the difficulty picked in its Bots row (`CUSTOM_DIFFICULTIES`: Off, Easy, Medium, Hard, and Nightmare, which plays only here). Without bots it needs 2 or more players: Start with only the owner in it shows a message (`CUSTOM_ALONE_MESSAGE`, a WidgetManager message) and the server refuses it too; with bots its owner may start it alone. In a party only the leader makes one,
and the whole party is in it at once (their windows stay closed; their Custom reads "Party lobby" and opens it); the
party must fit (on one team in Teams: `size // 2`), and a Teams lobby without bots needs someone from outside the
party. When the player's lobby closes without them pressing Leave (it started, or its owner closed it), the window
closes. Its member list ends with an open slot per free place up to the lobby's size (`CUSTOM_OPEN_SLOT_TEXT`), and every
change to the player's lobby is published (`MatchBoard_RoomChanged`) for the lobby's stage and the Party column, which
list it (2026-11-16). Launching builds the match's teams
(parties stay together, a party bigger than a team spilling onto the next team with room: Matchmaking's `Seat`), gives
each player the card the match seats them from until they arrive, writes the match's metadata and teleports everyone
to a reserved server of the Match map. On the Studio map (the lobby and the match on one Studio server) it hands the
match to `I.Match.Host` instead (a public Join to the match waiting there joins it), and refuses while one plays.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/MatchBoard` |
| Runs on | Server, Client · Lobby map, Studio map |
| Exposes | `I.MatchBoard` (server; on the client, `GetCustomRoom`) |
| Uses | `I.Matchmaking`, `I.Party`, `I.Teleport`, `I.TeleportToServer`, `I.Transition`, `I.Notify`, `I.Friends` (client), `I.WidgetManager`, `I.DoEvery`, `I.Console` (client: the pad's selection) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Starts the four server handlers; the `I` table |
| `Scripts/Server/Rows.lua` | The board's rows (the public cards and custom rooms) as `Configuration`s; leaving a custom room; `GetGroup(player)`, the players who travel with a player (their party here, or just them) |
| `Scripts/Server/Public.lua` | The public cards: Join (claim seats in an open match on the card's map anywhere, or open a new one on it) |
| `Scripts/Server/Custom.lua` | Custom rooms: creating, inviting, answering, starting, leaving |
| `Scripts/Server/Launch.lua` | Teams, cards, metadata and the teleport to a new match server or an open one (`Send`; on the Studio map, `I.Match.Host`); solo and party matches |
| `Client.lua` | Starts the three client handlers; `I.MatchBoard` on the client (`GetCustomRoom`) |
| `Scripts/Helpers/Rotation.lua` | `MatchBoard_Rotation`, both sides: each public card's map from the server clock (`GetMap(mode, size, at?)`), the seconds until the next (`GetSecondsLeft`), and the rotation's maps for a size (`GetPool`) |
| `Scripts/Client/Board.lua` | The `MatchBoard` board: Solo vs bots (Play with party), Custom, the public lobby cards (each the rotation's map and its timer, redrawn every second while the board shows, `TIMER_TICK`); a party member's locked buttons. On a pad the selection rests on Solo vs bots (`I.Console.SetHome`) |
| `Scripts/Client/Setup.lua` | The setup for a solo or party match (the studio's PlaySolo window, in the board's place): the bots, the picked one outlined white, what a win pays, Start, and X back to the board. On a pad the panel holds the selection, Start first, and B goes back to the board (`I.Console.Focus`) |
| `Scripts/Client/Custom.lua` | The `CustomLobby` widget and room invites; closes the widget when the player's lobby closes without them leaving it. Registers `MatchBoard_RoomChanged` and publishes it on every refresh of the player's lobby; lists its members, then open slots up to its `Size`; `GetMyRoom` (`I.MatchBoard.GetCustomRoom`) |
| `Settings.lua` | `MatchBoard_Settings` |
| `_meta/_types.lua` | `MatchBoard_RowOption`, `MatchBoard_MapRow`, `MatchBoard_Row` |

## API

### Server: `I.MatchBoard`

| Function | Returns | What it does |
| --- | --- | --- |
| `Launch(players, kind, mode, size, mapId, difficulty, tutorial?)` | `boolean` | Builds the teams and metadata and teleports the players. On the Studio map it starts the match on this server; on the Lobby map alone in Studio it only prints and notifies |
| `GetMap(size: number)` | `string` | A random map from `MAP_POOL` (the rotation) whose `Sizes` hold that many snails; any pool map when none does (solo and party matches) |

### Client: `I.MatchBoard`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetCustomRoom()` | `Instance?` | The custom lobby the local player is in (its `Configuration`: `Players`, `Size`, `Owner`…), nil when in none or before the board has arrived |

## Network

### Server

**Receive: RemoteEvents**

- `MatchBoard_Join @ (player: Player, rowId: string, shownMap: string?)`: a public card, and the map it showed; leaders only, one Join at a time; the party must fit the mode (a party bigger than a team is split over teams)
- `MatchBoard_PlaySolo @ (player: Player, difficulty: string)`: refused in a party of 2 or more
- `MatchBoard_PlayParty @ (player: Player, difficulty: string)`: a difficulty or `"None"` (no bots); the leader of a party of 2 or more
- `MatchBoard_CreateCustom @ (player: Player, mapId: string, mode: string, size: number, difficulty: string)`: `difficulty` from `CUSTOM_DIFFICULTIES` (`"None"` for no bots); not from a party member, and the party must fit
- `MatchBoard_InviteCustom @ (player: Player, target: Player)`
- `MatchBoard_InviteAnswer @ (player: Player, roomId: string, accept: boolean)`
- `MatchBoard_StartCustom @ (player: Player)`: the owner, with 2 or more players, or alone with bots; a Teams lobby without bots needs a player from outside the owner's party
- `MatchBoard_LeaveCustom @ (player: Player)`

**Send: RemoteEvents**

- `MatchBoard_Invited @ (fromUserId: number, roomId: string)`: to an invited player

### Client

**Topics**

- `MatchBoard_RoomChanged @ ()`: the player's custom lobby changed (joined, left, someone came or went, or it closed); the lobby's stage and Party redraw from `I.MatchBoard.GetCustomRoom`

## Data

Rows are `Configuration`s in `ReplicatedStorage.Ume.MatchBoard`, one per row, with the attributes `Kind`, `Mode`,
`Size`, `MapId` (`""` on a public card, whose map is the rotation's), `Difficulty` (the bots: `PUBLIC_DIFFICULTY`, or
a custom room's pick), `Players` (JSON list of user ids, custom rooms) and `Owner` (custom rooms). The match metadata it sends is `Match_Metadata` (Match's types). On the client, Join, Solo and Custom
keep the design's look in `Look_MainColor`, `Look_StrokeColor`, `Look_TextColor`, `Look_HoverScale` and
`Look_ClickScale` attributes the first time they're locked. The setup's difficulties and the custom lobby's maps, modes, player counts and bots carry the design's picked
and unpicked looks as `Look_Selected*` and `Look_*` attributes (outline colour and, where sizes match, its pictures;
text colour), which the picked one swaps to.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `TELEPORT_GUI` | `"TeleportGui"` | The teleport screen. Matches teleport to the place loader config's `MatchPlaceId`, the Arena of the experience the lobby runs in (dev or main) |
| `STUDIO_MAP` | `"Studio"` | The map where matches start on the lobby's own server |
| `PUBLIC_ROWS` | Deathmatch 4, Duo 4, Trio 6, Quads 8 | The public cards, one per mode and size, always on the board |
| `TEAM_SIZES`, `MODE_NAMES` | | Players per team by mode; mode names on the cards (Deathmatch, Duo, Trio, Quads, Teams) |
| `PUBLIC_DIFFICULTY` | `"Medium"` | Bots that fill public matches |
| `MAP_SECONDS` | `30` | How long each public card keeps its map, the same on every server |
| `JOIN_GRACE` | `2` | A Join this many seconds after the cards moved on still plays the map the player's card showed |
| `TIMER_TICK` | `0.2` | How often the board checks whether its timers reached another second |
| `JOIN_FAILED_MESSAGE` | "Couldn't find a match. Try again!" | What a Join says when the matches couldn't be reached |
| `MAPS`, `MAP_POOL`, `CUSTOM_MAP_POOL` | 12 map rows; `{ "PicnicPlains", "Desert", "FluffyFallout", "RollingPlains", "EchoCaverns", "VolcanoIsle" }`; those six plus `"MirageMesa", "LakesideShowdown", "RockslideRidge"` | Map names, sizes and pictures (`Thumbnail` for the lobby cards, `TileThumbnail` for the custom lobby's map tiles, cut to each one's shape: the game home's `assets/ui/map_thumbnails`; Mirage Mesa has the old Desert's card picture; Molten Spires and The Big Mashup have none, so their cards are plain; Training Meadow, the tutorial's map, shows Picnic Plains' until it has its own and is in neither pool). `MAP_POOL` is the rotation new public matches, Solo and Party pick from, by `Sizes` (Picnic Plains 6/8, Desert 2/4/6, Fluffy Fallout 2/4/6, Rolling Plains 2/4, Echo Caverns 2/4/6/8, Volcano Isle 2/4/6); `CUSTOM_MAP_POOL` is what a custom lobby lists and allows, the custom-only maps last |
| `SOLO_DIFFICULTIES` | Easy, Medium, Hard | The bots' difficulties in the setup (a party also gets No bots) |
| `CUSTOM_DIFFICULTIES` | None, Easy, Medium, Hard, Nightmare | The custom lobby's Bots row; Nightmare is only here |
| `CUSTOM_ALONE_MESSAGE` | "You can't start a custom lobby by yourself. Invite a player or turn bots on!" | What Start says with only the owner in the lobby and no bots |
| `CUSTOM_OPEN_SLOT_TEXT`, `CUSTOM_OPEN_SLOT_TRANSPARENCY` | `"Open slot"`, `0.5` | A free place in the lobby's member list (one per place up to its size): its name line, faded this much, no avatar or username |
| `REWARD_TEXT`, `SOLO_WIN_COINS` | | What the setup's reward line says for a solo match (beside the coins), a party match and a party match without bots; the coins a solo win pays by difficulty (20, 35, 60: MatchRewards' `SOLO_COINS`, which pays them) |
| `PARTY_BOTS_PER_PLAYER`, `PARTY_MAX_SIZE` | `1`, `8` | Bots per member in a party match with bots, and its most snails |
| `BOARD_GUI_NAME`, `CUSTOM_GUI_NAME` | | The guis |
| `LOCKED_MAIN_COLOR`, `LOCKED_STROKE_COLOR`, `LOCKED_TEXT_COLOR` | `(70, 70, 80)`, `(130, 130, 130)`, `(153, 153, 153)` | A party member's Join, Solo and Custom while their leader picks the match: the face, its outline, the text |
