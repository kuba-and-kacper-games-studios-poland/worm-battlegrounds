---
title: "Tutorial steps logged in the Roblox onboarding funnel (12 steps)"
date: 2026-11-15
status: open
kind: added
pages: ["Tutorial", "Analytics"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/Spotlight.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/MatchHints.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Tutorial/Scripts/Client/LobbyHints.lua
---

**What changed.** Each tutorial step is logged once per player in Roblox's onboarding funnel
(`AnalyticsService:LogOnboardingFunnelStepEvent`, Creator Hub → Analytics → Funnels), when its hint first shows. The
steps, numbered by their place in Tutorial's `FUNNEL_STEPS`: 1 Drop, 2 Aim, 3 Lobby (won, back to the lobby), 4 Crate,
5 OpenCrate, 6 Tap, 7 Opening, 8 Continue, 9 CloseCrates, 10 Equip, 11 Pick, 12 Equipped (tutorial done). Hints only
some players see (BotTurn, Retry, the touch Fire step) aren't steps. The client reports through the existing
`Tutorial_Step` remote; the server logs a step only while the tutorial isn't done.

**Still unsure.** Studio sends no analytics; the funnel fills only from live servers, with Roblox's usual delay.

**For the wiki.** Tutorial: the funnel and its steps.
