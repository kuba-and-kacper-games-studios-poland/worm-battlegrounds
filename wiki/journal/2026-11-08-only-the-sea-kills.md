---
title: "Only the sea knocks snails out; ponds are safe"
date: 2026-11-08
status: open
kind: changed
pages: ["Match modes & maps", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Liquid.lua
---

**What changed.** Liquid only knocks a snail out in the map's sea: the liquid along the bottom, which rises in sudden
death. A pond higher up (Desert's oasis) is safe; the snail sinks to its floor and walks out. Explosives still blow up
in ponds. Sudden death on Desert now always raises its lava sea (before, it raised whichever liquid marker came
first).

**Where.** `GetHazard` in `Arena/Server.lua` returns a liquid only up to `Liquid.GetSeaLevel() + SEA_SLACK` (1 stud,
`Arena/Settings.lua`). `Liquid.Build` takes the sea from the markers whose bottom is at the bounds' bottom (its kind
and its top); `RaiseLiquid` lifts the sea level with each row it fills; `Liquid.GetSeaLevel` is new.

**How to check.** Studio, Desert (2026-11-08): a snail put in the oasis stayed alive at full health; a bot dropped over
the lava sea was knocked out.

**For the wiki.** Match modes & maps: the oasis is safe, the sea (and what rises in sudden death) is deadly.

**From.** The owner: "only the bottom water kills, the one that rises".
