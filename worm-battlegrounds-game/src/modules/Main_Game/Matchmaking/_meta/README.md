# Matchmaking

The open public matches of every server in the experience, kept in a MemoryStore sorted map per mode, so a lobby
server's Join can put a player and their party in a match another lobby server opened. The lobby that opens a match
puts it in the store first, **pending** (no server or `AccessCode` yet, kept `seconds` while its server boots:
`Open(lobby, seconds)`); the match's own server then owns the entry: it opens it again once its waiting room is up
(`Open`, which keeps the seats lobbies claimed meanwhile), keeps it there (`Refresh`, which also reads the seats
claimed since) and closes it when the match starts (`Close`). Lobby servers claim or give back seats (`Claim`,
`Release`) and read one match (`Get`).

**Each mode fills one match at a time: its frontier** (2026-11-24). One more sorted map, `STORE_NAME` + `Frontier`,
holds one key per mode: the match every lobby's card for the mode shows and every Join seats players in
(`Matchmaking_Frontier`: `Id`, `MapId`, `Size`, `Players`, `EndsAt`). A Join claims in the frontier; when it's full,
closed, starting within `MIN_SECONDS_LEFT` or missing, the lobby opens the next match in the store (pending) and then
takes the frontier for it in one `UpdateAsync` (`TakeFrontier`), only while the frontier still holds the stale match
it found or nothing live. Of two lobbies opening a match at once only one takes it; the other closes its own and joins
the winner's. `Refresh`, and the lobby after each claim, bring the frontier's seats and start up to date (`TouchFrontier`),
and `Close` marks it full, so the next Join opens a new one. Before this, a Join that found no open match opened a new
server, and the match only reached the store when that server booted, so two players pressing Join a few seconds
apart each got a match of their own.

**No match ever gets more players than its size.** Every change to a match is one MemoryStore `UpdateAsync`, which
no other server can come between: a claim checks the match is still open, has a free seat for each player in the
group and doesn't seat any of them already, and takes the seats in the same step; closing is one such step too, so the
roster it closes with is final and no claim lands after it. A claim that loses a race to another server's claim, or to
the close, changes nothing, and the lobby opens the next match or joins whichever another lobby just opened. The match server checks again on its side (its waiting
room sends back anyone who arrives without a seat, Match's `Roster.Build` never seats more than the size). A match
opened again by its server keeps every seat claimed while it was pending, and starts no sooner than the lobby promised
(its `EndsAt`) nor sooner than `MIN_ROOM_SECONDS` after the server opened it, so players seated on the way still get in.

Each player's seat carries their **card** (`GetCard`: name, loadout, outfit), read in the lobby, so the match can
seat a player who is still teleporting or loading, and a bot plays for them until they're in (Match's `Connection`).

Studio never touches the live store: there the module keeps its own store on the server, with the same single steps
and JSON values, which the Studio map's lobby and match share.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/Matchmaking` |
| Runs on | Server · Lobby map, Match map, Studio map |
| Exposes | `I.Matchmaking` (server) |
| Uses | `MemoryStoreService`, `I.Loadout`, `I.Cosmetics`, `I.G_Cosmetics` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | The store (MemoryStore, or the Studio store), the claim, release, open, refresh and close steps, each mode's frontier, seating a group on teams, the card |
| `ServerSettings.lua` | `Matchmaking_Settings`, under a server name |
| `_meta/_types.lua` | `Matchmaking_Card`, `Matchmaking_Lobby`, `Matchmaking_Frontier`, `Matchmaking_LocalEntry` |

## API

### Server: `I.Matchmaking`

