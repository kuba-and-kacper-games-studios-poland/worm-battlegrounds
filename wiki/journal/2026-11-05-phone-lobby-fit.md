---
title: "Phone lobby: smaller logo between Party and the coins; corner buttons below the bar"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Lobby/init.lua
---

**What changed.** On phones the game's name at the top ran under the Party panel and the coin bar. It's smaller there
now and fits between the Party tab and the bar. The Crates and Skins buttons moved down a little so they clear the bar.
PC is unchanged.

**Where.** Lobby gui: `U_Logo` `Utils_MobileScale` 0.4 (was 0.7); `U_Menu` at y 0.165 (was 0.11).

**How to check.** On a 667 × 375 phone the name ends 16 px before the coin bar and starts 42 px after the Party tab.

**For the wiki.** Lobby: no change to describe beyond the layout; a screenshot refresh if the page has one.
