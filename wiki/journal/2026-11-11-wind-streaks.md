---
title: "The wind shows and sounds: streaks blow across the view and a per-map wind loop rises with the wind (none at 0)"
date: 2026-11-11
status: open
kind: added
pages: ["Match screen", "Match modes & maps", "Match modules"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Wind.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Scripts/Client/Mood.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Atmosphere/_meta/README.md
  - worm-battlegrounds-game/src/global_data/Sound/SoundsList.lua
---

**What changed.** Besides the HUD's wind arrow and number, the wind now shows in the world (the owner: "a wind
effect on the screen based on the intensity of it and the direction, so player visually sees the wind"). Faint
white streaks blow across the camera's view, just in front of the map (1 to 12 studs in front of its front face,
`WIND_DEPTH`), the way the wind blows: soft dashes (the studio's soft spec texture, stretched along their motion,
about 7 studs long), 65 % opaque at most, 1.1 to 1.6 s each, leaving within 2° of level (`WIND_SPREAD`). Their number
follows the wind's strength (`WIND_RATE` 40 a second at ±10, Match's `WIND_MAX`, scaled down to none at 0), their
speed goes from 45 % to 100 % of the prefab's 32 to 46 studs a second (`WIND_SPEED_SHARE`), and they breathe in gusts
(rate ±35 % over 4 s, `WIND_GUST_*`). Fight and Ride Animals' curved white zone-wind trails (its "solid glowing
bezier 3" flipbook) were tried in their place the same day, from 16 small to 2.5 big a second, and dropped: "the wind
style does not fit the game… lets bring back the old wind". Each map tints them
(`PROFILES[…].WindColor`: white on Picnic Plains, warm sand on Desert, dusty grey in Rockslide Ridge). The lobby has
none. The ambient pollen, leaves and sand keep drifting with the wind as before (2026-11-10-map-atmosphere).

The wind is heard too, with the per-area wind the owner made for Fight and Ride Animals (its `Ambience_Controller`
zone beds), reused here (the owner: "check the wind we did there for different areas, try to use it in our game"):
each map loops its own wind in the SFX group (`PROFILES[…].WindSound`: `Wind_OpenAir` 9112832297 on Picnic Plains,
`Wind_Desert` 9114057104 on Desert, `Wind_Howl` 9113286969 in Rockslide Ridge, from Fight and Ride Animals' open air,
The Oasis's desert wind and Snowy Hills' snow wind). Its volume eases over 2 s from 0.1 at wind ±1 to 0.7 at ±10
(`WIND_SOUND_VOLUME`) and to silence at 0, and it fades out in the lobby. In wind of 4 or more (`WIND_GUST_SOUND_FROM`
0.4), each streak gust peak (every 4 s) may whoosh (`Wind_Gust` 94321371111141, as likely as the wind's share, volume
0.15 to 0.5). All four ids were checked to load in this place; in a playtest the loop sat at 0.7 for wind +10 and
0.28 for −3.

**Where.** Atmosphere's `Scripts/Client/Wind.lua` (one copy of `PREFAB | Wind_Streak` kept over the view each frame,
at the `Camera` render priority + 2, after MatchCamera); Mood's `_refreshArea` and `_refreshWind` hand it the map and
the `Wind` attribute. The prefab is in `Workspace.Ume.ReplicatedStorage_Assets/Vfx`.

**How to check.** In a match, set the wind with the admin tools (`I.Match.SetWind`, or wait for a new turn): at +10
many fast streaks blow left to right, at −3 a few slow ones right to left, at 0 none.

**For the wiki.** Match screen: next to the wind indicator, a line that the wind also shows as streaks across the
view. Match modes & maps: each map's streak colour, if the page lists each map's look.

**Unsure.** The streaks were tuned in a Studio playtest at the default zoom; not yet seen on a phone. The wind sound's
volumes are first guesses, checked by their values, not yet listened to.
