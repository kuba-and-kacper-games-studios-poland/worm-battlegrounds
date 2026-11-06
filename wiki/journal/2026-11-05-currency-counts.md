---
title: "Coin and diamond counts stay on one line; 10,000 and up show short (18.62k)"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Currency", "Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Currency/init.lua
---

**What changed.** The coin count wrapped "100" onto two lines. Counts now have room for one line and sit left by their
icon, and from 10,000 up they show short: 18,620 coins reads "18.62k". The bar is a little wider (480, was 440).

**Where.** Currency gui: `S_Coins` and `S_Diamonds` 104 × 60, `Align = "Left"`, tag attribute
`Currency_ShortFrom = 10000` (ume's `Currency_Slot` abbreviates from it); `U_Bar` 480 wide.

**How to check.** With 100 coins the count is one line; give 18,620 and it reads "18.62k".

**For the wiki.** Currency: how big amounts are shown.
