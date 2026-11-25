---
title: "No level plate at the top of the lobby; it pops up only for the XP replay, without LEVEL n"
date: 2026-11-24
status: open
kind: removed
pages: ["Levels & XP", "Lobby"]
files:
  - worm-battlegrounds-gui/src/guis/WormBattlegrounds/LevelPlate/init.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Client.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Settings.lua
---

**What changed.** The level plate no longer sits at the top centre of the lobby: the level stands on each snail's
nameplate. The plate is hidden and pops up in the middle only while a match's XP plays back, then shrinks away. Its
"LEVEL n" title is gone (the owner: "we don't need to see 14 and LEVEL 14"); the diamond keeps the number, and the
bar moved up into the plate's middle.

**Where.** The LevelPlate gui: `U_Plate` hidden at 0.5, 0.3, `S_Pop` 0 at rest, `S_Title` removed. Progression's
client shows and hides it (`_playReplay`, `_endReplay`). Settings `PLATE_POSITION` and `REPLAY_POSITION` are removed;
`REPLAY_SCALE` 1.8 stays.

**How to check.** The lobby shows no plate at the top; after a match the plate grows in the middle and goes after.

**For the wiki.** Levels & XP: where the level shows (the nameplates) and the replay; drop the top-of-lobby plate.

Supersedes the plate's place at the top in 2026-11-17-level-plate-and-xp; the replay itself still holds.
