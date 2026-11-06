---
title: "Results: placings as a lineup of player cards, stats in the earnings box"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Match screen"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Results/init.lua
---

**What changed.** The end-of-match screen showed the placings as a list of wide rows, and only about 1.7 of them fit
before it had to scroll. Now each player gets a tall card (place, avatar, name in team colour, coins), side by side:
four fit across on a 16:9 screen, and on a phone six of eight show and the rest scroll. The match stats (damage
dealt, knockouts, best shot) moved into the "You earned" box as its second line, so there's one box under the
lineup instead of two.

**Where.** `U_Placings` uses the theme's `Players` cells (cards 200 × 300 at design size, `PlayerCard` /
`PlayerCardTall` tokens); `PREFAB | Placing` is a vertical card; `U_Stats` is gone and its labels (`S_Damage`,
`S_Knockouts`, `S_BestShot`) sit under `U_Earned`. MatchHud's `Scripts/Client/Results.lua` finds every label by
name, so it didn't change.

**How to check.** Finish a match with 4 players: all four cards show at once, the stats line sits under the
earnings, and Rematch and Back to lobby are still at the bottom.

**For the wiki.** Match screen: describe the results as a lineup of player cards with the earnings and stats under
it, if the page describes the results layout.
