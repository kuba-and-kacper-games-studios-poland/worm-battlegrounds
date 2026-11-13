---
title: "The wind stays for a whole round, and gusts when it changes"
date: 2026-11-13
status: open
kind: changed
pages: ["Turns", "Match screen", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Turns.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Wind.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
---

**What changed.** The wind was rolled every turn; now it's rolled only once every snail in play has had a turn on it. When it changes, a burst of wind streaks crosses the screen (`WIND_CHANGE_BURST` 40 at full strength, at least `WIND_CHANGE_BURST_MIN` 8) with the gust sound at full volume, and the HUD's wind number flashes.

**Where.** Match's `Turns._rollWind` (`windPlayed`, the `Wind` attribute); Atmosphere's `Wind._gustChange`; MatchHud's `Turn._refreshWind`.

**How to check.** In a 4-snail match the wind number stays the same for 4 turns, then changes with a gust.

**For the wiki.** Turns: the wind is per round. Match screen: the gust and the flash.

**From.** The testers: "wind should be same for one whole round (everyone plays) and add wind vfx when it changes".
