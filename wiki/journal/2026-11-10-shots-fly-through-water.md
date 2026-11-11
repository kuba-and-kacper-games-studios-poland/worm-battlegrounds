---
title: "Shots fly on through water and lava, slowed, instead of blowing up"
date: 2026-11-10
status: open
kind: changed
pages: ["Arsenal", "Match modes & maps", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Helpers/Ballistics.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Bouncer.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Rocket.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Homing.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Crawler.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
---

**What changed.** Water and lava (the sea and ponds alike) no longer set a shot off. A shot that enters liquid loses
half its speed as it splashes in, then flies on under it, slowed and pulled down more gently, and bursts on what it
touches there (the ground under the water, a snail) or when its fuse runs out. One that's under for 4 seconds
without touching anything is gone without a blast. This covers the Bazooka, Grenade, Dynamite, Cluster bomb and its
bomblets, Variety grenade, Homing missile, the Spartan spear (no longer a special case: it sticks where it lands
under the water) and the Spider bomb's throw. Still ending in liquid: the Black hole grenade bursts as it rolls in,
the Spider bomb bursts if it crawls in, and the Variety grenade's worms drown there.

**Where.** `Ballistics.Step` sets `body.Sunk` each step (in liquid now) and on entry multiplies the velocity by
`SINK_ENTRY_KEEP`. Combat settings, before → after: `SINK_ENTRY_KEEP` new, 0.5; `SINK_GRAVITY` 0.15 → 0.3 (share of
gravity under liquid); `SINK_KEEP` 0.05 → 0.12 (share of speed kept per second of the shot's own, slowed time);
`SINK_SECONDS` 1.5 → 4 (real seconds under before it's gone, `Projectiles.IsGone`). The behaviours' flight loops no
longer burst on `body.Sunk`; Roller still does. The bots' `Predict._fly` follows the same rules.

**How to check.** On Desert, place Dynamite in the oasis: it sinks, settles on the bottom (shots under liquid
don't bounce) and bursts when its fuse runs out. Fire the Bazooka into the sea: it carries on under the surface and
bursts on the island's side. Not checked in Studio by the docs pass.

The 4 s under-liquid limit (real seconds) only counts while a shot is still sinking: one resting on the ground under the
liquid (a Grenade on the pond's floor) waits for its fuse, so it always bursts.

**For the wiki.** Arsenal: replace the tip that explosives go off in water and lava with "shots fly through water and
lava, slower; the Black hole grenade still bursts in them". Match modes & maps (liquids): the same line. Match
modules: shots no longer sink and fizzle, they're slowed.

**From.** The owner, 2026-11-10: "in water you should be able to shoot through it, projectiles move through water but
slower". Supersedes `2026-11-08-explosives-blow-up-in-liquid` (all of it) and the sinking part of
`2026-11-07-projectile-physics`.
