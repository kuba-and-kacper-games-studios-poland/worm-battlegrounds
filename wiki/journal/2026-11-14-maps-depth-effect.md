---
title: "Every map's land juts toward the camera in slabs (the depth effect, up to 1.4 studs)"
date: 2026-11-14
status: open
kind: changed
pages: ["Picnic Plains", "Desert", "Volcano Isle", "Training Meadow", "Lakeside Showdown", "Rockslide Ridge", "Architecture"]
files: []
---

**What changed.** Every map's land has depth now (the owner: "so the maps gets depth but stays relatively the
same"): the front of the land is cut into rows of slabs that jut toward the camera by different amounts, so its
edges catch the light in steps, like a brick wall seen from the side. The outline, the layers and everything that
plays are unchanged: snails, shots and drops keep to the plane at Z 0, and the slabs only stick out in front of it.

| Map | Jut | Rows | Land parts before → now |
|---|---|---|---|
| Picnic Plains | 1.0 stud over 4 levels | 2 to 4 studs tall | 537 → 728 |
| Desert | 1.0 over 4 | 2 to 4 | 461 → 705 |
| Training Meadow | 1.0 over 4 | 2 to 4 | 191 → 253 |
| Lakeside Showdown | 1.0 over 4 | 2 to 4 | 610 (with its redo) |
| Rolling Plains | 1.0 over 4 | 2 to 4 | 602 (new) |
| Volcano Isle | 1.2 over 3 | 3 to 5 | 479 → 621 |
| Echo Caverns | 1.2 over 3 | 3 to 5 | 921 (new) |
| Rockslide Ridge | 1.4 over 3 | 3 to 5 | 646 (redone) |

Grassy and sandy maps jut less in thinner rows; rocky ones more in thicker rows. A blast still cuts all the way
through: the jut is at most 1.5 studs, inside the cutter's reach.

**Where.** Each map's `source/map.json` → `jut` in the game home's `assets/models/maps/`, built by map-kit 0.9.0
(`Kit.build`, the land data's 8th field); every arena template under `Workspace.Ume.ServerStorage_Assets.Arenas`
was exported again on 2026-11-14, the ones before kept in `Workspace._Labs.MapLab._Iterations` as
`<MapId>_arena_<n>`.

**How to check.** Every template passes MapLab's check (`PASS, 0 error(s), 0 warning(s)`), which holds each land
part's back at the map's depth and its front within the jut. In a Studio play test (2026-11-14) every map loads with
the part counts above and no Arena warnings. Not checked in a match: how the slabs look under each map's lighting
from the match camera, and that a liquid drawn as deep as the bedrock (Loader's `GetGroundDepth`) still sits right
where bedrock juts.

**For the wiki.** Architecture: maps have the depth effect (the table's numbers). Each map's page: its part count in
the infobox, a History line ("the land's front juts in slabs").
