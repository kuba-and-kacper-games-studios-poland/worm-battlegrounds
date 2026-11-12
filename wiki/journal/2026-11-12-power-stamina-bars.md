---
title: "Power and stamina bars use the studio's PowerSlider"
date: 2026-11-12
status: open
kind: changed
pages: ["Match screen"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
---

**What changed.** The HUD's power (charging a shot) and stamina (walking) bars follow the studio's `PowerSlider`:
the bar picture fits its box and its texture is cut at the same edge, so both empty and fill together from 0 to
full. The HUD has no jetpack fuel bar, so nothing else changed.

**Where.** `U_Power` and `U_Stamina` (`S_Bar`, `S_BarMask`) in the MatchHud gui; `Aim.lua` and `Turn.lua` put one
`UIGradient` cut on both; `BAR_FILL` stays 1.

**How to check.** In a Studio match, hold to charge a shot, and walk: both bars track their values.

**For the wiki.** Match screen: only if it describes the bars' look. Unsure: the fill wasn't watched in this
playtest.
