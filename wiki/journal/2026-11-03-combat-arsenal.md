---
title: "Weapons and utilities fire: Arsenal rows and the Combat module"
date: 2026-11-03
status: open
kind: added
pages: ["Arsenal", "Match modules", "Data & networking", "Roadmap"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/
  - worm-battlegrounds-game/src/modules/Main_Game/WormControl/Scripts/Server/Effects.lua
---

**What changed.** Every weapon and utility on the Arsenal page has a row in `Arsenal/Data/Weapons/` and
`Arsenal/Data/Utilities/` (14 weapons, 6 utilities), and the `Combat` module fires them on the server: rockets,
bouncers (grenades, cluster bombs, dynamite), crawlers (Spider Bomb and its snails), homing missiles, rollers (Black
Hole Grenade, detonated by a second press), hitscan guns (Shotgun, Uzi, Minigun) and melee (Baseball Bat, Spartan
Spear, One Punch). Blasts carve craters, damage from `DamageMax` at the centre to `DamageEdge` at the edge, and knock
worms back by class (`KNOCKBACK`: Small 20, Medium 45, High 70, VeryHigh 95, Extreme 130). Shiny weapons do ×1.05
(`SHINY_DAMAGE_MULTIPLIER`). Uses and cooldowns count per match. The movement utilities are WormControl effects:
parachute (fall speed 6, no fall damage), jetpack (3 s of fuel at 16 studs/s), speed potion (×1.5), low gravity (×0.4);
a shiny copy multiplies them by `SHINY_BOOST`.

**Where.** `I.G_Arsenal` (`Get`, `GetDamage`, `GetKnockback`); `I.Combat` (`Fire`, `UseUtility`, `Detonate`,
`Explode`, `Hit`, `CanUse`, `GetUses`); `I.G_Combat.PredictArc` for aim dots and bots. Remotes: `Combat_Select`,
`Combat_Fire` (item, angle, power 0–1, homing target), `Combat_UseUtility`, `Combat_Detonate`, `Combat_Aim`
(unreliable); `Combat_Explosion`, `Combat_Hit`, `Combat_Tracer` to everyone. Topics `Combat_ShotFired`,
`Combat_ShotResolved`. Replicator `Combat`: `Slots`, `Uses_<item>`, `Cooldown_<item>`. Worm attribute `DamageTaken`
multiplies damage taken.

**How to check.** In a Studio match, fire each weapon from the loadout bar: craters appear, health drops by the row's
numbers, and a weapon with `Uses` runs out.

**For the wiki.** Arsenal: confirm each row's numbers against the code (the rows are the source now). Match modules →
Combat and Data & networking → remotes. Effects and projectiles are placeholders (plain balls and parts, no particles
or sounds).
