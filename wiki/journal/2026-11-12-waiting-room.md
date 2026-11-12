---
title: "The waiting room is the studio's MatchWaiting panel"
date: 2026-11-12
status: open
kind: changed
pages: ["Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Scripts/Client/Board.lua
---

**What changed.** After Join, the waiting room is the studio's `MatchWaiting` design (ported 1:1): the countdown,
one line with mode, map and players ("Trios  |  Desert  |  5 / 8 players"), the joined players (avatar, display name,
@username), VOTE TO START with the votes ("Vote to start 4/6") and LEAVE. It still hangs beside Party.

**Where.** `U_WaitingRoom` in the MatchBoard gui; `Board.lua` writes `S_Countdown`, `S_Info` and `S_Vote`'s `S_Text`.

**How to check.** Join a public row in the lobby: the panel shows the new look and the vote count.

**For the wiki.** Lobby: the waiting room's look and texts. Unsure: not seen in this playtest.
