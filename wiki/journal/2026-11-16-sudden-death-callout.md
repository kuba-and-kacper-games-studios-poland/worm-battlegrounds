---
title: "Sudden death announced: \"Water is rising...\" / \"Lava is rising...\" on the turn banner"
date: 2026-11-16
status: open
kind: added
pages: ["Turns", "Match HUD", "Water", "Lava"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/_meta/_types.lua
---

**What changed.** When sudden death starts (round 11), the turn's own banner plays first, then the same banner
announces the rising liquid: "Water is rising..." or "Lava is rising..." over "Sudden death!", with no avatar, its
lines in the liquid's colour (water blue 63, 166, 255; lava orange 255, 140, 20) and the title filling with that colour
from the bottom, for 2.4 s. Every sudden-death turn's line under the title (the first one too) then adds "The water
rises" or "The lava rises".

**Where.** The server writes `SeaKind` on `Workspace.Ume.Match` (`Arena.GetLiquidKind()`, `"Water"` when the map has
no sea) as each sudden-death turn starts, before `SuddenDeath`. MatchHud's `Turn._onSuddenDeath` and
`_getSuddenDeathLiquid`; settings `SUDDEN_DEATH_TITLE`, `SUDDEN_DEATH_SUB`, `SUDDEN_DEATH_REMINDER`,
`SUDDEN_DEATH_HOLD` (2.4), `SUDDEN_DEATH_FILL_FROM`, `SUDDEN_DEATH_FILL_TO`, `SUDDEN_DEATH_FILL_TWEENINFO` (1.6 s),
`SUDDEN_DEATH_LIQUIDS` (class `MatchHud_SuddenDeathLiquid`).

**How to check.** Admin `match round 11` (or play to round 11): after the turn banner, "Water is rising..." shows on a
water map, "Lava is rising..." on Volcano Isle; later turns' lines end in "The water rises". Not checked in Studio.

**For the wiki.** Turns (sudden death) and Match HUD (the turn banner): the announcement and the line on later turns.
