---
title: "Homing missile fires without a picked target, and is drawn 3.5 times its size"
date: 2026-11-13
status: open
kind: fixed
pages: ["Homing missile"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Shots.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Flight.lua
---

**What changed.** Firing the Homing missile with no target picked (a pad's RT, the touch FIRE button) was refused by the server. Now it homes on the pointer's spot on the play plane, or `HOMING_AIM_REACH` (60) studs along the aim. It's drawn 3.5 times its size in flight (`PROJECTILE_DRAW_SCALES.HomingMissile`; other shots 2).

**Where.** MatchHud's `Aim._fire`; Combat's `PROJECTILE_DRAW_SCALES`, read in `Shots` and `Flight`.

**How to check.** On a pad fire the Homing missile: it flies and turns toward the aimed point. It's clearly bigger in flight.

**For the wiki.** Homing missile: aiming without a target, and its look.

**From.** The testers: "fix homing missle", "make homing missle bigger".
