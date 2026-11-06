---
title: "Small PC screens: guis never under 0.6 scale; Play moved just right of centre"
date: 2026-11-05
status: merged
merged: 2026-11-06
kind: changed
pages: ["Guis", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Utils/ScreenScale/Settings.lua
  - worm-battlegrounds-game/src/modules/Utils/ScreenScale/Client.lua
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/MatchBoard/init.lua
---

**What changed.** On a PC or console the guis never shrink below 0.6 of their 1080p size. At 1024 × 768 they used to
be 0.533 of it (the width rule), so most hud text was 10 to 12 px; now it's 14 px and up in a match. Phones are as
before. The lobby's Play and Modes row, and the waiting room that replaces it, now hang from 55 % across the screen
instead of the middle: at the bigger scale they ran into the Loadout card on 4:3 screens (by 28 px), and on phones they
already touched it. They clear it now on every screen checked (19 px at 1024 × 768, 25 px on a 667 × 375 phone,
147 px at 1080p).

**Where.** ScreenScale `Settings.lua` `MIN_SCALE = 0.6`, applied in `Client.lua` `_applyScale` to every device but
Mobile, after the width rule (so it wins over it). MatchBoard gui: `U_Play` and `U_WaitingRoom` at
`UDim2.fromScale(0.55, 0.978)` (were 0.5).

**How to check.** Size the Studio window to 1024 × 768: the turn panel's text is readable and the lobby's Loadout card
and Play button don't touch. At 1080p, Play sits a little right of the logo.

**For the wiki.** Lobby: Play's place (bottom, a little right of the centre). Guis: the smallest scale on PC.
