---
title: "Echo Caverns: a solid rock cliff on the left side"
date: 2026-11-15
status: open
kind: changed
pages: ["Echo Caverns", "Architecture"]
files: []
---

**What changed.** The left side used to be loose rocks against the back wall, cut off straight at the map's edge. The
owner asked to "update the cliff on the left side". Now a solid rock wall rises from the sea 4 studs in from the edge
(x −92). It has a smooth face that leans back to x −85 and a rounded top at Y 36 to 41, where the dome's slope starts.
The wall's top reaches across to the dome, so the dome stands on it. The back wall stops behind the cliff. The dome's
right rim steps were joined at their corners, so the map has no floating ledges (before the fix, two 4-stud scraps
would have floated).

- **Islands:** six, all standing on the bed. `Island_1` is the new cliff (x −92 to −65, top Y 41). `Island_3` is
  still the dome and the right wall (x −62 to 96, up to Y 81).
- **Land:** 773 parts (was 803). The bedrock, Y −8 to 0, has `Arena_Indestructible` (25 parts).
- **Backdrop:** 70 parts (was 80).
- **Markers:** `Sea` (`Water`, Y −8 to −2) and `Bounds` 192 × 114.
- **Props:** the same 21. A grass tuft and a rock pile whose rocks went now stand on the cliff's top (x −77 and −82,
  Y 37).

**Where.** `Workspace.Ume.ServerStorage_Assets.Arenas.EchoCaverns` (slot 8, MapLab 0.11.0). The template before is
`MapLab._Iterations.EchoCaverns_arena_3`. MapLab files are in the game home's `assets/models/maps/echo_caverns/`:
`source/reshape.py` (`FACE`, `THICK`, `JOIN`, `RIM`).

**How to check.** `Kit.validate` passes with no errors. A Studio playtest of `Arena.Load("EchoCaverns")` loads with no
warnings and finds 8 land spots.

**For the wiki.** Echo Caverns: a sheer rock cliff closes the west side. The lobby card picture still shows the old
side.

Supersedes the left side in 2026-11-15-echo-caverns-narrower; the rest of that entry still holds.
