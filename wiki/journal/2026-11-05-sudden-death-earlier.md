---
title: "Sudden death from round 4: water rises 0.5 studs a turn, 2 studs from round 8"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Match modes & maps", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
---

**What changed.** Sudden death used to start at round 10, the liquid rising 2 studs at the start of every turn. Now
it starts at round 4 (after three full rounds) with a small rise, half a stud (one liquid row) every turn, and from
round 8, when the match drags on, it rises 2 studs (four rows) every turn. The liquid is the map's first one: the
sea on Picnic Plains, the lava on Desert.

**Where.** Match's settings `SUDDEN_DEATH_ROUND` (4), `SUDDEN_DEATH_RISE` (1 row), `SUDDEN_DEATH_FAST_ROUND` (8) and
`SUDDEN_DEATH_FAST_RISE` (4 rows); `Turns.RunTurn` picks the rise from the match attribute `Round` and calls
`I.Arena.RaiseLiquid`. The match attribute `SuddenDeath` turns true at round 4.

**How to check.** In a 4-worm match, the sea stays put for rounds 1 to 3, hops up one row at each turn of rounds 4
to 7, then four rows a turn from round 8.

**For the wiki.** Match modes & maps → Sudden death: "After 10 rounds" becomes the two speeds above. Match modules:
the Settings line (`SUDDEN_DEATH_ROUND` 10, `SUDDEN_DEATH_RISE` 1) and the check line ("after round 10").

**From.** Match modes & maps → question sudden-death-start: the owner chose "after a few rounds, small rises, then
larger ones if the game drags". Its listed options didn't cover this; the round numbers are a first pick to tune.
