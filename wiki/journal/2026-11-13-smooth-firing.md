---
title: "Firing is smooth: the weapon holds its aim, the sound plays at once, launchers blast"
date: 2026-11-13
status: open
kind: fixed
pages: ["Match modules", "Arsenal"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Held.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Fire.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Shots.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
---

**What changed.** On fire the shooter's screen kept drawing the aim while the held weapon swung flat until the server answered, so shots looked late and rockets seemed to leave from beside the launcher. Now the screen keeps the fired angle (up to `FIRE_ANSWER_SECONDS` 2), hides the aim and plays the `Fire_<itemId>` sound at once; the server plays it for everyone else. The Bazooka and the Homing missile blast out of the launcher (`LAUNCH_VFX`: `Flash_Sniper` and `Explosion_Gun`, scale `LAUNCH_VFX_SCALE` 1.5).

**Where.** MatchHud's `Aim._fire` (`firedAngle`, `firedAt`); Combat's `Held._onPhaseChanged`, `Fire._playSound(name, position, skip)`, `Shots._onShot`.

**How to check.** Fire the Bazooka: the sound and the muzzle blast come with the release, and the rocket leaves the launcher's mouth.

**For the wiki.** Match modules (Combat): firing and the launch effects.

**From.** The testers: "shooting isnt smooth there is still odd delay", "rockets dont shoot from rocket launcher", "vfx when shooting rocket (out of bazooka) is missing".
