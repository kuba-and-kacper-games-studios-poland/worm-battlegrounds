---
title: "Lava colour 255, 81, 58 → 179, 89, 47 (#b3592f) on every map"
date: 2026-11-14
status: open
kind: changed
pages: ["Volcano Isle", "Desert", "Rockslide Ridge", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
---

**What changed.** All lava is one colour, 179, 89, 47 (#b3592f), the owner's pick. Before, Arena's default lava was
255, 96, 20 (Desert's lava used it) and Volcano Isle's lava sea, crater and chamber had their own 255, 81, 58.

**Where.** `LIQUID_COLORS.Lava` in Arena's `Settings.lua`. Volcano Isle's lava markers in the place
(`Arenas.VolcanoIsle.Markers.Sea`, `Crater`, `Chamber`) lost their `Arena_LiquidColor`, so they take Arena's; they
keep `Arena_LiquidNeon`. The place change is unsaved until the owner saves it.

**How to check.** `LIQUID_COLORS.Lava` is `Color3.fromRGB(179, 89, 47)`; no lava marker under `Arenas` has
`Arena_LiquidColor`. In game, Volcano Isle's neon lava renders much brighter than the hex (about #ffa016 in Studio's
light), Desert's stud lava shows it as it is.

**For the wiki.** Volcano Isle and Desert: the lava's colour, a History line. Architecture: lava has one colour, set in
Arena's settings; a marker's `Arena_LiquidColor` is still there for water (Rockslide Ridge's old sea). Rockslide
Ridge's lava sea (its redo, not exported yet) uses it too.
