---
title: "Guis fit narrow windows and short phones (scale floor follows the width, panels capped to the screen)"
date: 2026-11-10
status: open
kind: fixed
pages: ["Match screen", "Controls & platforms"]
files:
  - worm-battlegrounds-game/src/modules/Utils/ScreenScale/Client.lua
  - worm-battlegrounds-game/src/modules/Utils/ScreenScale/Settings.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
---

**What changed.** On a narrow PC window the HUD's top corners, turn timer and emote button squashed and overlapped,
and on short phones some windows grew past the screen. Now the smallest scale on PC and console (0.6) shrinks with a
window narrower than 1024 px, a window's panel is never scaled past 86 % of the screen, and the HUD's top-left and
top-right team blocks, the timer block and the emote button keep their design's shape at any size; the turn banner's
text block is sized from the banner's height. Checked by building every gui at 970 × 1400, 667 × 375, 844 × 390,
1024 × 768 and 1920 × 1080 in Studio: all fit.

**Where.** ScreenScale's `MIN_SCALE_WIDTH` 1024 and `FIT_MARGIN` 0.86 (`_fitScale` caps a panel straight on its
ScreenGui). MatchHud gui: `UIAspectRatioConstraint`s on `U_EmoteButton` (1.2498), `U_Turn` (2.7496), `TopLeft` and
`TopRight` (3.8098), and `U_TurnCallout` › `S_Content` (5.0203, height 0.9 of the band).

**How to check.** Shrink the Studio window to about 970 px wide during a match: the team blocks, timer and emote
button keep their shape and don't overlap.

**For the wiki.** Controls & platforms: supported screen sizes, if the page lists them.
