---
title: "Phones: the turn timer sits higher and smaller, no YOUR TURN line under it"
date: 2026-11-25
status: open
kind: changed
pages: ["Match HUD"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
---

**What changed.** On phones and tablets the turn timer and wind overlapped the aim (the owner: "it can overlap with the
shooting area pretty easily"). There the panel now sits at the top of the HUD (MatchHud's `TURN_MOBILE_POSITION`,
0.012 down) at 0.8 of its size (the gui's `U_Turn` `Utils_MobileSize` 0.1684 × 0.1089), and "Your turn!" under the
timer is left out on the player's own turn (the turn callout and the arrow already say it). Other snails' names and
"You play in N turns" still show. Desktop and console are unchanged.

**Where.** Turn's `_refreshLayout` (on `Platform_Changed`) and `_refresh` (the banner); Settings'
`TURN_MOBILE_POSITION`; the gui's `U_Turn`.

**How to check.** On a phone, on your turn: the timer is higher and smaller, with no YOUR TURN under it. Not checked
on a real phone yet (Studio's device simulator reports Desktop).

**For the wiki.** Match HUD: on phones the timer is at the top, smaller, without the YOUR TURN line.
