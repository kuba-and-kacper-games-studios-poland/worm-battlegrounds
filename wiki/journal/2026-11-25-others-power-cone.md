---
title: "Other snails' power shows as the cone of circles again"
date: 2026-11-25
status: dropped
kind: changed
pages: ["Aiming", "Match HUD"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
---

**What changed.** Since the drag-and-FIRE aim (2026-11-24), another snail's aim showed only its crosshair; the owner:
"without the bar it feels empty". On other snails' turns (players' and bots') their power shows again as the old cone:
14 circles from the snail toward its crosshair, growing from small to big and yellow to red, each one appearing as the
power passes it. The player's own aim stays as it was (crosshair, ring, readout, preview dots).

**Where.** Aim's `_buildLook` (the circles, from the gui's `PREFAB | PowerDot`, back) and `_drawPower`, called from
`_watchStep`; Settings' `POWER_DOTS` (14) and `POWER_DOT_SIZE` (0.8 to 2 units, smaller than the old 0.9 to 2.3 so
they stop short of the crosshair).

**How to check.** Watch a bot aim: the cone grows from it to its crosshair. Checked in a Studio play test on
2026-11-25.

**For the wiki.** Aiming: what you see while others aim. Supersedes the "no cone" part of the 2026-11-24 aim entry
for other players' screens only.

**Dropped.** Replaced the same day by the power wedge on every aim (2026-11-25-aim-power-wedge): the owner asked for ShellShock Live's triangle instead of the circles.
