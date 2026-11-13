---
title: "The camera looks further past the map's sides; the sea is drawn 120 studs out"
date: 2026-11-13
status: open
kind: changed
pages: ["Match screen", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
---

**What changed.** The view may go past each side of the map by half the view's width (`SIDE_EXTRA` 1), so a snail at the edge can sit mid-screen. The sea is drawn 120 studs past the sides (`SEA_EDGE_WIDTH`, was 50) to fill it.

**Where.** MatchCamera's `_getClamped`; Arena's `SEA_EDGE_WIDTH`.

**How to check.** Pan to a map's edge: the edge snail can be centred, and the sea runs on past it. A map's backdrop may now end in view; not yet checked in Studio.

**For the wiki.** Match screen (camera): how far it pans.

**From.** The testers: "you should be able to look way more left and right on the map, increase border".
