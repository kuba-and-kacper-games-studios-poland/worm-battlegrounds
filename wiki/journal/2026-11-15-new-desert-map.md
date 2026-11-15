---
title: "New Desert map: one sandy island of five dune peaks over lava, with cacti"
date: 2026-11-15
status: open
kind: added
pages: ["Match modes & maps", "Desert", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
---

**What changed.** The owner's new Desert (from the dev place's `Workspace.New`, a MapLab build made outside the place)
is the map `Desert`, in the rotation for 2, 4 and 6 snails: one island over a lava sea, five sandy dune peaks from
x −109 to 112 (tops up to Y 45), layered sand, dark sand and sandstone over `DarkStone` bedrock (Y 4 to 8,
`Arena_Indestructible`). No floating ledges, no pond, no backdrop. 1,233 land parts; markers `Lava` (Y −8 to 4, the
sea that knocks out and rises in sudden death) and `Bounds` (282 × 114). Nine cacti props in `Decor/Cacti` (saguaro,
organ pipe, candelabra, prickly pear, cactus cluster) with spikes and flowers.

Put in as built, with small fixes: its 1,980 Plastic parts with the `2022 Stud` variant became SmoothPlastic (so the
studs show here); the cacti's 592 spike and body parts were collidable and touchable and are now off like every
prop's (snails would have bumped into them); 8 cacti were stood on their ground.

**Where.** `MAPS.Desert` in MatchBoard's Settings (`Thumbnail` empty: no picture yet, so the board keeps the design's);
Atmosphere keeps its `Desert` row (the Desert preset and music). Dev place:
`Workspace.Ume.ServerStorage_Assets.Arenas.Desert` (slot 9, X 0, Z −600).

**How to check.** Studio playtest: `Desert` loads with 1,233 terrain parts, 9 props, lava drawn, 6 landing spots
found, no errors.

**For the wiki.** The Desert page describes this map. Still unsure: each cactus carries `Arena_Hazard` = `Cactus` and
`CactusVariant`, which no code reads, so cacti don't hurt; ask the owner whether they should. The map needs a lobby
card picture.
