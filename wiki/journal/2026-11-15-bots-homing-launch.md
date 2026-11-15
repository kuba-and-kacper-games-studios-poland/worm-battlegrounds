---
title: "Bots fire the homing missile the way that reaches: 8 launches flown in full"
date: 2026-11-15
status: open
kind: changed
pages: ["Match modules", "Bots"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Brain.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
---

**What changed.** The owner: "make them use homing missiles better". Bots always launched it at 70° and 0.7 power
toward the target's side, into ceilings and walls. Now they try each of `HOMING_LAUNCHES` (8: 70° at 0.7, 90° at
0.5 and 0.85, 55° at 0.45 and 0.8, 35° and 15° at 0.6, and 115°, back over their own head, at 0.6), fly each in full
(its arc up to its lock, `LockDelay` 1, then straight at the point at `HomingSpeed` 60) and keep the launch that
bursts nearest the point: it clears ceilings and comes down over cover. The point can be the snail, its feet or the
ground under it, as for other weapons.

**Where.** `Brain._getRough` (the Homing branch); Bots' `HOMING_LAUNCHES`.

**How to check.** PC gym Nightmare matches: homing hits of 56 to 89 damage; a live Nightmare match in Studio fired
it with no errors.

**For the wiki.** Bots: how they use the homing missile. The admin aim guide (Combat's `Aimbot`) still shows the old
fixed launch.
