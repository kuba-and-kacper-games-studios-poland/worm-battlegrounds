---
title: "Lakeside Showdown: pits in each bank and four small floating islands"
date: 2026-11-14
status: open
kind: changed
pages: ["Lakeside Showdown", "Architecture"]
files: []
---

**What changed.** Lakeside Showdown gets the studio's edit of it (the owner: "pits in the ground, and small floating
islands"). The rolling banks, the beaches, the lake and its lily pads stay as they were. Dug into the banks, where the
studio put theirs (x from the map's middle): on the left two flat-bottomed pits 5 studs deep, at x −78 and −53; on
the right a shoulder 3 deep at x 69 stepping down into a pit 12 deep at x 77. Their floors are dirt. Over the banks
float four small islands: upside-down cones of earth with grass on top, blunt at the ends, at x −122 to −102 (Y 50 to
65), −65 to −47 (Y 62 to 79), 47 to 65 (Y 50 to 63) and 102 to 122 (Y 48 to 61). A blast that splits one keeps its
biggest piece floating and drops the rest. The right bank's rock, birch and pine moved off the pits. The studio's edit
also flattened the banks and squared their outer ends; the map keeps its rolling banks.

**Where.** The arena template `Workspace.Ume.ServerStorage_Assets.Arenas.LakesideShowdown` (slot 6, at X 500,
Z −300 in Studio), the game home's `assets/models/maps/lakeside_showdown/` (`source/generate.py`: `PITS`,
`FLOATERS`). 610 land parts, up from 322: `Island_1` and six ledges numbered left to right, so the lily pads are
`Ledge_3` (x −27 to −11) and `Ledge_4` (x 11 to 27) now, and the floating islands `Ledge_1`, `Ledge_2`, `Ledge_5`,
`Ledge_6`. 54 backdrop parts and 16 props, as before. The land has the depth effect (1.0 stud over 4 levels). The old
template is `Workspace._Labs.MapLab._Iterations.LakesideShowdown_arena_1`.

**How to check.** In a Studio play test (2026-11-14) `I.Arena.Load("LakesideShowdown")` loads it at X 0 with 610
terrain parts and 18 water blocks, and no Arena warnings. Not played as a match yet: nobody has stood on the floating
islands or in the pits.

**For the wiki.** Lakeside Showdown: the pits and the floating islands in the description, the ledge count in its
infobox, a History line. The earlier entry `2026-11-13-lakeside-showdown-map` names the pads `Ledge_1` and `Ledge_2`:
they're `Ledge_3` and `Ledge_4` now.
