---
title: "Sudden death after 10 rounds: the liquid rises 2 studs every turn"
date: 2026-11-07
status: open
kind: changed
pages: ["Match modes & maps", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
---

**What changed.** Back to the studio's wiki ("After 10 rounds, sudden death starts: the water rises every turn").
Before: from round 4 the liquid rose half a stud a turn, and from round 8 two studs a turn. Now nothing rises for 10
full rounds; from round 11 the map's liquid (the sea on Picnic Plains, the lava on Desert) rises 2 studs (4 half-stud
rows) at the start of every turn.

**Where.** Match's `SUDDEN_DEATH_ROUND` 11 and `SUDDEN_DEATH_RISE` 4; `SUDDEN_DEATH_FAST_ROUND` and
`SUDDEN_DEATH_FAST_RISE` are gone. `Turns.RunTurn` calls `I.Arena.RaiseLiquid(SUDDEN_DEATH_RISE)`; the match attribute
`SuddenDeath` turns true at round 11.

**How to check.** In a long match the sea stays put through round 10 and hops up four rows at each turn from round 11.
Checked 2026-11-07 in a Studio match: `SuddenDeath` was still false at round 6 (it turned true at round 4 before). Round 11 itself wasn't reached.

**For the wiki.** Match modes & maps → Sudden death: after 10 rounds, 2 studs every turn; the sudden-death-start
question's answer goes back to the studio's original. Match modules: the two settings.

Supersedes 2026-11-05-sudden-death-earlier (none of it still holds).
