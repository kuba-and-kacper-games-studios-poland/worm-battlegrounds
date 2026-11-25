---
title: "Round intro darkens the whole screen on every device, not a box"
date: 2026-11-25
status: open
kind: fixed
pages: ["Match HUD"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Scripts/Client/BattleIntro.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchHud/init.lua
---

**What changed.** On phones THE BATTLE BEGINS! intro's dark edges and flash stopped at the HUD's safe area, leaving a
grey box with clear strips along the top (Roblox's top bar row) and the notch side. The intro is now stretched over
the device's whole screen each time it plays (BattleIntro's `_coverScreen`), and the MatchHud ScreenGui no longer
clips to the safe area (`ClipToDeviceSafeArea` off). The HUD's own pieces stay where they were.

**Where.** BattleIntro's `_coverScreen` (called by `_getReady` and `_slam`); the gui's `Screen`.

On PC the intro also left the top bar's row clear (the owner, the same day: "the top is not filled"):
`_coverScreen` now always counts from under the top bar's inset (`GuiService:GetGuiInset`), as every gui's
`AbsolutePosition` does, so the frame starts at the screen's very top on every device.

**How to check.** On a phone with a notch, start a match: the intro's dark edges reach every edge. On PC the dark
covers the top bar row too. Checked in Studio on a 1920 × 1080 desktop screen: the intro sits at (0, −58), 1920 ×
1080.

**For the wiki.** Nothing, unless a page describes the intro's look.
