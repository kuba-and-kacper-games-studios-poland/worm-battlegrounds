---
title: "Bots never spend their own health; air shots only as high as a safe fall"
date: 2026-11-15
status: open
kind: changed
pages: ["Match modules", "Bots"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/Scripts/Server/Brain.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/ServerSettings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Bots/_meta/_types.lua
---

**What changed.** The owner: "remove that the bots sacrifice their hp". A bot never takes a plan that hurts or
knocks out its own snail, or walks it into a pond, while any plan that doesn't is left; the one exception is a shot
that wins the match while the bot stays in play. When every one of its `Finalists` hurts itself, it simulates on,
up to `CLEAN_SEARCH` (3) times as many, to find one that doesn't. Air shots on the jetpack now hover only as high as
a safe fall (Snails' `SAFE_FALL_HEIGHT`), never at the flight's full height with the fall after the shot; the spot's
`Fall` is gone.

**Where.** `Brain.GetPlan` (the clean list), `_simulate` (the plan's `Harm`), `_getAirSpots` (the safe height
only); Bots' `CLEAN_SEARCH`.

**How to check.** PC gym Nightmare matches on every map (2026-11-15): own-side damage 0 %; live Nightmare custom
matches in Studio on Volcano Isle and Picnic Plains: no bot lost health to its own shot.

**For the wiki.** Bots: they never hurt themselves, and hover only as high as they can drop safely.

Supersedes 2026-11-13-bots-play-tricks: its "Air shots, higher" part (the fall traded for the shot) is undone; its
bank shots, bounces into the sea and wind still hold.
