---
title: "Map templates side by side in 400-stud slots, all on the Z = 0 plane"
date: 2026-11-07
status: open
kind: fixed
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/_meta/README.md
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/_meta/README.md
---

**What changed.** The owner asked for the asset folders in the place to be sorted, nothing overlapping. Before:
Desert's template stood 22.75 studs behind Picnic Plains at the same X, Rockslide Ridge at x 348, Z −269.6, and the
weapon models in an L in front of Picnic Plains. Now the arena templates stand side by side along +X, one per
400-stud slot (MapLab's slots): Picnic Plains at X 0, Desert at 400, Rockslide Ridge at 800, each with its Bounds
at Z = 0. The Arsenal models stand in three rows left of the maps (weapons, utilities, projectiles, in the data's
order). A match plays wherever its template stands, so Desert and Rockslide Ridge matches now play at X 400 and 800.

**Fixed with it.** The drop picker reads the play plane as Z = 0 (`Match/Scripts/Client/DropPicker.lua`,
`_getPlanePoint`), so on Desert (plane at Z −22.75) and Rockslide Ridge (Z −269.6) a picked landing spot was off
from where the mouse pointed. Every plane is at Z = 0 now.

**Where.** `Workspace.Ume.ServerStorage_Assets/Arenas` and `ReplicatedStorage_Assets/Arsenal` in the place. MapLab
0.5.2 (the game home's `assets/_tools/map-kit/`) exports a map into its slot's X, so re-exports keep the layout;
slot 3 is Rockslide Ridge's, so the next MapLab map takes slot 4.

**How to check.** In Studio, the three maps stand in a row with no overlap. Checked 2026-11-07 in a playtest: a
Desert match loaded at Bounds (400, 49, 0), all four snails stood at Z 0.00, and the lobby's backdrop still plays on
Picnic Plains. Not checked by hand: picking a landing spot with the mouse on Desert.

**For the wiki.** Architecture → In the place: the slot layout of the arena templates and where the Arsenal models
stand.
