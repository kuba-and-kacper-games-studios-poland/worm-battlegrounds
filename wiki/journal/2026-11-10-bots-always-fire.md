---
title: "Bots never pass a turn: with no plan they fire the Bazooka toward the nearest enemy"
date: 2026-11-10
status: open
kind: changed
pages: ["Match modes & maps", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/_meta/README.md
---

**What changed.** A bot whose brain found no plan (no shot at anyone and nothing to dig through) used to stand still
until its turn ran out. Now it always fires: the Bazooka at the nearest snail not on its team, on the first arc that
reaches it, or, when no arc reaches, lobbed at 45° toward it (135° when it's to the left) at full power. It aims and
charges on screen like any bot shot. The same goes for a bot playing a dropped player's snail. Only with no enemy left
does it fire nothing.

**Where.** `Module._fireAnyway(participantId, model)` in `Bots/Server.lua`, called from `Module.TakeTurn` when
`Brain.GetPlan` returns nil: once after thinking, and again after a walk that ended off its spot and planned again.
The target is the nearest alive snail whose `Team` attribute differs from the bot's; the arc is
`I.Combat.GetArcs(origin, target, "Bazooka", wind, POWER_STEPS)[1]` (the lowest power in `POWER_STEPS`, 0.4 to 1 by
0.1, that reaches), else `Vector2.new(math.rad(45 or 135), 1)`. It shows the aim with `_showAim`, then
`I.Combat.Fire`. The arc is solved in open air: it isn't checked against the terrain, so the shot may hit ground in
the way.

**How to check.** In Studio, a match against an Easy bot with the bot boxed in or far out of reach (or every enemy
behind terrain): on its turn it swings its crosshair and fires the Bazooka toward you instead of waiting out the timer.
Not checked in Studio by the docs pass.

**For the wiki.** Match modes & maps (bots): bots always take a shot on their turn. Match modules: Bots fire anyway
with no plan.
