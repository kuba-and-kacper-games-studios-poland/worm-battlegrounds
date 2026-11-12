---
title: "The next turn waits: 3 s after a shot or a hit, until nobody's in the air, 5 s stall, 20 s cap"
date: 2026-11-12
status: open
kind: changed
pages: ["Turns"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
---

**What changed.** After a turn, the match waits for the arena to settle before the next snail plays. After a shot, or
anyone getting hurt (a hit, a fall, pond damage), it waits for 3 s of calm (`HIT_HOLD`), up from 0.3 s
(`SETTLE_HOLD`, still used after a turn with no shot and no hurt). Calm now also needs every snail standing on
something or in a liquid, so a snail still in the air keeps the turn waiting, and any health change restarts the
wait. If nothing moves and nobody gets hurt for 5 s (`STALL_SECONDS`), the turn moves on anyway (a snail stuck off
the ground, later a mine that never goes off), and after 20 s of settling it always does (`MAX_SETTLE`, was 6).

**Where.** Match's `Turns._settle(hit)` (watches every alive snail's `Health`, `I.Snails.IsSettled`,
`I.Arena.IsSettled`, `I.Combat.IsIdle`, and the new `_areLanded`: `I.Snails.IsGrounded` or `I.Arena.GetLiquid`).

**How to check.** In a Studio bot match the Settle phase lasted 3.0 to 3.4 s after every shot, and 0.3 s after an idle
turn that ran out.

**For the wiki.** Turns: the wait after a shot (3 s, longer while snails fly), and the 20 s limit. Future hazards
(mines, fire) keep the turn waiting by moving or hurting snails.
