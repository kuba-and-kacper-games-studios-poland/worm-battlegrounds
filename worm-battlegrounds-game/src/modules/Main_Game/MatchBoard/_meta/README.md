# MatchBoard

The lobby's way into matches, along the bottom of the screen (the studio's `LobbyRework` design since 2026-11-24):
PUBLIC MATCHES, a scrolling row of public matches, one lobby card per mode (`PUBLIC_ROWS`: Deathmatch, Duo, Trio; Quads
left the board on 2026-11-24, the owner: "we want only 3 segments"): the mode with its icon over the map's picture
(its `Thumbnail`, big, fading out to the right; a plain card for a map with none yet), a band with the map's name and
the players seated (`2/4`), a timer at the top right, and the orange **Join**; and at the right the yellow **Play
solo** with a square gear tile over it (since 2026-11-25, in the place of the blue **Local** and **Custom**), which opens **PLAY WITH FRIENDS** (`FriendsMatch`, `FRIENDS_GUI_NAME`): **Local** and **Custom**, each opening its setup as the board's buttons did. A card shows its mode's filling match on every server
(Matchmaking's frontier, read every `CARD_REFRESH_SECONDS`: its map, `players/size` and the countdown to its start),
or, while none fills, the rotation's map, `0/size` and the time until the next map. **Play solo** opens the setup in the board's place: the custom lobby's window, with the map, the bots'
difficulty (Easy, Medium, Hard), the diamonds a win pays and **Start**, a 1v1 against a bot. In a party the button reads **Play with party**: its leader sets up a friends-only deathmatch with bots
(`PARTY_BOTS_PER_PLAYER` per member) or with **No bots**, which pays half (MatchRewards).

**Public matches are global** (the owner, 2026-11-15). **Join** sends the player, with their whole party in this
server, straight to a match server (`Public`), into **the one match every server fills for that mode** (Matchmaking's
frontier, 2026-11-24): it claims seats there in one step, so a match never overfills. When the frontier is full,
closed or missing (or the group doesn't fit), it opens the next match on the card's map: first in the store, pending,
with the group seated, then as the mode's frontier in one step that only one lobby can win; a lobby that loses it
closes its own and joins the winner's, so two players pressing Join together land in one match. It tries `JOIN_TRIES`
rounds; with the store out of reach the group plays a match of its own, bots in the empty seats. The teleport card
goes up on the group's screens the moment Join is pressed (`I.Transition.Show`, `JOIN_SEARCH_KICKER` over
`JOIN_SEARCH_MESSAGE`, whipping through the rotation's maps for the card's size), so the press
shows while all this runs, and comes down if no teleport follows (`I.Transition.Hide`). The group that opened a match
goes to its new server at once; a group seated in a match another lobby just opened waits for that server (up to
`SERVER_WAIT_SECONDS`, the card showing the match's map under `JOIN_WAIT_MESSAGE`, "Match found") until it has written its
`AccessCode`, then follows. A teleport that fails, or a server that never comes, gives the seats back (and closes a
match the group opened). The metadata of a public match carries its mode's and map's names and the mode's icon
(`ModeName`, `MapName`, `ModeIcon`) for the match server's waiting room, since the match place doesn't load MatchBoard. **A card's map is the same on every server** for `MAP_SECONDS` (30, the owner, 2026-11-16):
`Rotation` works it out from the server clock, walking each mode through a shuffle of the rotation's maps for its
size, never the same map twice in a row, so nothing stores it and a Join never changes it. A new match opens on it:
the card sends the map it shows with its Join, and a Join less than `JOIN_GRACE` seconds after the cards moved on
still opens that map. A Join into the frontier plays the frontier's map, which the card shows while it fills. The
waiting room is on the match server (Match's `WaitingRoom`): bots fill the seats nobody took. A party leader joins for
the whole party, and only the leader picks the match: a party member's Join ("Host picks"), Play solo ("Waiting for
host") and Custom ("Host picks") are greyed out, and pressing one says "Your party's leader picks the match."
**Custom** makes a room that friends are invited into and its owner starts, its empty places filled with bots of the difficulty picked in its Bots row (`CUSTOM_DIFFICULTIES`: Off, Easy, Medium, Hard, and Nightmare, which plays only here), with wind or without (its WIND row, OFF until picked: the owner, 2026-11-24; public, solo, party and tutorial matches have no wind). Without bots it needs 2 or more players: Start with only the owner in it shows a message (`CUSTOM_ALONE_MESSAGE`, a WidgetManager message) and the server refuses it too; with bots its owner may start it alone. In a party only the leader makes one,
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
| Exposes | `I.MatchBoard` (server; on the client, `GetCustomRoom` and `GetPickedSize`) |
| Uses | `I.Matchmaking`, `I.Party`, `I.Teleport`, `I.TeleportToServer`, `I.Transition`, `I.Notify`, `I.Friends` (client), `I.WidgetManager`, `I.DoEvery`, `I.Console` (client: the pad's selection) |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Starts the four server handlers; the `I` table |
| `Scripts/Server/Rows.lua` | The board's rows (the public cards and custom rooms) as `Configuration`s; leaving a custom room; `GetGroup(player)`, the players who travel with a player (their party here, or just them) |
| `Scripts/Server/Public.lua` | The public cards: every `CARD_REFRESH_SECONDS` each card's live match from its mode's frontier (`LiveId`, `LiveMapId`, `LivePlayers`, `LiveEndsAt`); Join (claim seats in the frontier, or open the next match on the card's map, pending, and take the frontier for it; wait for a pending match's server before sending a seated group); `PlayAgain` |
| `Scripts/Server/Custom.lua` | Custom rooms: creating, inviting, answering, starting, leaving |
| `Scripts/Server/Launch.lua` | Teams, cards, metadata and the teleport to a new match server or an open one (`Send`; on the Studio map, `I.Match.Host`); solo and party matches |
| `Client.lua` | Starts the three client handlers; `I.MatchBoard` on the client (`GetCustomRoom`, `GetPickedSize`) |
| `Scripts/Helpers/Rotation.lua` | `MatchBoard_Rotation`, both sides: each public card's map from the server clock (`GetMap(mode, size, at?)`), the seconds until the next (`GetSecondsLeft`), the rotation's maps for a size (`GetPool`), and how many snails a solo or party match holds (`GetPlaySize(members, difficulty)`) |
| `Scripts/Client/Board.lua` | The `MatchBoard` board: Play solo (Play with party) with its mode icon (`MODE_ICONS` Bots or Party), the two centred on the button as one group from the text's `TextBounds` (`_centreSolo`, `SOLO_ICON_GAP`), JOIN ignoring presses within `JOIN_PRESS_GAP`, Custom, the public lobby cards with their mode's icon (each its live match's map, `players/size` and countdown from the card's `Live*` attributes, or the rotation's map, `0/size` and the time to the next map while none fills; redrawn every server second while the board shows, `TIMER_TICK`); slides away while the solo setup or the custom lobby's window shows; a party member's locked buttons. On a pad the selection rests on Play solo (`I.Console.SetHome`) |
| `Scripts/Client/Setup.lua` | The setup for a solo, party or local match, the `MatchSetup` widget (`SETUP_GUI_NAME`: the custom lobby's window and buttons since the owner's second look on 2026-11-17, its own widget since their third, so WidgetManager blurs and dims behind it as for the custom lobby; centred under the top bar while the board slides away), opened and closed through `I.WidgetManager`: the title with its mode icon (`MODE_ICONS` Bots, Party or Local), the map (`S_MapList`: Random, with the die, then the rotation's maps for the match's size), the bots, what a win pays, PLAY, and X back to the board; the picked choices are marked as the custom lobby's are (`Custom.SetPicked`) and START sends them. LOCAL (`S_Local`) opens it in its local form: "Local play", the players row (`S_PlayersRow`, 2 to `LOCAL_MAX_PLAYERS`), the wind (`S_WindBox`: `S_WindOff`, `S_WindOn`, OFF until picked, shown only for local play), OFF first in the bots, and "No rewards" in the reward line. PLAY SOLO alone shows only the difficulty (2026-11-25: the owner, "select random map and also we only have difficulty choice"): `S_DifficultyRow`, a card per `SOLO_DIFFICULTIES` cloned from `PREFAB | Difficulty` with its glyph (`DIFFICULTY_ICONS`), in place of the map list and the bots row, then the reward and PLAY; it always sends `"Random"` for the map. On a pad the window holds the selection while it's open, Start first, and B closes it (`I.Console.Focus`, on `WidgetManager_Opened`) |
| `Scripts/Client/Custom.lua` | The `CustomLobby` widget and room invites; closes the widget when the player's lobby closes without them leaving it. Registers `MatchBoard_RoomChanged` and publishes it on every refresh of the player's lobby, on a picked size or map, and when the window closes; lists its members, then open slots up to its `Size`; fades the player counts the picked map isn't made for, and moves the pick to the nearest one it is; the create step's wind (`S_WindOff`, `S_WindOn`, OFF until picked) goes with `MatchBoard_CreateCustom`, and the room's info line ends in "  |  Wind" when it's on; `SetPicked` marks a picked button or map card (the setup uses it too); `GetMyRoom` (`I.MatchBoard.GetCustomRoom`), `GetPickedSize` (the create step's size while the window shows it) |
| `Settings.lua` | `MatchBoard_Settings` |
| `_meta/_types.lua` | `MatchBoard_RowOption`, `MatchBoard_MapRow`, `MatchBoard_Row` (its `Wind`, false unless a custom room picked it) |

## API

### Server: `I.MatchBoard`

| Function | Returns | What it does |
| --- | --- | --- |
| `Launch(players, kind, mode, size, mapId, difficulty, tutorial?, wind?)` | `boolean` | Builds the teams and metadata (its `Wind` true only when `wind` is) and teleports the players. On the Studio map it starts the match on this server; on the Lobby map alone in Studio it only prints and notifies |
| `PlayAgain(player, kind, mode, difficulty)` | | Puts the player straight into another match like the one they were knocked out of (Lobby's Play again): a solo match at that difficulty, or Join on the public card of that mode |
| `GetMap(size: number, askedId: string?)` | `string` | The asked map when it's in `MAP_POOL` (the rotation) for that many snails, else a random one of those; any pool map when none is (solo and party matches) |

### Client: `I.MatchBoard`

| Function | Returns | What it does |
| --- | --- | --- |
| `GetCustomRoom()` | `Instance?` | The custom lobby the local player is in (its `Configuration`: `Players`, `Size`, `Owner`…), nil when in none or before the board has arrived |
| `GetPickedSize()` | `number?` | The player count picked on the custom lobby's create step while the window shows it and the player is in no lobby; nil otherwise (Party shows that many places) |

## Network

### Server

**Receive: RemoteEvents**

- `MatchBoard_Join @ (player: Player, rowId: string, shownMap: string?)`: a public card, and the map it showed (the one a new match opens on); leaders only, one Join at a time; the party must fit the mode (a party bigger than a team is split over teams)
- `MatchBoard_PlaySolo @ (player: Player, difficulty: string, mapId: string)`: refused in a party of 2 or more; `mapId` a rotation map for 2 or `"Random"`
- `MatchBoard_PlayLocal @ (player: Player, difficulty: string, mapId: string, players: number, wind: boolean)`: local play, 2 to `LOCAL_MAX_PLAYERS` players on the player's screen (refused in a party of 2 or more), a bot each at a difficulty or `"None"`, on a rotation map for that size or `"Random"`, with wind or without (the metadata's `Wind`)
- `MatchBoard_PlayParty @ (player: Player, difficulty: string, mapId: string)`: a difficulty or `"None"` (no bots); the leader of a party of 2 or more; `mapId` a rotation map for the match's size or `"Random"`
- `MatchBoard_CreateCustom @ (player: Player, mapId: string, mode: string, size: number, difficulty: string, wind: boolean)`: `size` 2, 4, 6 or 8 and one the map is made for (its `Sizes`); `difficulty` from `CUSTOM_DIFFICULTIES` (`"None"` for no bots); `wind` whether its match has wind (the row's `Wind`, sent on with its launch); not from a party member, and the party must fit
- `MatchBoard_InviteCustom @ (player: Player, target: Player)`
- `MatchBoard_InviteAnswer @ (player: Player, roomId: string, accept: boolean)`
- `MatchBoard_StartCustom @ (player: Player)`: the owner, with 2 or more players, or alone with bots; a Teams lobby without bots needs a player from outside the owner's party
- `MatchBoard_LeaveCustom @ (player: Player)`

**Send: RemoteEvents**

- `MatchBoard_Invited @ (fromUserId: number, roomId: string)`: to an invited player

### Client

**Topics**

- `MatchBoard_RoomChanged @ ()`: the player's custom lobby changed (joined, left, someone came or went, or it closed), or its create step's size or map was picked, or the window closed; the lobby's stage and Party redraw from `I.MatchBoard.GetCustomRoom` and `GetPickedSize`

## Data

Rows are `Configuration`s in `ReplicatedStorage.Ume.MatchBoard`, one per row, with the attributes `Kind`, `Mode`,
`Size`, `MapId` (`""` on a public card, whose map is the rotation's), `Difficulty` (the bots: `PUBLIC_DIFFICULTY`, or
a custom room's pick), `Wind` (whether its match has wind: false on a public card, a custom room's pick), `Players` (JSON list of user ids, custom rooms) and `Owner` (custom rooms). A public card also
carries its mode's filling match, written every `CARD_REFRESH_SECONDS` from Matchmaking's frontier (2026-11-24):
`LiveId` (`""` while none fills), `LiveMapId`, `LivePlayers` (the seats taken) and `LiveEndsAt` (`os.time()` when it
starts). The match metadata it sends is `Match_Metadata` (Match's types). On the client, Join, Solo and Custom
keep the design's look in `Look_MainColor`, `Look_StrokeColor`, `Look_TextColor`, `Look_HoverScale` and
`Look_ClickScale` attributes the first time they're locked. The setup's and the custom lobby's maps, modes, player counts and bots carry the design's picked
and unpicked looks as `Look_Selected*` and `Look_*` attributes (outline colour and, where sizes match, its pictures;
text colour), which the picked one swaps to.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `TELEPORT_GUI` | `"TeleportGui"` | The teleport screen. Matches teleport to the place loader config's `MatchPlaceId`, the Arena of the experience the lobby runs in (dev or main) |
| `STUDIO_MAP` | `"Studio"` | The map where matches start on the lobby's own server |
| `PUBLIC_ROWS` | Deathmatch 4, Duo 4, Trio 6 | The public cards, one per mode and size, always on the board; Quads 8 left on 2026-11-24 (the owner: "we want only 3 segments") |
| `TEAM_SIZES`, `MODE_NAMES` | | Players per team by mode; mode names on the cards (Deathmatch, Duo, Trio, Quads, Teams) |
| `MODE_ICONS` | Deathmatch, Duo, Trio, Quads, Bots, Party, Local | The mode icons that change with the board: each public card's by its mode, and Play solo's and the setup title's by the match it sets up. Since 2026-11-24 the white ink-outlined glyphs (`art/ui_glyphs`): `deathmatch`, `duo`, `trio`, `play` for Bots and Party, `local` for Local; Quads keeps its `art/modes` icon (uploaded 2026-11-17). LOCAL, CUSTOM, the custom lobby's title and the Random map card carry theirs in the gui |
| `PUBLIC_DIFFICULTY` | `"Medium"` | Bots that fill public matches |
| `CARD_REFRESH_SECONDS` | `3` | How often the server reads every mode's frontier for the cards (the owner, 2026-11-24: "it updates every 3 seconds or so") |
| `JOIN_TRIES` | `3` | The most rounds a Join tries (the frontier, or opening the next match) before it gives the group a match of its own |
| `SERVER_BOOT_SECONDS`, `WAITING_SECONDS`, `PENDING_SECONDS` | `12`, `30`, `45` | A match a lobby opens starts `SERVER_BOOT_SECONDS` plus `WAITING_SECONDS` later, and stays in the store `PENDING_SECONDS` while its server boots. `WAITING_SECONDS` copies Match's (the lobby place doesn't load Match): change both together |
| `JOIN_SEARCH_KICKER`, `JOIN_SEARCH_MESSAGE` | "Public match", "Finding a match" | The teleport card's line and title, up the moment Join is pressed |
| `SERVER_WAIT_SECONDS`, `SERVER_WAIT_POLL`, `JOIN_WAIT_MESSAGE` | `25`, `0.5`, "Match found" | A group seated in a match another lobby just opened waits this long at most for its server, looking this often, the card saying this over the map's name |
| `DESTINATION_KICKER`, `DESTINATION_DETAIL` | "Heading to", "%d snails" | The teleport card's line over a match's map, and how it says the match's size (`Launch.GetDestination`) |
| `MAP_SECONDS` | `30` | How long each public card keeps its map, the same on every server |
| `JOIN_GRACE` | `2` | A Join this many seconds after the cards moved on still plays the map the player's card showed |
| `TIMER_TICK` | `0.2` | How often the board checks whether the server clock reached another second |
| `JOIN_FAILED_MESSAGE` | "Couldn't find a match. Try again!" | What a Join says when the matches couldn't be reached, or the server it waited for never came |
| `JOIN_PRESS_GAP` | `1` | A JOIN pressed again within this many seconds sends nothing (the server takes 2 a second and warns past that) |
| `SOLO_ICON_GAP` | `0.25` | PLAY SOLO's icon and text are centred on the button as one group, the text this share of the icon's width after it |
| `MAPS`, `MAP_POOL`, `CUSTOM_MAP_POOL` | 12 map rows; `{ "EchoCaverns", "Desert", "RollingPlains" }`; the same three (the owner, 2026-11-25: only three maps while the maps are tested) | Map names, sizes and pictures (`Thumbnail` for the lobby cards, `TileThumbnail` for the custom lobby's map tiles, cut to each one's shape: the game home's `assets/ui/map_thumbnails`; Mirage Mesa has the old Desert's card picture; Molten Spires and The Big Mashup have none, so their cards are plain; Training Meadow, the tutorial's map, shows Picnic Plains' until it has its own and is in neither pool). `MAP_POOL` is the rotation new public matches, Solo and Party pick from, by `Sizes` (Picnic Plains 6/8, Desert 2/4/6, Fluffy Fallout 2/4/6, Rolling Plains 2/4, Echo Caverns 2/4/6/8, Volcano Isle 2/4/6); `CUSTOM_MAP_POOL` is what a custom lobby lists and allows, the custom-only maps last |
| `SOLO_DIFFICULTIES` | Easy, Medium, Hard | The bots' difficulties in the setup (a party also gets No bots) |
| `DIFFICULTY_ICONS` | Easy, Medium, Hard | Solo's difficulty cards' glyphs (`art/ui_glyphs`, uploaded 2026-11-25): a smile, a frown, a skull |
| `DIFFICULTY_COLORS`, `DIFFICULTY_GLYPH_TINT` | green (110, 220, 110), amber (255, 190, 70), red (255, 85, 80); `0.45` | Each difficulty card's colour, played subtly: the wash from its bottom, its glyph tinted this far from white, and the picked card's outline and name |
| `CUSTOM_DIFFICULTIES` | None, Easy, Medium, Hard, Nightmare | The custom lobby's Bots row; Nightmare is only here |
| `CUSTOM_ALONE_MESSAGE` | "You can't start a custom lobby by yourself. Invite a player or turn bots on!" | What Start says with only the owner in the lobby and no bots |
| `CUSTOM_OPEN_SLOT_TEXT`, `CUSTOM_OPEN_SLOT_TRANSPARENCY` | `"Open slot"`, `0.5` | A free place in the lobby's member list (one per place up to its size): its name line, faded this much, no avatar or username |
| `REWARD_TEXT`, `SOLO_WIN_DIAMONDS` | | What the setup's reward line says for a solo match ("Win reward", beside the diamonds), a party match ("Pays diamonds like a public match"), a party match without bots ("Pays half the diamonds of a public match") and local play ("No rewards"); the diamonds a solo win pays by difficulty (20, 30, 40: MatchRewards' `SOLO_DIAMONDS`, which pays them) |
| `PARTY_BOTS_PER_PLAYER`, `PARTY_MAX_SIZE` | `1`, `8` | Bots per member in a party match with bots, and its most snails |
| `LOCAL_PLAYERS`, `LOCAL_MAX_PLAYERS`, `LOCAL_GUEST_NAME` | `2`, `8`, `"Player %d"` | Local play: the players' count it starts at and its most, and what each guest's snail is called |
| `BOARD_GUI_NAME`, `CUSTOM_GUI_NAME`, `SETUP_GUI_NAME`, `FRIENDS_GUI_NAME` | MatchBoard, CustomLobby, MatchSetup, FriendsMatch | The guis: the board, the two widgets that take its place, and PLAY WITH FRIENDS (its gear tile's window, holding LOCAL and CUSTOM) |
| `LOCKED_MAIN_COLOR`, `LOCKED_STROKE_COLOR`, `LOCKED_TEXT_COLOR` | `(70, 70, 80)`, `(130, 130, 130)`, `(153, 153, 153)` | A party member's Join, Play solo and Custom while their leader picks the match: the face, its outline, the text |
