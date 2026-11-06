---
title: "Turn timer: blank while a shot flies, and it now counts on the active worm's tag too"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
---

**What changed.** Two timer bugs. The turn panel's timer read 0 while a shot flew and settled, which looked like
time running out; it's now blank between the shot and the next turn. The timer over the active worm's head never
counted: it always read 15. It now shows the same count as the panel, and is blank between turns too.

**Where.** `Turn._tick` (MatchHud): the count only during the `Turn` phase, else `""`, written to `U_Turn` ›
`S_Timer` and, through `Turn._setTagTimer`, to the active worm's `WormTag` › `S_Timer` (the worm from Match's
`ActiveId`). Whether both timers should stay is an open design question (the gui audit, 2026-11-05).

**How to check.** In a Studio match: panel and tag count 15 → 1 together, both go blank on Flight and Settle, and
the next worm's tag starts at 15. Checked over four turns.

**For the wiki.** Match screen → Whose turn: the timer shows over the active worm's head and in the top banner,
and pauses (blank) while a shot is in the air.

**Merged.** The tag half was undone by 2026-11-05-worm-tag-health-colours; only the blank timer while a shot flies went in. The tag timer is asked on Match screen (question tag-timer).
