---
title: "Rolling Plains: rolling hills behind it, and new props"
date: 2026-11-14
status: open
kind: changed
pages: ["Rolling Plains", "Architecture"]
files: []
---

**What changed.** Rolling Plains had no backdrop; now rolling hills stand far behind the plain (the owner: "add
backdrops"). They are five swells of different heights with a bumpy treeline, one muted green-grey colour
(`6f8f7a`), their tops at Y 44 to 57, well over the shoulders (Y 32), easing down over the last 30 studs at each end.
The props are redone (the owner: "redo and improve props on RollingPlains"): two big oaks on each shoulder, where the
studio's big trees stood; an acacia (x 104) and a fallen log (x 73) where the studio's were; a pine by the picnic
set; and ferns, grass tufts, meadow flowers (daisies or buttercups), bushes and rocks along the plain, with one grass
tuft on top of the arch and nothing under it. Of the studio's own props only the picnic set stays as they built it
(blanket, table, basket); their acacia, log and grass tufts are replaced by MapLab's.

**Where.** The arena template `Workspace.Ume.ServerStorage_Assets.Arenas.RollingPlains` (slot 7, at X 1000, Z −300
in Studio), the game home's `assets/models/maps/rolling_plains/` (`source/generate.py`: `backdrop()`, `PROPS`;
`source/studio_props.json` keeps only the picnic set). 602 land parts as before, 79 `Decor/Backdrop` parts (none
before), 47 props (24 before): big oak 4, grass 10, flower 9, fern 8, bush 7, rock 3, pine 1, log 1, acacia 1 and the
3 picnic pieces, as `Arena_Prop` Models in `Decor/Trees`, `Bushes`, `Rocks`, `Flowers` and `Picnic`. The new props'
parts are named `Trunk`, `Leaves`, `Flower`, `Wood` (the log's cut end), so their leaves get the leaves effect. Built
at map-kit 0.11.0. The old template is `Workspace._Labs.MapLab._Iterations.RollingPlains_arena_1`.

**How to check.** In a Studio play test (2026-11-14) `I.Arena.Load("RollingPlains")` loads it at X −203 to 203 with
602 terrain parts, 79 backdrop parts and 47 props, and no Arena warnings. Not played as a match yet.

**For the wiki.** Rolling Plains: the hills in the description, the props (big oaks on the shoulders, the acacia and
the log), the prop and backdrop counts in its infobox, a History line. Supersedes the "no backdrop" and the props of
`2026-11-14-rolling-plains-map`; the rest of it still holds.
