---
title: "Lakeside Showdown: deeper sand, wider lily pads, new props"
date: 2026-11-14
status: open
kind: changed
pages: ["Lakeside Showdown", "Architecture"]
files: []
---

**What changed.** The owner: "improve lilly pads and props on LakesideShowdown and make the sand more deep than one
size".
- **Sand:** the beaches and the lake bed are sand 2 to 4 studs deep (3 on most of it), was 1 to 2, over a stud of
  darker sand (`DarkSand`, `c4a46c`), and as thick on the lake bowl's steep walls. To fit it over the bedrock (Y 8),
  the lake's floor is 2 studs higher: the lake is x −39 to 38, Y 11 to 21 (was Y 9 to 21), so about 10 studs deep at
  most. The water's surface is where it was.
- **Lily pads:** 18 studs wide, was 16 (`Ledge_3` x −28 to −10, `Ledge_4` x 10 to 28, Y 20 to 22, half under the
  water), the darker stud under each 2 studs shorter at each end, so they look round (32 square studs each). The water
  lily on each is fuller: long white petals, two pink rings inside, a yellow heart and a closed bud beside it.
- **Props:** a big oak in each gap between the floating islands (x −91 and 86); the smaller oaks under the outer
  floating islands (x −113 and 117), each with a fallen log beside it; cattails at the water's edge on both beaches
  (x −42 and 42); ferns, grass tufts and meadow flowers along the banks; a pine on each bank, a birch, a bush and a
  rock kept; and a plant on top of each floating island (grass, a fern, flowers, grass). The banks, pits and floating
  islands are as they were.

**Where.** The arena template `Workspace.Ume.ServerStorage_Assets.Arenas.LakesideShowdown` (slot 6, at X 500, Z −300
in Studio), the game home's `assets/models/maps/lakeside_showdown/` (`source/generate.py`: `LAKE` floor 12, `PADS`
half width 9, the `sand` depth, `PROPS`, `FLOATER_PROPS`; `map.json`'s palette gains `DarkSand`). 635 land parts (610
before) named as before plus `DarkSand`; 54 backdrop parts as before; 26 props (16 before): grass 5, fern 3, flower
3, oak 2, big oak 2, log 2, pine 2, cattail 2, lily 2, rock 1, bush 1, birch 1, as `Arena_Prop` Models in
`Decor/Trees`, `Bushes`, `Rocks` and `Flowers` (the cattails' heads are parts named `Head`). The `Lake` marker is
77 × 10 at Y 16 (was Y 15). Built at map-kit 0.11.0. The old template is
`Workspace._Labs.MapLab._Iterations.LakesideShowdown_arena_2`.

**How to check.** In a Studio play test (2026-11-14) `I.Arena.Load("LakesideShowdown")` loads it at X −135 to 137
with 635 terrain parts, 26 props and 17 water blocks, and no Arena warnings. Not played as a match yet.

**For the wiki.** Lakeside Showdown: the deeper sand, the lake's depth (floor Y 11), the wider lily pads and their
fuller lilies, the new props (big oaks, logs, cattails, ferns, flowers, plants on the floating islands), the part and
prop counts in its infobox, a History line. Supersedes the lake floor (Y 9), the pad sizes and the props in
`2026-11-13-lakeside-showdown-map` and `2026-11-14-lakeside-pits-and-islands`; the rest of them still holds.
