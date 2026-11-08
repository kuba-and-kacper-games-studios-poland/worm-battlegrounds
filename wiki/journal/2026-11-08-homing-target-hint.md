---
title: "Homing missile says \"Click on a target\", then \"Shoot!\""
date: 2026-11-08
status: open
kind: added
pages: ["Homing missile", "Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
---

**What changed.** With the Homing missile in hand on the player's turn, the power bar's text reads "Click on a
target" until a target is picked, then "Shoot!" until the player starts aiming. While aiming it shows the power as
usual.

**Where.** `Aim._step` writes MatchHud's `TARGET_HINTS` (`Pick`, `Shoot`) to the power bar's status label.

**How to check.** Studio match (2026-11-08): picking the Homing missile showed "Click on a target" on the power bar.
"Shoot!" after the click wasn't seen: the test snail was knocked out first.

**For the wiki.** Homing missile and Match screen: how to fire it (click the target, then drag and let go). Also
found and not changed: on a gamepad there's no way to pick a target, so the Homing missile can't be fired with a pad.
