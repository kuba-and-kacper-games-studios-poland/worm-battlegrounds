---
title: "Match HUD sits below Roblox's top bar on phones"
date: 2026-11-13
status: open
kind: changed
pages: ["Match screen", "Controls & platforms"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchHud/Client.lua
---

**What changed.** On phones and tablets Roblox's top bar covered the left team panel and the turn timer and wind.
There the match HUD now lays out under the bar: its ScreenGui's `ScreenInsets` is `CoreUISafeInsets` on Mobile and
`DeviceSafeInsets` elsewhere, switched again if the device type changes. The whole HUD fits the screen below the bar,
so its top blocks move down by the bar's height (58 px measured in Studio) and its height-based sizes shrink by that
much.

**Where.** MatchHud's `Client._refreshInsets`, on `Platform_Changed`.

**How to check.** On a phone, the team panels, the timer and the wind sit fully under the Roblox menu and chat buttons.
On PC nothing moves.

**For the wiki.** Match screen / Controls & platforms: on phones the HUD starts under Roblox's top bar.

Unsure: checked only on PC in Studio (where `CoreUISafeInsets` measured the 58 px bar); not seen on a real phone.
