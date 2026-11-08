---
title: "Variety grenade lets out worms that dig down"
date: 2026-11-08
status: open
kind: changed
pages: ["Variety grenade", "Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Snail.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Bouncer.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Flight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Settings.lua
---

**What changed.** The Variety grenade's four creatures are worms now: pink, segmented, with eyes, head first and
swaying as they go. They dig down in a fan from the blast (about 35° and 15° to either side of straight down) instead
of crawling left, right and diagonally, eating a tunnel 4 studs wide. They still bite snails they touch (5 damage, 8
bites at most), dig at 6 studs a second for 6 seconds at most, and now drown when they reach water or lava.

**Where.** The burst shot's name is `Worm` (Arsenal's `BURST_SHOTS`), drawn with the place's
`Assets/Arsenal/Projectiles/Worm` model (built in Studio on 2026-11-08; the old `Projectiles/Snail` model moved to
`Assets/Arsenal/_Unused`). Directions: `snailDirections` in `Bouncer.lua`. The drown check is in `Snail.Run`. The sway is
Combat's `WORM_SWAY` (0.35 rad) and `WORM_SWAY_SPEED` (2 a second); speed, bites and lifetime are still `SNAIL_SPEED`,
`SNAIL_BITE`, `SNAIL_LIFETIME` and the row's `Snails`.

**How to check.** Studio match (2026-11-08): four worms dug from the blast down to the sea, about 27 studs in 5 s.
The drown-in-liquid stop was added after that run, so in this build they stop at the water.

**For the wiki.** Variety grenade: worms, not snails; they dig down and can open tunnels under snails standing near
the blast. The tunnels reach the sea on most maps, so a snail above them can fall in; the owner chose to keep that
(2026-11-08).
