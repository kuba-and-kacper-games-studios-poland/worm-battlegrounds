---
title: "Wind streaks calmer: 40 → 18 a second at full wind, 60 % as opaque; they no longer go missing on some loads"
date: 2026-11-12
status: open
kind: changed
pages: ["Match screen", "Match modes & maps"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Wind.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Mood.lua
---

**What changed.** The owner found the wind on the map too much. Its streaks now come at 18 a second in the strongest
wind (±10), down from 40, still scaled down with the wind and breathing in gusts, and each is 60 % as opaque as
before (at most about 39 % opaque, was 65 %). Their size, speed, colour and the wind's sound are unchanged.

Fixed with it: when a map's `Bounds` marker arrived after its markers folder (seen in a Studio match on Picnic
Plains), the match ran with no wind streaks, no wind loop and no ambient pollen or leaves. The client now waits for
the bounds (up to 10 s) and shows them once they're there.

**Where.** Atmosphere's `WIND_RATE` (18) and new `WIND_OPACITY` (0.6, applied to the streak prefab's `Transparency`
keypoints in Wind's `_build`); the fix in Mood's `_refreshArea`. Supersedes the rate and opacity in
2026-11-11-wind-streaks; the rest of that entry holds.

**How to check.** In a match with wind ±2 the streak emitter's `Rate` swings around 3.6 (was about 8); at ±10 around
18. The streaks show from the first turn.

**For the wiki.** Match screen: the wind's streaks are fainter and fewer.
