---
title: "Blast craters are stepped like voxels on the 1-stud grid"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Architecture", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Carver.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Props.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
---

**What changed.** Blasts used to cut smooth, round craters (a CSG cylinder). Now a crater is stepped like voxels:
a blast removes every 1-stud square of the map whose center is within its radius, so its edge is a staircase of
whole studs lined up with the maps' grid. Trees, bushes and rocks are cut by the same stepped shape. Blast radii and
damage are unchanged; a crater can reach up to half a stud past the radius at its edge.

**Where.** `Carver.BuildCutter(center, radius, z, depth)` builds one box per row of squares; `Carver.Carve` and
`Props._cut` subtract those boxes with `GeometryService:SubtractAsync` (still CSG, still `SplitApart`). The square
size is `CARVE_CELL` (1 stud) in Arena's `Settings.lua`. `Arena.Carve` refreshes the liquid half a square past the
radius. The terrain is still the maps' long parts; only the cut is stepped.

**How to check.** In a match, or with `/arena carve -75 18 6` in the command bar on Picnic Plains: the crater's
walls and floor step in 1-stud stairs, with studs lined up on the cut faces. Tested in Studio with radii 3, 6, 9
and 14 and bots' shots: no warnings, no slivers, debris lands as before.

**For the wiki.** Architecture's terrain section still describes the old grid plan (greedy-meshed chunks, "bedrock
stays"): craters now look like its "clears every cell whose center is within its radius", but done by CSG on authored
parts. Match modules' Arena line ("cuts a round hole") should say stepped. A note on the player's guide that
craters are blocky, if any page shows a crater.
