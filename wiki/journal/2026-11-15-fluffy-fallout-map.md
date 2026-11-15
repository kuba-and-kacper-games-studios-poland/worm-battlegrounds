---
title: "New map: Fluffy Fallout, ten floating clouds over a glowing sea"
date: 2026-11-15
status: open
kind: added
pages: ["Match modes & maps", "Fluffy Fallout", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchBoard/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
---

**What changed.** Fluffy Fallout (map id `FluffyFallout`; its MatchBoard row was already there) is built and in the
rotation for 2, 4 and 6 snails. From the owner's build in `Workspace.New` (238 loose cloud parts over a four-layer
water box), made in MapLab on the 1-stud grid: ten block clouds in two rows (Y 9 to 33 and 35 to 65), every one a
floating ledge (`Arena_Floats`), nothing standing on the sea and no bedrock, so the whole sea is open: a snail in it
is out, and a cloud blasted apart keeps only its biggest piece floating. 446 parts in three greys (`Cloud`,
`CloudShade`, `DarkCloud`), with the depth effect. The water box became the `Sea` marker (`Water`, Y −8 to 6.5, in
Neon so it glows, as the build's glowing layer did). No backdrop, no props.

**Where.** `MAP_POOL` in MatchBoard's Settings (`MAPS.FluffyFallout`, no picture yet); `PROFILES.FluffyFallout` in
Atmosphere's Settings (Picnic Plains' sky mood and music, pollen only; a shortcut until it has its own). Dev place:
`Arenas.FluffyFallout` (slot 10, X 500, Z −600). MapLab: the game home's `assets/models/maps/fluffy_fallout/`.

**How to check.** MapLab: PASS, 0 errors, 0 warnings. Studio playtest: loads with 446 terrain parts, the sea drawn,
6 landing spots, no errors. Not played as a match yet: whether snails land and fight well on clouds this size.

**For the wiki.** A Fluffy Fallout page; Match modes & maps: the map list. It needs a lobby card picture, a mood and
music of its own.
