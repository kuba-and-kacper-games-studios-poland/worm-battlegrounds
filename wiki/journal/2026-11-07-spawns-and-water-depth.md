---
title: "No spawns on a map's roof; liquid as deep as the ground"
date: 2026-11-07
status: open
kind: fixed
pages: ["Match modes & maps", "Architecture"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Server.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Loader.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Arena/Scripts/Server/Liquid.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Match/Scripts/Server/Phases.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Lobby/Client.lua
---

**What changed.**

- **Spawns:** nothing starts in the top 20 studs of a map's bounds (`START_TOP_GAP` in Arena's `Settings.lua`, the
  same as Match's `DROP_HEIGHT`). Bots' and unplaced players' spots are looked for from there down, a placed drop
  above it is refused, and the drop picker can't move above it (`DropMaxY` on `Workspace.Ume.Match` is the bounds'
  top minus 20). Before, snails could spawn on top of Rockslide Ridge's rock ceiling, 10 studs under its bounds' top.
- **Liquid depth:** water and lava are drawn as deep as the map's ground along Z, measured when the map loads from its
  bedrock (`Arena_Indestructible`) blocks: the middle of their backs to the middle of their fronts. Before, they took
  the bounds' depth. Rockslide Ridge's sea went from 25 studs deep to 8.5 (Z −6.5 to 2); Picnic Plains' sea and the
  Desert's lava and oasis from 11 to 10 (Z −5 to 5).
- **Studio only:** starting a custom lobby on the Studio map closes its window as the match begins (it stayed open
  over the match, blurred). Live servers teleport, so nothing changes there.

**Where.** `GetLandSpots` and `IsFree` in `Arena/Server.lua`; `GetGroundDepth` in `Arena/Scripts/Server/Loader.lua`;
`Build` in `Arena/Scripts/Server/Liquid.lua`; `_drop` in `Match/Scripts/Server/Phases.lua`; `_refreshGuis` in
`Lobby/Client.lua`.

**How to check.** A custom match on Rockslide Ridge (Studio, alone with bots): every drop spot is under Y 86.5 and
every snail lands under the roof; the sea's blocks span Z −6.5 to 2. Checked on 2026-11-07, with four snails.

**For the wiki.** Match modes & maps (Rockslide Ridge): the sea's depth, and that the roof isn't a starting spot. Match flow: a drop can't
be placed in the top 20 studs of the map. Architecture: maps need no per-map liquid depth; the game measures
it from the bedrock.
