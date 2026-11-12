---
title: "Backdrops and Rockslide Ridge's ceiling end in slopes, not straight walls"
date: 2026-11-12
status: open
kind: changed
pages: ["Match modes & maps", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/_meta/README.md
---

**What changed.** The owner: the backdrops and Rockslide Ridge's ceiling were "cut clean", ending in straight walls.
On all three maps the backdrop (the wall behind the play plane, `Decor/Backdrop`, never touched by blasts) now eases
down at its ends, and Rockslide Ridge's ceiling thins to a blunt tip. The land players stand on, the props, the
liquids and the markers are unchanged, except the ceiling's ends.

- **Picnic Plains:** each backdrop hill's skyline is smoothed and its ends slope down to the sea over up to 30 studs
  (30 % of a narrow hill's width). `Decor/Backdrop` 52 → 101 parts. Terrain unchanged, 537 parts.
- **Desert:** the mesas' skyline is smoothed and both ends of the map slope down to the lava over 55 studs instead of
  standing as walls. `Decor/Backdrop` 17 → 70 parts. Terrain unchanged, 461 parts.
- **Rockslide Ridge:** the backdrop's rock pillars keep their shapes, with their outer top corners rounded (radius 7
  studs) and a scree slope at each pillar's foot (30 % of its height wide, 35 % tall, eased into the water).
  `Decor/Backdrop` 104 → 201 parts (159 boxes and 42 detail plates). The ceiling, `Terrain/Ledge_1` (a floating
  ledge, `Arena_Floats`, numbered at load), keeps its middle and its top line; its last 32 studs at each end are
  2-stud columns whose underside curves up to a 5-stud tip, thinning in depth too. `Ledge_1` 28 → 57 parts, Y 70.6
  to 96 (was 68 to 96: its lowest bit was near an end). Terrain 295 → 324 parts; floating parts 138 → 167; bedrock
  (`Arena_Indestructible`) unchanged, 46 parts.

**Where.** In the place: `Workspace.Ume.ServerStorage_Assets/Arenas/PicnicPlains`, `Desert` and `RockslideRidge`.
The templates they replaced are in `Workspace._Labs.MapLab._Iterations` (`PicnicPlains_arena_2`, `Desert_arena_1`,
`RockslideRidge_arena_1`). Sources in the game home, outside this repo: MapLab's new `maplab.py soften` (map kit
0.6.2) for Picnic Plains and Desert (`backdrop_original.png` → `backdrop.png`; Desert's `map.json`
`backdrop.soften.taper` 55), and `assets/models/maps/rockslide_ridge/source/soften.luau` for Rockslide Ridge, which
is still the owner's hand-built map.

**How to check.** Studio playtests of the Match map on each map (2026-11-12): Picnic Plains `Ledge_1`–`4` numbered,
Desert `Ledge_1`–`2`, Rockslide Ridge `Ledge_1` (the ceiling) one ledge among 8; no Arena warnings. MapLab's
validation passes on Picnic Plains and Desert. From the match camera, the ends of each backdrop slope or round off.

**For the wiki.** Architecture: the arena table's Rockslide Ridge row if it gets one (324 terrain parts, 201 backdrop
parts) and the Picnic Plains and Desert backdrop counts if listed. Match modes & maps: nothing a player reads changes,
unless the page describes the maps' look. Not checked: how a blast near the ceiling's thin tips breaks it in play
(each tip column is a floating ledge part like the rest, so what's cut off falls).
