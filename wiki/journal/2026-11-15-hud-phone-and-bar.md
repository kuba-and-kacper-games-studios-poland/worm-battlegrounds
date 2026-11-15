---
title: "HUD: jump on the right above FIRE on phones, locks on used-up items, homing target by tap and drag, guns that miss don't move the camera"
date: 2026-11-15
status: open
kind: changed
pages: ["Match HUD", "Homing missile", "Controls", "Camera"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/TouchControls.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/LoadoutBar.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchCamera/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Hitscan.lua
---

**What changed.**

- **Phones:** the jump button moved from above the walk arrows (bottom left) to the right side, above the power bar
  and FIRE (`U_TouchJump` › `S_Jump`). The walk arrows stay bottom left.
- **Locks:** a loadout bar slot whose item has no uses left for the match shows a lock (the Loadout card's lock
  picture, `S_Lock`) over its darkened icon, as a cooling one is darkened.
- **Homing missile on touch:** a finger now places the target and drags it until FIRE ("Tap on a target"). Fixed: on
  phones the next turn's crosshair sat where the finger last lifted (the camera had moved since); that point is now
  forgotten when a turn starts or ends.
- **Camera:** a gun's bullets that hit neither a snail nor the map no longer move the camera; it glides only to bullets
  that struck something. `Combat_Tracer` gained a 5th argument, `struck: { Vector3 }?`.

**How to check.** On a phone (or Studio's device emulator): the jump button above FIRE; use up a Grenade: its slot
locks; pick the homing missile, drag the target, FIRE. Fire the Shotgun into the sky: the camera stays.

**For the wiki.** Match HUD: phone layout, locked slots; Homing missile: touch aiming; Camera: guns.