| Function | Returns | What it does |
| --- | --- | --- |
| `Claim(mode, lobbyId, group: { Match_RosterEntry })` | `Matchmaking_Lobby?` | Seats a group (each entry its `UserId`, `PartyId`, `Card`) in an open match in one step: refused when the match closed, starts within `MIN_SECONDS_LEFT`, lacks a seat for each, or seats one of them already. The match as stored after, or nil |
| `Release(mode, lobbyId, userIds: { number })` | | Gives back seats (a failed teleport, a player who left the waiting room); a closed match keeps them |
| `Open(lobby: Matchmaking_Lobby, seconds: number?)` | `Matchmaking_Lobby?` | Puts a public match in the store, open, for `seconds` (`OPEN_SECONDS` when nil): a lobby opens it pending, its server again once it's up. When it's there already, the seats claimed meanwhile are kept (the new entry's own seats added) and `EndsAt` becomes the later of the stored one and `MIN_ROOM_SECONDS` from now. The match as stored, or nil when the store can't be reached |
| `Refresh(lobby)` | `Matchmaking_Lobby?` | Keeps the match in the store (`OPEN_SECONDS`) and returns it as stored, with every seat claimed since; puts it back from the server's copy when the store lost it; brings the frontier up to date (`TouchFrontier`). Nil when the store can't be reached |
| `Close(lobby)` | `Matchmaking_Lobby?` | Closes the match to joins in one step and returns it as it closed: its roster is final. It stays `CLOSED_SECONDS`, closed, and its frontier is marked full |
| `TakeFrontier(lobby, staleId: string?)` | `boolean` | Makes a match already in the store its mode's frontier, in one step: only while the frontier is still `staleId` (the full, closed or missing match the caller found there), this match, or nothing live. False means another lobby just opened one, which the caller joins instead. The frontier stays until the match starts, plus `CLOSED_SECONDS` |
| `TouchFrontier(lobby, closed: boolean?)` | | Brings the mode's frontier up to date with its match (seats taken, `EndsAt`), or marks it full once the match closed (`closed`, or the match isn't `Open`); leaves it alone when the frontier is another match by now |
| `Get(mode, lobbyId)` | `Matchmaking_Lobby?` | One match as the store has it; nil when there's none or the store can't be reached (a group seated in a pending match polls it for its `AccessCode`) |
| `GetFrontier(mode)` | `Matchmaking_Frontier?`, `string?` | The mode's frontier while it's live (seats left, not starting within `MIN_SECONDS_LEFT`); nil when there's none or the store can't be reached, and then the second value is the id of one that isn't live any more, for `TakeFrontier` |
| `GetOpen(mode)` | `{ Matchmaking_Lobby }` | The mode's matches still taking joins, from every server; empty when the store can't be reached. Nothing calls it since 2026-11-24 (Join reads the frontier) |
| `GetCard(player)` | `Matchmaking_Card` | What the player takes into a match: display name, VIP, level, loadout (`I.Loadout.GetMatchLoadout`: the items, `ShinyItems`, `GoldenItems` and the looks they wear, `ItemLooks`) and outfit |
| `GetFit(lobby, groupSize)` | `number`, `boolean` | The match's free seats, and whether a group of that size would sit on one team (always true for a group bigger than a team). Nothing calls it since 2026-11-24 |
| `Seat(roster, group, teamSize, size)` | `{ Match_RosterEntry }?` | The group's entries with their teams: all on the team with the most room, a member spilling onto the next roomiest once it's full; nil when the match has fewer free seats than the group. MatchBoard's `Launch` seats its rosters with it too |

## Network

No remotes or Topics. Servers share the matches through MemoryStore; a match's server shows its own seats to its
players (Match's `Room` attribute).

## Data

| Where | Key | What |
| --- | --- | --- |
| MemoryStore sorted map `STORE_NAME` + mode | the match's `LobbyId` | `Matchmaking_Lobby`: `Id`, `AccessCode` (its reserved server; none while pending), `Open`, `EndsAt` (`os.time()` when its waiting room ends), `Mode`, `Size`, `TeamSize`, `MapId`, `Roster` (each seat's `UserId`, `Team`, `PartyId`, `Card`). Expires MatchBoard's `PENDING_SECONDS` after a lobby opened it pending, `OPEN_SECONDS` after its server last opened or refreshed it, or `CLOSED_SECONDS` after it closed |
| MemoryStore sorted map `STORE_NAME` + `Frontier` | the mode | `Matchmaking_Frontier`: the match the mode's cards show and Join fills: `Id`, `MapId`, `Size`, `Players` (its seats taken; `Size` once it closed), `EndsAt`. Expires `CLOSED_SECONDS` after its match starts |

## Settings

`ServerSettings.lua` (clients never get it):

| Key | Default | What |
| --- | --- | --- |
| `STORE_NAME` | `"PublicLobbies_1_"` | The sorted maps' name before the mode (and before `Frontier`); a new name starts over with an empty store |
| `OPEN_SECONDS` | `30` | How long an open match stays in the store without a refresh, so a server that stopped drops out |
| `MIN_ROOM_SECONDS` | `8` | The least time a match's waiting room stays open once its server opened it, so players still on their way get in |
| `CLOSED_SECONDS` | `30` | How long a started match stays in the store, closed |
| `LIST_COUNT` | `100` | The most matches read for a mode |
| `RETRIES`, `RETRY_DELAY` | `3`, `0.5` | Tries of a store call that failed, and the wait before the next (times the try) |
| `MIN_SECONDS_LEFT` | `5` | A match this close to its start takes no more joins (they'd land after it started), and its frontier isn't live |
