---
title: "A match's map loads before it waits for its players"
date: 2026-11-06
status: merged
merged: 2026-11-06
kind: fixed
pages: ["Match modes & maps"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
---

**What changed.** Before: a match server loaded its map only after every player in its roster had arrived with their
data loaded (up to 20 seconds), so players who arrived first saw an empty sky behind the waiting screen. A party,
whose members arrive one by one, waited longest. Now the map loads first and shows while everyone arrives.

**Where.** `_mainLoop` in `Phases.lua` calls `I.Arena.Load` before `Roster.WaitForPlayers`, and `Play(loaded)` skips
the second load; `WAIT_FOR_PLAYERS` stays 20.

**How to check.** Start any match: the arena shows during the waiting screen ("1 / 2").

**For the wiki.** Probably nothing beyond a History line. Unsure: the owner saw "map not loading when in party" in the
published game; this is the likeliest cause found, but it wasn't reproduced (it needs a party in the published game).

**From.** The owner's bug list (2026-11-06): "Map not loading when in party".
