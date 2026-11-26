---
title: "Pad aim: pushing through the snail turns the aim round; long pushes speed up to 2.5x"
date: 2026-11-26
status: open
kind: fixed
pages: ["Controls", "Match"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** On a pad, the right stick can now aim to the other side: pushing the crosshair back through the
snail brings it out on the far side, where it used to stop at 0 power with nothing to fire. A push held longer than
0.35 s speeds up, to 2.5 times the normal speed over the next 0.6 s, so small nudges stay as precise as before and a
sweep from one side to the other is quicker.

**Where.** `Module._aimWithStick` in MatchHud's `Scripts/Client/Aim.lua` (new locals `stickHeld`, `stickSlack`);
MatchHud's `STICK_RAMP_DELAY` 0.35, `STICK_RAMP_TIME` 0.6, `STICK_RAMP_MAX` 2.5 (`STICK_DEADZONE` 0.2,
`STICK_AIM_SPEED` 1.1 and `STICK_CURVE` 2 unchanged). Mouse and touch aiming are unchanged.

**How to check.** On a pad, aim level to the right at any power, then hold the right stick left: the power drops to
nothing, then grows again pointing left. Hold the stick for over half a second: the crosshair visibly speeds up.
Checked in Studio with simulated stick input (100% right to 100% left in about one second); not yet on a real pad.

**For the wiki.** Controls: the right stick aims, finer for a gentle lean and faster on a long push; push through the
snail to aim the other way.
