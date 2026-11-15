# Matchmaking

The open public matches of every server in the experience, kept in a MemoryStore sorted map per mode, so a lobby
server's Join can put a player and their party in a match another lobby server opened. A match's own server owns its
entry: it puts it in the store when its waiting room opens (`Open`), keeps it there (`Refresh`, which also reads the
seats lobbies claimed since) and closes it when the match starts (`Close`). Lobby servers only read the open matches
(`GetOpen`) and claim or give back seats (`Claim`, `Release`).

**No match ever gets more players than its size.** Every change to a match is one MemoryStore `UpdateAsync`, which
no other server can come between: a claim checks the match is still open, has a free seat for each player in the
group and doesn't seat any of them already, and takes the seats in the same step; closing is one such step too, so the
roster it closes with is final and no claim lands after it. A claim that loses a race to another server's claim, or to
the close, changes nothing and the lobby tries the next match. The match server checks again on its side (its waiting
room sends back anyone who arrives without a seat, Match's `Roster.Build` never seats more than the size).

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
| `Server.lua` | The store (MemoryStore, or the Studio store), the claim, release, open, refresh and close steps, seating a group on teams, the card |
| `ServerSettings.lua` | `Matchmaking_Settings`, under a server name |
| `_meta/_types.lua` | `Matchmaking_Card`, `Matchmaking_Lobby`, `Matchmaking_LocalEntry` |

## API

### Server: `I.Matchmaking`

| Function | Returns | What it does |
| --- | --- | --- |
| `Claim(mode, lobbyId, group: { Match_RosterEntry })` | `Matchmaking_Lobby?` | Seats a group (each entry its `UserId`, `PartyId`, `Card`) in an open match in one step: refused when the match closed, starts within `MIN_SECONDS_LEFT`, lacks a seat for each, or seats one of them already. The match as stored after, or nil |
| `Release(mode, lobbyId, userIds: { number })` | | Gives back seats (a failed teleport, a player who left the waiting room); a closed match keeps them |
| `Open(lobby: Matchmaking_Lobby)` | `boolean` | The match server puts its match in the store, open; whether it's in |
| `Refresh(lobby)` | `Matchmaking_Lobby?` | Keeps the match in the store (`OPEN_SECONDS`) and returns it as stored, with every seat claimed since; puts it back from the server's copy when the store lost it. Nil when the store can't be reached |
| `Close(lobby)` | `Matchmaking_Lobby?` | Closes the match to joins in one step and returns it as it closed: its roster is final. It stays `CLOSED_SECONDS`, closed |
| `GetOpen(mode)` | `{ Matchmaking_Lobby }` | The mode's matches still taking joins, from every server; empty when the store can't be reached |
| `GetCard(player)` | `Matchmaking_Card` | What the player takes into a match: display name, VIP, level, loadout (`I.Loadout.GetMatchLoadout`) and outfit |
| `GetFit(lobby, groupSize)` | `number`, `boolean` | The match's free seats, and whether a group of that size would sit on one team (always true for a group bigger than a team) |
| `Seat(roster, group, teamSize, size)` | `{ Match_RosterEntry }?` | The group's entries with their teams: all on the team with the most room, a member spilling onto the next roomiest once it's full; nil when the match has fewer free seats than the group. MatchBoard's `Launch` seats its rosters with it too |

## Network

No remotes or Topics. Servers share the matches through MemoryStore; a match's server shows its own seats to its
players (Match's `Room` attribute).

## Data

| Where | Key | What |
| --- | --- | --- |
| MemoryStore sorted map `STORE_NAME` + mode | the match's `LobbyId` | `Matchmaking_Lobby`: `Id`, `AccessCode` (its reserved server), `Open`, `EndsAt` (`os.time()` when its waiting room ends), `Mode`, `Size`, `TeamSize`, `MapId`, `Roster` (each seat's `UserId`, `Team`, `PartyId`, `Card`). Expires `OPEN_SECONDS` after its server last refreshed it, or `CLOSED_SECONDS` after it closed |

## Settings

`ServerSettings.lua` (clients never get it):

| Key | Default | What |
| --- | --- | --- |
| `STORE_NAME` | `"PublicLobbies_1_"` | The sorted maps' name before the mode; a new name starts over with an empty store |
| `OPEN_SECONDS` | `30` | How long an open match stays in the store without a refresh, so a server that stopped drops out |
| `CLOSED_SECONDS` | `30` | How long a started match stays in the store, closed |
| `LIST_COUNT` | `100` | The most matches read for a mode |
| `RETRIES`, `RETRY_DELAY` | `3`, `0.5` | Tries of a store call that failed, and the wait before the next (times the try) |
| `MIN_SECONDS_LEFT` | `5` | A match this close to its start takes no more joins (they'd land after it started) |
