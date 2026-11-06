---
title: "Turn panel names whose turn it is, with a clock and a wind picture"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Match screen"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Icons.lua
---

**What changed.** On another worm's turn the turn panel's title is now that worm's name, "BAX'S TURN", in its team's
colour, with the player's wait on a line under it ("YOU'RE NEXT!" or "YOUR TURN IN 3 TURNS"). It used to show only the
wait, in white, and nothing said whose turn it was. On the player's own turn it still says "YOUR TURN!" in white, with
no wait line; once the player's worm is out, the wait line hides and the name stays. The timer has the kit's clock
beside it, and the wind has a new wind picture (three gusts) beside its arrow; the wind now shows only its strength,
"4" (was "Wind 4").

**Where.** MatchHud gui `U_Turn`: `S_Banner` (Title), the new `S_Wait` (Heading), then a row with the `wb-clock` picture
and `S_Timer`, and the `wb-wind` picture, `S_WindArrow` and `S_Wind`. `Turn.lua` `_refresh` writes the banner from the
active worm's `DisplayName` and `Color` attributes and puts the gui's colour back on the player's turn; `_refreshWind`
writes `math.abs(wind)`. The wind picture is the kit's `wind.png` (game home `assets/_inbox/ui_kit_brawl/`), a local
preview (`rbxasset://textures/wb_brawlpreview/…`) until the owner approves uploading it.

**How to check.** In a match with bots, watch a bot's turn: its name in its colour, your wait under it. Play-tested in
an 8-worm match: "NINJA'S TURN" in teal and "YOUR TURN IN 7 TURNS".

**For the wiki.** Match screen: the turn panel's lines (whose turn, your wait, timer with clock, wind picture, arrow and
strength). This replaces the "You're next!" banner from the entry `2026-11-05-your-turn-in` (the wait is its own line
now, under the name). The wind picture isn't uploaded yet: other PCs show a blank space there until it is.
