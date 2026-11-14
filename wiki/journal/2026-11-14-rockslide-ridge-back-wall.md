---
title: "Rockslide Ridge: a dark back wall behind the cave"
date: 2026-11-14
status: open
kind: changed
pages: ["Rockslide Ridge", "Architecture"]
files: []
---

**What changed.** Rockslide Ridge had no backdrop, so the sky showed through the cave between its walls and under
its ceiling. Now a dark back wall (`3b3733`, darker than the cave's rock, so the pillars and floating slabs stand out
against it) fills the cave from the lava up to just behind the ceiling (3 studs past its underside; the stalactites
hang in front of it), and behind the side walls up to under their tops. No sky shows inside the cave. The land, the
lava and how it plays are unchanged.

**Where.** The arena template `Workspace.Ume.ServerStorage_Assets.Arenas.RockslideRidge` (slot 3, at X 1000, Z 0 in
Studio), the game home's `assets/models/maps/rockslide_ridge/` (`source/generate.py`: `backdrop()`; `map.json`'s
`backdrop`). 646 land parts as before and 60 `Decor/Backdrop` parts (none before); no props. Built at map-kit
0.11.0. The old template is `Workspace._Labs.MapLab._Iterations.RockslideRidge_arena_3`.

**How to check.** In a Studio play test (2026-11-14) `I.Arena.Load("RockslideRidge")` loads it at X −145 to 145
with 646 terrain parts, 60 backdrop parts and 17 lava blocks, and no Arena warnings.

**For the wiki.** Rockslide Ridge: the back wall in the description and its picture, the backdrop count in its
infobox, a History line. Supersedes "no backdrop" in `2026-11-14-rockslide-ridge-lava-cave`; the rest of it still
holds.
