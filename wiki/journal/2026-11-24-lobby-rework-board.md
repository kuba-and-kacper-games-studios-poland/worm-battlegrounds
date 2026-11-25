---
title: "Lobby board in the LobbyRework look: PUBLIC MATCHES, 3 cards with player counts, PLAY SOLO"
date: 2026-11-24
status: open
kind: changed
pages: ["Lobby", "Match modes & maps", "Solo vs bots", "Matchmaking"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Public.lua
---

**What changed.** The board along the bottom of the lobby is the studio's new `LobbyRework` design. The header reads
PUBLIC MATCHES (was ACTIVE LOBBIES). There are three public cards, Deathmatch (4), Duo (4) and Trio (6); Quads (8) is
gone (the owner: "we want only 3 segments"). Each card shows the mode and its icon over the map's picture, a dark band
with the map's name and the players seated ("2/4"), a timer at the top right and an orange JOIN. The count is back
(it was hidden on 2026-11-15): a card shows the match filling for its mode on every server, its map, players seated
and countdown to its start, or, while none fills, the rotation's map, 0/size and the time to the next map. The yellow
button reads PLAY SOLO (was SOLO VS BOTS; "Play with party" in a party, "Waiting for host" for a member), with LOCAL
and CUSTOM in light blue over it. Each button's outline is drawn as eight ink copies of its fill around it (the
design's outline pictures were cut off).

**Where.** `PUBLIC_ROWS` in MatchBoard's `Settings.lua`; the card's `S_Players` in the MatchBoard gui; the server
writes `LiveId`, `LiveMapId`, `LivePlayers`, `LiveEndsAt` on each public card's Configuration every
`CARD_REFRESH_SECONDS` (3) from Matchmaking's frontier (`Public._refreshCards`); `Board._refresh` draws them. "Play
solo" is written by `Board.lua`.

**How to check.** In the lobby: three cards, PUBLIC MATCHES, PLAY SOLO. Press JOIN on Duo in one server and watch
the Duo card on another lobby server read 1/4 within about 3 s.

**For the wiki.** Lobby: the new board (screenshot), the three modes, the player counts and what the timer counts.
Match modes & maps: Quads is no longer a public mode (it stays in the game's modes and icons). Solo vs bots: the
button is PLAY SOLO now.

Supersedes the "no player count" part of 2026-11-15's minimal card; the timer of 2026-11-16 still holds.
