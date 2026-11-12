---
title: "A thrown Grenade bursts as soon as it stops"
date: 2026-11-12
status: open
kind: changed
pages: ["Grenade"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Bouncer.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
---

**What changed.** A thrown bomb with a fuse (the Grenade, 3 s fuse) explodes the moment it comes to rest on the
ground, instead of waiting for its fuse; it still bursts on its fuse if that runs out first. Dynamite, placed at the
feet, still waits for its 3.5 s fuse.

**Where.** Combat's `Bouncer` behaviour (thrown means `Aim ~= "Feet"`; rest is on the ground with no speed left); the
bots' `Predict._fly` mirrors it.

**How to check.** Throw a Grenade onto flat ground: it bounces, rolls, and bursts when it stops.

**For the wiki.** Grenade: when it explodes.
