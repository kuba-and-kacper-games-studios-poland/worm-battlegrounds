---
title: "Prestige frames by level: Bronze 5, Silver 15, Gold 25, Emerald 50, Diamond 75, Mythic 100"
date: 2026-11-17
status: open
kind: added
pages: ["Levels", "Lobby"]
files:
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Global.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Progression/Settings.lua
  - worm-battlegrounds-game/src/modules/Main_Game/Party/Client.lua
---

**What changed.** A player's picture wears a frame by their level, as a rank: Rookie (orange, as before) from 1, Bronze
from 5, Silver 15, Gold 25, Emerald 50, Diamond 75, Mythic 100. Gold and up have a light sweeping across the rim every
few seconds; Mythic's rim is a rainbow that turns round. It shows on the party cards (the card's rim) and the lobby's
level plate (its diamond). Reaching a milestone plays its own moment in the XP replay ("New frame: Silver").

**Where.** Progression's `FRAME_TIERS`, `FRAME_SHINE_*`, `FRAME_SPIN_SPEED`; `I.G_Progression.ApplyFrame(gradient,
level)`. Frames are colour gradients over the existing rim pictures: no new pictures. In matches the portraits keep their
team colours.

**How to check.** A level 26 player's party card has a gold rim with a sweeping light.

**For the wiki.** Levels: a table of the frames and their levels.
