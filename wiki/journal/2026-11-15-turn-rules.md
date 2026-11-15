---
title: "Hurt no longer ends a turn; after a throw you keep moving until it bursts; the timer stays, greyed, after the shot"
date: 2026-11-15
status: open
kind: changed
pages: ["Turns", "Match HUD", "Lava"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Fire.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Blast.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Combat/Scripts/Server/Behaviors/Roller.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.**

- **Hurt doesn't end a turn.** A turn ends only with the shot or the timer. A fall, lava's burn or any other damage
  before the shot no longer cuts it short. Supersedes the 2026-11-12 "hurt ends the turn" rule; lava's burn still
  ticks the same.
- **Throw, then run.** After a thrown or launched shot (every `Arc` or `Target` weapon: Grenade, Black hole grenade,
  Bazooka…) the player keeps moving their snail with the stamina left until the shot bursts. The blast takes the
  snail back first (Combat's `Blast._takeBack`), as does a hit on it or an open black hole drawing it; guns and swings
  still end the move at once. Dynamite is unchanged (its 3 s retreat with full stamina).
- **The timer stays.** Once the shot is away the HUD's timer stays on the time that was left, grey
  (`TIMER_SPENT_COLOR` 140, 140, 150), until the turn ends; it used to blank. The stamina bar stays up while the
  player can still move after a throw.

**How to check.** Throw a grenade and walk away before it bursts. Fall from high on your turn: you lose health and can
still shoot.

**For the wiki.** Turns: what ends a turn, running after a throw; Match HUD: the greyed timer.
