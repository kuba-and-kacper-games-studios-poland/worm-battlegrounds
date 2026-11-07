---
title: "Snails can't fly or drop through the ground on a changed client"
date: 2026-11-07
status: open
kind: fixed
pages: ["Controls & platforms", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Scripts/Server/Control.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Settings.lua
---

**What changed.** The server now takes a snail back from its player (the turn ends, the snail returns to where it was
a moment before, with a warning in the server's Output) in two more cases:

- **It went through the terrain:** the snail's middle crossed a terrain surface between two frames.
- **It climbed higher than its jump and jetpack reach:** every stud above a jump's height (`JUMP_SPEED`² / 2g, about
  4.9 studs, higher under the Low gravity potion) over the ground it last stood on, plus `MOVE_SLACK` (2), counts
  against the jetpack. A jetpack allows `JETPACK_SPEED` (16) studs a second of the `JetpackFuel` it was given (3 s,
  3.6 shiny), plus `LIFT_GRACE` (3).

Before, the server checked only speed and stamina, so a changed client could fly up for the whole turn. Normal play
is unchanged: jumps, steps, slopes and jetpack flights stay within the limits.

**Where.** `_checkSnail` (its Path and Height phases), `_getJumpHeight` and `_isGrounded` in
`SnailControl/Scripts/Server/Control.lua`; `LIFT_GRACE` in `SnailControl/Settings.lua`.

**How to check.** In a Studio match on your turn: walking and jumping until the stamina runs out, or a jetpack flight,
keeps the turn. Moving the snail up by script about 50 studs a second logs "flew higher than its jump and jetpack
reach - snapped back"; moving it 5 studs down into the ground logs "went through the terrain - snapped back". All four
were checked on Picnic Plains on 2026-11-07. A jetpack flight in open sky wasn't tried (the test flight hit a ledge at
24 studs); by the numbers it climbs about 43 studs past its reach, under the 51 allowed.

**For the wiki.** Architecture: the server's movement checks (path, speed, height with the jetpack, stamina). Players
see nothing new; probably only a History line.
