---
title: "Active lobbies' timers always run (30 s), then start, reset and change map"
date: 2026-11-09
status: open
kind: changed
pages: ["Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Rows.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Server/Launch.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
---

**What changed.** Every public row on the lobby's ACTIVE LOBBIES board counts down all the time, players or not,
instead of waiting for its first player. At 0 the row starts with whoever joined (bots fill the empty seats) and a
fresh row of the same mode takes its place on a different map, with its timer back at 30; an empty row just resets
to a new map. Joining a row no longer restarts its timer, so a player who joins late waits only what's left.

**Where.** `ROW_SECONDS` (30) in MatchBoard's Settings; a public row's `EndsAt` is set when the row is made
(`Rows.AddRow`) and never cleared; `Rows._checkTimers` starts any public row at 0; `Launch.GetMap(size, avoid)` skips
the map the row just had while another fits.

**How to check.** In Studio with nobody joined, all four public rows reach 0 together and come back as new rows
(new ids) on other maps at 0:29; a player who joined a row is in the match (`InMatch` true) when it hits 0.

**For the wiki.** Lobby: the timer line ("starts when the first player joins") becomes "always runs; at 0 the match
starts and the row resets on another map".

**From.** The owner's note (2026-11-09): "make that the timers always go, and if they end they'll move players then
reset and change map, so the game looks active and the maps reset".
