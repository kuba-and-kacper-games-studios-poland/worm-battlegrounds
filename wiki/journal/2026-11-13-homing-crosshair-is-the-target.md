---
title: "Homing missile: the crosshair is the target, placed anywhere with a click"
date: 2026-11-13
status: open
kind: changed
pages: ["Arsenal", "Match screen", "Controls & platforms"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
---

**What changed.** The owner found the homing missile's aim "confusing a bit". Before, a homing missile showed the
normal aim (the crosshair at the end of the power cone, next to the snail), while the first click picked a target
wherever the mouse was, marked only by a small red ball.

Now the crosshair is the target. With the homing missile held and no target yet, the spinning crosshair follows the
mouse or finger anywhere on the arena, with no power cone, and the slider says "Click on a target". The click places
the target there; the crosshair stays on it (with the red ball in its middle) while the next press charges and fires,
and the power cone shows the launch as usual. The slider says "Shoot!".

**Where.** `Aim._step` passes the target (or, before one is placed, the pointer's point on the arena) to `Aim._draw`'s
new `crosshairAt`, which puts the crosshair there instead of past the cone. On a pad, with no pointer, the crosshair
stays past the cone and RT fires toward the aim as before (`HOMING_AIM_REACH`). Other players still see the shooter's
cone and crosshair as before.

**How to check.** Hold the homing missile on your turn: the crosshair sits on the mouse and follows it. Click
somewhere: it stays there while you move the mouse. Press and release to fire, and the missile homes there. Checked in
Studio on 2026-11-13: before the click the crosshair's centre was within 1 px of the mouse; after it, the crosshair
stayed on the target with the mouse 800 px away, and the shot hit the bot. Touch and pad weren't checked.

**For the wiki.** Homing Missile (Arsenal) and Match screen: how to aim it (move the crosshair onto the target, click,
then charge and fire). Controls & platforms: the same for mouse and touch.
