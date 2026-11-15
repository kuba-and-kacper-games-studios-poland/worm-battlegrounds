---
title: "Picnic Plains: the right end is a smooth cliff, not a straight wall"
date: 2026-11-15
status: open
kind: changed
pages: ["Picnic Plains", "Architecture"]
files: []
---

**What changed.** The right island's end was a straight wall cut at the map's edge (x 190). Now it's a cliff. It
rises from the sea at x 184 and leans back a stud every few rows to x 175 at Y 26, where the top rounds over. The
island now ends at x 184 (was 190), and grass grows on the cliff's ledges. Nothing else on the map changed. The
owner asked for it ("right side is straight wall, make it more smooth or look like a cliff edge").

- **Land:** 1,093 parts (was 1,098): 1,041 MapLab stud parts and the 52 stalactites and stalagmites
  (`Terrain/Speleothems`, carried over as built).
- **Backdrop:** 90 parts.
- **Bedrock:** each island's `DarkStone` bedrock, Y 4 to 8, has `Arena_Indestructible` (8, 15 and 10 parts).
- **Ledges:** the four ledges keep `Arena_Floats`.
- **Markers:** `Sea` (`Water`, Y −8 to 6.5); the pond as eight rows, `Pond_1`–`8` (Y 12 to 20); `Bounds` 380 × 114.
- **Props:** the same 49, plus the five clouds. Three props moved by hand at the new edge: the oak 5 studs in, the
  fern from x 186 (its land is gone) to x 162, and a flower beside the rock.

**Where.** `Workspace.Ume.ServerStorage_Assets.Arenas.PicnicPlains` (slot 1, MapLab 0.11.0). The template before is
`MapLab._Iterations.PicnicPlains_arena_5`. MapLab files are in the game home's `assets/models/maps/picnic_plains/`:
`source/reshape.py`, whose `FACE` table gives the cliff's profile.

**How to check.** `Kit.validate` reports only the errors the build had before: the stalactites are off the grid, two
lilies stand on the pond, not on land, and one flower's leaves z-fight. A Studio playtest of `Arena.Load("PicnicPlains")`
loads with no warnings and finds 8 land spots.

**For the wiki.** Picnic Plains: the east end is a cliff down to the sea, and the east island runs from x 100 to 184.
The lobby card picture still shows the old end.

Supersedes the right end in 2026-11-15-picnic-plains-wider; the rest of that entry still holds.
