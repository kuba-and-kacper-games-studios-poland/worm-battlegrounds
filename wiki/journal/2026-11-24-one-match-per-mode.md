---
title: "Fixed: two players pressing JOIN together got separate matches (one filling match per mode)"
date: 2026-11-24
status: open
kind: fixed
pages: ["Matchmaking", "Lobby", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Matchmaking/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Matchmaking/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Public.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/WaitingRoom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
---

**What changed.** Before, a Join that found no open match opened a new server, and the match only appeared in the
MemoryStore when that server booted, so two players pressing JOIN within about 5 to 15 seconds each got their own
empty match. Now each mode fills one match at a time, its **frontier**, which every lobby server's card shows and
every Join seats players in. When it's full, closed or missing, the lobby puts the next match in the store first
(pending, its server not up yet) and then takes the frontier for it in one step; if another lobby got there first,
it closes its own and joins that one. A group seated in a match whose server is still booting waits for it ("Match
found! Joining...", up to 25 s), then teleports. A full room now starts 4 s after its last seat is taken.

**Where.** Matchmaking: the `Frontier` sorted map (`STORE_NAME` + "Frontier", one key per mode: `Id`, `MapId`,
`Size`, `Players`, `EndsAt`), new `I.Matchmaking.TakeFrontier`, `TouchFrontier`, `Get`, `GetFrontier`;
`Open(lobby, seconds?)` merges and returns the stored match; new `MIN_ROOM_SECONDS` 8. MatchBoard's `Public._join`,
`_sendNew`, `_sendSeated`, `_getNewLobby`; settings `JOIN_TRIES` 3, `SERVER_BOOT_SECONDS` 12, `PENDING_SECONDS` 45,
`SERVER_WAIT_SECONDS` 25, `SERVER_WAIT_POLL` 0.5, `JOIN_WAIT_MESSAGE`, `CARD_REFRESH_SECONDS` 3. Match's
`FULL_START_SECONDS` 4 (`WaitingRoom.Run`). No new remotes.

**How to check.** Checked in Studio: a Join made a frontier at 1/4 and the room; a second claim for the same mode
landed in the same match (2/4). Live: two players on two lobby servers press Duo's JOIN a few seconds apart and end
up in one match.

**For the wiki.** Matchmaking: how a Join picks its match (the frontier), the wait message, the 4 s full start.
Architecture: the MemoryStore maps.

Still unsure: the live path where a second player waits for a booting server can't run in Studio and is unchecked.
Supersedes the "fullest open match on the card's map" part of 2026-11-15's global public matches.
