---
title: "Custom lobbies give no XP"
date: 2026-11-13
status: open
kind: changed
pages: ["Lobby & meta modules", "Match modes & maps"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/MatchRewards/ServerSettings.lua
---

**What changed.** A custom lobby's match gives no XP (`XP_KINDS.Custom = false`). Public, party and solo matches are unchanged.

**Where.** MatchRewards' `XP_KINDS` in its ServerSettings.

**How to check.** Finish a custom match: the results show no XP gained.

**For the wiki.** Lobby & meta modules (rewards) and the custom lobby: no XP.

**From.** The testers: "custom games shouldnt give exp", "custom lobby should not give exp".
