---
title: "Picnic Plains rebuilt in MapLab: land on the 1-stud grid, part-built props"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Match modes & maps", "Architecture"]
files:
  - worm-battlegrounds-game/.claude/rules/game/practices.md
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/_meta/README.md
---

**What changed.** Picnic Plains (`PicnicPlains`) keeps its layout (three islands at the waterline, four floating
ledges, the same prop spots and colours) but its land was cleaned and rebuilt with MapLab, the game home's map kit:
every edge sits on a whole stud, the one-stud spikes and ragged undersides are gone, and the layers follow each
piece's surface (grass, 4 to 7 studs of dirt, a two-stud band of dark dirt, then stone). The ground no blast can cut
is now each island's dark stone bedrock from Y 4 to 8 (4 parts), instead of 48 waterline blocks. The 18 trees, bushes
and rocks are no longer meshes: they're built from parts in the meshes' look (piles of bevelled blocks, half-stud
studs on leaves and bushes), so blasts can cut them (see the entry "Props break under blasts").

**Where.** In the place: `Workspace.Ume.ServerStorage_Assets/Arenas/PicnicPlains`. Terrain 537 parts (was 318) in
`Island_1`–`3`, `Ledge_1`–`4`, named `Grass`, `Dirt`, `DarkDirt`, `Stone`, `DarkStone`; `Arena_Indestructible` on the
4 `DarkStone` bedrock parts; `Arena_Floats` on all 249 ledge parts. Decor: `Backdrop` 52 parts, `Trees` (Pine, Oak,
Birch: parts `Trunk`, `Leaves`, `Needles`, `Spot`), `Bushes`, `Rocks`, each an `Arena_Prop` Model (15 to 69 parts).
Markers: `Bounds` 282 × 114 × 11 at 0, 49, 0; `Sea` (`Arena_Liquid = "Water"`) from −8 to 6.5. The template it
replaced is in `Workspace._Labs.MapLab._Iterations.PicnicPlains_arena_1`. The map's sources (`land.png`, `map.json`)
and the kit are in the game home (`assets/models/maps/picnic_plains/`, `assets/_tools/map-kit/`), outside this repo.

**How to check.** Played in Studio (`I.Arena.Load("PicnicPlains")`): the map loads with no warnings and the sea fills.
MapLab's validation passes with 0 errors and 0 warnings.

**For the wiki.** Match modes & maps → Picnic Plains: the cleaner land and the part-built props (the look stays the
same). Architecture's terrain section: maps are made in MapLab (picture on the 1-stud grid, built into parts,
exported after approval); the indestructible ground is the islands' bedrock. Unsure: whether the wiki should name
MapLab at all, since it lives outside the repo.

**Merged.** Part counts and markers come from this entry; the place itself wasn't opened to check them. MapLab is named on Architecture only.
