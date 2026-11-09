---
title: "The power and stamina bars fill all the way at 100% (they stopped at about 70%)"
date: 2026-11-09
status: open
kind: fixed
pages: ["Controls & platforms", "HUD"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Aim.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
---

**What changed.** The owner noticed the power bar at the bottom right never looked full: at 100% power its fill
stopped at about 70%. The bar's picture (the studio's) has its empty end drawn in, so its fill covers only the left
0.744 of the picture's width, and the code cut the bar's gradient at the share of the whole picture. Now 100% fills
the bar to its end, and the power handle stops there too. The stamina bar uses the same picture and had the same
fault; it's fixed the same way.

**Where.** MatchHud's new setting `BAR_FILL = 0.744`. `Scripts/Client/Aim.lua` cuts the power bar's gradient at
`power × BAR_FILL` and places the handle the same way; `Scripts/Client/Turn.lua` cuts the stamina bar at
`share × BAR_FILL`. In the MatchHud gui both `S_Bar` nodes (`U_Power`, `U_Stamina`) are now `ScaleType.Stretch`,
sized `1.2526 × 0.4312`; the gui was exported again to `StarterGui.MatchHud`.

**How to check.** In a match, aim at full power: the power bar's yellow reaches its right end and the handle sits
there, showing 100%. Checked in Studio on 2026-11-09 by measuring the picture's pixels and a playtest copy at full
power.

**For the wiki.** Nothing players need to read, unless the HUD page describes the bars: the power and stamina bars
fill to their end.
