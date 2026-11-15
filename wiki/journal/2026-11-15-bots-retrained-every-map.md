---
title: "Every difficulty's bots retrained on all 10 maps"
date: 2026-11-15
status: open
kind: changed
pages: ["Match modules", "Bots"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerData/Brains.lua
---

**What changed.** The owner: "start training the bots on all maps using the bot gym… train all difficulties on all
maps", on the place saved as `saves/6.rbxl`. Earlier runs played only four maps; these played all ten in
`Arenas`: Rockslide Ridge, Desert, Volcano Isle, Fluffy Fallout, Mirage Mesa, Lakeside Showdown, Training Meadow,
Picnic Plains, Rolling Plains and Echo Caverns. Each run trained with the brain as it is now (no self-harm, homing
launches, walking on after thrown shots, and for Nightmare its new abilities), from the shipped genome, on the PC gym;
each champion then sat its exam against the shipped genome in Studio. All four beat it and replace their row in
`ServerData/Brains.lua`.

| Difficulty | Run (PC gym) | PC exam: champion vs shipped | Studio exam |
| --- | --- | --- | --- |
| Easy | seed 53, 16 generations of 16, 96 matches each | 0.576 vs 0.539 (96 matches) | 0.596 vs 0.570 (48) |
| Medium | seed 41, 12 generations of 16, 64 matches each | 0.709 vs 0.587 (64) | 0.667 vs 0.590 (24) |
| Hard | seed 41, 12 generations of 16, 96 matches each | 0.725 vs 0.681 (96) | 0.838 vs 0.608 (24) |
| Nightmare | seed 41, 16 generations of 20, 128 matches each | 0.812 vs 0.625 (96) | 0.908 vs 0.581 (24) |

Points are per seat, `PLACE_POINTS` plus `DAMAGE_POINTS` per point of damage. Easy's first run (seed 41) tied
(0.574 vs 0.580) and was dropped; the seed 53 run is what shipped.

How they play in the PC exams: Easy hits 24 % of shots, 8 damage a shot, mostly the Bazooka; Medium 42 %, 18 a shot;
Hard 63 %, 30 a shot; Nightmare 69 %, 40 a shot, the Spartan spear about a third of its shots, walking on after 27 %
of them, own-side damage 1 to 2 % (teammates in 2 v 2s, never itself).

**Where.** `ServerData/Brains.lua`, every row. Reports: the repo's `bot-gym/runs/<Difficulty>-<seed>.json` (not
committed).

**How to check.** `Brains.lua`'s Nightmare row has `EnemyDamage = 0.993`, `HealBelow = 76`; Hard's `HealBelow = 106`;
Medium's `HealBelow = 48`; Easy's `EnemyDamage = 2.477`, `HealBelow = 83`.

**For the wiki.** Bots: a History line for the retraining; how strong each difficulty plays (hit rates above).
