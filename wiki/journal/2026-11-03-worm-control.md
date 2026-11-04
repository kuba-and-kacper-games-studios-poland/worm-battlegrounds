---
title: "Worm movement: walk 8 studs/s, 20 studs of stamina, jump speed 44, server speed check"
date: 2026-11-03
status: open
kind: added
pages: ["Match modules", "Architecture", "Controls & platforms", "Roadmap"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/WormControl/
---

**What changed.** The `WormControl` module exists (server and client), as P2 planned, with these numbers and
differences:

- **Turns:** `I.WormControl.StartTurn(participantId)` gives the worm's physics to its player's client, fills its
  stamina and sets the worm's `CanMove` attribute; `EndTurn` takes it back (server ownership, facing kept). The
  client follows `CanMove`, so there are no remotes. Stamina is a `Stamina` attribute on the worm, not the
  Replicator `Match.Stamina` the wiki planned.
- **Walking:** 8 studs/s (`WALK_SPEED`), A / D, arrows, the left stick (deadzone 0.3) and the d-pad; on touch
  ContextActionService's own ◀ ▶ buttons until the match HUD has its own. While walking the ball has no friction, so
  it slides along walls and up slopes instead of sticking; at rest it grips again. Ledges up to 2 studs
  (`STEP_HEIGHT`) are climbed by walking into them, with a 16 studs/s upward push (`STEP_SPEED`).
- **Jumping:** Space, A on a pad, or the Jump button sets the worm's upward speed to 44 (`JUMP_SPEED`, about 5 studs
  high), replacing the planned `JUMP_IMPULSE`. Jumps are unlimited and cost no stamina, but only start from the
  ground.
- **Stamina:** 20 studs a turn (`STAMINA_STUDS`), charged by the server from the worm's sideways movement. At 0 the
  worm stops walking but keeps its turn and can still jump. Moving on sideways by more than 8 studs
  (`STAMINA_GRACE`, which covers momentum through the air and slides) snaps it back, ends the turn and warns
  `[WormControl::Control]: Worm (P_<id>) walked past its stamina - snapped back.` A first version ended the turn
  at 0, which froze the worm for a moment (mid-jump, in the air) and took its jumps away; fixed the same day.
- **Speed check:** the server compares the worm with where it was up to 0.25 s ago (`CHECK_INTERVAL`); more than
  1.5 × the walk speed sideways (or the jump speed up) over at least one interval, plus 2 studs of slack
  (`SPEED_TOLERANCE`, `MOVE_SLACK`), snaps it back, ends the turn and warns
  `[WormControl::Control]: Worm (P_<id>) moved too fast - snapped back.` Positions reach the server in bursts (up to
  about 70 ms apart in Studio), so the check never allows less than one interval's movement.
- **Controls** bind at `Enum.ContextActionPriority.High` while `CanMove` is on, sunk; the default avatar controls are
  off.
- **Not built:** the utility effects (`ApplyEffect`: jetpack, speed, low gravity, parachute).
- **Shortcut:** `STUDIO_TEST_TURNS` (on): in a Studio test every player gets a worm on each map that loads, and a new
  turn 1 s after one ends or its stamina runs out, until the Match module runs turns. It also prints every
  `Worms_Died`.

**Where.** `WormControl/Server.lua` (`I.WormControl`), `Scripts/Server/Control.lua` (turns, the checks),
`Scripts/Server/StudioTest.lua` (the shortcut), `WormControl/Client.lua` (input, walking, jumping, climbing);
numbers in `WormControl/Settings.lua`. Admin command: `/wormcontrol turn [id]`, `/wormcontrol end [id]`.

**How to check.** In a Studio test, D walks right at once and Space jumps; after about 20 studs `Stamina` reaches 0, the
worm stops walking (`CanMove` stays on, Space still jumps), and a second later the bar refills. Moving the worm
30 studs from the client (its `Root.CFrame`) snaps it back within a second with the "moved too fast" warning;
pushing it on at 11 studs/s from the client once the bar is empty snaps it back after about 9 studs with the
"walked past its stamina" one. All checked in Studio on 2026-11-03, on keyboard only, including 40 jumps in a row
and jumping while walking through three empty bars, with no snap-back.

**For the wiki.** Match modules → WormControl: the attributes instead of Replicator and remotes, `JUMP_SPEED`
instead of `JUMP_IMPULSE`, jumps only from the ground, no grip while walking, the speed check's numbers and
`STAMINA_GRACE`, effects not built. Architecture → the client-owned row and the server checks. Controls & platforms: jumps start from the ground.
Still unsure: touch and gamepad movement weren't tested, and a Studio test turn that starts while the worm is still
falling can trip the speed check (the Match module should start turns once worms settle).
