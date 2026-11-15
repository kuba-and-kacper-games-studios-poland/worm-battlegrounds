---
title: "Rolling Plains: smoother ground and a cliff at the right end"
date: 2026-11-15
status: open
kind: changed
pages: ["Rolling Plains", "Architecture"]
files: []
---

**What changed.** The owner asked to "make it more smooth and maybe cliff from one side". Three changes:

- **Smoother ground.** The plain's top is smoothed: small bumps and one-stud steps are gone, and the rock arch in the
  middle is kept as it was.
- **A gentle left end.** The left shoulder eases down to the bedrock in one smooth curve.
- **A cliff at the right end.** It used to be a straight cut at the map's edge. Now it rises from x 123 at the
  bottom and leans back to x 112 at Y 24, where the top rounds over. The island now ends at x 123 from the middle
  (was 132), and grass grows on the cliff's ledges.

Grass stays on top with dark grass under it, and the new land is rock.

- **Land:** 509 parts (was 585), named `Grass`, `DarkGrass`, `Rock`, `Strata`, `Bedrock`. The bedrock, Y −8 to 0, has
  `Arena_Indestructible` (48 parts). No backdrop.
- **Markers:** `Sea` (`Water`, Y −8 to −4, still inside the rock) and `Bounds` 264 × 114.
- **Props:** the same 47, moved up or down with the ground under them, most by a stud or less. The grass on the old
  right edge moved 9 studs in.

**Where.** `Workspace.Ume.ServerStorage_Assets.Arenas.RollingPlains` (slot 7, MapLab 0.11.0). The template before is
`MapLab._Iterations.RollingPlains_arena_3`. MapLab files are in the game home's `assets/models/maps/rolling_plains/`:
`source/reshape.py` (`SMOOTH`, `SHOULDER`, `FACE`).

**How to check.** `Kit.validate` reports only one flower whose leaves z-fight, at x −97, as before. A Studio playtest
of `Arena.Load("RollingPlains")` loads with no warnings and finds 8 land spots.

**For the wiki.** Rolling Plains: smoother rolling ground, a cliff at the east end, and the island from x −132 to 123.
The lobby card picture still shows the old map.

Supersedes the land in 2026-11-15-rolling-plains-narrower; its size and props still hold.
