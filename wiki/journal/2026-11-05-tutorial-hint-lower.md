---
title: "Tutorial hint hangs lower (27 % down), clear of the taller turn panel"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Match screen"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/TutorialHint/init.lua
---

**What changed.** The tutorial's hint bubble hangs from 27 % down the screen (was 21 %). On the bot's turn the turn
panel is taller now (the bot's name and the player's wait), and on a phone the hint ("The bot's turn. Watch out!")
covered its bottom by 16 px. It clears it now by 6 px on a 667 × 375 phone, and still sits well above the lobby's Play
row.

**Where.** TutorialHint gui `U_Hint`: `Position = UDim2.fromScale(0.5, 0.27)`.

**How to check.** Play the tutorial on a phone-sized screen and wait for the bot's turn: the hint sits under the turn
panel.

**For the wiki.** Probably nothing; the Match screen page if it shows where the tutorial's hints appear.
