---
title: "Blasts hurt at once, and craters show in the blast's frame"
date: 2026-11-13
status: open
kind: fixed
pages: ["Architecture", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Blast.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Helpers/Cutter.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Carver.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Client/Carver.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Props.lua
---

**What changed.** The owner: "some explosions like black hole bomb is laggy, it updates the terrain after a lag… and
also it deals damage after a lag". Three causes, all fixed:

- **Damage waited for the crater.** `Blast.Explode` cut the crater first and hurt snails only after the cut, which
  takes several frames. It now hurts every snail in reach (and sends `Combat_Hit`) the moment the blast shows, while
  the crater is cut, and throws them once it's cut, so a thrown snail still flies over the new ground.
- **Every cut used a box per row.** A crater's stepped shape is one box per row of cells (28 for the black hole's
  14-stud blast), and each terrain part was cut with all of them. Arena's new `Cutter.Merge` merges them into one
  cutter first (`UnionAsync`, about 0.01 s); measured in Studio on Picnic Plains, a 14-stud blast over 36 parts went
  from 0.86 s to 0.32 s of cutting. Props cut with it too. The row boxes still answer which parts a blast reaches.
- **Clients cut with precise collision.** Each client cuts its own copy of the hole; its pieces never collide or
  answer queries, so they now skip precise collision (`CollisionFidelity.Box`), several times faster again.

**Where.** `Blast.Explode` (`_hurt`, throws after the carve), `Blast.Hit` (same behaviour); Arena's `Cutter.Merge`,
`Cutter.Subtract(part, cutter, shownOnly)`, the server and client `Carver`, `Props._cut`. The PC gym's engine has no
`UnionAsync`, so it keeps cutting with the boxes (same shape).

**How to check.** Studio, 2026-11-13, Nightmare custom match: the damage arrived in the same frame as the
explosion's effect; each client's hole appeared in that frame too, the server's pieces 0.04 to 0.14 s later; the
worst client frame over 100 s of play was 62 ms.

**For the wiki.** Architecture (craters): one merged cutter; damage before the crater.
