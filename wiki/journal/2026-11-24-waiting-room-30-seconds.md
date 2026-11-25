---
title: "Public waiting room 15 → 30 seconds"
date: 2026-11-24
status: open
kind: changed
pages: ["Public matches"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
---

**What changed.** A public match's waiting room takes joins for 30 seconds before bots fill the empty seats, up from
15, so more real players find it (the owner, 2026-11-24, after a Play again landed in a match of bots). Everyone
voting to start, or every seat taken (`FULL_START_SECONDS`, 4), still starts it sooner.

**Where.** `WAITING_SECONDS` = 30 in Match's `Settings.lua` (the room) and MatchBoard's `Settings.lua` (the start a
lobby promises a match it opens: `SERVER_BOOT_SECONDS` + `WAITING_SECONDS`); the two are copies and change together.

**How to check.** A JOIN that opens a new match shows "Starts in 0:30" in the waiting room once its server is up
(a little less, as the start counts from the Join).

**For the wiki.** Public matches: the waiting room's time, 30 seconds.
