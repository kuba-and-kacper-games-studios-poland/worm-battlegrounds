---
title: "Map rotation cut to six maps; Mirage Mesa, Lakeside Showdown and Rockslide Ridge custom-only"
date: 2026-11-15
status: open
kind: changed
pages: ["Matchmaking", "Picnic Plains", "Desert", "Fluffy Fallout", "Rolling Plains", "Echo Caverns", "Volcano Isle", "Mirage Mesa", "Lakeside Showdown", "Rockslide Ridge"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Custom.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Custom.lua
---

**What changed.** The owner: "leave only in the game rotation, for active lobbies maps and solo vs bots these
maps … rest of them will only be available in the custom matches". The public rows, Solo vs bots and Party matches
now pick only from six maps, each for these match sizes (snails in the match):

| Map | Sizes before | Sizes now |
| --- | --- | --- |
| Picnic Plains | 2/4/6 | 6/8 |
| Desert | 2/4/6 | 2/4/6 |
| Fluffy Fallout | 2/4/6 | 2/4/6 |
| Rolling Plains | 2/4/6 | 2/4 |
| Echo Caverns | 2/4/6 | 2/4/6/8 |
| Volcano Isle | 2/4/6 | 2/4/6 |

So Solo (2) and Deathmatch and Duo rows (4) play Desert, Fluffy Fallout, Rolling Plains, Echo Caverns or Volcano Isle;
Trio rows (6) Picnic Plains, Desert, Fluffy Fallout, Echo Caverns or Volcano Isle; Quads rows (8) Picnic Plains or
Echo Caverns. Before, 8 had no map made for it and played on any map in the pool. Mirage Mesa, Lakeside Showdown and
Rockslide Ridge left the rotation but are still in the game: a custom lobby lists all nine, the rotation's six first.
Training Meadow stays the tutorial's map only.

**Where.** MatchBoard's `Settings.lua`: `MAPS[...].Sizes`, `MAP_POOL` (the rotation, read by `Launch.GetMap`) and
the new `CUSTOM_MAP_POOL` (the custom lobby's list and the server's check in `Scripts/Server/Custom.lua`). No
remotes or saved data changed.

**How to check.** Studio playtest: `I.MatchBoard.GetMap(size)` 300 times per size gave exactly the lists above for 2,
4, 6 and 8; `CUSTOM_MAP_POOL` has 9 maps. The custom window's list wasn't opened on screen.

**For the wiki.** Matchmaking: which maps each mode plays, and that custom lobbies have three more. Each map's page:
the sizes it plays, and "custom lobbies only" for Mirage Mesa, Lakeside Showdown and Rockslide Ridge.
