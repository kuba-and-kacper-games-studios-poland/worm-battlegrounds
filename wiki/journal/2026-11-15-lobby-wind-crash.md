---
title: "Lobby: Atmosphere's start no longer fails on the wind"
date: 2026-11-15
status: open
kind: fixed
pages: ["Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Wind.lua
---

**What changed.** On the Lobby map, Atmosphere's client `_start` failed with `Wind:194: attempt to index nil with
'WIND_MAX'`: the lobby hands Wind a wind of 0, and `Wind.SetWind` divided by `I.Settings["Match"].WIND_MAX`, but the
Match module is off on the Lobby map, so its settings aren't loaded. Whatever Atmosphere starts after that (the
lobby's mood, music, ambient effects) could be missing. Now a wind of 0 gives the streaks no strength without reading
Match's settings.

**Where.** `Module.SetWind` in `Atmosphere/Scripts/Client/Wind.lua`.

**How to check.** In the lobby (live, or Studio with `Ume_StudioMapId = "Lobby"`), the Output shows no Atmosphere
`_start` error. The Studio map has both maps' modules, which is why Studio tests never showed it. Checked on
2026-11-15 in the dev place with `Ume_StudioMapId = "Lobby"`: Atmosphere's client started with no error.

**For the wiki.** Nothing players see beyond the lobby's mood and music playing; Architecture can note that modules on
both maps never read the other map's modules unguarded.
