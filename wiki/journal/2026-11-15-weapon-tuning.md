---
title: "Golf club 12, One Punch 48, Shotgun fires twice (2 × 20), black hole after 5 turns"
date: 2026-11-15
status: open
kind: changed
pages: ["Black hole grenade", "Golf club", "One Punch", "Shotgun", "Weapons"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arsenal/Data/Weapons/
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Hitscan.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Client/Held.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Predict.lua
---

**What changed.** The owner's 15 Nov list.

- **Golf club** (`BaseballBat`): 12 damage, down from 60 (80% weaker). Knockback unchanged (`VeryHigh`).
- **One Punch:** 48 damage, down from 80 (40% weaker). Knockback unchanged (`Extreme`).
- **Shotgun:** fires two blasts 1 s apart (`Volleys` 2, `VolleyInterval` 1), each 5 pellets of 4 damage
  (`PerBulletDamage`, was 10): 20 a blast, 40 if every pellet hits. The snail plays its shotgun recoil for each blast.
- **Black hole grenade:** `Cooldown` 5, so it waits 5 of the player's turns and is usable from their 6th, like One
  Punch. Bots obey cooldowns too (their brain only sees what `I.Combat.CanUse` allows).

**Where.** The rows in `Arsenal/Data/Weapons/`; the volleys in Combat's `Hitscan.Run` / `_fireVolley`; Bots' `Predict`
counts both volleys.

**How to check.** Shotgun a snail point blank: two blasts a second apart, up to 40.

A 70% longer range for every thrown shot (launch speeds 26–235) was tried the same day and taken back by the owner
before shipping ("this is bad"): launch speeds stay 20–180.

**For the wiki.** Each weapon's stats (damage, speeds, cooldown), the Shotgun's two blasts, a History line.
