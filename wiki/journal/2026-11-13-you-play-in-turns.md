---
title: "The turn line reads \"You play in N turns\""
date: 2026-11-13
status: open
kind: changed
pages: ["Match screen"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
---

**What changed.** The top-middle line and the turn callout read "You play in 2 turns" (was "Your turn in 2 turns").

**Where.** MatchHud's `Turn.lua` (both texts); the gui's sample text.

**How to check.** On someone else's turn the top middle reads YOU PLAY IN N TURNS.

**For the wiki.** Match screen: the text and its screenshot.

**From.** The testers: "instead of your turn in 2 turns, it says you play in 2 turns".
