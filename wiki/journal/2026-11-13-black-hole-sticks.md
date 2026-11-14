---
title: "Black hole: snails slide in and stick to it, and it no longer throws anyone"
date: 2026-11-13
status: open
kind: changed
pages: ["Arsenal", "Black hole grenade"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Roller.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Server/Drag.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/BlackHoleGrenade.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
---

**What changed.** The owner: "make it so black hole bomb does not knock people out but sticks to them… they slowly
move towards it if they're on ground, they like slide towards it". Before, an open black hole threw every snail within
its `PullRadius` (20) at it with one knock (`BLACK_HOLE_PULL_SPEED` 45), and its burst (up to 100 damage) threw them
with `High` knockback, often off the map. Now, for its `HoleTime` (2.5 s):

- every snail within 20 studs (the shooter's teammates aside, the shooter not) is drawn in at Combat's
  `BLACK_HOLE_DRAG_SPEED` (10 studs/s): it slides along the ground toward the hole while the hole is off to its side,
  and drifts straight to it through the air otherwise;
- within `BLACK_HOLE_STICK` (2.5 studs) of the hole's middle it sticks, held still;
- the burst has no knockback (its row's `Knockback` is the new `None` class, 0), so it only damages (100 at the
  middle, 25 at the 14-stud edge), then lets everyone go: they drop from where they were stuck (fall damage counts
  from there, so a hole high in the air still hurts on landing).

**Where.** Combat's `Roller.Run` and `_drag`, `BLACK_HOLE_DRAG_SPEED`, `BLACK_HOLE_STICK` (replace
`BLACK_HOLE_PULL_SPEED`); Snails' new `I.Snails.Drag` and `I.Snails.Release` (`Scripts/Server/Drag.lua`); Arsenal's
`KNOCKBACK.None`; the bots foresee it (`Predict._getPulls`: where each snail is when it bursts).

**How to check.** Studio, 2026-11-13: Nightmare bots threw it onto targets; each target was held anchored at the
hole for the 2.5 s, took 92 to 97 damage, wasn't thrown, and dropped into the crater after. Not seen yet: a snail
sliding in from across the ground (every throw landed beside its target).

**For the wiki.** Black hole grenade: how it draws snails in and holds them, no knockback. Arsenal: its row.
