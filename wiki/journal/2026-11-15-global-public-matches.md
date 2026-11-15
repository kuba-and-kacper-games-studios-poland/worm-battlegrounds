---
title: "Public matches are global: Join goes straight to a match server, which holds a 15 s waiting room"
date: 2026-11-15
status: open
kind: changed
pages: ["Architecture", "Lobby", "Matchmaking", "Party"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Matchmaking/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Matchmaking/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Public.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Launch.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Rows.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/WaitingRoom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Roster.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Connection.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Client/WaitingRoom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchWaiting/init.lua
---

**What changed.** The owner: "I want to make active lobbies global using memorystoreservice… when you click join, you
and your party will be moved to a new server, if the server is like for example duo and you have 4 people in party,
you all will be moved to a new server and play 2vs2, and if you are 2 in party, you'll be moved to a server where 2
slots are left… so there won't be instance of duo max 4 players will have more players". Before, each lobby server had
its own public rows with a 30 s timer, votes to start and a waiting room in the lobby; players only joined others in
the same lobby server. Now:

- **Join** (a public card) sends the player and their whole party in this server straight to a match server: the
  fullest open match of that mode on any server with a free seat for each of them, preferring one where the party sits
  on one team, or a new match on the card's map when none has room (a party of 4 in Duo gets a 2v2 of its own; a party
  bigger than the mode refuses with the usual message). Only the party leader can press it, one Join at a time.
- **The open matches live in MemoryStore,** a SortedMap per mode named `PublicLobbies_1_<Mode>` (Matchmaking's
  `STORE_NAME`), one entry per match keyed by its `LobbyId`: `Open`, `EndsAt`, `Mode`, `Size`, `TeamSize`, `MapId`,
  `AccessCode` and `Roster` (user id, team, party, card). Every seat is claimed in one `UpdateAsync` that checks the
  match is open, has `MIN_SECONDS_LEFT` (5) left, the player isn't seated already and there's a seat for each, so two
  lobby servers can't overfill a match. A failed teleport gives the seats back (`Release`). Entries live
  `OPEN_SECONDS` (30) while open and `CLOSED_SECONDS` (30) after; lists read `LIST_COUNT` (100); `RETRIES` 3 at
  `RETRY_DELAY` 0.5 s. Studio uses a JSON copy on the server instead (it never touches the live store).
- **The waiting room is on the match server** (Match's `WaitingRoom`, the new `MatchWaiting` gui at the bottom middle):
  "MATCH STARTS IN 0:15", the mode and seats ("DUO | 3 / 4 PLAYERS"), every seat (one still on the way reads
  "Joining…", one who pressed it READY in green), **Ready** ("Ready 1/2") and **Leave match**. It runs
  `WAITING_SECONDS` (15), or ends at once when everyone there has pressed Ready; then the match server closes its
  entry in one step (that roster is final) and bots fill every empty seat. It refreshes the entry every
  `ROOM_REFRESH_SECONDS` (2), frees the seat of anyone who left, and sends a player who arrived with no seat back to
  the lobby after `STRANGER_SECONDS` (6).
- **A card's map** is the map the player's Join would land on for their group size (the `Targets` attribute, read
  again every `TARGETS_SECONDS`, 3): an open match's map, or the card's own for a new match. If MemoryStore can't be
  reached, Join says `JOIN_FAILED_MESSAGE`, "Couldn't find a match. Try again!".

Remotes: `MatchBoard_Join (player, rowId)` stays (public cards only now); `Match_Ready` is new (the waiting room's
Ready, the client fires it, rate limit 2); `MatchBoard_Leave` and `MatchBoard_Vote` are gone, with MatchBoard's
`ROW_SECONDS` and `VOTE_FRACTION`. The match metadata carries `LobbyId`, and each roster seat a `Card`
(next entry). Workspace.Ume.Match attributes: `RoomEndsAt` (server time, while the room takes joins) and `Room` (JSON
of the seats: UserId, Name, Ready, Here). Custom lobbies, Solo and Party are unchanged.

**Where.** Matchmaking's `Claim`, `Release`, `Open`, `Refresh`, `Close`, `GetOpen`, `GetCard`, `GetFit`, `Seat`;
MatchBoard's `Public.Join` and `Launch.Send`; Match's `WaitingRoom.Run` and `Phases` (a public match runs the waiting
room instead of `Roster.WaitForPlayers`).

**How to check.** In Studio (the Studio map): Join on the Duo card opens the waiting room at the bottom middle with
the countdown; Ready starts the match with 3 bots. A Studio self-check of the store: a duplicate claim, an overfill,
a claim on a full match and one after close are all refused. Live: two lobby servers joining the same mode land in
the same match, and a Duo never holds more than 4.

**For the wiki.** Lobby / Matchmaking: Join is global, how a match is picked (fullest, party on one team, or new),
the waiting room on the match server (15 s, Ready, bots fill), no player count or timer on the cards. Party: the party
moves together, a party bigger than a team spills onto the next. Architecture: the MemoryStore map and its keys, the
waiting room, the remotes added and removed. Not tested yet on live servers (Studio can't run MemoryStore or teleports
between servers); the waiting room doesn't show the map's name.
