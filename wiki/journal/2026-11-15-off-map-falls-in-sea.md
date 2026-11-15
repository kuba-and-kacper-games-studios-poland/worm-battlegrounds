---
title: "Snails and shots past the map's sides fall into the sea instead of vanishing"
date: 2026-11-15
status: open
kind: changed
pages: ["Water", "Arena", "Knockouts"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Projectiles.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
---

**What changed.** A snail knocked past the play area's sides, or a shot fired out, used to vanish there (`"Bounds"`).
Now it flies on and goes out where it falls to the sea's level, where the sea is drawn (50 studs past the sides): a
snail is knocked out as drowned in the map's sea (`"Water"`, or `"Lava"` on a lava-sea map), a shot is gone. On a map
with no sea they fall to the play area's bottom (`"Bounds"`).

**Where.** Arena's `GetHazard`; Combat's `Projectiles.IsLost`; Bots' `Predict` follows the same rule.

**For the wiki.** Arena / Knockouts: going off the side is a fall into the sea.
