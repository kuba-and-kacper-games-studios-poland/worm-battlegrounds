---
title: "Turns 15 s → 25 s, walking stamina 20 → 40 studs"
date: 2026-11-12
status: open
kind: changed
pages: ["Turns", "Movement"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/SnailControl/Settings.lua
---

**What changed.** A turn lasts 25 seconds (was 15), and a snail may walk 40 studs a turn (was 20), twice as far.

**Where.** Match's `TURN_SECONDS` (25); SnailControl's `STAMINA_STUDS` (40). The HUD's stamina bar and the bots read
`STAMINA_STUDS`, so they follow.

**How to check.** In a match the turn timer starts at 25; walking from full stamina empties the bar after 40 studs.

**For the wiki.** Turns: the turn length. Movement: how far a snail walks a turn.
