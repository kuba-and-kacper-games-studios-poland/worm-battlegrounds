---
title: "Homing missile target: its own lock-on mark, bigger"
date: 2026-11-25
status: open
kind: changed
pages: ["Homing missile", "Aiming"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** The homing missile's placed target was a red copy of the aim crosshair, easy to mistake for it. The
owner: "a bit different so player knows its a homming missle target - also a bit bigger", then "polish the icon a bit
more - it looks like placeholder". It's now a lock-on mark: a red ring over a soft glow, a lit red dot in the middle,
and four red corner brackets outlined in ink. It's 3.6 units across (the crosshair is 2.6); the mark itself never
spins: its brackets turn slowly, snap in from 1.7 times their size as the target is placed, then breathe.

**Where.** The gui's `U_Aim` › `S_TargetMark` with `S_TargetBrackets`; Aim's `_drawTargetMark` and `_setTarget`
(`targetPlacedAt`); Settings' `TARGET_MARK_SIZE`, `TARGET_LOCK_SCALE`, `TARGET_LOCK_SECONDS`, `TARGET_MARK_PULSE`,
`TARGET_MARK_PULSE_SPEED`, `TARGET_BRACKET_SPIN`.

**How to check.** Hold the homing missile and click a target: the brackets close in on it and keep turning.
Captured in Studio on 2026-11-25; not yet fired in a play test with the new mark.

**For the wiki.** Homing missile: the target mark's look. Supersedes the "red copy of the crosshair" in the
2026-11-25 homing missile aim entry.
