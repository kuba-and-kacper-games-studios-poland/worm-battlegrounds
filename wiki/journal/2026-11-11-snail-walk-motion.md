---
title: "Snails visibly walk: faster Walk, plus bob, shell sway and tail swing"
date: 2026-11-11
status: open
kind: changed
pages: ["Snails", "Movement"]
files:
  - worm-battlegrounds-game/src/libs/Internal/SnailRig/init.lua
---

**What changed.** A walking snail was barely seen to walk: the Walk animation moves little (the body about 0.4 studs,
the shell 5°), and in a match the held weapon's pose covered it entirely. Now the Walk animation plays 1.5× faster,
and a walk made in code plays on top of everything, held weapon included: each step lifts the body 0.35 studs and
rocks it ±6°, the shell sways ±8° side to side, and the tail and eyestalks swing ±14°, each part a beat after the
one before. Two steps a cycle, 1.4 cycles a second; it blends in and out over 0.15 s. The held weapon moves with the
body, so the hands keep hold of it.

**Where.** SnailRig: `WALK_PLAY_SPEED` 1.5 in `SetMotion`; `_walk` (with `_swingBone`, `_moveJoint`) in `_step`;
`WALK_CYCLES_PER_SECOND` 1.4, `WALK_BLEND_TIME` 0.15, `WALK_BOB` 0.35, `WALK_LEAN` 6°, `WALK_SHELL_SWAY` 8°,
`WALK_SHELL_BOB` 0.2, `WALK_TAIL_SWING` and `WALK_EYE_SWING` 14°, `WALK_LAG` 0.7 (the SnailRig README → Walking). The
Snails module still decides when a snail walks (`Scripts/Client/Motion.lua`, `WALK_ANIMATION_SPEED`).

**How to check.** In a match, walk your snail left and right with a weapon held: it bobs and rocks with each step,
the shell sways and the tail swings, and it settles when it stops.

**For the wiki.** Snails or Movement: nothing to change in numbers players see; a short clip of the walk if the page
shows one.
