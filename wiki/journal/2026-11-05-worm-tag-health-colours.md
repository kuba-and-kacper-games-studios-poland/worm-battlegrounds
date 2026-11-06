---
title: "Worm tag: health bar green to yellow to red, no turn timer on the tag"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Match screen", "Worms"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Worms/Scripts/Client/Tags.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Worms/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/WormTag/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/Turn.lua
---

**What changed.** The health bar on a worm's tag shows health by colour: green at full, yellow at half, red near empty,
blended in between (it was tinted in the team's colour). The worm's name keeps the team colour (gold for VIP). The
worm whose turn it is shows only its down arrow over the tag; the turn's seconds are no longer written on the tag,
only on the turn panel.

**Where.** `Worms/Settings.lua` (Tags): `HEALTH_FULL_COLOR` (156, 240, 90), `HEALTH_HALF_COLOR` (255, 176, 32),
`HEALTH_EMPTY_COLOR` (255, 110, 96). `Tags.lua` `_refreshTag` sets the bar's `Fill` colour from `_getHealthColor(share)`.
WormTag gui: `S_Active` holds only the arrow (`S_Timer` removed); MatchHud's `Turn.lua` no longer writes a tag timer
(`_setTagTimer` removed).

**How to check.** Hurt a worm: at 115 of 200 its bar is yellow-green, at 45 orange-red. Play-tested: full worms green,
115/200 yellow, only the active worm's arrow shows.

**For the wiki.** Match screen and Worms: the tag's bar colours, and that the timer is only on the turn panel. This
supersedes the tag half of `2026-11-05-turn-timer` ("it now counts on the active worm's tag too"); its other half
(blank while a shot flies) still holds.
