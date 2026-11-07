---
title: "A blasted ledge keeps only its biggest piece; every other piece falls"
date: 2026-11-07
status: open
kind: changed
pages: ["Match modes & maps", "Architecture", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Debris.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
---

**What changed.** Back to the studio's wiki ("blocks left floating fall down"), keeping the maps' floating ledges up.
Before: a piece cut off a floating ledge kept floating while it was 24 square studs or more. Now, when a blast cuts a
ledge apart, only its biggest piece keeps floating; every other piece falls, whatever its size, and is plain ground
where it lands. Ground cut off an island falls as before.

**Where.** At load `Debris.LabelLedges()` numbers each group of touching `Arena_Floats` parts (`Arena_Ledge`, kept by
carved pieces); `Debris.Drop` keeps each ledge's biggest cut-off group and drops the rest; a falling piece loses
`Arena_Floats` and `Arena_Ledge`. `FLOAT_MIN_AREA` is gone.

**How to check.** On Picnic Plains, blast through the middle of a floating ledge: the smaller side falls, the bigger
one stays. Checked 2026-11-07 in a Studio match: Picnic Plains' 4 ledges were numbered at load (36, 70, 59 and 84 parts); after 6 rounds of bot fire, ledges 2 and 4 were cut (71 and 86 parts) and each ledge was still one connected piece, with no `Arena_Floats` part left without a number. A ledge cut fully in two wasn't seen in that run.

**For the wiki.** Match modes & maps → Movement and physics → Terrain: a cut ledge keeps its biggest piece, the rest
falls. Architecture's arena section: the same.

Supersedes the floating part of 2026-11-05-ledges-and-props (the 24-square-stud rule); its props part still holds.
