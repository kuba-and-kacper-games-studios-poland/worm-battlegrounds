---
title: "A hit snail ducks into its shell at once (hide animation ×1.8, 0.05 s fade)"
date: 2026-11-10
status: open
kind: changed
pages: ["Match screen"]
files:
  - worm-battlegrounds-game/src/libs/Internal/SnailRig/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Client/Motion.lua
---

**What changed.** A snail that takes damage hides in its shell the moment the hit lands, and the hide plays faster, so
it no longer looks late (the owner: it "feels lagged"). Before, it waited for the snail's motion to change and faded
in over the default time at normal speed.

**Where.** SnailRig's `HIDE_PLAY_SPEED` 1.8 and `HIDE_FADE_TIME` 0.05 (seconds; idle and walk stop as fast) in
`SetMotion`'s Hidden branch. Snails' `Motion.lua` listens to `Combat_Hit` (`_onHit`) and hides a snail hit for more
than 0 damage.

**How to check.** In a match, hit a snail: it ducks in the same frame as the blast's damage number.

**For the wiki.** Nothing unless a page describes the snails' animations.
