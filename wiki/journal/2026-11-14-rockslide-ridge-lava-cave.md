---
title: "Rockslide Ridge redone: a walled cave with hanging rocks, over a lava sea"
date: 2026-11-14
status: open
kind: changed
pages: ["Rockslide Ridge", "Match modes & maps", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
---

**What changed.** Rockslide Ridge is a new map on the same id (`RockslideRidge`), after the studio's rebuild of it in
Studio (the owner: "redo the rockslide to match the layout of the new rock map, so it has like the hanging rocks and
sides are blocked, and change water on that map to be lava"). 290 × 111 studs. Walls close both sides and join a thick
ceiling that hangs stalactites over the arena; six rock pillars stand in the lava with stalagmites on their tops and
shelves, and six floating rock slabs fill the middle. The sea is lava (Y −5 to 15), neon, in Arena's one lava colour.
The land is the studio's, stud for stud, except that what stood just over the floor now stands on it and crumbs
under 24 square studs went. Before, it was the owner's Studio build: eight islands and eight ledges over a yellow
water sea, with a backdrop of rock pillars.

The lava between the pillars is 5 to 14 studs across at its surface, under the open-sea rule's 16: a snail that
falls in burns (24 health over 3 s, its turn ends) instead of being knocked out, until sudden death raises the lava
over the pillars and it widens into open sea. Below the land's floor it still knocks out. The owner kept it that way
(2026-11-14: "Keep the burn").

The map's mood stays the `Cave` preset and its epic music; the surface effects are lava bubbles and embers now (the
water ripples went).

**Where.** The arena template `Workspace.Ume.ServerStorage_Assets.Arenas.RockslideRidge` (slot 3, at X 1000, Z 0 in
Studio), made in MapLab (the game home's `assets/models/maps/rockslide_ridge/`, card `asset.yaml`):
`Terrain/Island_1` (both walls and the ceiling, x −145 to 145, up to Y 98), `Island_2`–`7` (the pillars),
`Ledge_1`–`6` (the slabs), 646 parts named `Rock`, `LightRock`, `Strata`, `Bedrock` (bedrock from Y −5 to 3 with
`Arena_Indestructible`); no backdrop (201 parts before) and no props. Markers `Sea` (`Lava`, Y −5 to 15,
`Arena_LiquidNeon`, no `Arena_LiquidColor`) and `Bounds` (290 × 111 × 11, its middle at Y 50.5). The land has the
depth effect (1.4 studs over 3 levels). Atmosphere's `PROFILES.RockslideRidge.Surface`: `Lava_Bubble` every 0.4 to
1.2 s and `Ember` every 0.2 to 0.6 s (Volcano Isle's), replacing the water's `Ripple`. The old template is
`Workspace._Labs.MapLab._Iterations.RockslideRidge_arena_2`.

**How to check.** In a Studio play test (2026-11-14) `I.Arena.Load("RockslideRidge")` loads it at X 0 with 646
terrain parts and 17 lava blocks, its Bounds at 0, 50.5, 0, and no Arena warnings. Not played as a match yet: the
burn in the lava between pillars is from the rules (`Liquid.IsSea`, `SEA_MIN_WIDTH`), not seen.

**For the wiki.** Rockslide Ridge: the whole page's description (the cave, the walls, the hanging rocks, the pillars
and slabs, the lava sea that burns between the pillars and kills under the floor), its infobox (lava, no backdrop),
a History line for the redo. Match modes & maps: its line. Architecture: Rockslide Ridge is a MapLab map now, no
longer the one built by hand.

Supersedes the part of `2026-11-14-lava-colour` that says Rockslide Ridge's lava sea isn't exported yet.
