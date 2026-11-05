---
title: "Currency bar shows the player's coins and diamonds (was stuck at 0)"
date: 2026-11-05
status: open
kind: fixed
pages: ["Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Currency/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/Currency/_meta/README.md
---

**What changed.** The coin and diamond counts in the top-right currency bar always showed 0. They now show the
player's amounts and follow every change (checked in a Studio playtest: a new player's 100 coins plus 125 added
showed 225).

**Where.** Each count is ume Currency's `Currency_Slot` component, which needs its `Currency_UIScale` ObjectValue to
point at a UIScale; both were empty, so the slot warned (`Currency_UIScale does not reference a UIScale!`) and
stopped before connecting. The Currency gui now puts each icon and its count on a transparent frame with its own
UIScale (`S_CoinsScale`, `S_DiamondsScale`), and the exported copy in StarterGui points `S_Coins` and `S_Diamonds`'s
`Currency_UIScale` at them (a step after every export, in the gui's README → Setup). The layout is unchanged.

**How to check.** In a playtest, the bar shows the player's coins; `I.Currency.Add(player, "Coins", "125")` raises it
by 125, and the Output has no `Currency_UIScale` warning.

**For the wiki.** Lobby: nothing to change if the page already says the bar shows coins and diamonds. If orbs are
ever turned on (`Currency_SpawnOrbs`, off on both counts), each orb flying in makes the icon and count pop (up to
×1.5); that isn't in the game today.
