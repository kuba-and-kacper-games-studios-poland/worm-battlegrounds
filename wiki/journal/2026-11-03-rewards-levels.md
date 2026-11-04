---
title: "Match rewards and levels: coins by place, anti-farming, 100 XP a match, level skins"
date: 2026-11-03
status: open
kind: added
pages: ["Levels & XP", "Currencies & crates", "Match screen", "Lobby & meta modules", "Data & networking"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchRewards/
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/
  - worm-battlegrounds-game/src/global_data/Statistic/Statistic.lua
  - worm-battlegrounds-game/src/modules/Main_Controllers/Leaderstats_Controller/Settings.lua
---

**What changed.** When a match ends, `MatchRewards` pays every player and sends them the Results:

- **Public deathmatch** by size, then place (`DEATHMATCH_COINS`): 2: 50, 15 · 4: 100, 50, 25, 15 · 6: 125, 75, 50,
  30, 20, 15 · 8: 150, 100, 70, 50, 35, 25, 20, 15.
- **Public teams** by number of teams (`TEAM_COINS`): 2: 100, 15 · 3: 100, 50, 15 · 4: 100, 60, 30, 15; a won 2v2
  pays 75 (`TEAM_2V2_WIN`).
- **Solo:** a win only, Easy 20, Medium 35, Hard 60. **Custom and tutorial:** no coins.
- **Anti-farming:** the last two places are paid only after 2 rounds (`ANTI_FARM_ROUNDS`) or a knockout by another
  player. Double Coins doubles. Leavers get nothing.
- **XP:** 100 per public, solo or custom match (`XP_PER_MATCH`, `XP_KINDS`).

`Progression` turns XP into levels up to 100: reaching level L takes `100 × (L−1) + 4 × (L−1) × L / 2` XP (level 2
at 104). Level ups show a toast and give the Prisoner skin at 25, FBI Agent at 50, Wizard at 100 (`LEVEL_REWARDS`).
New statistics: `XP`, `MatchesPlayed`, `Wins`, `Knockouts`, `DamageDealt`. The player list shows Level and Wins.

**Where.** `I.Progression.AddXP` / `GetLevel`, Topic `Progression_LevelUp`; remote `Match_Results(placements, stats,
earned)`; Replicator `Progression` (`Level`, `XPIntoLevel`, `XPForLevel`) and the `Level` Player attribute.

**How to check.** End a Studio match: Results show the coins and +100 XP, and the replicator's `XPIntoLevel` goes up.

**For the wiki.** Levels & XP (the curve and rewards), Currencies & crates (match coins), Match screen → Results.
Results' best shot shows the damage only, not the weapon.
