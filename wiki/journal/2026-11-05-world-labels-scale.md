---
title: "Worm tags, drop markers and damage numbers scale with the screen; big centred health"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Match screen", "Worms"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/WormTag/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/DropMarker/init.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/DamagePop/init.lua
  - worm-battlegrounds-gui/src/themes/WormBattlegroundsBrawl/Styles/Progress.lua
  - worm-battlegrounds-game/src/modules/Utils/ScreenScale/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Worms/Scripts/Client/Tags.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Client/DropPicker.lua
---

**What changed.** The labels over the world now grow and shrink with the screen like the rest of the screen's guis.
The worm tag was a fixed 240 × 200 px on every screen (about half the height of a phone); now it's 240 × 240 at
1080p and 108 px wide on a 667 × 375 phone. The drop marker (240 × 100) and the damage number (160 × 100) scale the
same way. On the tag, the health number is big (48 at design size, was squeezed to about 18 px) and centred over the
bar, and the tag stacks up from the bar, which sits nearest the worm.

**Where.** `I.ScreenScale.AddBillboard(billboard)` (new, ScreenScale client) sets each label's `S_ScreenScale` to
the screen's scale (height / 1080, width / 1920 on narrow screens, ×1.3 on short phones; no device scale) and its
size to the root's design size times it. Called by `Tags.lua` for every WormTag and DamagePop, and by
`DropPicker.lua` for every DropMarker. The health number is the kit theme's `Progress` `Health` style
(`StatusAlign` Center, `TextSize` Heading).

**How to check.** In a match, the tags over worms are about as big for the screen as the hud; resize the window and
they follow. The health number is centred over the bar.

**For the wiki.** Match screen (or Worms): the tag shows the name, level, health number and bar, and scales with the
screen; health is the big number. Still undecided: the bar's colour (team or health) and whether the tag keeps the
turn timer.
