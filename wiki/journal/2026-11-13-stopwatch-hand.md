---
title: "The lobby cards' stopwatch shows its hand"
date: 2026-11-13
status: open
kind: fixed
pages: ["Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
---

**What changed.** The stopwatch beside each lobby card's timer has a white hand. The studio's picture (119838940397311) draws its hand in black inside the dial, which didn't show on the dark card; a white `Hand` frame is drawn over it, so nothing is uploaded.

**Where.** The MatchBoard gui's Row prefab: `TimerIcon` > `TimerIcon` > `Hand` (position 0.51, 0.5, size 0.06 x 0.19, turned 15 degrees). The gui needs exporting again in Studio.

**How to check.** The lobby cards' stopwatch shows a white hand from the center up.

**For the wiki.** Lobby: a fresh screenshot of a card, if one is shown.

**From.** The testers: "stopwatch icon does not have clock hand inside of it".
