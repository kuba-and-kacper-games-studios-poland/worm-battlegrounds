---
title: "Health and stamina labels read \"Health · 200\", closer to their bars"
date: 2026-11-25
status: open
kind: changed
pages: ["Match HUD"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/Preview.lua
---

**What changed.** The bars' labels read "Health · 200", "Stamina · 100%" and "Jetpack · 70%" (a middle dot between the
name and the value, as in the aim's "62% · 41°"), and sit closer over their bars (0.25 → 0.29 down their frame).

**Where.** MatchHud's `HEALTH_FORMAT`, `STAMINA_FORMAT`, `FUEL_FORMAT`; the gui's `U_Health`, `U_Stamina`, `U_Fuel` ›
`S_Text`.

**How to check.** In a match, bottom left: "Health · 200" just over the red bar. Checked in Studio.

**For the wiki.** Any Match HUD text quoting "Health 200" takes the new form.
