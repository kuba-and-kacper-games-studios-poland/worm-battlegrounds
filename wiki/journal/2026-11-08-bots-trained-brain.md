---
title: "Bots think with a trained brain; map-aware; secret Nightmare difficulty"
date: 2026-11-08
status: open
kind: changed
pages: ["Match modes & maps", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Data/Brains.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Brain.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Sim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Gym.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Snails/Scripts/Server/Health.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Global.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
---

**What changed.** Bots no longer follow fixed rules or miss on purpose. Each turn a bot's brain lists the spots it can
walk or jetpack to, the enemies it can aim at and every usable weapon, solves each shot exactly for the wind it reads,
simulates the best ones with the game's own shot physics (bounces, fuses, bomblets, blasts, knockback, craters, the
sea) and picks the plan its difficulty's trained weights score best. It weighs damage and knockouts, friendly fire and
its own safety, ammo, and the spot itself: a deadly edge nearby, thin ground or a floating ledge a blast would drop it
through into the sea, low ground as sudden death nears, height, being seen by enemies, crowding friends. Hard and
Nightmare also aim at the ground under enemies to blast it away and drop them into the sea, and every bot digs through
terrain when nothing is in sight. Bots pick their drop spot the same way, focus wounded enemies, and hold a grudge
against whoever hit them last.

Difficulty is now skill, not deliberate misses (`SKILLS` in Bots' Settings): the hand's error (Easy 9°, Medium 4.5°,
Hard 1.8°, Nightmare 0.8° of aim; 0.1 / 0.06 / 0.025 / 0.012 of power), which narrows as a bot keeps shooting at the
same target from the same spot (walking its shots in); how much of the wind it reads (0.3 / 0.7 / 1 / 1); how many
spots (2 / 4 / 7 / 10), targets (1 / 2 / 3 / 4) and aim points (1 / 1 / 3 / 4) it weighs; how much it minds the map
(0.5 / 0.75 / 1 / 1). The old `HIT_RATE`, `MISS_*`, `CLOSE_IN_CHANCE`, `HEAL_BELOW`, `GOOD_MISS` settings are gone.

**Nightmare** is a new, secret difficulty: not on the board (MatchBoard's `SOLO_DIFFICULTIES` is unchanged), no coin
reward set (`SOLO_COINS` has no Nightmare row). Loadout: Hard's plus a Grenade. How players reach it is still the
owner's call.

**Training.** The weights were trained by self-play in Studio (the Bots gym, the `train-bots` skill), five Studios at
once, 8 generations of 10 genomes, 10 matches each, then a 10-match exam against the starting weights (mean points per
seat; 1 is a win):

| Difficulty | Shipped | Exam | Play in the exam |
| --- | --- | --- | --- |
| Easy | starting weights (training didn't beat them: 0.55 vs 0.58) | | hit 28%, 8.5 damage a shot |
| Medium | seed 41 | 0.94 vs 0.37 | hit 41%, 12.8 damage a shot |
| Hard | seed 21 (beat seed 22's champion 0.92 vs 0.40 head-to-head) | 0.97 vs 0.49 | hit 43–53%, 17–20 damage a shot |
| Nightmare | seed 31 (beat seed 32's 0.77 vs 0.70 head-to-head) | 0.94 vs 0.55 | hit 46–61%, 21–30 damage a shot |

Trained styles: Hard guards its own life above all (it never risks the sea) and heals under 114; Nightmare goes for
raw damage, spends limited weapons freely, likes high ground and close range, and heals late (under 64); Medium plays
for knockouts and avoids friendly fire.

**Where.** The brain in `Bots/Scripts/Server/Brain.lua`, shot solving and the hand's error in `Aim.lua`, outcome
prediction in `Predict.lua`, the weights in `Bots/Data/Brains.lua`, skills in `Bots/Settings.lua` (`SKILLS`,
`LOADOUTS`). Bots pick their drop with `I.Bots.GetStart` (Match's `Phases.lua`). Snails now carry a `LastAttacker`
attribute (`Snails/Scripts/Server/Health.lua`). `I.G_Combat` gained `NewBody`, `StepBody`, `GetBodySnail`;
`I.Arena` gained `GetSeaLevel`.

**How to check.** Studio, Match map (Medium bots): bots walk, fly, switch weapons and hit; one blasted the player's
snail off its ledge from 47 down to 24 studs (40 damage). Gym logs show sea knockouts by throws and drops on Hard and
Nightmare. Not checked live: Hard and Nightmare bots in a real match (only in the gym).

**For the wiki.** Match modes & maps: how bots play at each difficulty (skill, loadouts), that they learn by self-play,
Nightmare (private until the owner releases it). Match modules: the Bots module's brain and gym.

Supersedes 2026-11-08-bots-move: its moving and closing in still hold (bots walk, jetpack, swing, place Dynamite and
run, heal), but the chances and thresholds it lists are replaced by the trained brain.

**From.** The owner: train the bots by self-play so harder ones feel like real players, use the map, jetpacks and
utilities, mind other players and play in teams; a secret Nightmare difficulty that exploits the map.
