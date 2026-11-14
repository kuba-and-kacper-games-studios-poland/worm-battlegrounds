---
title: "New map: Rolling Plains, a long grassy plain on rock, 406 studs wide"
date: 2026-11-14
status: open
kind: added
pages: ["Match modes & maps", "Rolling Plains", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
---

**What changed.** Rolling Plains (map id `RollingPlains`) is built and in the match rotation for 2, 4 and 6 snails.
It's the studio's "simple plain", which they built in Studio; the owner had no name for it, so Rolling Plains is a
working name. At 406 × 114 studs it's the widest map (the others are 200 to 296 wide). One island fills it from side
to side: a long grassy plain on solid rock with dark strata lines through it, a raised shoulder at each end (tops
about Y 31 on the left, 29 on the right) and a rock arch in the middle. The bottom 8 studs (Y −8 to 0) are bedrock.
There's no sea to fall into at the start: the sea's marker sits inside the rock, so the water only shows when sudden
death raises it. On the plain stand the studio's picnic set (a table, a blanket and a basket), an acacia, a log and
grass tufts, with oaks, bushes, rocks and a pine on the shoulders.

For now it borrows Picnic Plains' mood (the `Plains` lighting preset, pollen and leaves) and music, and Picnic
Plains' lobby card picture, until it has its own (`shortcut:` comments mark both).

**Where.** The arena template `Workspace.Ume.ServerStorage_Assets.Arenas.RollingPlains` (slot 7, at X 1000, Z −300
in Studio), made in MapLab from the studio's build (the game home's `assets/models/maps/rolling_plains/`, card
`asset.yaml`): `Terrain/Island_1`, 602 parts named `Grass`, `DarkGrass`, `Rock`, `Strata`, `Bedrock` (the 77
`Bedrock` parts, Y −8 to 0, carry `Arena_Indestructible`); no backdrop; 24 props in `Decor/Trees`, `Bushes`,
`Rocks`, `Picnic` (16 MapLab ones: 7 bushes, 4 oaks, 4 rocks, a pine; 8 the studio built, rebuilt part for part:
`PicnicTable`, `PicnicBlanket`, `Basket`, `Acacia`, `Log`, 3 `GrassTuft`). Markers `Sea` (`Water`, Y −8 to −4) and
`Bounds` (406 × 114 × 11). The land has the depth effect (1.0 stud over 4 levels, see
`2026-11-14-maps-depth-effect`). MatchBoard's `MAPS.RollingPlains` (`Thumbnail` Picnic Plains'
`rbxassetid://114380640476396`) and `MAP_POOL`; Atmosphere's `PROFILES.RollingPlains` (Picnic Plains' row). One of
the studio's picnic table planks was moved 0.03 studs inward: two of its faces were 0.02 studs apart and would
flicker.

**How to check.** In a Studio play test (2026-11-14) `I.Arena.Load("RollingPlains")` loads it at X 0 on the plane
with 602 terrain parts, its Bounds at 0, 49, 0, no water drawn, and no Arena warnings. Not played as a match yet:
nobody has dropped on it, shot on it or played sudden death on it.

**For the wiki.** Match modes & maps: Rolling Plains is built and in rotation (sizes 2 · 4 · 6; "a long grassy plain
with a rock arch, a picnic in the middle"). A page of its own, Rolling Plains, like the other maps': the plain, the
shoulders, the arch, no sea until sudden death, the widest map. Architecture: slot 7. Still to come: its own lobby
card picture, mood and music, and maybe its final name.
