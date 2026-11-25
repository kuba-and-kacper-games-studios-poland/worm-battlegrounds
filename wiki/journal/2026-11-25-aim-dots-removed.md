---
title: "Aim preview dots removed (tutorial path line stays)"
date: 2026-11-25
status: dropped
kind: removed
pages: ["Controls", "Tutorial"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** While aiming an arced weapon (or a homing missile's launch), no dots show the start of the path any
more: the owner, "the dots are making the game too easy". The player aims by the crosshair's distance from the snail
(the power) and the readout ("62% · 41°") alone. The tutorial match keeps its whole path line, and so does a player
with the admin aimbot.

**Where.** MatchHud's `Aim.lua`: `_drawPreview`, `_placePreviewDot`, `_hidePreview` and the preview's dots are gone,
and `_drawPrediction` (the tutorial's and the aimbot's line) is the only path drawn. Settings `PREVIEW_DOTS`,
`PREVIEW_SHARE`, `PREVIEW_STEPS`, `PREVIEW_SPACING`, `PREVIEW_DOT_SIZE`, `PREVIEW_TRANSPARENCY` removed. The MatchHud
gui still carries the unused `PREFAB | AimDot` template until its source drops it.

**How to check.** In a public or solo match, drag to aim a Grenade: the crosshair and readout show, no dots. In the
tutorial match, the gold path line still shows.

**For the wiki.** Controls / aiming: no aim preview; the tutorial shows the path once. Supersedes the dots part of
2026-11-25-aim-power-wedge (its power wedge stays) and the earlier preview-dot entries (short, smaller, closer dots).

**Undone the same evening.** The 24 Nov preview dots are back outside the tutorial (2026-11-25-aim-preview-back).
