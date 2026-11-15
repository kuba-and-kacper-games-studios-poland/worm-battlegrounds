---
title: "Lobby cards: one map per mode on every server, 30 s each, with a timer"
date: 2026-11-16
status: open
kind: changed
pages: ["Matchmaking", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Helpers/Rotation.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Public.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Launch.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Rows.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
---

**What changed.** Each ACTIVE LOBBIES card (Deathmatch, Duo, Trio, Quads) now shows the same map on every lobby
server for 30 seconds (MatchBoard's `MAP_SECONDS`), then moves on, with a timer over Join counting down ("0:30" to
"0:01"). Before, each server picked its own map per card, and pressing Join on a card that opened a new match changed
that card's map at once; the card could also change when matches opened elsewhere.

The map comes from the server clock (`Rotation.GetMap(mode, size)`): each mode walks through a shuffle of the
rotation's maps for its size (`MAP_POOL`, e.g. Deathmatch 4 snails: Desert, Fluffy Fallout, Rolling Plains, Echo
Caverns, Volcano Isle), never the same map twice in a row. Join now joins only open matches on the card's map, or
opens a new one on it. The card sends the map it showed (`MatchBoard_Join` gained `shownMap`), and a press less than 2
seconds after the cards moved on (`JOIN_GRACE`) still gets that map. The `Targets` attribute and `TARGETS_SECONDS`
(the old per-card reads of the open matches every 3 s) are gone.

**How to check.** Checked in Studio on 2026-11-16: the four cards counted down from 0:29 to 0:01 and all changed map
together at 0:00; client and server worked out the same maps at the same moment; a Join pressed at 0:00 while the Duo
card still showed Volcano Isle opened the match on Volcano Isle, and the card then showed Echo Caverns. Not checked
across two live servers.

**For the wiki.** Matchmaking / Lobby: public cards keep one map for 30 s on every server, with a countdown; a Join
plays the map the card shows.
