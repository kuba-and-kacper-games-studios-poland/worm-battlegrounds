---
title: "Worms start on every storey, and leaning props stay up"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Match modes & maps", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Props.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/_meta/README.md
  - worm-battlegrounds-game/.claude/rules/game/practices.md
---

**What changed.** Two fixes the Desert's two storeys showed. Worms that don't place themselves (bots, players who
skip placing) used to start only on the highest ground in each column, so on the Desert 15 of 16 start spots were
on the upper islands; now every top counts, ground under a floating island too, and spots are kept 16 studs apart by
distance instead of by X alone (on the Desert, 16 spots split 6 on the ground and 10 above; 6 spots split 2 and 4).
And a prop used to fall after any blast when the middle of its outline hung over a drop (a palm leaning over the
oasis); now it stands while there's ground under its trunk.

**Where.** `Module.GetLandSpots` in `Arena/Server.lua`: each column's ray goes on from just under every hit, and the
gap check uses the distance between spots (`LAND_SPOT_STEP` 2, `LAND_SPOT_GAP` 16, `LAND_SPOT_MIN_NORMAL` 0.7
unchanged). `Module._isSupported(prop, boxCFrame, boxSize)` in `Arena/Scripts/Server/Props.lua` looks under the
prop's pivot (a part-built prop's trunk; a one-part mesh's middle, as before), `PROP_SUPPORT_DEPTH` 1.5 unchanged.

**How to check.** Played in Studio: `I.Arena.GetLandSpots(16, 1.5)` on the Desert gives spots on both storeys in
about 7 ms; blasts far from the palms leave all three standing, a blast at a trunk takes that palm down; Picnic
Plains still gives 16 spots, all on its islands.

**For the wiki.** Match modes & maps: on maps with storeys, worms that don't place can start on any of them.
Architecture's arena section: props stand while there's ground under their trunk.
