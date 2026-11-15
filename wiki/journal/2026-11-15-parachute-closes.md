---
title: "Parachutes close in water or lava and after the landing (stuck spawn fixed)"
date: 2026-11-15
status: open
kind: fixed
pages: ["Parachute", "Volcano Isle"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Scripts/Server/Effects.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua

---

**What changed.** A snail that dropped in by Volcano Isle's chamber pool kept its parachute open and couldn't
move. A parachute closed only when the snail touched ground after being airborne, so landing in a liquid, or being
set straight onto ground, left it open. Now it also closes in water or lava, and the landing closes every parachute
still open before the first turn.

**Where.** SnailControl's `Effects._checkParachutes` (closes in liquid: `I.Arena.GetLiquid`) and new
`I.SnailControl.CloseParachute(participantId)`; Match's `Phases._land` counts a grounded snail as down and closes all
chutes after the wait.

**How to check.** At the first turn of any match no snail has its `Parachute` attribute; checked in Studio.

**For the wiki.** Parachute or the match start: nothing a player reads changes, beyond no snail being stuck.
