---
title: "The snail flies the jetpack still, and puts its weapon away in its shell"
date: 2026-11-12
status: open
kind: fixed
pages: ["Snails", "Jetpack"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Motion.lua
  - worm-battlegrounds-game/src/libs/Internal/SnailRig/init.lua
---

**What changed.** Flying the jetpack sideways played the walk in the air: the shell swayed and the body bobbed, away
from the snail. The walk now plays only on the ground, so a flying snail idles with its shell close and keeps its
weapon held in its pose all through the flight and the landing. While a snail hides in its shell (hit or thrown) and
comes back out, its held weapon is hidden and its hands stay in, so the weapon no longer floats beside the shell.

**Where.** Snails' client `Motion`: the walk needs the ball on the ground (`_isGrounded`, the same spherecast as
SnailControl's, `ROOT_SIZE`, `GROUND_GAP`). SnailRig's `_step`: the weapon is hidden while the motion is `Hidden` or
the `Show` animation plays, and `_aimHands` is skipped then.

**How to check.** Fly the jetpack sideways: the snail holds still in the air with the Bazooka in its pose, and lands
holding it. Checked in a Studio match: Idle and the Bazooka pose played through the flight; no Walk.

**For the wiki.** Jetpack (or Snails): nothing a player reads unless a page describes the snail's animations.
