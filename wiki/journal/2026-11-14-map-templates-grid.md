---
title: "Map templates stand in a grid in Studio, four to a row; the Loader puts each on the plane"
date: 2026-11-14
status: open
kind: changed
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Loader.lua
---

**What changed.** In the place, the arena templates no longer stand in one line along +X, 400 studs apart (8 maps
would have run into MapLab's lab at X 2800). They stand in a grid, four to a row, 500 studs apart, each row 300 studs
behind the last (−Z), in slot order: Picnic Plains (X 0, Z 0), Desert (500, 0), Rockslide Ridge (1000, 0), Volcano
Isle (1500, 0); Training Meadow (0, −300), Lakeside Showdown (500, −300), Rolling Plains (1000, −300), Echo Caverns
(1500, −300). The owner asked for it: maps "better like 4 per row", nothing overlapping, nothing stacked high. Nothing
changes in play: every map still plays at X 0 on the plane at Z 0.

MapLab follows the same plan: the lab's builds in the same grid from X 3000, their old versions in a yard of their
own from X 5500 going back (−Z), four to a row, each map's together, newest first (`Kit.tidy`, map-kit 0.10.0), and
`_Study` at X 2400 between the game and the lab.

**Where.** The Arena's `Scripts/Server/Loader.lua`, `Module._cacheTemplates`: it moves every template so its Bounds
stand at X 0 and Z 0 when it caches it. Before, it moved the X only, and a template whose Bounds weren't at Z 0 was
moved back with a warning ("dragged off it in Studio"); that warning is gone, since templates in the grid's back rows
stand off the plane on purpose. Each template carries `MapLab_Slot` (its slot) and `MapLab_Version` (0.10.0).

**How to check.** In a Studio play test (2026-11-14) `I.Arena.Load` on each of the eight maps loads it with its
Bounds at X 0, Z 0 and no Arena warnings, the back row's maps too. The PC bot gym reads the templates from the saved
place through the same Loader, so it follows once the owner saves the place.

**For the wiki.** Architecture: where the templates stand in Studio (the grid, slot → X = column × 500,
Z = −row × 300), that the Loader puts each on the plane at X 0, Z 0, and MapLab's layout (lab, yard, study).
