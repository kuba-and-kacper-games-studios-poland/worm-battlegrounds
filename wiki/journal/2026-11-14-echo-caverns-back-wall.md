---
title: "Echo Caverns: a dark back wall under the dome"
date: 2026-11-14
status: open
kind: changed
pages: ["Echo Caverns", "Architecture"]
files: []
---

**What changed.** Echo Caverns had no backdrop, so the sky showed under its dome. Now a dark blue-grey back wall
(`45474f`, darker than the cavern's rock) fills the cavern from the sea up to just behind the dome (3 studs past its
underside; the stalactites hang in front of it), never over the dome's snowy top, and across the short break in the
dome's left arm. It reaches both ends of the map. The land, the water and how it plays are unchanged.

**Where.** The arena template `Workspace.Ume.ServerStorage_Assets.Arenas.EchoCaverns` (slot 8, at X 1500, Z −300
in Studio), the game home's `assets/models/maps/echo_caverns/` (`source/generate.py`: `backdrop()`; `map.json`'s
`backdrop`). 921 land parts as before, 80 `Decor/Backdrop` parts (none before), the studio's 21 props as before.
Built at map-kit 0.11.0. The old template is `Workspace._Labs.MapLab._Iterations.EchoCaverns_arena_1`.

**How to check.** In a Studio play test (2026-11-14) `I.Arena.Load("EchoCaverns")` loads it at X −148 to 148 with
921 terrain parts, 80 backdrop parts, 21 props and 8 water blocks, and no Arena warnings.

**For the wiki.** Echo Caverns: the back wall in the description and its picture, the backdrop count in its infobox,
a History line. Supersedes "no backdrop" in `2026-11-14-echo-caverns-map`; the rest of it still holds.
