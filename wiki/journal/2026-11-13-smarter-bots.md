---
title: "Smarter bots: they dig toward enemies, take cover, mind walls, ceilings and ponds; Nightmare shoots in flight"
date: 2026-11-13
status: open
kind: changed
pages: ["Match modules", "Match modes & maps"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerData/Brains.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Brain.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Move.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Sim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Gym.lua
---

**What changed.** The bots' brain, asked for by the owner:

- **Out of reach, they shoot toward you or dig.** A shot that hurts nobody is worth the genome's `Pressure` the
  nearer it lands to an enemy (none from `PRESSURE_RANGE` 30 studs). With no arc reaching anyone, they aim at the
  terrain on the way to each target, every `DIG_STEP` 8 studs from `DIG_MIN` 10 out. The no-plan fallback shot now
  takes the arc landing nearest the enemy and never within 10 studs of itself (it used to fire 45° at full power,
  which could fall back on its head).
- **They walk to better spots and take cover.** Spots under terrain within `COVER_HEIGHT` 12 studs are cover
  (genome `Cover`). Walks are checked step by step for walls and ceilings (`Move.CanStep`); flights rise first, keep
  `HEADROOM` 1.5 studs under ceilings and give up on a wall after `WALL_JUMPS` 2 jumps.
- **Ponds are a danger.** A spot with its head in a pond costs Match's `UNDERWATER_DAMAGE` × `POND_TURNS` 3 in its
  danger score.
- **Teammates.** Knocking out the last enemy adds `WIN_VALUE` 6, so a bot hurts its own side only when that wins.
- **Nightmare** weighs 4 spots in the air (`AirShots`), hovering on its jetpack at least `AIR_MIN` 5 studs up, and
  shoots from there; it picks players over bots a little (`Hunt` 0.5), and weighs 12 spots and 16 finalists (were 10
  and 14). The other difficulties' skills are unchanged.
- **Genomes.** Every row gained `Pressure` and `Cover`. Trained on the PC gym (10 generations of 16, 64 matches each,
  48-match exam, seed 11, all four maps). PC exams, champion against shipped, points per seat: Easy 0.624 vs 0.626,
  Medium 0.675 vs 0.633, Hard 0.832 vs 0.624, Nightmare 0.678 vs 0.785. Studio exams (24 matches): Medium 0.782 vs
  0.575, Hard 0.708 vs 0.646. So Medium and Hard ship their champions; Easy and Nightmare keep their old weights, with
  `Pressure` 0.3 and `Cover` 0.1 added.
- **Medium's new genome** (was → now): EnemyDamage 1.085 → 1.226, Focus 0.275 → 0.137, AllyDamage 2.921 → 2.383,
  AllyKnockout 3.047 → 1.229, SelfDamage 0.441 → 0.182, SelfKnockout 4.498 → 2.997, Ammo 0.052 → 0.297, Walk 0.09 →
  0.207, Height 0.238 → 0.412, Footing 0.391 → 0.314, HealBelow 76 → 70; Pressure 0.104, Cover -0.002. Plays: hit 36 %,
  own side 5 %, moves 68 % of turns.
- **Hard's new genome:** EnemyDamage 0.267 → 0.742, Knockout 0.566 → 0.345, AllyDamage 0.555 → 0.139, AllyKnockout
  3.005 → 6.361, SelfDamage 1.22 → 0.278, SelfKnockout 5.467 → 3.712, Exposure 0.174 → 0.355, Crowd 0.155 → -0.168,
  HealBelow 114 → 140; Pressure 0.141, Cover -0.342 (it prefers open ground to shoot from). Plays: hit 47 %, 20.6
  damage a shot (was about 17), own side 4 %.

**Where.** `Brain.lua` (`_getSpots`, `_getSpot`, `_getAirSpot`, `_getPlace`, `_getTargets`, `_simulate`), `Move.lua`
(`WalkTo`, `Hover`, `CanStep`, `CanFly`, `GetLanding`, `GetCruise`), `Server.lua` (`_walk`, `_land`, hovering while
it aims, `_fireAnyway`), `ServerSettings.lua` (`SKILLS`, the new keys), `ServerData/Brains.lua`.

**How to check.** Play a custom lobby with Hard bots on Rockslide Ridge: they walk along ledges without jumping into
the walls, and one with no arc to you blasts the ground toward you. Nightmare sometimes rises on its jetpack and
fires from the air. Not yet watched in a full Studio playtest: walls, ceilings and hovering were checked only in the
PC gym and in code.

**For the wiki.** Match modules (Bots): how a bot plans now (pressure and digging, cover, ponds, the win bonus,
walls and ceilings, Nightmare's air shots), the new genome keys, and a History line. Match modes & maps: nothing new
for players beyond smarter bots. Keep Nightmare's details private (it's secret).
