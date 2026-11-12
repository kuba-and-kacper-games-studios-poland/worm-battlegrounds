---
title: "The power cone is one smooth yellow-to-red shape"
date: 2026-11-12
status: open
kind: changed
pages: ["Match screen", "Aiming"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** The circles that grow along the aim while a shot charges (the Bazooka's, and every weapon with
power) were flat colours from dark red at the snail to pale yellow at the tip, which looked dark and patchy. They now
run bright yellow at the snail through orange to red at full power, and blend into one seamless shape: each circle's
gradient carries the cone's colours from its back edge to its front, turned along the aim, with no outlines. Their
number, sizes and where they sit are unchanged.

**Where.** MatchHud's `POWER_COLORS` (255, 226, 92), (255, 148, 38), (240, 62, 46); the `PREFAB | PowerDot` in the
MatchHud gui (white, `UICorner`, a `UIGradient`); Aim's `_buildLook` (each circle's gradient colours) and `_draw`
(the gradient's `Rotation` along the aim each frame).

**How to check.** Hold to charge the Bazooka: a smooth cone from yellow to orange grows toward the crosshair, red at
full power.

**For the wiki.** Aiming (or the Match screen): how the power cone looks.
